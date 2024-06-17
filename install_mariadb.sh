#!/bin/bash

# Verificar si el script se está ejecutando como root
if [ "$(id -u)" != "0" ]; then
   echo "Este script debe ser ejecutado como root" 1>&2
   exit 1
fi

# Actualizar el sistema
echo "Actualizando el sistema..."
dnf update -y

# Instalar MariaDB
echo "Instalando MariaDB..."
dnf install -y mariadb-server

# Iniciar el servicio de MariaDB y habilitarlo para que se inicie en el arranque
echo "Iniciando y habilitando el servicio de MariaDB..."
systemctl start mariadb
systemctl enable mariadb

# Configurar seguridad inicial de MariaDB
echo "Configurando la seguridad inicial de MariaDB..."
mysql_secure_installation <<EOF

y
root_password
root_password
y
y
y
y
EOF

# Crear un archivo de configuración personalizada
cat <<EOL > /etc/my.cnf.d/99-custom.cnf
[mysqld]
# Ajustar la memoria asignada para 8GB RAM
innodb_buffer_pool_size = 6G
innodb_log_file_size = 2G
innodb_buffer_pool_instances = 6
max_connections = 500

# Ajustes adicionales
innodb_flush_method = O_DIRECT
innodb_log_buffer_size = 16M
innodb_flush_log_at_trx_commit = 1
query_cache_type = 0
query_cache_size = 0
join_buffer_size = 256K
sort_buffer_size = 256K
tmp_table_size = 32M
max_heap_table_size = 32M
thread_cache_size = 50
EOL

# Reiniciar el servicio de MariaDB para aplicar los cambios
echo "Reiniciando MariaDB para aplicar los cambios..."
systemctl restart mariadb

echo "La instalación y configuración de MariaDB se ha completado."
