From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH 8/8] can: enable module auto loading for virtual CAN interfaces
Date: Tue, 25 Apr 2017 08:19:45 +0200
Message-ID: <20170425061945.28722-9-socketcan@hartkopp.net>
References: <20170425061945.28722-1-socketcan@hartkopp.net>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, mkl@pengutronix.de,
        dev@kicherer.org, netdev@vger.kernel.org
To: linux-can@vger.kernel.org, davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170425061945.28722-1-socketcan@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Autoload the vcan module when a vcan instance is to be created by
'ip link add type vcan'

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 drivers/net/can/vcan.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 674f367087c5..facca33d53e9 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -1,7 +1,7 @@
 /*
  * vcan.c - Virtual CAN interface
  *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
+ * Copyright (c) 2002-2017 Volkswagen Group Electronic Research
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -50,9 +50,12 @@
 #include <linux/slab.h>
 #include <net/rtnetlink.h>
 
+#define DRV_NAME "vcan"
+
 MODULE_DESCRIPTION("virtual CAN interface");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Urs Thuermann <urs.thuermann@volkswagen.de>");
+MODULE_ALIAS_RTNL_LINK(DRV_NAME);
 
 
 /*
@@ -164,7 +167,7 @@ static void vcan_setup(struct net_device *dev)
 }
 
 static struct rtnl_link_ops vcan_link_ops __read_mostly = {
-	.kind	= "vcan",
+	.kind	= DRV_NAME,
 	.setup	= vcan_setup,
 };
 
-- 
2.11.0

