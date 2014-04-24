From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] Altera TSE: Remove unnecessary cast of void pointers
Date: Thu, 24 Apr 2014 13:50:09 +0200
Message-ID: <1398340209-3887-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:43173 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753522AbaDXLuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 07:50:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to cast void pointers.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/altera/altera_msgdma.c |   15 ++++-------
 drivers/net/ethernet/altera/altera_sgdma.c  |   37 ++++++++++++---------------
 2 files changed, 22 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_msgdma.c b/drivers/net/ethernet/altera/altera_msgdma.c
index 3df1866..0e38a03 100644
--- a/drivers/net/ethernet/altera/altera_msgdma.c
+++ b/drivers/net/ethernet/altera/altera_msgdma.c
@@ -32,10 +32,8 @@ void msgdma_uninitialize(struct altera_tse_private *priv)
 void msgdma_reset(struct altera_tse_private *priv)
 {
 	int counter;
-	struct msgdma_csr *txcsr =
-		(struct msgdma_csr *)priv->tx_dma_csr;
-	struct msgdma_csr *rxcsr =
-		(struct msgdma_csr *)priv->rx_dma_csr;
+	struct msgdma_csr *txcsr = priv->tx_dma_csr;
+	struct msgdma_csr *rxcsr = priv->rx_dma_csr;
 
 	/* Reset Rx mSGDMA */
 	iowrite32(MSGDMA_CSR_STAT_MASK, &rxcsr->status);
@@ -133,8 +131,7 @@ u32 msgdma_tx_completions(struct altera_tse_private *priv)
 	u32 ready = 0;
 	u32 inuse;
 	u32 status;
-	struct msgdma_csr *txcsr =
-		(struct msgdma_csr *)priv->tx_dma_csr;
+	struct msgdma_csr *txcsr = priv->tx_dma_csr;
 
 	/* Get number of sent descriptors */
 	inuse = ioread32(&txcsr->rw_fill_level) & 0xffff;
@@ -186,10 +183,8 @@ u32 msgdma_rx_status(struct altera_tse_private *priv)
 	u32 rxstatus = 0;
 	u32 pktlength;
 	u32 pktstatus;
-	struct msgdma_csr *rxcsr =
-		(struct msgdma_csr *)priv->rx_dma_csr;
-	struct msgdma_response *rxresp =
-		(struct msgdma_response *)priv->rx_dma_resp;
+	struct msgdma_csr *rxcsr = priv->rx_dma_csr;
+	struct msgdma_response *rxresp = priv->rx_dma_resp;
 
 	if (ioread32(&rxcsr->resp_fill_level) & 0xffff) {
 		pktlength = ioread32(&rxresp->bytes_transferred);
diff --git a/drivers/net/ethernet/altera/altera_sgdma.c b/drivers/net/ethernet/altera/altera_sgdma.c
index 0ee9663..519f0f0 100644
--- a/drivers/net/ethernet/altera/altera_sgdma.c
+++ b/drivers/net/ethernet/altera/altera_sgdma.c
@@ -112,12 +112,12 @@ void sgdma_uninitialize(struct altera_tse_private *priv)
  */
 void sgdma_reset(struct altera_tse_private *priv)
 {
-	u32 *ptxdescripmem = (u32 *)priv->tx_dma_desc;
+	u32 *ptxdescripmem = priv->tx_dma_desc;
 	u32 txdescriplen   = priv->txdescmem;
-	u32 *prxdescripmem = (u32 *)priv->rx_dma_desc;
+	u32 *prxdescripmem = priv->rx_dma_desc;
 	u32 rxdescriplen   = priv->rxdescmem;
-	struct sgdma_csr *ptxsgdma = (struct sgdma_csr *)priv->tx_dma_csr;
-	struct sgdma_csr *prxsgdma = (struct sgdma_csr *)priv->rx_dma_csr;
+	struct sgdma_csr *ptxsgdma = priv->tx_dma_csr;
+	struct sgdma_csr *prxsgdma = priv->rx_dma_csr;
 
 	/* Initialize descriptor memory to 0 */
 	memset(ptxdescripmem, 0, txdescriplen);
@@ -132,14 +132,14 @@ void sgdma_reset(struct altera_tse_private *priv)
 
 void sgdma_enable_rxirq(struct altera_tse_private *priv)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->rx_dma_csr;
+	struct sgdma_csr *csr = priv->rx_dma_csr;
 	priv->rxctrlreg |= SGDMA_CTRLREG_INTEN;
 	tse_set_bit(&csr->control, SGDMA_CTRLREG_INTEN);
 }
 
 void sgdma_enable_txirq(struct altera_tse_private *priv)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->tx_dma_csr;
+	struct sgdma_csr *csr = priv->tx_dma_csr;
 	priv->txctrlreg |= SGDMA_CTRLREG_INTEN;
 	tse_set_bit(&csr->control, SGDMA_CTRLREG_INTEN);
 }
@@ -156,13 +156,13 @@ void sgdma_disable_txirq(struct altera_tse_private *priv)
 
 void sgdma_clear_rxirq(struct altera_tse_private *priv)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->rx_dma_csr;
+	struct sgdma_csr *csr = priv->rx_dma_csr;
 	tse_set_bit(&csr->control, SGDMA_CTRLREG_CLRINT);
 }
 
 void sgdma_clear_txirq(struct altera_tse_private *priv)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->tx_dma_csr;
+	struct sgdma_csr *csr = priv->tx_dma_csr;
 	tse_set_bit(&csr->control, SGDMA_CTRLREG_CLRINT);
 }
 
@@ -174,8 +174,7 @@ void sgdma_clear_txirq(struct altera_tse_private *priv)
 int sgdma_tx_buffer(struct altera_tse_private *priv, struct tse_buffer *buffer)
 {
 	int pktstx = 0;
-	struct sgdma_descrip *descbase =
-		(struct sgdma_descrip *)priv->tx_dma_desc;
+	struct sgdma_descrip *descbase = priv->tx_dma_desc;
 
 	struct sgdma_descrip *cdesc = &descbase[0];
 	struct sgdma_descrip *ndesc = &descbase[1];
@@ -208,7 +207,7 @@ int sgdma_tx_buffer(struct altera_tse_private *priv, struct tse_buffer *buffer)
 u32 sgdma_tx_completions(struct altera_tse_private *priv)
 {
 	u32 ready = 0;
-	struct sgdma_descrip *desc = (struct sgdma_descrip *)priv->tx_dma_desc;
+	struct sgdma_descrip *desc = priv->tx_dma_desc;
 
 	if (!sgdma_txbusy(priv) &&
 	    ((desc->control & SGDMA_CONTROL_HW_OWNED) == 0) &&
@@ -231,8 +230,8 @@ int sgdma_add_rx_desc(struct altera_tse_private *priv,
  */
 u32 sgdma_rx_status(struct altera_tse_private *priv)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->rx_dma_csr;
-	struct sgdma_descrip *base = (struct sgdma_descrip *)priv->rx_dma_desc;
+	struct sgdma_csr *csr = priv->rx_dma_csr;
+	struct sgdma_descrip *base = priv->rx_dma_desc;
 	struct sgdma_descrip *desc = NULL;
 	int pktsrx;
 	unsigned int rxstatus = 0;
@@ -312,10 +311,8 @@ static void sgdma_descrip(struct sgdma_descrip *desc,
  */
 static int sgdma_async_read(struct altera_tse_private *priv)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->rx_dma_csr;
-	struct sgdma_descrip *descbase =
-		(struct sgdma_descrip *)priv->rx_dma_desc;
-
+	struct sgdma_csr *csr = priv->rx_dma_csr;
+	struct sgdma_descrip *descbase = priv->rx_dma_desc;
 	struct sgdma_descrip *cdesc = &descbase[0];
 	struct sgdma_descrip *ndesc = &descbase[1];
 
@@ -364,7 +361,7 @@ static int sgdma_async_read(struct altera_tse_private *priv)
 static int sgdma_async_write(struct altera_tse_private *priv,
 			     struct sgdma_descrip *desc)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->tx_dma_csr;
+	struct sgdma_csr *csr = priv->tx_dma_csr;
 
 	if (sgdma_txbusy(priv))
 		return 0;
@@ -485,7 +482,7 @@ queue_rx_peekhead(struct altera_tse_private *priv)
  */
 static int sgdma_rxbusy(struct altera_tse_private *priv)
 {
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->rx_dma_csr;
+	struct sgdma_csr *csr = priv->rx_dma_csr;
 	return ioread32(&csr->status) & SGDMA_STSREG_BUSY;
 }
 
@@ -495,7 +492,7 @@ static int sgdma_rxbusy(struct altera_tse_private *priv)
 static int sgdma_txbusy(struct altera_tse_private *priv)
 {
 	int delay = 0;
-	struct sgdma_csr *csr = (struct sgdma_csr *)priv->tx_dma_csr;
+	struct sgdma_csr *csr = priv->tx_dma_csr;
 
 	/* if DMA is busy, wait for current transactino to finish */
 	while ((ioread32(&csr->status) & SGDMA_STSREG_BUSY) && (delay++ < 100))
-- 
1.7.9.5
