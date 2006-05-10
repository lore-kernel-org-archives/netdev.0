From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] dl2k: use explicit DMA_48BIT_MASK
Date: Wed, 10 May 2006 20:57:18 +0200
Message-ID: <20060510185718.GA25334@electric-eye.fr.zoreil.com>
References: <200605101812.k4AICpRo006555@dwalker1.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, edward_peng@dlink.com.tw, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42713 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S964776AbWEJS7j
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 14:59:39 -0400
To: Daniel Walker <dwalker@mvista.com>
Content-Disposition: inline
In-Reply-To: <200605101812.k4AICpRo006555@dwalker1.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Typo will be harder with this one.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

---

 drivers/net/dl2k.c          |   13 ++++++-------
 include/linux/dma-mapping.h |    1 +
 2 files changed, 7 insertions(+), 7 deletions(-)

5019a27a2a4e259f29a7bd03e905764eedfa034c
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index ca73f07..18d67cf 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -765,8 +765,7 @@ rio_free_tx (struct net_device *dev, int
 			break;
 		skb = np->tx_skbuff[entry];
 		pci_unmap_single (np->pdev,
-				  np->tx_ring[entry].fraginfo & 
-						0xffffffffffffULL,
+				  np->tx_ring[entry].fraginfo & DMA_48BIT_MASK,
 				  skb->len, PCI_DMA_TODEVICE);
 		if (irq)
 			dev_kfree_skb_irq (skb);
@@ -895,7 +894,7 @@ receive_packet (struct net_device *dev)
 			if (pkt_len > copy_thresh) {
 				pci_unmap_single (np->pdev,
 						  desc->fraginfo & 
-							0xffffffffffffULL,
+							DMA_48BIT_MASK,
 						  np->rx_buf_sz,
 						  PCI_DMA_FROMDEVICE);
 				skb_put (skb = np->rx_skbuff[entry], pkt_len);
@@ -903,7 +902,7 @@ receive_packet (struct net_device *dev)
 			} else if ((skb = dev_alloc_skb (pkt_len + 2)) != NULL) {
 				pci_dma_sync_single_for_cpu(np->pdev,
 				  			    desc->fraginfo & 
-							      0xffffffffffffULL,
+							      DMA_48BIT_MASK,
 							    np->rx_buf_sz,
 							    PCI_DMA_FROMDEVICE);
 				skb->dev = dev;
@@ -915,7 +914,7 @@ receive_packet (struct net_device *dev)
 				skb_put (skb, pkt_len);
 				pci_dma_sync_single_for_device(np->pdev,
 				  			      desc->fraginfo & 
-							      0xffffffffffffULL,
+							      DMA_48BIT_MASK,
 							       np->rx_buf_sz,
 							       PCI_DMA_FROMDEVICE);
 			}
@@ -1803,7 +1802,7 @@ rio_close (struct net_device *dev)
 		if (skb) {
 			pci_unmap_single(np->pdev, 
 					 np->rx_ring[i].fraginfo & 
-						0xffffffffffffULL,
+						DMA_48BIT_MASK,
 					 skb->len, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb (skb);
 			np->rx_skbuff[i] = NULL;
@@ -1814,7 +1813,7 @@ rio_close (struct net_device *dev)
 		if (skb) {
 			pci_unmap_single(np->pdev, 
 					 np->tx_ring[i].fraginfo & 
-						0xffffffffffffULL,
+						DMA_48BIT_MASK,
 					 skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb (skb);
 			np->tx_skbuff[i] = NULL;
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index ff61817..635690c 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -14,6 +14,7 @@ enum dma_data_direction {
 };
 
 #define DMA_64BIT_MASK	0xffffffffffffffffULL
+#define DMA_48BIT_MASK	0x0000ffffffffffffULL
 #define DMA_40BIT_MASK	0x000000ffffffffffULL
 #define DMA_39BIT_MASK	0x0000007fffffffffULL
 #define DMA_32BIT_MASK	0x00000000ffffffffULL
-- 
1.3.1

