From: Holger Brunck <holger.brunck@keymile.com>
Subject: [PATCH net-next 4/8] net/wan/fsl_ucc_hdlc: fix incorrect memory allocation
Date: Wed, 17 May 2017 17:24:35 +0200
Message-ID: <20170517152439.8817-4-holger.brunck@keymile.com>
References: <20170517152439.8817-1-holger.brunck@keymile.com>
Cc: Holger Brunck <holger.brunck@keymile.com>,
        Zhao Qiang <qiang.zhao@nxp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:47227 "EHLO
        mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753985AbdEQPbY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 11:31:24 -0400
In-Reply-To: <20170517152439.8817-1-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need space for the struct qe_bd and not for a pointer to this struct.

Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
Cc: Zhao Qiang <qiang.zhao@nxp.com>
---
 drivers/net/wan/fsl_ucc_hdlc.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index 1a60897767d9..49b91b2c113c 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -136,7 +136,7 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 	priv->tx_ring_size = TX_BD_RING_LEN;
 	/* Alloc Rx BD */
 	priv->rx_bd_base = dma_alloc_coherent(priv->dev,
-			RX_BD_RING_LEN * sizeof(struct qe_bd *),
+			RX_BD_RING_LEN * sizeof(struct qe_bd),
 			&priv->dma_rx_bd, GFP_KERNEL);
 
 	if (!priv->rx_bd_base) {
@@ -147,7 +147,7 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 
 	/* Alloc Tx BD */
 	priv->tx_bd_base = dma_alloc_coherent(priv->dev,
-			TX_BD_RING_LEN * sizeof(struct qe_bd *),
+			TX_BD_RING_LEN * sizeof(struct qe_bd),
 			&priv->dma_tx_bd, GFP_KERNEL);
 
 	if (!priv->tx_bd_base) {
@@ -294,11 +294,11 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 	qe_muram_free(priv->ucc_pram_offset);
 free_tx_bd:
 	dma_free_coherent(priv->dev,
-			  TX_BD_RING_LEN * sizeof(struct qe_bd *),
+			  TX_BD_RING_LEN * sizeof(struct qe_bd),
 			  priv->tx_bd_base, priv->dma_tx_bd);
 free_rx_bd:
 	dma_free_coherent(priv->dev,
-			  RX_BD_RING_LEN * sizeof(struct qe_bd *),
+			  RX_BD_RING_LEN * sizeof(struct qe_bd),
 			  priv->rx_bd_base, priv->dma_rx_bd);
 free_uccf:
 	ucc_fast_free(priv->uccf);
@@ -656,7 +656,7 @@ static void uhdlc_memclean(struct ucc_hdlc_private *priv)
 
 	if (priv->rx_bd_base) {
 		dma_free_coherent(priv->dev,
-				  RX_BD_RING_LEN * sizeof(struct qe_bd *),
+				  RX_BD_RING_LEN * sizeof(struct qe_bd),
 				  priv->rx_bd_base, priv->dma_rx_bd);
 
 		priv->rx_bd_base = NULL;
@@ -665,7 +665,7 @@ static void uhdlc_memclean(struct ucc_hdlc_private *priv)
 
 	if (priv->tx_bd_base) {
 		dma_free_coherent(priv->dev,
-				  TX_BD_RING_LEN * sizeof(struct qe_bd *),
+				  TX_BD_RING_LEN * sizeof(struct qe_bd),
 				  priv->tx_bd_base, priv->dma_tx_bd);
 
 		priv->tx_bd_base = NULL;
-- 
2.12.0.rc1
