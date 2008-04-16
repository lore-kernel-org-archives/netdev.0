From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 12/13] dl2k: use netdev_alloc_skb
Date: Wed, 16 Apr 2008 16:37:39 -0700
Message-ID: <20080416233757.849736298@vyatta.com>
References: <20080416233727.732025083@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:43787 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752900AbYDPXt2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 19:49:28 -0400
Content-Disposition: inline; filename=dl2k
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_alloc_skb. This sets skb->dev and allows arch specific
allocation.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/dl2k.c	2008-04-07 10:36:16.000000000 -0700
+++ b/drivers/net/dl2k.c	2008-04-07 12:36:56.000000000 -0700
@@ -499,7 +499,7 @@ rio_timer (unsigned long data)
 			entry = np->old_rx % RX_RING_SIZE;
 			/* Dropped packets don't need to re-allocate */
 			if (np->rx_skbuff[entry] == NULL) {
-				skb = dev_alloc_skb (np->rx_buf_sz);
+				skb = netdev_alloc_skb (dev, np->rx_buf_sz);
 				if (skb == NULL) {
 					np->rx_ring[entry].fraginfo = 0;
 					printk (KERN_INFO
@@ -570,7 +570,7 @@ alloc_list (struct net_device *dev)
 	/* Allocate the rx buffers */
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		/* Allocated fixed size of skbuff */
-		struct sk_buff *skb = dev_alloc_skb (np->rx_buf_sz);
+		struct sk_buff *skb = netdev_alloc_skb (dev, np->rx_buf_sz);
 		np->rx_skbuff[i] = skb;
 		if (skb == NULL) {
 			printk (KERN_ERR
@@ -867,7 +867,7 @@ receive_packet (struct net_device *dev)
 						  PCI_DMA_FROMDEVICE);
 				skb_put (skb = np->rx_skbuff[entry], pkt_len);
 				np->rx_skbuff[entry] = NULL;
-			} else if ((skb = dev_alloc_skb (pkt_len + 2)) != NULL) {
+			} else if ((skb = netdev_alloc_skb(dev, pkt_len + 2))) {
 				pci_dma_sync_single_for_cpu(np->pdev,
 							    desc_to_dma(desc),
 							    np->rx_buf_sz,
@@ -904,7 +904,7 @@ receive_packet (struct net_device *dev)
 		struct sk_buff *skb;
 		/* Dropped packets don't need to re-allocate */
 		if (np->rx_skbuff[entry] == NULL) {
-			skb = dev_alloc_skb (np->rx_buf_sz);
+			skb = netdev_alloc_skb(dev, np->rx_buf_sz);
 			if (skb == NULL) {
 				np->rx_ring[entry].fraginfo = 0;
 				printk (KERN_INFO

-- 

