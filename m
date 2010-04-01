From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH 2/2] acenic: use the dma state API instead of the pci equivalents
Date: Thu,  1 Apr 2010 17:13:06 +0900
Message-ID: <1270109586-9193-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
References: <1270109586-9193-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: netdev@vger.kernel.org, fujita.tomonori@lab.ntt.co.jp
To: linux-acenic@sunsite.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:48854 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753979Ab0DAIRR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 04:17:17 -0400
In-Reply-To: <1270109586-9193-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA API is preferred.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/acenic.c |   26 +++++++++++++-------------
 drivers/net/acenic.h |    6 +++---
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 02a4746..1328eb9 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -661,7 +661,7 @@ static void __devexit acenic_remove_one(struct pci_dev *pdev)
 			dma_addr_t mapping;
 
 			ringp = &ap->skb->rx_std_skbuff[i];
-			mapping = pci_unmap_addr(ringp, mapping);
+			mapping = dma_unmap_addr(ringp, mapping);
 			pci_unmap_page(ap->pdev, mapping,
 				       ACE_STD_BUFSIZE,
 				       PCI_DMA_FROMDEVICE);
@@ -681,7 +681,7 @@ static void __devexit acenic_remove_one(struct pci_dev *pdev)
 				dma_addr_t mapping;
 
 				ringp = &ap->skb->rx_mini_skbuff[i];
-				mapping = pci_unmap_addr(ringp,mapping);
+				mapping = dma_unmap_addr(ringp,mapping);
 				pci_unmap_page(ap->pdev, mapping,
 					       ACE_MINI_BUFSIZE,
 					       PCI_DMA_FROMDEVICE);
@@ -700,7 +700,7 @@ static void __devexit acenic_remove_one(struct pci_dev *pdev)
 			dma_addr_t mapping;
 
 			ringp = &ap->skb->rx_jumbo_skbuff[i];
-			mapping = pci_unmap_addr(ringp, mapping);
+			mapping = dma_unmap_addr(ringp, mapping);
 			pci_unmap_page(ap->pdev, mapping,
 				       ACE_JUMBO_BUFSIZE,
 				       PCI_DMA_FROMDEVICE);
@@ -1683,7 +1683,7 @@ static void ace_load_std_rx_ring(struct ace_private *ap, int nr_bufs)
 				       ACE_STD_BUFSIZE,
 				       PCI_DMA_FROMDEVICE);
 		ap->skb->rx_std_skbuff[idx].skb = skb;
-		pci_unmap_addr_set(&ap->skb->rx_std_skbuff[idx],
+		dma_unmap_addr_set(&ap->skb->rx_std_skbuff[idx],
 				   mapping, mapping);
 
 		rd = &ap->rx_std_ring[idx];
@@ -1744,7 +1744,7 @@ static void ace_load_mini_rx_ring(struct ace_private *ap, int nr_bufs)
 				       ACE_MINI_BUFSIZE,
 				       PCI_DMA_FROMDEVICE);
 		ap->skb->rx_mini_skbuff[idx].skb = skb;
-		pci_unmap_addr_set(&ap->skb->rx_mini_skbuff[idx],
+		dma_unmap_addr_set(&ap->skb->rx_mini_skbuff[idx],
 				   mapping, mapping);
 
 		rd = &ap->rx_mini_ring[idx];
@@ -1800,7 +1800,7 @@ static void ace_load_jumbo_rx_ring(struct ace_private *ap, int nr_bufs)
 				       ACE_JUMBO_BUFSIZE,
 				       PCI_DMA_FROMDEVICE);
 		ap->skb->rx_jumbo_skbuff[idx].skb = skb;
-		pci_unmap_addr_set(&ap->skb->rx_jumbo_skbuff[idx],
+		dma_unmap_addr_set(&ap->skb->rx_jumbo_skbuff[idx],
 				   mapping, mapping);
 
 		rd = &ap->rx_jumbo_ring[idx];
@@ -2013,7 +2013,7 @@ static void ace_rx_int(struct net_device *dev, u32 rxretprd, u32 rxretcsm)
 		skb = rip->skb;
 		rip->skb = NULL;
 		pci_unmap_page(ap->pdev,
-			       pci_unmap_addr(rip, mapping),
+			       dma_unmap_addr(rip, mapping),
 			       mapsize,
 			       PCI_DMA_FROMDEVICE);
 		skb_put(skb, retdesc->size);
@@ -2085,7 +2085,7 @@ static inline void ace_tx_int(struct net_device *dev,
 
 		if (dma_unmap_len(info, maplen)) {
 			pci_unmap_page(ap->pdev, dma_unmap_addr(info, mapping),
-				       pci_unmap_len(info, maplen),
+				       dma_unmap_len(info, maplen),
 				       PCI_DMA_TODEVICE);
 			dma_unmap_len_set(info, maplen, 0);
 		}
@@ -2392,7 +2392,7 @@ static int ace_close(struct net_device *dev)
 				memset(ap->tx_ring + i, 0,
 				       sizeof(struct tx_desc));
 			pci_unmap_page(ap->pdev, dma_unmap_addr(info, mapping),
-				       pci_unmap_len(info, maplen),
+				       dma_unmap_len(info, maplen),
 				       PCI_DMA_TODEVICE);
 			dma_unmap_len_set(info, maplen, 0);
 		}
@@ -2429,8 +2429,8 @@ ace_map_tx_skb(struct ace_private *ap, struct sk_buff *skb,
 
 	info = ap->skb->tx_skbuff + idx;
 	info->skb = tail;
-	pci_unmap_addr_set(info, mapping, mapping);
-	pci_unmap_len_set(info, maplen, skb->len);
+	dma_unmap_addr_set(info, mapping, mapping);
+	dma_unmap_len_set(info, maplen, skb->len);
 	return mapping;
 }
 
@@ -2549,8 +2549,8 @@ restart:
 			} else {
 				info->skb = NULL;
 			}
-			pci_unmap_addr_set(info, mapping, mapping);
-			pci_unmap_len_set(info, maplen, frag->size);
+			dma_unmap_addr_set(info, mapping, mapping);
+			dma_unmap_len_set(info, maplen, frag->size);
 			ace_load_tx_bd(ap, desc, mapping, flagsize, vlan_tag);
 		}
 	}
diff --git a/drivers/net/acenic.h b/drivers/net/acenic.h
index 17079b9..0681da7 100644
--- a/drivers/net/acenic.h
+++ b/drivers/net/acenic.h
@@ -589,7 +589,7 @@ struct ace_info {
 
 struct ring_info {
 	struct sk_buff		*skb;
-	DECLARE_PCI_UNMAP_ADDR(mapping)
+	DEFINE_DMA_UNMAP_ADDR(mapping);
 };
 
 
@@ -600,8 +600,8 @@ struct ring_info {
  */
 struct tx_ring_info {
 	struct sk_buff		*skb;
-	DECLARE_PCI_UNMAP_ADDR(mapping)
-	DECLARE_PCI_UNMAP_LEN(maplen)
+	DEFINE_DMA_UNMAP_ADDR(mapping);
+	DEFINE_DMA_UNMAP_LEN(maplen);
 };
 
 
-- 
1.7.0

