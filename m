From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 13/33] arcnet: Remove unnecessary OOM messages
Date: Tue, 22 Sep 2015 11:01:54 +0200
Message-ID: <1442912534-10821-14-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34736 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932525AbbIVJCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:41 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Alloc failures have generic stack dumps so these are redundant.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rawmode.c  | 1 -
 drivers/net/arcnet/capmode.c      | 5 +----
 drivers/net/arcnet/com20020-pci.c | 4 +---
 drivers/net/arcnet/rfc1051.c      | 1 -
 drivers/net/arcnet/rfc1201.c      | 1 -
 5 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index e4a2702..7fc5b042 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -98,7 +98,6 @@ static void rx(struct net_device *dev, int bufnum,
 
 	skb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
 	if (skb == NULL) {
-		arc_printk(D_NORMAL, dev, "Memory squeeze, dropping packet\n");
 		dev->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 92b553e..de80d9e 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -57,7 +57,6 @@ static void rx(struct net_device *dev, int bufnum,
 
 	skb = alloc_skb(length + ARC_HDR_SIZE + sizeof(int), GFP_ATOMIC);
 	if (skb == NULL) {
-		arc_printk(D_NORMAL, dev, "Memory squeeze, dropping packet\n");
 		dev->stats.rx_dropped++;
 		return;
 	}
@@ -197,10 +196,8 @@ static int ack_tx(struct net_device *dev, int acked)
 
 	/* Now alloc a skb to send back up through the layers: */
 	ackskb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
-	if (ackskb == NULL) {
-		arc_printk(D_NORMAL, dev, "Memory squeeze, can't acknowledge\n");
+	if (ackskb == NULL)
 		goto free_outskb;
-	}
 
 	skb_put(ackskb, length + ARC_HDR_SIZE);
 	ackskb->dev = dev;
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 7247add..fc6809b 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -142,10 +142,8 @@ static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *i
 
 		card = devm_kzalloc(&pdev->dev, sizeof(struct com20020_dev),
 				    GFP_KERNEL);
-		if (!card) {
-			pr_err("%s out of memory!\n", __func__);
+		if (!card)
 			return -ENOMEM;
-		}
 
 		card->index = i;
 		card->pci_priv = priv;
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index d5a0f90..7e7eda5 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -134,7 +134,6 @@ static void rx(struct net_device *dev, int bufnum,
 
 	skb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
 	if (skb == NULL) {
-		arc_printk(D_NORMAL, dev, "Memory squeeze, dropping packet\n");
 		dev->stats.rx_dropped++;
 		return;
 	}
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index 3dae141..9040a8b 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -179,7 +179,6 @@ static void rx(struct net_device *dev, int bufnum,
 
 		skb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
 		if (skb == NULL) {
-			arc_printk(D_NORMAL, dev, "Memory squeeze, dropping packet\n");
 			dev->stats.rx_dropped++;
 			return;
 		}
-- 
2.5.1
