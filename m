From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 3/5] stmmac: remove some __func__ printing
Date: Thu, 10 Sep 2015 14:37:31 +0200
Message-ID: <1441888653-30535-4-git-send-email-clabbe.montjoie@gmail.com>
References: <1441888653-30535-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com, LABBE Corentin <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441888653-30535-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that stmmac use netdev_xxx, some __func__ are not necessary since their
use was to clearly identify which driver was logging.

This patch remove __func__ where such printing is useless.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 52 +++++++++--------------
 1 file changed, 21 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index b016f04..c3ec169 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -987,8 +987,7 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 
 	skb = __netdev_alloc_skb_ip_align(priv->dev, priv->dma_buf_sz, flags);
 	if (!skb) {
-		netdev_err(priv->dev,
-			   "%s: Rx init fails; skb is NULL\n", __func__);
+		netdev_err(priv->dev, "Rx init fails; skb is NULL\n");
 		return -ENOMEM;
 	}
 	priv->rx_skbuff[i] = skb;
@@ -996,7 +995,7 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 						priv->dma_buf_sz,
 						DMA_FROM_DEVICE);
 	if (dma_mapping_error(priv->device, priv->rx_skbuff_dma[i])) {
-		netdev_err(priv->dev, "%s: DMA mapping error\n", __func__);
+		netdev_err(priv->dev, "DMA mapping error\n");
 		dev_kfree_skb_any(skb);
 		return -EINVAL;
 	}
@@ -1710,8 +1709,7 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	/* DMA initialization and SW reset */
 	ret = stmmac_init_dma_engine(priv);
 	if (ret < 0) {
-		netdev_err(priv->dev, "%s: DMA engine initialization failed\n",
-			   __func__);
+		netdev_err(priv->dev, "DMA engine initialization failed\n");
 		return ret;
 	}
 
@@ -1743,15 +1741,13 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	if (init_ptp) {
 		ret = stmmac_init_ptp(priv);
 		if (ret && ret != -EOPNOTSUPP)
-			netdev_warn(priv->dev, "%s: failed PTP initialisation\n",
-				    __func__);
+			netdev_warn(priv->dev, "failed PTP initialisation\n");
 	}
 
 #ifdef CONFIG_DEBUG_FS
 	ret = stmmac_init_fs(dev);
 	if (ret < 0)
-		netdev_warn(priv->dev, "%s: failed debugFS registration\n",
-			    __func__);
+		netdev_warn(priv->dev, "failed debugFS registration\n");
 #endif
 	/* Start the ball rolling... */
 	netdev_dbg(priv->dev, "%s: DMA RX/TX processes started...\n",
@@ -1798,8 +1794,7 @@ static int stmmac_open(struct net_device *dev)
 		ret = stmmac_init_phy(dev);
 		if (ret) {
 			netdev_err(priv->dev,
-				   "%s: Cannot attach to PHY (error: %d)\n",
-				   __func__, ret);
+				   "Cannot attach to PHY (error: %d)\n", ret);
 			return ret;
 		}
 	}
@@ -1815,21 +1810,19 @@ static int stmmac_open(struct net_device *dev)
 
 	ret = alloc_dma_desc_resources(priv);
 	if (ret < 0) {
-		netdev_err(priv->dev, "%s: DMA descriptors allocation failed\n"
-			   __func__);
+		netdev_err(priv->dev, "DMA descriptors allocation failed\n");
 		goto dma_desc_error;
 	}
 
 	ret = init_dma_desc_rings(dev, GFP_KERNEL);
 	if (ret < 0) {
-		netdev_err(priv->dev, "%s: DMA descriptors initialization failed\n",
-			   __func__);
+		netdev_err(priv->dev, "DMA descriptors initialization failed\n");
 		goto init_error;
 	}
 
 	ret = stmmac_hw_setup(dev, true);
 	if (ret < 0) {
-		netdev_err(priv->dev, "%s: Hw setup failed\n", __func__);
+		netdev_err(priv->dev, "Hw setup failed\n");
 		goto init_error;
 	}
 
@@ -1843,8 +1836,8 @@ static int stmmac_open(struct net_device *dev)
 			  IRQF_SHARED, dev->name, dev);
 	if (unlikely(ret < 0)) {
 		netdev_err(priv->dev,
-			   "%s: ERROR: allocating the IRQ %d (error: %d)\n",
-			   __func__, dev->irq, ret);
+			   "ERROR: allocating the IRQ %d (error: %d)\n",
+			   dev->irq, ret);
 		goto init_error;
 	}
 
@@ -1854,8 +1847,8 @@ static int stmmac_open(struct net_device *dev)
 				  IRQF_SHARED, dev->name, dev);
 		if (unlikely(ret < 0)) {
 			netdev_err(priv->dev,
-				   "%s: ERROR: allocating the WoL IRQ %d (%d)\n",
-				   __func__, priv->wol_irq, ret);
+				   "ERROR: allocating the WoL IRQ %d (%d)\n",
+				   priv->wol_irq, ret);
 			goto wolirq_error;
 		}
 	}
@@ -1866,8 +1859,8 @@ static int stmmac_open(struct net_device *dev)
 				  dev->name, dev);
 		if (unlikely(ret < 0)) {
 			netdev_err(priv->dev,
-				   "%s: ERROR: allocating the LPI IRQ %d (%d)\n",
-				   __func__, priv->lpi_irq, ret);
+				   "ERROR: allocating the LPI IRQ %d (%d)\n",
+				   priv->lpi_irq, ret);
 			goto lpiirq_error;
 		}
 	}
@@ -1973,8 +1966,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 			netif_stop_queue(dev);
 			/* This is a hard error, log it. */
 			netdev_err(priv->dev,
-				   "%s: Tx Ring full when queue awake\n",
-				   __func__);
+				   "Tx Ring full when queue awake\n");
 		}
 		return NETDEV_TX_BUSY;
 	}
@@ -2882,8 +2874,7 @@ int stmmac_dvr_probe(struct device *device,
 
 	priv->stmmac_clk = devm_clk_get(priv->device, STMMAC_RESOURCE_NAME);
 	if (IS_ERR(priv->stmmac_clk)) {
-		netdev_warn(priv->dev, "%s: warning: cannot get CSR clock\n",
-			    __func__);
+		netdev_warn(priv->dev, "warning: cannot get CSR clock\n");
 		/* If failed to obtain stmmac_clk and specific clk_csr value
 		 * is NOT passed from the platform, probe fail.
 		 */
@@ -2956,8 +2947,7 @@ int stmmac_dvr_probe(struct device *device,
 
 	ret = register_netdev(ndev);
 	if (ret) {
-		netdev_err(priv->dev, "%s: ERROR %i registering the device\n",
-			   __func__, ret);
+		netdev_err(priv->dev, "ERROR %i registering the device\n", ret);
 		goto error_netdev_register;
 	}
 
@@ -2980,8 +2970,8 @@ int stmmac_dvr_probe(struct device *device,
 		ret = stmmac_mdio_register(ndev);
 		if (ret < 0) {
 			netdev_err(priv->dev,
-				   "%s: MDIO bus (id: %d) registration failed",
-				   __func__, priv->plat->bus_id);
+				   "MDIO bus (id: %d) registration failed",
+				   priv->plat->bus_id);
 			goto error_mdio_register;
 		}
 	}
@@ -3013,7 +3003,7 @@ int stmmac_dvr_remove(struct net_device *ndev)
 {
 	struct stmmac_priv *priv = netdev_priv(ndev);
 
-	netdev_info(priv->dev, "%s: removing driver", __func__);
+	netdev_info(priv->dev, "removing driver");
 
 	priv->hw->dma->stop_rx(priv->ioaddr);
 	priv->hw->dma->stop_tx(priv->ioaddr);
-- 
2.4.6
