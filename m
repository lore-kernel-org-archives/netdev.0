From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH 3/4] stmmac: remove some __func__ printing
Date: Wed,  9 Sep 2015 15:14:15 +0200
Message-ID: <1441804456-15914-3-git-send-email-clabbe.montjoie@gmail.com>
References: <1441804456-15914-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	LABBE Corentin <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37372 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032AbbIINOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 09:14:52 -0400
In-Reply-To: <1441804456-15914-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that stmmac use dev_xxx, some __func__ are not necessary since their
use was to clearly identify which driver was logging.

This patch remove __func__ where such printing is useless.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 57 +++++++++--------------
 1 file changed, 21 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c1dc41b..5335bad 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -988,7 +988,7 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 	skb = __netdev_alloc_skb_ip_align(priv->dev, priv->dma_buf_sz, flags);
 	if (!skb) {
 		dev_err(priv->device,
-			"%s: Rx init fails; skb is NULL\n", __func__);
+			"Rx init fails; skb is NULL\n");
 		return -ENOMEM;
 	}
 	priv->rx_skbuff[i] = skb;
@@ -996,7 +996,7 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 						priv->dma_buf_sz,
 						DMA_FROM_DEVICE);
 	if (dma_mapping_error(priv->device, priv->rx_skbuff_dma[i])) {
-		dev_err(priv->device, "%s: DMA mapping error\n", __func__);
+		dev_err(priv->device, "DMA mapping error\n");
 		dev_kfree_skb_any(skb);
 		return -EINVAL;
 	}
@@ -1709,8 +1709,7 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	/* DMA initialization and SW reset */
 	ret = stmmac_init_dma_engine(priv);
 	if (ret < 0) {
-		dev_err(priv->device, "%s: DMA engine initialization failed\n",
-			__func__);
+		dev_err(priv->device, "DMA engine initialization failed\n");
 		return ret;
 	}
 
@@ -1742,15 +1741,13 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	if (init_ptp) {
 		ret = stmmac_init_ptp(priv);
 		if (ret && ret != -EOPNOTSUPP)
-			dev_warn(priv->device, "%s: failed PTP initialisation\n",
-				 __func__);
+			dev_warn(priv->device, "failed PTP initialisation\n");
 	}
 
 #ifdef CONFIG_DEBUG_FS
 	ret = stmmac_init_fs(dev);
 	if (ret < 0)
-		dev_warn(priv->device, "%s: failed debugFS registration\n",
-			 __func__);
+		dev_warn(priv->device, "failed debugFS registration\n");
 #endif
 	/* Start the ball rolling... */
 	dev_dbg(priv->device, "%s: DMA RX/TX processes started...\n",
@@ -1797,8 +1794,7 @@ static int stmmac_open(struct net_device *dev)
 		ret = stmmac_init_phy(dev);
 		if (ret) {
 			dev_err(priv->device,
-				"%s: Cannot attach to PHY (error: %d)\n",
-			       __func__, ret);
+				"Cannot attach to PHY (error: %d)\n", ret);
 			return ret;
 		}
 	}
@@ -1814,22 +1810,19 @@ static int stmmac_open(struct net_device *dev)
 
 	ret = alloc_dma_desc_resources(priv);
 	if (ret < 0) {
-		dev_err(priv->device, "%s: DMA descriptors allocation failed\n",
-			__func__);
+		dev_err(priv->device, "DMA descriptors allocation failed\n");
 		goto dma_desc_error;
 	}
 
 	ret = init_dma_desc_rings(dev, GFP_KERNEL);
 	if (ret < 0) {
-		dev_err(priv->device,
-			"%s: DMA descriptors initialization failed\n",
-			__func__);
+		dev_err(priv->device, "DMA descriptors initialization failed\n");
 		goto init_error;
 	}
 
 	ret = stmmac_hw_setup(dev, true);
 	if (ret < 0) {
-		dev_err(priv->device, "%s: Hw setup failed\n", __func__);
+		dev_err(priv->device, "Hw setup failed\n");
 		goto init_error;
 	}
 
@@ -1842,9 +1835,8 @@ static int stmmac_open(struct net_device *dev)
 	ret = request_irq(dev->irq, stmmac_interrupt,
 			  IRQF_SHARED, dev->name, dev);
 	if (unlikely(ret < 0)) {
-		dev_err(priv->device,
-			"%s: ERROR: allocating the IRQ %d (error: %d)\n",
-		       __func__, dev->irq, ret);
+		dev_err(priv->device, "ERROR: allocating the IRQ %d (error: %d)\n",
+			dev->irq, ret);
 		goto init_error;
 	}
 
@@ -1853,9 +1845,8 @@ static int stmmac_open(struct net_device *dev)
 		ret = request_irq(priv->wol_irq, stmmac_interrupt,
 				  IRQF_SHARED, dev->name, dev);
 		if (unlikely(ret < 0)) {
-			dev_err(priv->device,
-				"%s: ERROR: allocating the WoL IRQ %d (%d)\n",
-			       __func__, priv->wol_irq, ret);
+			dev_err(priv->device, "ERROR: allocating the WoL IRQ %d (%d)\n",
+				priv->wol_irq, ret);
 			goto wolirq_error;
 		}
 	}
@@ -1865,9 +1856,8 @@ static int stmmac_open(struct net_device *dev)
 		ret = request_irq(priv->lpi_irq, stmmac_interrupt, IRQF_SHARED,
 				  dev->name, dev);
 		if (unlikely(ret < 0)) {
-			dev_err(priv->device,
-				"%s: ERROR: allocating the LPI IRQ %d (%d)\n",
-			       __func__, priv->lpi_irq, ret);
+			dev_err(priv->device, "ERROR: allocating the LPI IRQ %d (%d)\n",
+				priv->lpi_irq, ret);
 			goto lpiirq_error;
 		}
 	}
@@ -1972,9 +1962,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (!netif_queue_stopped(dev)) {
 			netif_stop_queue(dev);
 			/* This is a hard error, log it. */
-			dev_err(priv->device,
-				"%s: Tx Ring full when queue awake\n",
-				__func__);
+			dev_err(priv->device, "Tx Ring full when queue awake\n");
 		}
 		return NETDEV_TX_BUSY;
 	}
@@ -2881,8 +2869,7 @@ int stmmac_dvr_probe(struct device *device,
 
 	priv->stmmac_clk = devm_clk_get(priv->device, STMMAC_RESOURCE_NAME);
 	if (IS_ERR(priv->stmmac_clk)) {
-		dev_warn(priv->device, "%s: warning: cannot get CSR clock\n",
-			 __func__);
+		dev_warn(priv->device, "warning: cannot get CSR clock\n");
 		/* If failed to obtain stmmac_clk and specific clk_csr value
 		 * is NOT passed from the platform, probe fail.
 		 */
@@ -2955,8 +2942,7 @@ int stmmac_dvr_probe(struct device *device,
 
 	ret = register_netdev(ndev);
 	if (ret) {
-		dev_err(priv->device, "%s: ERROR %i registering the device\n",
-			__func__, ret);
+		dev_err(priv->device, "ERROR %i registering the device\n", ret);
 		goto error_netdev_register;
 	}
 
@@ -2978,9 +2964,8 @@ int stmmac_dvr_probe(struct device *device,
 		/* MDIO bus Registration */
 		ret = stmmac_mdio_register(ndev);
 		if (ret < 0) {
-			dev_err(priv->device,
-				"%s: MDIO bus (id: %d) registration failed",
-				 __func__, priv->plat->bus_id);
+			dev_err(priv->device, "MDIO bus (id: %d) registration failed",
+				priv->plat->bus_id);
 			goto error_mdio_register;
 		}
 	}
@@ -3012,7 +2997,7 @@ int stmmac_dvr_remove(struct net_device *ndev)
 {
 	struct stmmac_priv *priv = netdev_priv(ndev);
 
-	dev_info(priv->device, "%s: removing driver", __func__);
+	dev_info(priv->device, "removing driver");
 
 	priv->hw->dma->stop_rx(priv->ioaddr);
 	priv->hw->dma->stop_tx(priv->ioaddr);
-- 
2.4.6
