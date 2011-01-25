From: Yong Zhang <yong.zhang0@gmail.com>
Subject: [PATCH] net: NETCONSOLE_DYNAMIC need CONFIGFS_FS=y
Date: Tue, 25 Jan 2011 16:22:28 +0800
Message-ID: <1295943748-9699-1-git-send-email-yong.zhang0@gmail.com>
Cc: nab@linux-iscsi.org, "David S. Miller" <davem@davemloft.net>,
	Kevin Hilman <khilman@deeprootsystems.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With CONFIGFS_FS=m && NETCONSOLE_DYNAMIC=y, build error:

drivers/built-in.o: In function `netconsole_target_put':
build/drivers/net/netconsole.c:133: undefined reference to `config_item_put'
drivers/built-in.o: In function `netconsole_target_get':
build/drivers/net/netconsole.c:127: undefined reference to `config_item_get'
build/drivers/net/netconsole.c:127: undefined reference to `config_item_get'
drivers/built-in.o: In function `netconsole_target_put':
build/drivers/net/netconsole.c:133: undefined reference to `config_item_put'
drivers/built-in.o: In function `drop_netconsole_target':
build/drivers/net/netconsole.c:634: undefined reference to `config_item_put'
drivers/built-in.o: In function `make_netconsole_target':
build/drivers/net/netconsole.c:607: undefined reference to `config_item_init_type_name'
drivers/built-in.o: In function `dynamic_netconsole_init':
build/drivers/net/netconsole.c:109: undefined reference to `config_group_init'
build/drivers/net/netconsole.c:111: undefined reference to `configfs_register_subsystem'
drivers/built-in.o: In function `dynamic_netconsole_exit':
build/drivers/net/netconsole.c:116: undefined reference to `configfs_unregister_subsystem'

Signed-off-by: Yong Zhang <yong.zhang0@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Kevin Hilman <khilman@deeprootsystems.com>
---
 drivers/net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0382332..2b12c0d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3389,7 +3389,7 @@ config NETCONSOLE
 
 config NETCONSOLE_DYNAMIC
 	bool "Dynamic reconfiguration of logging targets"
-	depends on NETCONSOLE && SYSFS && CONFIGFS_FS
+	depends on NETCONSOLE && SYSFS && CONFIGFS_FS=y
 	help
 	  This option enables the ability to dynamically reconfigure target
 	  parameters (interface, IP addresses, port numbers, MAC addresses)
-- 
1.7.0.4
