From: raj@tardy.usa.hp.com (Rick Jones)
Subject: [PATCH net-next] hp100: Convert the normal skb free path to dev_consume_skb_any()
Date: Mon,  8 Sep 2014 08:31:32 -0700 (PDT)
Message-ID: <20140908153133.103882900309@tardy>
Cc: <davem@davemloft.net>, <perex@perex.cz>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:9817 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925AbaIHPbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 11:31:47 -0400
Received: from g6t1526.atlanta.hp.com (g6t1526.atlanta.hp.com [15.193.200.69])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id D21864097
	for <netdev@vger.kernel.org>; Mon,  8 Sep 2014 15:31:46 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Rick Jones <rick.jones2@hp.com>

A bit of floor sweeping in a dusty old corner.  Convert the "normal"
skb free calls to dev_consume_skb_any() so packet drop tracing will
be more sane.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Compile tested only.  I wonder how many of these cards are still in
operation?-)

diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index ed7916f..76a6e0c 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -1627,7 +1627,7 @@ static void hp100_clean_txring(struct net_device *dev)
 #endif
 		/* Conversion to new PCI API : NOP */
 		pci_unmap_single(lp->pci_dev, (dma_addr_t) lp->txrhead->pdl[1], lp->txrhead->pdl[2], PCI_DMA_TODEVICE);
-		dev_kfree_skb_any(lp->txrhead->skb);
+		dev_consume_skb_any(lp->txrhead->skb);
 		lp->txrhead->skb = NULL;
 		lp->txrhead = lp->txrhead->next;
 		lp->txrcommit--;
@@ -1745,7 +1745,7 @@ static netdev_tx_t hp100_start_xmit(struct sk_buff *skb,
 	hp100_ints_on();
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	dev_kfree_skb_any(skb);
+	dev_consume_skb_any(skb);
 
 #ifdef HP100_DEBUG_TX
 	printk("hp100: %s: start_xmit: end\n", dev->name);
