From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 15/21] ARCNET: capmode: remove extra function and use C99 in struct
Date: Fri, 24 Apr 2015 19:20:49 +0200
Message-ID: <1429896055-31680-16-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44240 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031388AbbDXRWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 13:22:18 -0400
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleans the capmode protocol module. It removes the obsolete
function arcnet_cap_init and uses the C99 struct definition. It also
replaces printk with pr_info.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/capmode.c | 28 +++++++++++-----------------
 1 file changed, 11 insertions(+), 17 deletions(-)

diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index b6868a2..91ec9fa 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -229,22 +229,22 @@ free_outskb:
 	return 0;
 }
 
-static struct ArcProto capmode_proto =
-{
-	'r',
-	XMTU,
-	0,
-	rx,
-	build_header,
-	prepare_tx,
-	NULL,
-	ack_tx
+static struct ArcProto capmode_proto = {
+	.suffix		= 'r',
+	.mtu		= XMTU,
+	.rx		= rx,
+	.build_header	= build_header,
+	.prepare_tx	= prepare_tx,
+	.continue_tx    = NULL,
+	.ack_tx         = ack_tx
 };
 
-static void arcnet_cap_init(void)
+static int __init capmode_module_init(void)
 {
 	int count;
 
+	pr_info(VERSION);
+
 	for (count = 1; count <= 8; count++)
 		if (arc_proto_map[count] == arc_proto_default)
 			arc_proto_map[count] = &capmode_proto;
@@ -255,12 +255,6 @@ static void arcnet_cap_init(void)
 
 	arc_proto_default = &capmode_proto;
 	arc_raw_proto = &capmode_proto;
-}
-
-static int __init capmode_module_init(void)
-{
-	printk(VERSION);
-	arcnet_cap_init();
 	return 0;
 }
 
-- 
2.1.4
