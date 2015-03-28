From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next 1/3] net: bcmgenet: add UMAC_IRQ_RXDMA_DONE and UMAC_IRQ_TXDMA_DONE
Date: Fri, 27 Mar 2015 22:50:50 -0700 (PDT)
Message-ID: <20150328055050.0CBDB220209@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:33405 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbbC1F52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2015 01:57:28 -0400
Received: by yhzz6 with SMTP id z6so1217988yhz.0
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 22:57:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add #define for UMAC_IRQ_RXDMA_DONE and UMAC_IRQ_TXDMA_DONE in order
to simplify the code that handles Rx and Tx default queue interrupts.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 20 ++++++++------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  4 ++++
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 31e1407..620021e 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -966,15 +966,13 @@ static void bcmgenet_free_cb(struct enet_cb *cb)
 
 static inline void bcmgenet_rx_ring16_int_disable(struct bcmgenet_rx_ring *ring)
 {
-	bcmgenet_intrl2_0_writel(ring->priv,
-				 UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE,
+	bcmgenet_intrl2_0_writel(ring->priv, UMAC_IRQ_RXDMA_DONE,
 				 INTRL2_CPU_MASK_SET);
 }
 
 static inline void bcmgenet_rx_ring16_int_enable(struct bcmgenet_rx_ring *ring)
 {
-	bcmgenet_intrl2_0_writel(ring->priv,
-				 UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE,
+	bcmgenet_intrl2_0_writel(ring->priv, UMAC_IRQ_RXDMA_DONE,
 				 INTRL2_CPU_MASK_CLEAR);
 }
 
@@ -994,15 +992,13 @@ static inline void bcmgenet_rx_ring_int_enable(struct bcmgenet_rx_ring *ring)
 
 static inline void bcmgenet_tx_ring16_int_disable(struct bcmgenet_tx_ring *ring)
 {
-	bcmgenet_intrl2_0_writel(ring->priv,
-				 UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE,
+	bcmgenet_intrl2_0_writel(ring->priv, UMAC_IRQ_TXDMA_DONE,
 				 INTRL2_CPU_MASK_SET);
 }
 
 static inline void bcmgenet_tx_ring16_int_enable(struct bcmgenet_tx_ring *ring)
 {
-	bcmgenet_intrl2_0_writel(ring->priv,
-				 UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE,
+	bcmgenet_intrl2_0_writel(ring->priv, UMAC_IRQ_TXDMA_DONE,
 				 INTRL2_CPU_MASK_CLEAR);
 }
 
@@ -1727,10 +1723,10 @@ static int init_umac(struct bcmgenet_priv *priv)
 	bcmgenet_intr_disable(priv);
 
 	/* Enable Rx default queue 16 interrupts */
-	int0_enable |= (UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE);
+	int0_enable |= UMAC_IRQ_RXDMA_DONE;
 
 	/* Enable Tx default queue 16 interrupts */
-	int0_enable |= (UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE);
+	int0_enable |= UMAC_IRQ_TXDMA_DONE;
 
 	/* Monitor cable plug/unplugged event for internal PHY */
 	if (phy_is_internal(priv->phydev)) {
@@ -2353,7 +2349,7 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 	netif_dbg(priv, intr, priv->dev,
 		  "IRQ=0x%x\n", priv->irq0_stat);
 
-	if (priv->irq0_stat & (UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE)) {
+	if (priv->irq0_stat & UMAC_IRQ_RXDMA_DONE) {
 		rx_ring = &priv->rx_rings[DESC_INDEX];
 
 		if (likely(napi_schedule_prep(&rx_ring->napi))) {
@@ -2362,7 +2358,7 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 		}
 	}
 
-	if (priv->irq0_stat & (UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE)) {
+	if (priv->irq0_stat & UMAC_IRQ_TXDMA_DONE) {
 		tx_ring = &priv->tx_rings[DESC_INDEX];
 
 		if (likely(napi_schedule_prep(&tx_ring->napi))) {
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index a834da1..f86d635 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -303,9 +303,13 @@ struct bcmgenet_mib_counters {
 #define UMAC_IRQ_RXDMA_MBDONE		(1 << 13)
 #define UMAC_IRQ_RXDMA_PDONE		(1 << 14)
 #define UMAC_IRQ_RXDMA_BDONE		(1 << 15)
+#define UMAC_IRQ_RXDMA_DONE		(UMAC_IRQ_RXDMA_PDONE | \
+					 UMAC_IRQ_RXDMA_BDONE)
 #define UMAC_IRQ_TXDMA_MBDONE		(1 << 16)
 #define UMAC_IRQ_TXDMA_PDONE		(1 << 17)
 #define UMAC_IRQ_TXDMA_BDONE		(1 << 18)
+#define UMAC_IRQ_TXDMA_DONE		(UMAC_IRQ_TXDMA_PDONE | \
+					 UMAC_IRQ_TXDMA_BDONE)
 /* Only valid for GENETv3+ */
 #define UMAC_IRQ_MDIO_DONE		(1 << 23)
 #define UMAC_IRQ_MDIO_ERROR		(1 << 24)
-- 
2.2.0.rc0.207.ga3a616c
