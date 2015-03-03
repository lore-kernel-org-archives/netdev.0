From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 05/14] netconsole: Use eth_<foo>_addr instead of memset
Date: Mon,  2 Mar 2015 19:54:50 -0800
Message-ID: <d2daaff790e6bc6bc49b7fe579f0396d7222ea58.1425354528.git.joe@perches.com>
References: <cover.1425354527.git.joe@perches.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1425354527.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the built-in function instead of memset.

Miscellanea:

Add #include <linux/etherdevice.h>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/netconsole.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index ba2f5e7..15731d1 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -47,6 +47,7 @@
 #include <linux/netpoll.h>
 #include <linux/inet.h>
 #include <linux/configfs.h>
+#include <linux/etherdevice.h>
 
 MODULE_AUTHOR("Maintainer: Matt Mackall <mpm@selenic.com>");
 MODULE_DESCRIPTION("Console driver for network interfaces");
@@ -185,7 +186,7 @@ static struct netconsole_target *alloc_param_target(char *target_config)
 	nt->np.local_port = 6665;
 	nt->np.remote_port = 6666;
 	mutex_init(&nt->mutex);
-	memset(nt->np.remote_mac, 0xff, ETH_ALEN);
+	eth_broadcast_addr(nt->np.remote_mac);
 
 	/* Parse parameters and setup netpoll */
 	err = netpoll_parse_options(&nt->np, target_config);
@@ -604,7 +605,7 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 	nt->np.local_port = 6665;
 	nt->np.remote_port = 6666;
 	mutex_init(&nt->mutex);
-	memset(nt->np.remote_mac, 0xff, ETH_ALEN);
+	eth_broadcast_addr(nt->np.remote_mac);
 
 	/* Initialize the config_item member */
 	config_item_init_type_name(&nt->item, name, &netconsole_target_type);
-- 
2.1.2
