From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 3/6] r8169: replace PCI_DMA_{TO,FROM}DEVICE to DMA_{TO,FROM}_DEVICE
Date: Fri, 15 Oct 2010 14:15:19 +0200
Message-ID: <1287144922-3297-3-git-send-email-sgruszka@redhat.com>
References: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62002 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754288Ab0JOMNI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 08:13:08 -0400
In-Reply-To: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/r8169.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 86be06c..1eafe9b 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3984,7 +3984,7 @@ static void rtl8169_free_rx_skb(struct rtl8169_private *tp,
 	struct pci_dev *pdev = tp->pci_dev;
 
 	dma_unmap_single(&pdev->dev, le64_to_cpu(desc->addr), tp->rx_buf_sz,
-			 PCI_DMA_FROMDEVICE);
+			 DMA_FROM_DEVICE);
 	dev_kfree_skb(*sk_buff);
 	*sk_buff = NULL;
 	rtl8169_make_unusable_by_asic(desc);
@@ -4020,7 +4020,7 @@ static struct sk_buff *rtl8169_alloc_rx_skb(struct rtl8169_private *tp,
 	skb_reserve(skb, align ? ((pad - 1) & (unsigned long)skb->data) : pad);
 
 	mapping = dma_map_single(&tp->pci_dev->dev, skb->data, tp->rx_buf_sz,
-				 PCI_DMA_FROMDEVICE);
+				 DMA_FROM_DEVICE);
 	if (dma_mapping_error(&tp->pci_dev->dev, mapping))
 		goto err_free_skb_1;
 
@@ -4107,7 +4107,7 @@ static void rtl8169_unmap_tx_skb(struct pci_dev *pdev, struct ring_info *tx_skb,
 	unsigned int len = tx_skb->len;
 
 	dma_unmap_single(&pdev->dev, le64_to_cpu(desc->addr), len,
-			 PCI_DMA_TODEVICE);
+			 DMA_TO_DEVICE);
 	desc->opts1 = 0x00;
 	desc->opts2 = 0x00;
 	desc->addr = 0x00;
@@ -4257,7 +4257,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		len = frag->size;
 		addr = ((void *) page_address(frag->page)) + frag->page_offset;
 		mapping = dma_map_single(&tp->pci_dev->dev, addr, len,
-					 PCI_DMA_TODEVICE);
+					 DMA_TO_DEVICE);
 		if (unlikely(dma_mapping_error(&tp->pci_dev->dev, mapping)))
 			goto err_out;
 
@@ -4324,7 +4324,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	len = skb_headlen(skb);
 	mapping = dma_map_single(&tp->pci_dev->dev, skb->data, len,
-				 PCI_DMA_TODEVICE);
+				 DMA_TO_DEVICE);
 	if (unlikely(dma_mapping_error(&tp->pci_dev->dev, mapping)))
 		goto err_stop_0;
 
@@ -4505,7 +4505,7 @@ static inline bool rtl8169_try_rx_copy(struct sk_buff **sk_buff,
 		goto out;
 
 	dma_sync_single_for_cpu(&tp->pci_dev->dev, addr, pkt_size,
-				PCI_DMA_FROMDEVICE);
+				DMA_FROM_DEVICE);
 	skb_copy_from_linear_data(*sk_buff, skb->data, pkt_size);
 	*sk_buff = skb;
 	done = true;
@@ -4575,11 +4575,11 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 
 			if (rtl8169_try_rx_copy(&skb, tp, pkt_size, addr)) {
 				dma_sync_single_for_device(&pdev->dev, addr,
-					pkt_size, PCI_DMA_FROMDEVICE);
+					pkt_size, DMA_FROM_DEVICE);
 				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 			} else {
 				dma_unmap_single(&pdev->dev, addr, tp->rx_buf_sz,
-						 PCI_DMA_FROMDEVICE);
+						 DMA_FROM_DEVICE);
 				tp->Rx_skbuff[entry] = NULL;
 			}
 
-- 
1.7.1

