From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [PATCH 1/2] b44: replace define
Date: Fri, 16 Feb 2007 13:27:23 -0800
Message-ID: <1171661243.20573.25.camel@dhcp-10-7-81-58.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4946 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751511AbXBPVmb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 16:42:31 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replaced B44_DMA_MASK with DMA_30BIT_MASK.

Signed-off by: Gary Zambrano <zambrano@broadcom.com>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 5ff7882..9332f4c 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -59,7 +59,6 @@
 #define B44_DEF_TX_RING_PENDING		(B44_TX_RING_SIZE - 1)
 #define B44_TX_RING_BYTES	(sizeof(struct dma_desc) * \
 				 B44_TX_RING_SIZE)
-#define B44_DMA_MASK 0x3fffffff
 
 #define TX_RING_GAP(BP)	\
 	(B44_TX_RING_SIZE - (BP)->tx_pending)
@@ -665,7 +664,7 @@ static int b44_alloc_rx_skb(struct b44 *
 	/* Hardware bug work-around, the chip is unable to do PCI DMA
 	   to/from anything above 1GB :-( */
 	if (dma_mapping_error(mapping) ||
-		mapping + RX_PKT_BUF_SZ > B44_DMA_MASK) {
+		mapping + RX_PKT_BUF_SZ > DMA_30BIT_MASK) {
 		/* Sigh... */
 		if (!dma_mapping_error(mapping))
 			pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
@@ -677,7 +676,7 @@ static int b44_alloc_rx_skb(struct b44 *
 					 RX_PKT_BUF_SZ,
 					 PCI_DMA_FROMDEVICE);
 		if (dma_mapping_error(mapping) ||
-			mapping + RX_PKT_BUF_SZ > B44_DMA_MASK) {
+			mapping + RX_PKT_BUF_SZ > DMA_30BIT_MASK) {
 			if (!dma_mapping_error(mapping))
 				pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
 			dev_kfree_skb_any(skb);
@@ -988,7 +987,7 @@ static int b44_start_xmit(struct sk_buff
 	}
 
 	mapping = pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
-	if (dma_mapping_error(mapping) || mapping + len > B44_DMA_MASK) {
+	if (dma_mapping_error(mapping) || mapping + len > DMA_30BIT_MASK) {
 		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
 		if (!dma_mapping_error(mapping))
 			pci_unmap_single(bp->pdev, mapping, len, PCI_DMA_TODEVICE);
@@ -1000,7 +999,7 @@ static int b44_start_xmit(struct sk_buff
 
 		mapping = pci_map_single(bp->pdev, bounce_skb->data,
 					 len, PCI_DMA_TODEVICE);
-		if (dma_mapping_error(mapping) || mapping + len > B44_DMA_MASK) {
+		if (dma_mapping_error(mapping) || mapping + len > DMA_30BIT_MASK) {
 			if (!dma_mapping_error(mapping))
 				pci_unmap_single(bp->pdev, mapping,
 					 len, PCI_DMA_TODEVICE);
@@ -1227,7 +1226,7 @@ static int b44_alloc_consistent(struct b
 		                             DMA_BIDIRECTIONAL);
 
 		if (dma_mapping_error(rx_ring_dma) ||
-			rx_ring_dma + size > B44_DMA_MASK) {
+			rx_ring_dma + size > DMA_30BIT_MASK) {
 			kfree(rx_ring);
 			goto out_err;
 		}
@@ -1254,7 +1253,7 @@ static int b44_alloc_consistent(struct b
 		                             DMA_TO_DEVICE);
 
 		if (dma_mapping_error(tx_ring_dma) ||
-			tx_ring_dma + size > B44_DMA_MASK) {
+			tx_ring_dma + size > DMA_30BIT_MASK) {
 			kfree(tx_ring);
 			goto out_err;
 		}
@@ -2151,13 +2150,13 @@ static int __devinit b44_init_one(struct
 
 	pci_set_master(pdev);
 
-	err = pci_set_dma_mask(pdev, (u64) B44_DMA_MASK);
+	err = pci_set_dma_mask(pdev, (u64) DMA_30BIT_MASK);
 	if (err) {
 		dev_err(&pdev->dev, "No usable DMA configuration, aborting.\n");
 		goto err_out_free_res;
 	}
 
-	err = pci_set_consistent_dma_mask(pdev, (u64) B44_DMA_MASK);
+	err = pci_set_consistent_dma_mask(pdev, (u64) DMA_30BIT_MASK);
 	if (err) {
 		dev_err(&pdev->dev, "No usable DMA configuration, aborting.\n");
 		goto err_out_free_res;


