From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 14/21] ARCNET: arc-rawmode: reorder module functions
Date: Fri, 24 Apr 2015 19:20:48 +0200
Message-ID: <1429896055-31680-15-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44278 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031540AbbDXRWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 13:22:23 -0400
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the module_init and module_exit patches to
the end of the file. It also replaces the printk with pr_info.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rawmode.c | 87 ++++++++++++++++++----------------------
 1 file changed, 38 insertions(+), 49 deletions(-)

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index b603470..68466b3 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -35,55 +35,6 @@
 
 #define VERSION "arcnet: raw mode (`r') encapsulation support loaded.\n"
 
-
-static void rx(struct net_device *dev, int bufnum,
-	       struct archdr *pkthdr, int length);
-static int build_header(struct sk_buff *skb, struct net_device *dev,
-			unsigned short type, uint8_t daddr);
-static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
-		      int bufnum);
-
-static struct ArcProto rawmode_proto =
-{
-	.suffix		= 'r',
-	.mtu		= XMTU,
-	.rx		= rx,
-	.build_header	= build_header,
-	.prepare_tx	= prepare_tx,
-	.continue_tx    = NULL,
-	.ack_tx         = NULL
-};
-
-
-static int __init arcnet_raw_init(void)
-{
-	int count;
-
-	printk(VERSION);
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
-
 /* packet receiver */
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
@@ -201,3 +152,41 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 
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
+	pr_info(VERSION);
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
2.1.4
