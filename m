From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/5] samsung: xgmac: Neatening
Date: Wed,  5 Mar 2014 11:20:15 -0800
Message-ID: <5c9d68da4f153eaea52ff5d84c56c2749704fc4a.1394046997.git.joe@perches.com>
References: <cover.1394046997.git.joe@perches.com>
Cc: linux-samsung-soc@vger.kernel.org, davem@davemloft.net,
	siva.kallam@samsung.com, vipul.pandya@samsung.com,
	ks.giri@samsung.com, ilho215.lee@samsung.com,
	netdev@vger.kernel.org
To: Byungho An <bh74.an@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0054.hostedemail.com ([216.40.44.54]:44197 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756496AbaCETU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 14:20:26 -0500
In-Reply-To: <cover.1394046997.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quiet checkpatch noise:
o Multi-line statement alignment
o Add braces
o Move logical continuations
o Remove externs from .h
o Remove unnecessary blank lines around braces

Typo fixes where noticed.
Change logic to return first to reduce indentation.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/samsung/xgmac_common.h  | 24 ++++----
 drivers/net/ethernet/samsung/xgmac_desc.c    |  4 --
 drivers/net/ethernet/samsung/xgmac_dma.c     | 32 +++++-----
 drivers/net/ethernet/samsung/xgmac_ethtool.c | 67 ++++++++++----------
 drivers/net/ethernet/samsung/xgmac_main.c    | 92 +++++++++++++---------------
 drivers/net/ethernet/samsung/xgmac_mdio.c    | 13 ++--
 drivers/net/ethernet/samsung/xgmac_mtl.c     |  4 +-
 7 files changed, 115 insertions(+), 121 deletions(-)

diff --git a/drivers/net/ethernet/samsung/xgmac_common.h b/drivers/net/ethernet/samsung/xgmac_common.h
index 4932824..4c46504 100644
--- a/drivers/net/ethernet/samsung/xgmac_common.h
+++ b/drivers/net/ethernet/samsung/xgmac_common.h
@@ -544,24 +544,24 @@ struct xgmac_priv_data {
 };
 
 /* Function prototypes */
-extern struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
+struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
 					struct xgmac_plat_data *plat_dat,
 					void __iomem *addr);
-extern int xgmac_dvr_remove(struct net_device *ndev);
-extern void xgmac_set_ethtool_ops(struct net_device *netdev);
-extern int xgmac_mdio_unregister(struct net_device *ndev);
-extern int xgmac_mdio_register(struct net_device *ndev);
-extern int xgmac_register_platform(void);
-extern void xgmac_unregister_platform(void);
+int xgmac_dvr_remove(struct net_device *ndev);
+void xgmac_set_ethtool_ops(struct net_device *netdev);
+int xgmac_mdio_unregister(struct net_device *ndev);
+int xgmac_mdio_register(struct net_device *ndev);
+int xgmac_register_platform(void);
+void xgmac_unregister_platform(void);
 
 #ifdef CONFIG_PM
-extern int xgmac_suspend(struct net_device *ndev);
-extern int xgmac_resume(struct net_device *ndev);
-extern int xgmac_freeze(struct net_device *ndev);
-extern int xgmac_restore(struct net_device *ndev);
+int xgmac_suspend(struct net_device *ndev);
+int xgmac_resume(struct net_device *ndev);
+int xgmac_freeze(struct net_device *ndev);
+int xgmac_restore(struct net_device *ndev);
 #endif /* CONFIG_PM */
 
-extern const struct xgmac_mtl_ops *xgmac_get_mtl_ops(void);
+const struct xgmac_mtl_ops *xgmac_get_mtl_ops(void);
 
 void xgmac_disable_eee_mode(struct xgmac_priv_data * const priv);
 bool xgmac_eee_init(struct xgmac_priv_data * const priv);
diff --git a/drivers/net/ethernet/samsung/xgmac_desc.c b/drivers/net/ethernet/samsung/xgmac_desc.c
index c5417de..ddf3e94 100644
--- a/drivers/net/ethernet/samsung/xgmac_desc.c
+++ b/drivers/net/ethernet/samsung/xgmac_desc.c
@@ -196,7 +196,6 @@ static void xgmac_tx_ctxt_desc_set_tstamp(struct xgmac_tx_ctxt_desc *p,
 		p->tstamp_lo = (u32) tstamp;
 		p->tstamp_hi = (u32) (tstamp>>32);
 	}
-
 }
 /* Close TX context descriptor */
 static void xgmac_tx_ctxt_desc_close(struct xgmac_tx_ctxt_desc *p)
@@ -217,7 +216,6 @@ static void xgmac_init_rx_desc(struct xgmac_rx_norm_desc *p, int disable_rx_ic,
 	p->rdes23.rx_rd_des23.own_bit = 1;
 	if (disable_rx_ic)
 		p->rdes23.rx_rd_des23.int_on_com = disable_rx_ic;
-
 }
 
 /* Get RX own bit */
@@ -337,7 +335,6 @@ static int xgmac_rx_wbstatus(struct xgmac_rx_norm_desc *p,
 			pr_err("\tInvalid L2 Packet type\n");
 			break;
 		}
-
 	}
 
 	/* L3/L4 Pkt type */
@@ -443,7 +440,6 @@ static void xgmac_rx_ctxt_wbstatus(struct xgmac_rx_ctxt_desc *p,
 		x->rx_ptp_signal++;
 	else if (p->ptp_msgtype == RX_PTP_RESV_MSG)
 		x->rx_ptp_resv_msg_type++;
-
 }
 
 /* get rx timestamp status */
diff --git a/drivers/net/ethernet/samsung/xgmac_dma.c b/drivers/net/ethernet/samsung/xgmac_dma.c
index 47945a3..384866c 100644
--- a/drivers/net/ethernet/samsung/xgmac_dma.c
+++ b/drivers/net/ethernet/samsung/xgmac_dma.c
@@ -85,14 +85,14 @@ static void xgmac_dma_channel_init(void __iomem *ioaddr, int cha_num,
 
 	/* program desc registers */
 	writel((dma_tx >> 32),
-			ioaddr + XGMAC_DMA_CHA_TXDESC_HADD_REG(cha_num));
+	       ioaddr + XGMAC_DMA_CHA_TXDESC_HADD_REG(cha_num));
 	writel((dma_tx & 0xFFFFFFFF),
-			ioaddr + XGMAC_DMA_CHA_TXDESC_LADD_REG(cha_num));
+	       ioaddr + XGMAC_DMA_CHA_TXDESC_LADD_REG(cha_num));
 
 	writel((dma_rx >> 32),
-			ioaddr + XGMAC_DMA_CHA_RXDESC_HADD_REG(cha_num));
+	       ioaddr + XGMAC_DMA_CHA_RXDESC_HADD_REG(cha_num));
 	writel((dma_rx & 0xFFFFFFFF),
-			ioaddr + XGMAC_DMA_CHA_RXDESC_LADD_REG(cha_num));
+	       ioaddr + XGMAC_DMA_CHA_RXDESC_LADD_REG(cha_num));
 
 	/* program tail pointers */
 	/* assumption: upper 32 bits are constant and
@@ -100,18 +100,18 @@ static void xgmac_dma_channel_init(void __iomem *ioaddr, int cha_num,
 	 */
 	dma_addr = dma_tx + ((t_rsize-1) * XGMAC_DESC_SIZE_BYTES);
 	writel((dma_addr & 0xFFFFFFFF),
-			ioaddr + XGMAC_DMA_CHA_TXDESC_TAILPTR_REG(cha_num));
+	       ioaddr + XGMAC_DMA_CHA_TXDESC_TAILPTR_REG(cha_num));
 
 	dma_addr = dma_rx + ((r_rsize-1) * XGMAC_DESC_SIZE_BYTES);
 	writel((dma_addr & 0xFFFFFFFF),
-			ioaddr + XGMAC_DMA_CHA_RXDESC_LADD_REG(cha_num));
+	       ioaddr + XGMAC_DMA_CHA_RXDESC_LADD_REG(cha_num));
 	/* program the ring sizes */
 	writel(t_rsize-1, ioaddr + XGMAC_DMA_CHA_TXDESC_RINGLEN_REG(cha_num));
 	writel(r_rsize-1, ioaddr + XGMAC_DMA_CHA_RXDESC_RINGLEN_REG(cha_num));
 
 	/* Enable TX/RX interrupts */
 	writel(XGMAC_DMA_ENA_INT,
-			ioaddr + XGMAC_DMA_CHA_INT_ENABLE_REG(cha_num));
+	       ioaddr + XGMAC_DMA_CHA_INT_ENABLE_REG(cha_num));
 }
 
 static void xgmac_enable_dma_transmission(void __iomem *ioaddr, int cha_num)
@@ -126,7 +126,7 @@ static void xgmac_enable_dma_irq(void __iomem *ioaddr, int dma_cnum)
 {
 	/* Enable TX/RX interrupts */
 	writel(XGMAC_DMA_ENA_INT,
-			ioaddr + XGMAC_DMA_CHA_INT_ENABLE_REG(dma_cnum));
+	       ioaddr + XGMAC_DMA_CHA_INT_ENABLE_REG(dma_cnum));
 }
 
 static void xgmac_disable_dma_irq(void __iomem *ioaddr, int dma_cnum)
@@ -144,7 +144,7 @@ static void xgmac_dma_start_tx(void __iomem *ioaddr, int tchannels)
 		tx_ctl_reg = readl(ioaddr + XGMAC_DMA_CHA_TXCTL_REG(cnum));
 		tx_ctl_reg |= XGMAC_TX_ENABLE;
 		writel(tx_ctl_reg,
-			ioaddr + XGMAC_DMA_CHA_TXCTL_REG(cnum));
+		       ioaddr + XGMAC_DMA_CHA_TXCTL_REG(cnum));
 	}
 }
 
@@ -187,7 +187,7 @@ static void xgmac_dma_start_rx(void __iomem *ioaddr, int rchannels)
 		rx_ctl_reg = readl(ioaddr + XGMAC_DMA_CHA_RXCTL_REG(cnum));
 		rx_ctl_reg |= XGMAC_RX_ENABLE;
 		writel(rx_ctl_reg,
-			ioaddr + XGMAC_DMA_CHA_RXCTL_REG(cnum));
+		       ioaddr + XGMAC_DMA_CHA_RXCTL_REG(cnum));
 	}
 }
 
@@ -245,14 +245,16 @@ static int xgmac_tx_dma_int_status(void __iomem *ioaddr, int channel_no,
 			if (int_status & XGMAC_DMA_INT_STATUS_TEB0) {
 				x->tx_read_transfer_err++;
 				clear_val |= XGMAC_DMA_INT_STATUS_TEB0;
-			} else
+			} else {
 				x->tx_write_transfer_err++;
+			}
 
 			if (int_status & XGMAC_DMA_INT_STATUS_TEB1) {
 				x->tx_desc_access_err++;
 				clear_val |= XGMAC_DMA_INT_STATUS_TEB1;
-			} else
+			} else {
 				 x->tx_buffer_access_err++;
+			}
 
 			if (int_status & XGMAC_DMA_INT_STATUS_TEB2) {
 				x->tx_data_transfer_err++;
@@ -315,14 +317,16 @@ static int xgmac_rx_dma_int_status(void __iomem *ioaddr, int channel_no,
 			if (int_status & XGMAC_DMA_INT_STATUS_REB0) {
 				x->rx_read_transfer_err++;
 				clear_val |= XGMAC_DMA_INT_STATUS_REB0;
-			} else
+			} else {
 				x->rx_write_transfer_err++;
+			}
 
 			if (int_status & XGMAC_DMA_INT_STATUS_REB1) {
 				x->rx_desc_access_err++;
 				clear_val |= XGMAC_DMA_INT_STATUS_REB1;
-			} else
+			} else {
 				 x->rx_buffer_access_err++;
+			}
 
 			if (int_status & XGMAC_DMA_INT_STATUS_REB2) {
 				x->rx_data_transfer_err++;
diff --git a/drivers/net/ethernet/samsung/xgmac_ethtool.c b/drivers/net/ethernet/samsung/xgmac_ethtool.c
index 74af3865..3f0698a 100644
--- a/drivers/net/ethernet/samsung/xgmac_ethtool.c
+++ b/drivers/net/ethernet/samsung/xgmac_ethtool.c
@@ -152,9 +152,9 @@ static int xgmac_set_eee(struct net_device *dev,
 
 	priv->eee_enabled = edata->eee_enabled;
 
-	if (!priv->eee_enabled)
+	if (!priv->eee_enabled) {
 		xgmac_disable_eee_mode(priv);
-	else {
+	} else {
 		/* We are asking for enabling the EEE but it is safe
 		 * to verify all by invoking the eee_init function.
 		 * In case of failure it will return an error.
@@ -251,7 +251,6 @@ static void xgmac_setmsglevel(struct net_device *dev, u32 level)
 {
 	struct xgmac_priv_data *priv = netdev_priv(dev);
 	priv->msg_enable = level;
-
 }
 
 static int xgmac_get_ts_info(struct net_device *dev,
@@ -259,38 +258,38 @@ static int xgmac_get_ts_info(struct net_device *dev,
 {
 	struct xgmac_priv_data *priv = netdev_priv(dev);
 
-	if (priv->hw_cap.atime_stamp) {
-
-		info->so_timestamping = SOF_TIMESTAMPING_TX_SOFTWARE |
-					SOF_TIMESTAMPING_RX_SOFTWARE |
-					SOF_TIMESTAMPING_SOFTWARE |
-					SOF_TIMESTAMPING_TX_HARDWARE |
-					SOF_TIMESTAMPING_RX_HARDWARE |
-					SOF_TIMESTAMPING_RAW_HARDWARE;
-
-		if (priv->ptp_clock)
-			info->phc_index = ptp_clock_index(priv->ptp_clock);
-
-		info->tx_types = (1 << HWTSTAMP_TX_OFF) | (1 << HWTSTAMP_TX_ON)
-				 | (1 << HWTSTAMP_TX_ONESTEP_SYNC);
-
-		info->rx_filters = ((1 << HWTSTAMP_FILTER_NONE) |
-				    (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
-				    (1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
-				    (1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
-				    (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
-				    (1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
-				    (1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ) |
-				    (1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
-				    (1 << HWTSTAMP_FILTER_PTP_V2_L2_SYNC) |
-				    (1 << HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ) |
-				    (1 << HWTSTAMP_FILTER_PTP_V2_EVENT) |
-				    (1 << HWTSTAMP_FILTER_PTP_V2_SYNC) |
-				    (1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ) |
-				    (1 << HWTSTAMP_FILTER_ALL));
-		return 0;
-	} else
+	if (!priv->hw_cap.atime_stamp)
 		return ethtool_op_get_ts_info(dev, info);
+
+	info->so_timestamping = (SOF_TIMESTAMPING_TX_SOFTWARE |
+				 SOF_TIMESTAMPING_RX_SOFTWARE |
+				 SOF_TIMESTAMPING_SOFTWARE |
+				 SOF_TIMESTAMPING_TX_HARDWARE |
+				 SOF_TIMESTAMPING_RX_HARDWARE |
+				 SOF_TIMESTAMPING_RAW_HARDWARE);
+
+	if (priv->ptp_clock)
+		info->phc_index = ptp_clock_index(priv->ptp_clock);
+
+	info->tx_types = ((1 << HWTSTAMP_TX_OFF) |
+			  (1 << HWTSTAMP_TX_ON) |
+			  (1 << HWTSTAMP_TX_ONESTEP_SYNC));
+
+	info->rx_filters = ((1 << HWTSTAMP_FILTER_NONE) |
+			    (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
+			    (1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+			    (1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+			    (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
+			    (1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
+			    (1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ) |
+			    (1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
+			    (1 << HWTSTAMP_FILTER_PTP_V2_L2_SYNC) |
+			    (1 << HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ) |
+			    (1 << HWTSTAMP_FILTER_PTP_V2_EVENT) |
+			    (1 << HWTSTAMP_FILTER_PTP_V2_SYNC) |
+			    (1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ) |
+			    (1 << HWTSTAMP_FILTER_ALL));
+	return 0;
 }
 
 int xgmac_set_flow_ctrl(struct xgmac_priv_data *priv, int rx, int tx)
diff --git a/drivers/net/ethernet/samsung/xgmac_main.c b/drivers/net/ethernet/samsung/xgmac_main.c
index 1eae636..05853d2 100644
--- a/drivers/net/ethernet/samsung/xgmac_main.c
+++ b/drivers/net/ethernet/samsung/xgmac_main.c
@@ -212,9 +212,8 @@ static void xgmac_clk_csr_set(struct xgmac_priv_data *priv)
 		 (clk_rate <= XGMAC_CSR_F_400M))
 		priv->clk_csr = XGMAC_CSR_350_400M;
 	else if ((clk_rate >= XGMAC_CSR_F_400M) &&
-		(clk_rate <= XGMAC_CSR_F_500M))
+		 (clk_rate <= XGMAC_CSR_F_500M))
 		priv->clk_csr = XGMAC_CSR_400_500M;
-
 }
 
 static void print_pkt(unsigned char *buf, int len)
@@ -271,8 +270,8 @@ static void xgmac_adjust_link(struct net_device *dev)
 				break;
 			default:
 				if (netif_msg_link(priv))
-					pr_err("%s: Speed (%d) not suppoted\n",
-						dev->name, phydev->speed);
+					pr_err("%s: Speed (%d) not supported\n",
+					       dev->name, phydev->speed);
 			}
 
 			priv->speed = phydev->speed;
@@ -346,7 +345,7 @@ static int xgmac_init_phy(struct net_device *ndev)
 	}
 
 	pr_debug("xgmac_init_phy: %s: attached to PHY (UID 0x%x) Link = %d\n",
-			ndev->name, phydev->phy_id, phydev->link);
+		 ndev->name, phydev->phy_id, phydev->link);
 
 	/* save phy device in private structure */
 	priv->phydev = phydev;
@@ -554,7 +553,6 @@ static int init_rx_ring(struct net_device *dev, u8 queue_no,
 		rx_ring->cur_rx = 0;
 		rx_ring->dirty_rx = (unsigned int)(desc_index - rx_rsize);
 		priv->dma_buf_sz = bfsize;
-
 	}
 
 	return 0;
@@ -656,9 +654,9 @@ static void tx_free_ring_skbufs(struct xgmac_tx_queue *txqueue)
 
 		if (txqueue->tx_skbuff_dma[dma_desc])
 			dma_unmap_single(priv->device,
-					txqueue->tx_skbuff_dma[dma_desc],
-					priv->hw->desc->get_tx_len(tdesc),
-					DMA_TO_DEVICE);
+					 txqueue->tx_skbuff_dma[dma_desc],
+					 priv->hw->desc->get_tx_len(tdesc),
+					 DMA_TO_DEVICE);
 
 		dev_kfree_skb_any(txqueue->tx_skbuff[dma_desc]);
 		txqueue->tx_skbuff[dma_desc] = NULL;
@@ -745,25 +743,26 @@ static void xgmac_mtl_operation_mode(struct xgmac_priv_data *priv)
 		/* set TC mode for TX QUEUES */
 		XGMAC_FOR_EACH_QUEUE(priv->hw_cap.tx_mtl_queues, queue_num)
 			priv->hw->mtl->set_tx_mtl_mode(priv->ioaddr, queue_num,
-					XGMAC_MTL_SFMODE);
+						       XGMAC_MTL_SFMODE);
 		tx_tc = XGMAC_MTL_SFMODE;
 
 		/* set TC mode for RX QUEUES */
 		XGMAC_FOR_EACH_QUEUE(priv->hw_cap.rx_mtl_queues, queue_num)
 			priv->hw->mtl->set_rx_mtl_mode(priv->ioaddr, queue_num,
-					XGMAC_MTL_SFMODE);
+						       XGMAC_MTL_SFMODE);
 		rx_tc = XGMAC_MTL_SFMODE;
 	} else if (unlikely(priv->plat->force_thresh_dma_mode)) {
 		/* set TC mode for TX QUEUES */
 		XGMAC_FOR_EACH_QUEUE(priv->hw_cap.tx_mtl_queues, queue_num)
 			priv->hw->mtl->set_tx_mtl_mode(priv->ioaddr, queue_num,
-						   tx_tc);
+						       tx_tc);
 		/* set TC mode for RX QUEUES */
 		XGMAC_FOR_EACH_QUEUE(priv->hw_cap.rx_mtl_queues, queue_num)
 			priv->hw->mtl->set_rx_mtl_mode(priv->ioaddr, queue_num,
-						   rx_tc);
-	} else
+						       rx_tc);
+	} else {
 		pr_err("ERROR: %s: Invalid TX threshold mode\n", __func__);
+	}
 }
 
 /**
@@ -796,13 +795,13 @@ static void xgmac_tx_queue_clean(struct xgmac_tx_queue *tqueue)
 
 		if (netif_msg_tx_done(priv))
 			pr_debug("%s: curr %d, dirty %d\n", __func__,
-					tqueue->cur_tx, tqueue->dirty_tx);
+				 tqueue->cur_tx, tqueue->dirty_tx);
 
 		if (likely(tqueue->tx_skbuff_dma[entry])) {
 			dma_unmap_single(priv->device,
-					tqueue->tx_skbuff_dma[entry],
-					priv->hw->desc->get_tx_len(p),
-					DMA_TO_DEVICE);
+					 tqueue->tx_skbuff_dma[entry],
+					 priv->hw->desc->get_tx_len(p),
+					 DMA_TO_DEVICE);
 			tqueue->tx_skbuff_dma[entry] = 0;
 		}
 
@@ -818,10 +817,10 @@ static void xgmac_tx_queue_clean(struct xgmac_tx_queue *tqueue)
 
 	/* wake up queue */
 	if (unlikely(netif_tx_queue_stopped(dev_txq) &&
-		xgmac_tx_avail(tqueue, tx_rsize) > XGMAC_TX_THRESH(priv))) {
+		     xgmac_tx_avail(tqueue, tx_rsize) > XGMAC_TX_THRESH(priv))) {
 		netif_tx_lock(priv->dev);
 		if (netif_tx_queue_stopped(dev_txq) &&
-		xgmac_tx_avail(tqueue, tx_rsize) > XGMAC_TX_THRESH(priv)) {
+		    xgmac_tx_avail(tqueue, tx_rsize) > XGMAC_TX_THRESH(priv)) {
 			if (netif_msg_tx_done(priv))
 				pr_debug("%s: restart transmit\n", __func__);
 			netif_tx_wake_queue(dev_txq);
@@ -984,8 +983,7 @@ static void xgmac_check_ether_addr(struct xgmac_priv_data *priv)
 			eth_hw_addr_random(priv->dev);
 	}
 	dev_info(priv->device, "device MAC address %pM\n",
-			priv->dev->dev_addr);
-
+		 priv->dev->dev_addr);
 }
 
 /**
@@ -1035,7 +1033,6 @@ static void xgmac_init_mtl_engine(struct xgmac_priv_data *priv)
 				priv->hw_cap.tx_mtl_qsize);
 		priv->hw->mtl->mtl_enable_txqueue(priv->ioaddr, queue_num);
 	}
-
 }
 
 /**
@@ -1121,7 +1118,7 @@ static int xgmac_open(struct net_device *dev)
 	ret = xgmac_init_phy(dev);
 	if (ret) {
 		pr_err("%s: Cannot attach to PHY (error: %d)\n",
-				__func__, ret);
+		       __func__, ret);
 		goto phy_error;
 	}
 
@@ -1190,7 +1187,7 @@ static int xgmac_open(struct net_device *dev)
 					dev->name, priv->txq[queue_num]);
 		if (unlikely(ret < 0)) {
 			pr_err("%s: ERROR: allocating TX IRQ %d (error: %d)\n",
-				__func__, dev->irq, ret);
+			       __func__, dev->irq, ret);
 			goto init_error;
 		}
 	}
@@ -1203,7 +1200,7 @@ static int xgmac_open(struct net_device *dev)
 					dev->name, priv->rxq[queue_num]);
 		if (unlikely(ret < 0)) {
 			pr_err("%s: ERROR: allocating TX IRQ %d (error: %d)\n",
-				__func__, dev->irq, ret);
+			       __func__, dev->irq, ret);
 			goto init_error;
 		}
 	}
@@ -1301,7 +1298,6 @@ static int xgmac_release(struct net_device *dev)
 	clk_disable_unprepare(priv->xgmac_clk);
 
 	return 0;
-
 }
 
 /* Prepare first Tx descriptor for doing TSO operation */
@@ -1324,7 +1320,6 @@ void xgmac_tso_prepare(struct xgmac_priv_data *priv,
 	priv->hw->desc->tx_desc_enable_tse(first_desc, 1, total_hdr_len,
 					   tcp_hdr_len,
 					   skb->len - total_hdr_len);
-
 }
 
 /**
@@ -1355,10 +1350,10 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* get the TX queue handle */
 	dev_txq = netdev_get_tx_queue(dev, txq_index);
 
-	if (likely(skb_is_gso(skb)
-	    || vlan_tx_tag_present(skb)
-	    || ((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)
-		 && tqueue->hwts_tx_en)))
+	if (likely(skb_is_gso(skb) ||
+		   vlan_tx_tag_present(skb) ||
+		   ((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+		    tqueue->hwts_tx_en)))
 		ctxt_desc_req = 1;
 
 	/* get the spinlock */
@@ -1371,7 +1366,7 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (!netif_tx_queue_stopped(dev_txq)) {
 			netif_tx_stop_queue(dev_txq);
 			pr_err("%s: Tx Ring is full when %d queue is awake\n",
-				__func__, txq_index);
+			       __func__, txq_index);
 		}
 		/* release the spin lock in case of BUSY */
 		spin_unlock(&tqueue->tx_lock);
@@ -1446,9 +1441,10 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		priv->hw->desc->clear_tx_ic(tx_desc);
 		priv->xstats.tx_reset_ic_bit++;
 		mod_timer(&tqueue->txtimer,
-			 XGMAC_COAL_TIMER(tqueue->tx_coal_timer));
-	} else
+			  XGMAC_COAL_TIMER(tqueue->tx_coal_timer));
+	} else {
 		tqueue->tx_count_frames = 0;
+	}
 
 	/* set owner for first desc */
 	priv->hw->desc->set_tx_owner(first_desc);
@@ -1461,9 +1457,9 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* display current ring */
 	if (netif_msg_pktdata(priv)) {
 		pr_debug("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
-			__func__, (tqueue->cur_tx % tx_rsize),
-			(tqueue->dirty_tx % tx_rsize), entry,
-			first_desc, nr_frags);
+			 __func__, (tqueue->cur_tx % tx_rsize),
+			 (tqueue->dirty_tx % tx_rsize), entry,
+			 first_desc, nr_frags);
 
 		pr_debug(">>> xgmac: tx frame to be transmitted: ");
 		print_pkt(skb->data, skb->len);
@@ -1587,7 +1583,7 @@ static int xgmac_rx(struct xgmac_priv_data *priv, int limit)
 
 		if (unlikely(!skb)) {
 			pr_err("%s: rx descriptor is not in consistent\n",
-				priv->dev->name);
+			       priv->dev->name);
 		}
 
 		prefetch(skb->data - NET_IP_ALIGN);
@@ -1921,10 +1917,10 @@ static void xgmac_set_rx_mode(struct net_device *dev)
 	pr_debug("%s: # mcasts %d, # unicast %d\n", __func__,
 		 netdev_mc_count(dev), netdev_uc_count(dev));
 
-	if (dev->flags & IFF_PROMISC)
+	if (dev->flags & IFF_PROMISC) {
 		value = XGMAC_FRAME_FILTER_PR;
-	else if ((netdev_mc_count(dev) > XGMAC_HASH_TABLE_SIZE)
-		 || (dev->flags & IFF_ALLMULTI)) {
+	} else if ((netdev_mc_count(dev) > XGMAC_HASH_TABLE_SIZE) ||
+		   (dev->flags & IFF_ALLMULTI)) {
 		value = XGMAC_FRAME_FILTER_PM;	/* pass all multi */
 		writel(0xffffffff, ioaddr + XGMAC_HASH_HIGH);
 		writel(0xffffffff, ioaddr + XGMAC_HASH_LOW);
@@ -1967,7 +1963,7 @@ static void xgmac_set_rx_mode(struct net_device *dev)
 	writel(value, ioaddr + XGMAC_FRAME_FILTER);
 
 	pr_debug("\tFilter: 0x%08x\n\tHash: HI 0x%08x, LO 0x%08x\n",
-	readl(ioaddr + XGMAC_FRAME_FILTER),
+		 readl(ioaddr + XGMAC_FRAME_FILTER),
 	readl(ioaddr + XGMAC_HASH_HIGH), readl(ioaddr + XGMAC_HASH_LOW));
 }
 
@@ -2106,7 +2102,7 @@ static int xgmac_hw_init(struct xgmac_priv_data * const priv)
 	priv->hw->ctrl_uid = (ctrl_ids & 0x00ff0000) >> 16;
 	priv->hw->ctrl_id = (ctrl_ids & 0x000000ff);
 	pr_info("xgmac - user ID: 0x%x, Controller ID: 0x%x\n",
-			priv->hw->ctrl_uid, priv->hw->ctrl_id);
+		priv->hw->ctrl_uid, priv->hw->ctrl_id);
 
 	/* get the H/W features */
 	if (!xgmac_get_hw_features(priv))
@@ -2267,8 +2263,8 @@ struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
 	/* MDIO bus Registration */
 	ret = xgmac_mdio_register(ndev);
 	if (ret < 0) {
-		pr_debug("%s: MDIO bus (id: %d) registration failed",
-				__func__, priv->plat->bus_id);
+		pr_debug("%s: MDIO bus (id: %d) registration failed\n",
+			 __func__, priv->plat->bus_id);
 		goto error_mdio_register;
 	}
 
@@ -2337,9 +2333,9 @@ int xgmac_suspend(struct net_device *ndev)
 		priv->hw->mtl->mtl_readout_rxqueue(priv->ioaddr, queue_num);
 
 	/* Enable Power down mode by programming the PMT regs */
-	if (device_may_wakeup(priv->device))
+	if (device_may_wakeup(priv->device)) {
 		priv->hw->mac->pmt(priv->ioaddr, priv->wolopts);
-	else {
+	} else {
 		netdev_for_each_uc_addr(ha, ndev)
 			priv->hw->mac->set_umac_addr(priv->ioaddr, ha->addr,
 						     reg++);
diff --git a/drivers/net/ethernet/samsung/xgmac_mdio.c b/drivers/net/ethernet/samsung/xgmac_mdio.c
index 647a7bd..568c2fb 100644
--- a/drivers/net/ethernet/samsung/xgmac_mdio.c
+++ b/drivers/net/ethernet/samsung/xgmac_mdio.c
@@ -78,7 +78,7 @@ static int xgmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 		 */
 		if (phyaddr < 4)
 			writel((1 << phyaddr),
-				priv->ioaddr + XGMAC_MDIO_CLAUSE22_PORT_REG);
+			       priv->ioaddr + XGMAC_MDIO_CLAUSE22_PORT_REG);
 		else
 			return -ENODEV;
 		/* set mdio address register */
@@ -137,12 +137,12 @@ static int xgmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 		/* configure the port for C22
 		 * ports 0-3 only supports C22
 		 */
-		if (phyaddr < 4)
-			writel((1 << phyaddr),
-				priv->ioaddr + XGMAC_MDIO_CLAUSE22_PORT_REG);
-		else
+		if (phyaddr >= 4)
 			return -ENODEV;
 
+		writel((1 << phyaddr),
+		       priv->ioaddr + XGMAC_MDIO_CLAUSE22_PORT_REG);
+
 		/* set mdio address register */
 		reg_val = (phyaddr << 16) | (phyreg & 0x1F);
 		writel(reg_val, priv->ioaddr + mii_addr);
@@ -173,8 +173,7 @@ int xgmac_mdio_register(struct net_device *ndev)
 	/* allocate the new mdio bus */
 	mdio_bus = mdiobus_alloc();
 	if (!mdio_bus) {
-		pr_err("%s : mii bus allocation failed\n",
-			__func__);
+		pr_err("%s : mii bus allocation failed\n", __func__);
 		return -ENOMEM;
 	}
 
diff --git a/drivers/net/ethernet/samsung/xgmac_mtl.c b/drivers/net/ethernet/samsung/xgmac_mtl.c
index 85e0132..82d275b 100644
--- a/drivers/net/ethernet/samsung/xgmac_mtl.c
+++ b/drivers/net/ethernet/samsung/xgmac_mtl.c
@@ -208,9 +208,9 @@ static void xgmac_set_tx_mtl_mode(void __iomem *ioaddr, int queue_num,
 
 	reg_val = readl(ioaddr + XGMAC_MTL_TXQ_OPMODE_REG(queue_num));
 	/* TX specific MTL mode settings */
-	if (tx_mode == XGMAC_MTL_SFMODE)
+	if (tx_mode == XGMAC_MTL_SFMODE) {
 		reg_val |= XGMAC_MTL_SFMODE;
-	else {
+	} else {
 		/* set the TTC values */
 		if (tx_mode <= 64)
 			reg_val |= MTL_CONTROL_TTC_64;
-- 
1.8.1.2.459.gbcd45b4.dirty
