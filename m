From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 33/33] arcnet: capmode: remove extra function
Date: Tue, 22 Sep 2015 11:02:14 +0200
Message-ID: <1442912534-10821-34-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60680 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932761AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleans the capmode protocol module. It removes the obsolete
function arcnet_cap_init and replaces printk with pr_info.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/capmode.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 8297e00..37d842b 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -238,10 +238,12 @@ static struct ArcProto capmode_proto = {
 	.ack_tx		= ack_tx
 };
 
-static void arcnet_cap_init(void)
+static int __init capmode_module_init(void)
 {
 	int count;
 
+	pr_info("%s\n", "cap mode (`c') encapsulation support loaded");
+
 	for (count = 1; count <= 8; count++)
 		if (arc_proto_map[count] == arc_proto_default)
 			arc_proto_map[count] = &capmode_proto;
@@ -252,12 +254,7 @@ static void arcnet_cap_init(void)
 
 	arc_proto_default = &capmode_proto;
 	arc_raw_proto = &capmode_proto;
-}
 
-static int __init capmode_module_init(void)
-{
-	pr_info("%s\n", "cap mode (`c') encapsulation support loaded");
-	arcnet_cap_init();
 	return 0;
 }
 
-- 
2.5.1
