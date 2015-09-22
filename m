From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 32/33] arcnet: arc-rawmode: reorder module functions
Date: Tue, 22 Sep 2015 11:02:13 +0200
Message-ID: <1442912534-10821-33-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33719 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932702AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the module_init and module_exit patches to
the end of the file. It also replaces the printk with pr_info.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rawmode.c | 84 ++++++++++++++++++----------------------
 1 file changed, 38 insertions(+), 46 deletions(-)

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index 35a747a..0046ddb 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -33,54 +33,8 @@
 #include <net/arp.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-
 #include "arcdevice.h"
 
-static void rx(struct net_device *dev, int bufnum,
-	       struct archdr *pkthdr, int length);
-static int build_header(struct sk_buff *skb, struct net_device *dev,
-			unsigned short type, uint8_t daddr);
-static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
-		      int bufnum);
-
-static struct ArcProto rawmode_proto = {
-	.suffix		= 'r',
-	.mtu		= XMTU,
-	.rx		= rx,
-	.build_header	= build_header,
-	.prepare_tx	= prepare_tx,
-	.continue_tx    = NULL,
-	.ack_tx         = NULL
-};
-
-static int __init arcnet_raw_init(void)
-{
-	int count;
-
-	pr_info("%s\n", "raw mode (`r') encapsulation support loaded");
-
-	for (count = 0; count < 256; count++)
-		if (arc_proto_map[count] == arc_proto_default)
-			arc_proto_map[count] = &rawmode_proto;
-
-	/* for raw mode, we only set the bcast proto if there's no better one */
-	if (arc_bcast_proto == arc_proto_default)
-		arc_bcast_proto = &rawmode_proto;
-
-	arc_proto_default = &rawmode_proto;
-	return 0;
-}
-
-static void __exit arcnet_raw_exit(void)
-{
-	arcnet_unregister_proto(&rawmode_proto);
-}
-
-module_init(arcnet_raw_init);
-module_exit(arcnet_raw_exit);
-
-MODULE_LICENSE("GPL");
-
 /* packet receiver */
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
@@ -195,3 +149,41 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 
 	return 1;		/* done */
 }
+
+static struct ArcProto rawmode_proto = {
+	.suffix		= 'r',
+	.mtu		= XMTU,
+	.rx		= rx,
+	.build_header	= build_header,
+	.prepare_tx	= prepare_tx,
+	.continue_tx    = NULL,
+	.ack_tx         = NULL
+};
+
+static int __init arcnet_raw_init(void)
+{
+	int count;
+
+	pr_info("%s\n", "raw mode (`r') encapsulation support loaded");
+
+	for (count = 0; count < 256; count++)
+		if (arc_proto_map[count] == arc_proto_default)
+			arc_proto_map[count] = &rawmode_proto;
+
+	/* for raw mode, we only set the bcast proto if there's no better one */
+	if (arc_bcast_proto == arc_proto_default)
+		arc_bcast_proto = &rawmode_proto;
+
+	arc_proto_default = &rawmode_proto;
+	return 0;
+}
+
+static void __exit arcnet_raw_exit(void)
+{
+	arcnet_unregister_proto(&rawmode_proto);
+}
+
+module_init(arcnet_raw_init);
+module_exit(arcnet_raw_exit);
+
+MODULE_LICENSE("GPL");
-- 
2.5.1
