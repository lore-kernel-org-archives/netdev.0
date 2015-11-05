From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH v4 3/5] net: stmmac: remove some __func__ printing
Date: Thu,  5 Nov 2015 14:14:10 +0100
Message-ID: <1446729252-9160-4-git-send-email-clabbe.montjoie@gmail.com>
References: <1446729252-9160-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	LABBE Corentin <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446729252-9160-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that stmmac use netdev_xxx, some __func__ are not necessary since their
use was to clearly identify which driver was logging.
Moreover, as pointed by Joe Perches, using __func__ in xxx_dbg functions
is relatively low value and dynamic debug can add it.

This patch remove __func__ where such printing is useless.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 81 ++++++++++-------------
 1 file changed, 34 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 911cf28..f096416 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -448,8 +448,8 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			   sizeof(struct hwtstamp_config)))
 		return -EFAULT;
 
-	netdev_dbg(priv->dev, "%s config flags:0x%x, tx_type:0x%x, rx_filter:0x%x\n",
-		   __func__, config.flags, config.tx_type, config.rx_filter);
+	netdev_dbg(priv->dev, "config flags:0x%x, tx_type:0x%x, rx_filter:0x%x\n",
+		   config.flags, config.tx_type, config.rx_filter);
 
 	/* reserved for future extensions */
 	if (config.flags)
@@ -833,8 +833,7 @@ static int stmmac_init_phy(struct net_device *dev)
 
 		snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
 			 priv->plat->phy_addr);
-		netdev_dbg(priv->dev, "%s: trying to attach to %s\n", __func__,
-			   phy_id_fmt);
+		netdev_dbg(priv->dev, "trying to attach to %s\n", phy_id_fmt);
 
 		phydev = phy_connect(dev, phy_id_fmt, &stmmac_adjust_link,
 				     interface);
@@ -991,8 +990,7 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 
 	skb = __netdev_alloc_skb_ip_align(priv->dev, priv->dma_buf_sz, flags);
 	if (!skb) {
-		netdev_err(priv->dev,
-			   "%s: Rx init fails; skb is NULL\n", __func__);
+		netdev_err(priv->dev, "Rx init fails; skb is NULL\n");
 		return -ENOMEM;
 	}
 	priv->rx_skbuff[i] = skb;
@@ -1000,7 +998,7 @@ static int stmmac_init_rx_buffers(struct stmmac_priv *priv, struct dma_desc *p,
 						priv->dma_buf_sz,
 						DMA_FROM_DEVICE);
 	if (dma_mapping_error(priv->device, priv->rx_skbuff_dma[i])) {
-		netdev_err(priv->dev, "%s: DMA mapping error\n", __func__);
+		netdev_err(priv->dev, "DMA mapping error\n");
 		dev_kfree_skb_any(skb);
 		return -EINVAL;
 	}
@@ -1050,8 +1048,8 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 	priv->dma_buf_sz = bfsize;
 
 	if (netif_msg_probe(priv))
-		netdev_dbg(priv->dev, "%s: txsize %d, rxsize %d, bfsize %d\n",
-			   __func__, txsize, rxsize, bfsize);
+		netdev_dbg(priv->dev, "txsize %d, rxsize %d, bfsize %d\n",
+			   txsize, rxsize, bfsize);
 
 	if (netif_msg_probe(priv)) {
 		netdev_dbg(priv->dev, "(%s) dma_rx_phy=0x%08x dma_tx_phy=0x%08x\n",
@@ -1357,8 +1355,8 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 			stmmac_get_tx_hwtstamp(priv, entry, skb);
 		}
 		if (netif_msg_tx_done(priv))
-			netdev_dbg(priv->dev, "%s: curr %d, dirty %d\n",
-				   __func__, priv->cur_tx, priv->dirty_tx);
+			netdev_dbg(priv->dev, "curr %d, dirty %d\n",
+				   priv->cur_tx, priv->dirty_tx);
 
 		if (likely(priv->tx_skbuff_dma[entry].buf)) {
 			if (priv->tx_skbuff_dma[entry].map_as_page)
@@ -1396,8 +1394,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		if (netif_queue_stopped(priv->dev) &&
 		    stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv)) {
 			if (netif_msg_tx_done(priv))
-				netdev_dbg(priv->dev, "%s: restart transmit\n",
-					   __func__);
+				netdev_dbg(priv->dev, "restart transmit\n");
 			netif_wake_queue(priv->dev);
 		}
 		netif_tx_unlock(priv->dev);
@@ -1714,8 +1711,7 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	/* DMA initialization and SW reset */
 	ret = stmmac_init_dma_engine(priv);
 	if (ret < 0) {
-		netdev_err(priv->dev, "%s: DMA engine initialization failed\n",
-			   __func__);
+		netdev_err(priv->dev, "DMA engine initialization failed\n");
 		return ret;
 	}
 
@@ -1747,15 +1743,13 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
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
 	netdev_dbg(priv->dev, "DMA RX/TX processes started...\n");
@@ -1801,8 +1795,7 @@ static int stmmac_open(struct net_device *dev)
 		ret = stmmac_init_phy(dev);
 		if (ret) {
 			netdev_err(priv->dev,
-				   "%s: Cannot attach to PHY (error: %d)\n",
-				   __func__, ret);
+				   "Cannot attach to PHY (error: %d)\n", ret);
 			return ret;
 		}
 	}
@@ -1818,21 +1811,19 @@ static int stmmac_open(struct net_device *dev)
 
 	ret = alloc_dma_desc_resources(priv);
 	if (ret < 0) {
-		netdev_err(priv->dev, "%s: DMA descriptors allocation failed\n",
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
 
@@ -1846,8 +1837,8 @@ static int stmmac_open(struct net_device *dev)
 			  IRQF_SHARED, dev->name, dev);
 	if (unlikely(ret < 0)) {
 		netdev_err(priv->dev,
-			   "%s: ERROR: allocating the IRQ %d (error: %d)\n",
-			   __func__, dev->irq, ret);
+			   "ERROR: allocating the IRQ %d (error: %d)\n",
+			   dev->irq, ret);
 		goto init_error;
 	}
 
@@ -1857,8 +1848,8 @@ static int stmmac_open(struct net_device *dev)
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
@@ -1869,8 +1860,8 @@ static int stmmac_open(struct net_device *dev)
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
@@ -1976,8 +1967,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 			netif_stop_queue(dev);
 			/* This is a hard error, log it. */
 			netdev_err(priv->dev,
-				   "%s: Tx Ring full when queue awake\n",
-				   __func__);
+				   "Tx Ring full when queue awake\n");
 		}
 		return NETDEV_TX_BUSY;
 	}
@@ -2067,9 +2057,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (netif_msg_pktdata(priv)) {
 		netdev_dbg(priv->dev,
-			   "%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
-			   __func__, (priv->cur_tx % txsize),
-			(priv->dirty_tx % txsize), entry, first, nfrags);
+			   "curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
+			   (priv->cur_tx % txsize),
+			   (priv->dirty_tx % txsize), entry, first, nfrags);
 
 		if (priv->extend_desc)
 			stmmac_display_ring((void *)priv->dma_etx, txsize, 1);
@@ -2081,8 +2071,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	if (unlikely(stmmac_tx_avail(priv) <= (MAX_SKB_FRAGS + 1))) {
 		if (netif_msg_hw(priv))
-			netdev_dbg(priv->dev,
-				   "%s: stop transmitted packets\n", __func__);
+			netdev_dbg(priv->dev, "stop transmitted packets\n");
 		netif_stop_queue(dev);
 	}
 
@@ -2197,7 +2186,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 	int coe = priv->hw->rx_csum;
 
 	if (netif_msg_rx_status(priv)) {
-		netdev_dbg(priv->dev, "%s: descriptor ring:\n", __func__);
+		netdev_dbg(priv->dev, "descriptor ring:\n");
 		if (priv->extend_desc)
 			stmmac_display_ring((void *)priv->dma_erx, rxsize, 1);
 		else
@@ -2881,8 +2870,7 @@ int stmmac_dvr_probe(struct device *device,
 
 	priv->stmmac_clk = devm_clk_get(priv->device, STMMAC_RESOURCE_NAME);
 	if (IS_ERR(priv->stmmac_clk)) {
-		netdev_warn(priv->dev, "%s: warning: cannot get CSR clock\n",
-			    __func__);
+		netdev_warn(priv->dev, "warning: cannot get CSR clock\n");
 		/* If failed to obtain stmmac_clk and specific clk_csr value
 		 * is NOT passed from the platform, probe fail.
 		 */
@@ -2955,8 +2943,7 @@ int stmmac_dvr_probe(struct device *device,
 
 	ret = register_netdev(ndev);
 	if (ret) {
-		netdev_err(priv->dev, "%s: ERROR %i registering the device\n",
-			   __func__, ret);
+		netdev_err(priv->dev, "ERROR %i registering the device\n", ret);
 		goto error_netdev_register;
 	}
 
@@ -2979,8 +2966,8 @@ int stmmac_dvr_probe(struct device *device,
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
@@ -3012,7 +2999,7 @@ int stmmac_dvr_remove(struct net_device *ndev)
 {
 	struct stmmac_priv *priv = netdev_priv(ndev);
 
-	netdev_info(priv->dev, "%s: removing driver", __func__);
+	netdev_info(priv->dev, "removing driver");
 
 	priv->hw->dma->stop_rx(priv->ioaddr);
 	priv->hw->dma->stop_tx(priv->ioaddr);
-- 
2.4.10
