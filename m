From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 3/8] r8169: replace PCI_DMA_{TO,FROM}DEVICE to DMA_{TO,FROM}_DEVICE
Date: Thu, 21 Oct 2010 10:25:38 +0200
Message-ID: <1287649543-6569-4-git-send-email-sgruszka@redhat.com>
References: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3788 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753379Ab0JUIX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 04:23:26 -0400
In-Reply-To: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/r8169.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5a87036..7ad119f 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3948,7 +3948,7 @@ static void rtl8169_free_rx_databuff(struct rtl8169_private *tp,
 	struct pci_dev *pdev = tp->pci_dev;
 
 	dma_unmap_single(&pdev->dev, le64_to_cpu(desc->addr), rx_buf_sz,
-			 PCI_DMA_FROMDEVICE);
+			 DMA_FROM_DEVICE);
 	kfree(*data_buff);
 	*data_buff = NULL;
 	rtl8169_make_unusable_by_asic(desc);
@@ -3994,7 +3994,7 @@ static struct sk_buff *rtl8169_alloc_rx_data(struct rtl8169_private *tp,
 	}
 
 	mapping = dma_map_single(&tp->pci_dev->dev, rtl8169_align(data), rx_buf_sz,
-				 PCI_DMA_FROMDEVICE);
+				 DMA_FROM_DEVICE);
 	if (unlikely(dma_mapping_error(&tp->pci_dev->dev, mapping)))
 		goto err_out;
 
@@ -4072,7 +4072,7 @@ static void rtl8169_unmap_tx_skb(struct pci_dev *pdev, struct ring_info *tx_skb,
 	unsigned int len = tx_skb->len;
 
 	dma_unmap_single(&pdev->dev, le64_to_cpu(desc->addr), len,
-			 PCI_DMA_TODEVICE);
+			 DMA_TO_DEVICE);
 	desc->opts1 = 0x00;
 	desc->opts2 = 0x00;
 	desc->addr = 0x00;
@@ -4223,7 +4223,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 		len = frag->size;
 		addr = ((void *) page_address(frag->page)) + frag->page_offset;
 		mapping = dma_map_single(&tp->pci_dev->dev, addr, len,
-					 PCI_DMA_TODEVICE);
+					 DMA_TO_DEVICE);
 		if (unlikely(dma_mapping_error(&tp->pci_dev->dev, mapping)))
 			goto err_out;
 
@@ -4290,7 +4290,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	len = skb_headlen(skb);
 	mapping = dma_map_single(&tp->pci_dev->dev, skb->data, len,
-				 PCI_DMA_TODEVICE);
+				 DMA_TO_DEVICE);
 	if (unlikely(dma_mapping_error(&tp->pci_dev->dev, mapping)))
 		goto err_dma_0;
 
@@ -4469,13 +4469,13 @@ static struct sk_buff *rtl8169_try_rx_copy(void *data,
 
 	data = rtl8169_align(data);
 	dma_sync_single_for_cpu(&tp->pci_dev->dev, addr, pkt_size,
-				PCI_DMA_FROMDEVICE);
+				DMA_FROM_DEVICE);
 	prefetch(data);
 	skb = netdev_alloc_skb_ip_align(tp->dev, pkt_size);
 	if (skb)
 		memcpy(skb->data, data, pkt_size);
 	dma_sync_single_for_device(&tp->pci_dev->dev, addr, pkt_size,
-				   PCI_DMA_FROMDEVICE);
+				   DMA_FROM_DEVICE);
 	return skb;
 }
 
-- 
1.6.5.2

