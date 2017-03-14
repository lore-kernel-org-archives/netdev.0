From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 04/12] net: bcmgenet: remove meaningless lines
Date: Mon, 13 Mar 2017 17:41:34 -0700
Message-ID: <20170314004142.4746-5-opendmb@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, davem@davemloft.net,
        rafal@milecki.pl, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        pgynther@google.com, jaedon.shin@gmail.com,
        Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314004142.4746-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An assortment of non-functional lines are removed to reduce confusion
and some typos in comments are corrected.

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 2c008b09c4e3..22c92f5a9829 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -605,7 +605,7 @@ static int bcmgenet_set_coalesce(struct net_device *dev,
 
 	/* GENET TDMA hardware does not support a configurable timeout, but will
 	 * always generate an interrupt either after MBDONE packets have been
-	 * transmitted, or when the ring is emtpy.
+	 * transmitted, or when the ring is empty.
 	 */
 	if (ec->tx_coalesce_usecs || ec->tx_coalesce_usecs_high ||
 	    ec->tx_coalesce_usecs_irq || ec->tx_coalesce_usecs_low)
@@ -1834,10 +1834,8 @@ static void bcmgenet_intr_disable(struct bcmgenet_priv *priv)
 	/* Mask all interrupts.*/
 	bcmgenet_intrl2_0_writel(priv, 0xFFFFFFFF, INTRL2_CPU_MASK_SET);
 	bcmgenet_intrl2_0_writel(priv, 0xFFFFFFFF, INTRL2_CPU_CLEAR);
-	bcmgenet_intrl2_0_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
 	bcmgenet_intrl2_1_writel(priv, 0xFFFFFFFF, INTRL2_CPU_MASK_SET);
 	bcmgenet_intrl2_1_writel(priv, 0xFFFFFFFF, INTRL2_CPU_CLEAR);
-	bcmgenet_intrl2_1_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
 }
 
 static void bcmgenet_link_intr_enable(struct bcmgenet_priv *priv)
@@ -1926,7 +1924,6 @@ static int init_umac(struct bcmgenet_priv *priv)
 	bcmgenet_intrl2_0_writel(priv, int0_enable, INTRL2_CPU_MASK_CLEAR);
 	bcmgenet_intrl2_1_writel(priv, int1_enable, INTRL2_CPU_MASK_CLEAR);
 
-	/* Enable rx/tx engine.*/
 	dev_dbg(kdev, "done init umac\n");
 
 	return 0;
@@ -2836,7 +2833,7 @@ static int bcmgenet_close(struct net_device *dev)
 	if (ret)
 		return ret;
 
-	/* Disable MAC transmit. TX DMA disabled have to done before this */
+	/* Disable MAC transmit. TX DMA disabled must be done before this */
 	umac_enable_set(priv, CMD_TX_EN, false);
 
 	/* tx reclaim */
@@ -3115,22 +3112,18 @@ static void bcmgenet_set_hw_params(struct bcmgenet_priv *priv)
 		bcmgenet_dma_regs = bcmgenet_dma_regs_v3plus;
 		genet_dma_ring_regs = genet_dma_ring_regs_v4;
 		priv->dma_rx_chk_bit = DMA_RX_CHK_V3PLUS;
-		priv->version = GENET_V4;
 	} else if (GENET_IS_V3(priv)) {
 		bcmgenet_dma_regs = bcmgenet_dma_regs_v3plus;
 		genet_dma_ring_regs = genet_dma_ring_regs_v123;
 		priv->dma_rx_chk_bit = DMA_RX_CHK_V3PLUS;
-		priv->version = GENET_V3;
 	} else if (GENET_IS_V2(priv)) {
 		bcmgenet_dma_regs = bcmgenet_dma_regs_v2;
 		genet_dma_ring_regs = genet_dma_ring_regs_v123;
 		priv->dma_rx_chk_bit = DMA_RX_CHK_V12;
-		priv->version = GENET_V2;
 	} else if (GENET_IS_V1(priv)) {
 		bcmgenet_dma_regs = bcmgenet_dma_regs_v1;
 		genet_dma_ring_regs = genet_dma_ring_regs_v123;
 		priv->dma_rx_chk_bit = DMA_RX_CHK_V12;
-		priv->version = GENET_V1;
 	}
 
 	/* enum genet_version starts at 1 */
@@ -3397,7 +3390,7 @@ static int bcmgenet_suspend(struct device *d)
 	if (ret)
 		return ret;
 
-	/* Disable MAC transmit. TX DMA disabled have to done before this */
+	/* Disable MAC transmit. TX DMA disabled must be done before this */
 	umac_enable_set(priv, CMD_TX_EN, false);
 
 	/* tx reclaim */
-- 
2.11.1
