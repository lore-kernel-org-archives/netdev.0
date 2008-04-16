From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 11/13] hamachi: use netdev_alloc_skb
Date: Wed, 16 Apr 2008 16:37:38 -0700
Message-ID: <20080416233757.774016318@vyatta.com>
References: <20080416233727.732025083@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:43781 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751904AbYDPXt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 19:49:27 -0400
Content-Disposition: inline; filename=hamachi
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_alloc_skb. This sets skb->dev and allows arch specific
allocation.

Remove dead code and dead comments.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/hamachi.c	2008-04-07 08:48:24.000000000 -0700
+++ b/drivers/net/hamachi.c	2008-04-07 08:50:14.000000000 -0700
@@ -1140,11 +1140,11 @@ static void hamachi_tx_timeout(struct ne
 	}
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(hmp->rx_buf_sz);
+		struct sk_buff *skb = netdev_alloc_skb(dev, hmp->rx_buf_sz);
 		hmp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
-		skb->dev = dev;         /* Mark as being used by this device. */
+
 		skb_reserve(skb, 2); /* 16 byte align the IP header. */
                 hmp->rx_ring[i].addr = cpu_to_leXX(pci_map_single(hmp->pci_dev,
 			skb->data, hmp->rx_buf_sz, PCI_DMA_FROMDEVICE));
@@ -1178,14 +1178,6 @@ static void hamachi_init_ring(struct net
 	hmp->cur_rx = hmp->cur_tx = 0;
 	hmp->dirty_rx = hmp->dirty_tx = 0;
 
-#if 0
-	/* This is wrong.  I'm not sure what the original plan was, but this
-	 * is wrong.  An MTU of 1 gets you a buffer of 1536, while an MTU
-	 * of 1501 gets a buffer of 1533? -KDU
-	 */
-	hmp->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
-#endif
-	/* My attempt at a reasonable correction */
 	/* +26 gets the maximum ethernet encapsulation, +7 & ~7 because the
 	 * card needs room to do 8 byte alignment, +2 so we can reserve
 	 * the first 2 bytes, and +16 gets room for the status word from the

-- 

