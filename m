From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/8][BNX2]: Add ring constants.
Date: Wed, 12 Dec 2007 10:58:22 -0800
Message-ID: <1197485902.16386.26.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3490 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751954AbXLLSWx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 13:22:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Add ring constants.

Define the various ring constants to make the code cleaner.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4e7b46e..dfe50c2 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -468,8 +468,7 @@ bnx2_free_mem(struct bnx2 *bp)
 		bp->stats_blk = NULL;
 	}
 	if (bp->tx_desc_ring) {
-		pci_free_consistent(bp->pdev,
-				    sizeof(struct tx_bd) * TX_DESC_CNT,
+		pci_free_consistent(bp->pdev, TXBD_RING_SIZE,
 				    bp->tx_desc_ring, bp->tx_desc_mapping);
 		bp->tx_desc_ring = NULL;
 	}
@@ -477,8 +476,7 @@ bnx2_free_mem(struct bnx2 *bp)
 	bp->tx_buf_ring = NULL;
 	for (i = 0; i < bp->rx_max_ring; i++) {
 		if (bp->rx_desc_ring[i])
-			pci_free_consistent(bp->pdev,
-					    sizeof(struct rx_bd) * RX_DESC_CNT,
+			pci_free_consistent(bp->pdev, RXBD_RING_SIZE,
 					    bp->rx_desc_ring[i],
 					    bp->rx_desc_mapping[i]);
 		bp->rx_desc_ring[i] = NULL;
@@ -492,30 +490,24 @@ bnx2_alloc_mem(struct bnx2 *bp)
 {
 	int i, status_blk_size;
 
-	bp->tx_buf_ring = kzalloc(sizeof(struct sw_bd) * TX_DESC_CNT,
-				  GFP_KERNEL);
+	bp->tx_buf_ring = kzalloc(SW_TXBD_RING_SIZE, GFP_KERNEL);
 	if (bp->tx_buf_ring == NULL)
 		return -ENOMEM;
 
-	bp->tx_desc_ring = pci_alloc_consistent(bp->pdev,
-					        sizeof(struct tx_bd) *
-						TX_DESC_CNT,
+	bp->tx_desc_ring = pci_alloc_consistent(bp->pdev, TXBD_RING_SIZE,
 						&bp->tx_desc_mapping);
 	if (bp->tx_desc_ring == NULL)
 		goto alloc_mem_err;
 
-	bp->rx_buf_ring = vmalloc(sizeof(struct sw_bd) * RX_DESC_CNT *
-				  bp->rx_max_ring);
+	bp->rx_buf_ring = vmalloc(SW_RXBD_RING_SIZE * bp->rx_max_ring);
 	if (bp->rx_buf_ring == NULL)
 		goto alloc_mem_err;
 
-	memset(bp->rx_buf_ring, 0, sizeof(struct sw_bd) * RX_DESC_CNT *
-				   bp->rx_max_ring);
+	memset(bp->rx_buf_ring, 0, SW_RXBD_RING_SIZE * bp->rx_max_ring);
 
 	for (i = 0; i < bp->rx_max_ring; i++) {
 		bp->rx_desc_ring[i] =
-			pci_alloc_consistent(bp->pdev,
-					     sizeof(struct rx_bd) * RX_DESC_CNT,
+			pci_alloc_consistent(bp->pdev, RXBD_RING_SIZE,
 					     &bp->rx_desc_mapping[i]);
 		if (bp->rx_desc_ring[i] == NULL)
 			goto alloc_mem_err;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 30ba366..e6a2153 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6408,6 +6408,11 @@ struct sw_bd {
 	DECLARE_PCI_UNMAP_ADDR(mapping)
 };
 
+#define SW_RXBD_RING_SIZE (sizeof(struct sw_bd) * RX_DESC_CNT)
+#define RXBD_RING_SIZE (sizeof(struct rx_bd) * RX_DESC_CNT)
+#define SW_TXBD_RING_SIZE (sizeof(struct sw_bd) * TX_DESC_CNT)
+#define TXBD_RING_SIZE (sizeof(struct tx_bd) * TX_DESC_CNT)
+
 /* Buffered flash (Atmel: AT45DB011B) specific information */
 #define SEEPROM_PAGE_BITS			2
 #define SEEPROM_PHY_PAGE_SIZE			(1 << SEEPROM_PAGE_BITS)


