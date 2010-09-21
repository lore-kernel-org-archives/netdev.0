From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH -next 3/3] sundance: Use dev_kfree_skb_any() helper
Date: Tue, 21 Sep 2010 08:57:49 +0000
Message-ID: <20100921085749.GA21902@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:47096 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756385Ab0IUI5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Sep 2010 04:57:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use dev_kfree_skb_any() helper to free the skb

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/sundance.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index b21e961..794f33f 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -1114,7 +1114,6 @@ reset_tx (struct net_device *dev)
 	void __iomem *ioaddr = np->base;
 	struct sk_buff *skb;
 	int i;
-	int irq = in_interrupt();
 
 	/* Reset tx logic, TxListPtr will be cleaned */
 	iowrite16 (TxDisable, ioaddr + MACCtrl1);
@@ -1129,10 +1128,7 @@ reset_tx (struct net_device *dev)
 			dma_unmap_single(&np->pci_dev->dev,
 				le32_to_cpu(np->tx_ring[i].frag[0].addr),
 				skb->len, DMA_TO_DEVICE);
-			if (irq)
-				dev_kfree_skb_irq (skb);
-			else
-				dev_kfree_skb (skb);
+			dev_kfree_skb_any(skb);
 			np->tx_skbuff[i] = NULL;
 			dev->stats.tx_dropped++;
 		}
-- 
1.7.2.2

