From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 15/33] arcnet: Remove pointer comparisons to NULL
Date: Tue, 22 Sep 2015 11:01:56 +0200
Message-ID: <1442912534-10821-16-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60716 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932549AbbIVJCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:41 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Use direct tests of pointer instead.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rawmode.c | 2 +-
 drivers/net/arcnet/capmode.c     | 4 ++--
 drivers/net/arcnet/rfc1051.c     | 2 +-
 drivers/net/arcnet/rfc1201.c     | 4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index 7fc5b042..40035ee 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -97,7 +97,7 @@ static void rx(struct net_device *dev, int bufnum,
 		ofs = 256 - length;
 
 	skb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
-	if (skb == NULL) {
+	if (!skb) {
 		dev->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index de80d9e..a898647 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -56,7 +56,7 @@ static void rx(struct net_device *dev, int bufnum,
 		ofs = 256 - length;
 
 	skb = alloc_skb(length + ARC_HDR_SIZE + sizeof(int), GFP_ATOMIC);
-	if (skb == NULL) {
+	if (!skb) {
 		dev->stats.rx_dropped++;
 		return;
 	}
@@ -196,7 +196,7 @@ static int ack_tx(struct net_device *dev, int acked)
 
 	/* Now alloc a skb to send back up through the layers: */
 	ackskb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
-	if (ackskb == NULL)
+	if (!ackskb)
 		goto free_outskb;
 
 	skb_put(ackskb, length + ARC_HDR_SIZE);
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index 7e7eda5..b76e458 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -133,7 +133,7 @@ static void rx(struct net_device *dev, int bufnum,
 		ofs = 256 - length;
 
 	skb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
-	if (skb == NULL) {
+	if (!skb) {
 		dev->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index 9040a8b..1d777c1 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -178,7 +178,7 @@ static void rx(struct net_device *dev, int bufnum,
 		in->sequence = soft->sequence;
 
 		skb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
-		if (skb == NULL) {
+		if (!skb) {
 			dev->stats.rx_dropped++;
 			return;
 		}
@@ -286,7 +286,7 @@ static void rx(struct net_device *dev, int bufnum,
 			}
 			in->skb = skb = alloc_skb(508 * in->numpackets + ARC_HDR_SIZE,
 						  GFP_ATOMIC);
-			if (skb == NULL) {
+			if (!skb) {
 				arc_printk(D_NORMAL, dev, "(split) memory squeeze, dropping packet.\n");
 				lp->rfc1201.aborted_seq = soft->sequence;
 				dev->stats.rx_dropped++;
-- 
2.5.1
