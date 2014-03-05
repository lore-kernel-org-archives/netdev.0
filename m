From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/5] samsung: xgmac: Fix pr_<level> uses
Date: Wed,  5 Mar 2014 11:20:16 -0800
Message-ID: <401c4764c78a7bf8807f73f8a0502bd3f48a23ca.1394046997.git.joe@perches.com>
References: <cover.1394046997.git.joe@perches.com>
Cc: linux-samsung-soc@vger.kernel.org, davem@davemloft.net,
	siva.kallam@samsung.com, vipul.pandya@samsung.com,
	ks.giri@samsung.com, ilho215.lee@samsung.com,
	netdev@vger.kernel.org
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <cover.1394046997.git.joe@perches.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use pr_fmt to prefix messages consistently with "samsung_xgmac: ".
Add missing newlines.
Use print_hex_dump_debug.
Alignment neatening of pr_<level> uses.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/samsung/xgmac_core.c     |  8 ++--
 drivers/net/ethernet/samsung/xgmac_desc.c     | 11 +++--
 drivers/net/ethernet/samsung/xgmac_ethtool.c  |  5 +-
 drivers/net/ethernet/samsung/xgmac_main.c     | 69 +++++++++++++--------------
 drivers/net/ethernet/samsung/xgmac_mdio.c     |  5 +-
 drivers/net/ethernet/samsung/xgmac_mtl.c      |  7 ++-
 drivers/net/ethernet/samsung/xgmac_platform.c | 15 +++---
 7 files changed, 67 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/samsung/xgmac_core.c b/drivers/net/ethernet/samsung/xgmac_core.c
index 8fa2241..c5afba4 100644
--- a/drivers/net/ethernet/samsung/xgmac_core.c
+++ b/drivers/net/ethernet/samsung/xgmac_core.c
@@ -11,6 +11,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/export.h>
 #include <linux/io.h>
 #include <linux/netdevice.h>
@@ -92,15 +94,15 @@ static void xgmac_core_pmt(void __iomem *ioaddr, unsigned long mode)
 	unsigned int pmt = 0;
 
 	if (mode & WAKE_MAGIC) {
-		pr_debug("GMAC: WOL Magic frame\n");
+		pr_debug("WOL Magic frame\n");
 		pmt |= PMT_MGPKT_EN;
 	}
 	if (mode & WAKE_UCAST) {
-		pr_debug("GMAC: WOL on global unicast\n");
+		pr_debug("WOL on global unicast\n");
 		pmt |= PMT_GUCAST_EN;
 	}
 	if (mode & (WAKE_MCAST | WAKE_BCAST)) {
-		pr_debug("GMAC: WOL on any other packet\n");
+		pr_debug("WOL on any other packet\n");
 		pmt |= PMT_RWKPKT_EN;
 	}
 
diff --git a/drivers/net/ethernet/samsung/xgmac_desc.c b/drivers/net/ethernet/samsung/xgmac_desc.c
index ddf3e94..ef25efd 100644
--- a/drivers/net/ethernet/samsung/xgmac_desc.c
+++ b/drivers/net/ethernet/samsung/xgmac_desc.c
@@ -9,6 +9,9 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/bitops.h>
 #include <linux/export.h>
 #include <linux/io.h>
@@ -287,7 +290,7 @@ static int xgmac_rx_wbstatus(struct xgmac_rx_norm_desc *p,
 			x->overflow_error++;
 			break;
 		default:
-			pr_err("\tInvalid Error type\n");
+			pr_err("Invalid Error type\n");
 			break;
 		}
 	} else {
@@ -332,7 +335,7 @@ static int xgmac_rx_wbstatus(struct xgmac_rx_norm_desc *p,
 			x->dvlan_ocvlan_icvlan_pkt++;
 			break;
 		default:
-			pr_err("\tInvalid L2 Packet type\n");
+			pr_err("Invalid L2 Packet type\n");
 			break;
 		}
 	}
@@ -367,7 +370,7 @@ static int xgmac_rx_wbstatus(struct xgmac_rx_norm_desc *p,
 		x->ip6_unknown_pkt++;
 		break;
 	default:
-		pr_err("\tInvalid L3/L4 Packet type\n");
+		pr_err("Invalid L3/L4 Packet type\n");
 		break;
 	}
 
@@ -446,7 +449,7 @@ static void xgmac_rx_ctxt_wbstatus(struct xgmac_rx_ctxt_desc *p,
 static int xgmac_get_rx_ctxt_tstamp_status(struct xgmac_rx_ctxt_desc *p)
 {
 	if ((p->tstamp_hi == 0xffffffff) && (p->tstamp_lo == 0xffffffff)) {
-		pr_err("\tTime stamp corrupted\n");
+		pr_err("Time stamp corrupted\n");
 		return 0;
 	}
 
diff --git a/drivers/net/ethernet/samsung/xgmac_ethtool.c b/drivers/net/ethernet/samsung/xgmac_ethtool.c
index 3f0698a..576b23e 100644
--- a/drivers/net/ethernet/samsung/xgmac_ethtool.c
+++ b/drivers/net/ethernet/samsung/xgmac_ethtool.c
@@ -9,6 +9,9 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/clk.h>
 #include <linux/interrupt.h>
 #include <linux/kernel.h>
@@ -200,7 +203,7 @@ static int xgmac_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 		return -EOPNOTSUPP;
 
 	if (wol->wolopts) {
-		pr_info("xgmac: wakeup enable\n");
+		pr_info("wakeup enable\n");
 		device_set_wakeup_enable(priv->device, true);
 		enable_irq_wake(priv->wol_irq);
 	} else {
diff --git a/drivers/net/ethernet/samsung/xgmac_main.c b/drivers/net/ethernet/samsung/xgmac_main.c
index 05853d2..a212abf 100644
--- a/drivers/net/ethernet/samsung/xgmac_main.c
+++ b/drivers/net/ethernet/samsung/xgmac_main.c
@@ -9,6 +9,9 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/clk.h>
 #include <linux/crc32.h>
 #include <linux/dma-mapping.h>
@@ -166,7 +169,7 @@ bool xgmac_eee_init(struct xgmac_priv_data * const priv)
 					     XGMAC_DEFAULT_LPI_TIMER,
 					     priv->tx_lpi_timer);
 
-		pr_info("xgmac: Energy-Efficient Ethernet initialized\n");
+		pr_info("Energy-Efficient Ethernet initialized\n");
 
 		ret = true;
 	}
@@ -218,14 +221,9 @@ static void xgmac_clk_csr_set(struct xgmac_priv_data *priv)
 
 static void print_pkt(unsigned char *buf, int len)
 {
-	int j;
-	pr_debug("len = %d byte, buf addr: 0x%p", len, buf);
-	for (j = 0; j < len; j++) {
-		if ((j % 16) == 0)
-			pr_debug("\n %03x:", j);
-		pr_debug(" %02x", buf[j]);
-	}
-	pr_debug("\n");
+	pr_debug("len = %d byte, buf addr: 0x%p\n", len, buf);
+	print_hex_dump_debug(KBUILD_MODNAME ": ", DUMP_PREFIX_OFFSET, 16, 1,
+			     buf, len, true);
 }
 
 /* minimum number of free TX descriptors required to wake up TX process */
@@ -325,7 +323,7 @@ static int xgmac_init_phy(struct net_device *ndev)
 
 	snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
 		 priv->plat->phy_addr);
-	pr_debug("xgmac_init_phy:  trying to attach to %s\n", phy_id_fmt);
+	pr_debug("%s: trying to attach to %s\n", __func__, phy_id_fmt);
 
 	phydev = phy_connect(ndev, phy_id_fmt, &xgmac_adjust_link, phy_iface);
 
@@ -344,8 +342,8 @@ static int xgmac_init_phy(struct net_device *ndev)
 		return -ENODEV;
 	}
 
-	pr_debug("xgmac_init_phy: %s: attached to PHY (UID 0x%x) Link = %d\n",
-		 ndev->name, phydev->phy_id, phydev->link);
+	pr_debug("%s: %s: attached to PHY (UID 0x%x) Link = %d\n",
+		 __func__, ndev->name, phydev->phy_id, phydev->link);
 
 	/* save phy device in private structure */
 	priv->phydev = phydev;
@@ -506,7 +504,7 @@ static int init_rx_ring(struct net_device *dev, u8 queue_no,
 
 	/* RX ring is not allcoated */
 	if (rx_ring == NULL) {
-		pr_err("No memory for RX queue of XGMAC\n");
+		pr_err("No memory for RX queue\n");
 		goto error;
 	} else {
 		/* assign queue number */
@@ -518,7 +516,7 @@ static int init_rx_ring(struct net_device *dev, u8 queue_no,
 				&rx_ring->dma_rx_phy, GFP_KERNEL);
 
 		if (rx_ring->dma_rx == NULL) {
-			pr_err("No memory for RX desc of XGMAC\n");
+			pr_err("No memory for RX desc\n");
 			goto error;
 		}
 
@@ -527,7 +525,7 @@ static int init_rx_ring(struct net_device *dev, u8 queue_no,
 					sizeof(dma_addr_t), GFP_KERNEL);
 
 		if (rx_ring->rx_skbuff_dma == NULL) {
-			pr_err("No memory for RX skbuffs DMA of XGMAC\n");
+			pr_err("No memory for RX skbuffs DMA\n");
 			goto dmamem_err;
 		}
 
@@ -535,7 +533,7 @@ static int init_rx_ring(struct net_device *dev, u8 queue_no,
 					sizeof(struct sk_buff *), GFP_KERNEL);
 
 		if (rx_ring->rx_skbuff == NULL) {
-			pr_err("No memory for RX skbuffs of XGMAC\n");
+			pr_err("No memory for RX skbuffs\n");
 			goto rxbuff_err;
 		}
 
@@ -794,8 +792,8 @@ static void xgmac_tx_queue_clean(struct xgmac_tx_queue *tqueue)
 			break;
 
 		if (netif_msg_tx_done(priv))
-			pr_debug("%s: curr %d, dirty %d\n", __func__,
-				 tqueue->cur_tx, tqueue->dirty_tx);
+			pr_debug("%s: curr %d, dirty %d\n",
+				 __func__, tqueue->cur_tx, tqueue->dirty_tx);
 
 		if (likely(tqueue->tx_skbuff_dma[entry])) {
 			dma_unmap_single(priv->device,
@@ -1117,8 +1115,7 @@ static int xgmac_open(struct net_device *dev)
 	/* Init the phy */
 	ret = xgmac_init_phy(dev);
 	if (ret) {
-		pr_err("%s: Cannot attach to PHY (error: %d)\n",
-		       __func__, ret);
+		pr_err("%s: Cannot attach to PHY (error: %d)\n", __func__, ret);
 		goto phy_error;
 	}
 
@@ -1401,8 +1398,8 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 			tx_desc->tdes01 = dma_map_single(priv->device,
 					skb->data, no_pagedlen, DMA_TO_DEVICE);
 			if (dma_mapping_error(priv->device, tx_desc->tdes01))
-				pr_err("%s: TX dma mapping failed!!\n"
-						, __func__);
+				pr_err("%s: TX dma mapping failed!!\n",
+				       __func__);
 
 			priv->hw->desc->prepare_tx_desc(tx_desc, 1, no_pagedlen,
 					no_pagedlen, cksum_flag);
@@ -1456,12 +1453,12 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* display current ring */
 	if (netif_msg_pktdata(priv)) {
-		pr_debug("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
+		pr_debug("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d\n",
 			 __func__, (tqueue->cur_tx % tx_rsize),
 			 (tqueue->dirty_tx % tx_rsize), entry,
 			 first_desc, nr_frags);
 
-		pr_debug(">>> xgmac: tx frame to be transmitted: ");
+		pr_debug(">>> xgmac: tx frame to be transmitted:\n");
 		print_pkt(skb->data, skb->len);
 	}
 
@@ -1858,8 +1855,8 @@ static int xgmac_change_mtu(struct net_device *dev, int new_mtu)
 	 * a datagram of 68 octets without further fragmentation."
 	 */
 	if (new_mtu < MIN_MTU || (new_mtu > MAX_MTU)) {
-		pr_err("%s: invalid MTU, MTU should be in between %d and %d\n"
-		       , dev->name, MIN_MTU, MAX_MTU);
+		pr_err("%s: invalid MTU, MTU should be in between %d and %d\n",
+		       dev->name, MIN_MTU, MAX_MTU);
 		return -EINVAL;
 	}
 
@@ -1914,8 +1911,8 @@ static void xgmac_set_rx_mode(struct net_device *dev)
 	struct netdev_hw_addr *ha;
 	int reg = 1;
 
-	pr_debug("%s: # mcasts %d, # unicast %d\n", __func__,
-		 netdev_mc_count(dev), netdev_uc_count(dev));
+	pr_debug("%s: # mcasts %d, # unicast %d\n",
+		 __func__, netdev_mc_count(dev), netdev_uc_count(dev));
 
 	if (dev->flags & IFF_PROMISC) {
 		value = XGMAC_FRAME_FILTER_PR;
@@ -1962,7 +1959,7 @@ static void xgmac_set_rx_mode(struct net_device *dev)
 #endif
 	writel(value, ioaddr + XGMAC_FRAME_FILTER);
 
-	pr_debug("\tFilter: 0x%08x\n\tHash: HI 0x%08x, LO 0x%08x\n",
+	pr_debug("Filter: 0x%08x\n\tHash: HI 0x%08x, LO 0x%08x\n",
 		 readl(ioaddr + XGMAC_FRAME_FILTER),
 	readl(ioaddr + XGMAC_HASH_HIGH), readl(ioaddr + XGMAC_HASH_LOW));
 }
@@ -2106,13 +2103,13 @@ static int xgmac_hw_init(struct xgmac_priv_data * const priv)
 
 	/* get the H/W features */
 	if (!xgmac_get_hw_features(priv))
-		pr_info("XGMAC Hardware features not found\n");
+		pr_info("Hardware features not found\n");
 
 	if (priv->hw_cap.tx_csum_offload)
-		pr_info("XGMAC: TX Checksum offload supported\n");
+		pr_info("TX Checksum offload supported\n");
 
 	if (priv->hw_cap.rx_csum_offload)
-		pr_info("XGMAC: RX Checksum offload supported\n");
+		pr_info("RX Checksum offload supported\n");
 
 	return 0;
 }
@@ -2230,7 +2227,7 @@ struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
 	/* Rx Watchdog is available, enable depend on platform data */
 	if (!priv->plat->riwt_off) {
 		priv->use_riwt = 1;
-		pr_info(" Enable RX Mitigation via HW Watchdog Timer\n");
+		pr_info("Enable RX Mitigation via HW Watchdog Timer\n");
 	}
 
 	netif_napi_add(ndev, &priv->napi, xgmac_poll, 64);
@@ -2295,7 +2292,7 @@ int xgmac_dvr_remove(struct net_device *ndev)
 {
 	struct xgmac_priv_data *priv = netdev_priv(ndev);
 
-	pr_info("%s:\n\tremoving driver", __func__);
+	pr_info("%s: removing driver\n", __func__);
 
 	priv->hw->dma->stop_rx(priv->ioaddr, XGMAC_RX_QUEUES);
 	priv->hw->dma->stop_tx(priv->ioaddr, XGMAC_TX_QUEUES);
@@ -2384,7 +2381,7 @@ static int __init xgmac_init(void)
 		goto err;
 	return 0;
 err:
-	pr_err("xgmac: driver registration failed\n");
+	pr_err("driver registration failed\n");
 	return ret;
 }
 
@@ -2412,7 +2409,7 @@ static int __init xgmac_cmdline_opt(char *str)
 	return 0;
 
 err:
-	pr_err("%s: ERROR broken module parameter conversion", __func__);
+	pr_err("%s: ERROR broken module parameter conversion\n", __func__);
 	return -EINVAL;
 }
 
diff --git a/drivers/net/ethernet/samsung/xgmac_mdio.c b/drivers/net/ethernet/samsung/xgmac_mdio.c
index 568c2fb..98cd311 100644
--- a/drivers/net/ethernet/samsung/xgmac_mdio.c
+++ b/drivers/net/ethernet/samsung/xgmac_mdio.c
@@ -9,6 +9,9 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/io.h>
 #include <linux/mii.h>
 #include <linux/netdevice.h>
@@ -173,7 +176,7 @@ int xgmac_mdio_register(struct net_device *ndev)
 	/* allocate the new mdio bus */
 	mdio_bus = mdiobus_alloc();
 	if (!mdio_bus) {
-		pr_err("%s : mii bus allocation failed\n", __func__);
+		pr_err("%s: mii bus allocation failed\n", __func__);
 		return -ENOMEM;
 	}
 
diff --git a/drivers/net/ethernet/samsung/xgmac_mtl.c b/drivers/net/ethernet/samsung/xgmac_mtl.c
index 82d275b..2edad0f 100644
--- a/drivers/net/ethernet/samsung/xgmac_mtl.c
+++ b/drivers/net/ethernet/samsung/xgmac_mtl.c
@@ -9,6 +9,9 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/io.h>
 #include <linux/errno.h>
 #include <linux/export.h>
@@ -172,7 +175,7 @@ static int xgmac_mtl_flush_txqueue(void __iomem *ioaddr, int queue_num)
 	while ((reg_val &
 		(XGMAC_MTL_TXQ_EMPTY_STAT | XGMAC_MTL_TXQ_WRITE_STAT))) {
 		if (time_after(jiffies, timeout)) {
-			pr_err("cannot flush tx queue - timeout");
+			pr_err("cannot flush tx queue - timeout\n");
 			return -ETIMEDOUT;
 		}
 		reg_val = readl(ioaddr + XGMAC_MTL_TXQ_OPMODE_REG(queue_num));
@@ -192,7 +195,7 @@ static int xgmac_mtl_readout_rxqueue(void __iomem *ioaddr, int queue_num)
 	while ((reg_val &
 		(XGMAC_MTL_TXQ_EMPTY_STAT | XGMAC_MTL_TXQ_WRITE_STAT))) {
 		if (time_after(jiffies, timeout)) {
-			pr_err("cannot flush tx queue - timeout");
+			pr_err("cannot flush tx queue - timeout\n");
 			return -ETIMEDOUT;
 		}
 		reg_val = readl(ioaddr + XGMAC_MTL_TXQ_OPMODE_REG(queue_num));
diff --git a/drivers/net/ethernet/samsung/xgmac_platform.c b/drivers/net/ethernet/samsung/xgmac_platform.c
index d0cf6cf..f6b3d20 100644
--- a/drivers/net/ethernet/samsung/xgmac_platform.c
+++ b/drivers/net/ethernet/samsung/xgmac_platform.c
@@ -9,6 +9,9 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/etherdevice.h>
 #include <linux/io.h>
 #include <linux/module.h>
@@ -69,7 +72,7 @@ static int xgmac_probe_config_dt(struct platform_device *pdev,
 					"samsung,force_thresh_dma_mode");
 	if (plat->force_thresh_dma_mode) {
 		plat->force_sf_dma_mode = 0;
-		pr_warn("force_sf_dma_mode is ignored as force_thresh_dma_mode is set.");
+		pr_warn("force_sf_dma_mode is ignored as force_thresh_dma_mode is set\n");
 	}
 
 	return 0;
@@ -119,20 +122,20 @@ static int xgmac_platform_probe(struct platform_device *pdev)
 					sizeof(struct xgmac_plat_data),
 					GFP_KERNEL);
 		if (!plat_dat) {
-			pr_err("%s: ERROR: no memory", __func__);
+			pr_err("%s: ERROR: no memory\n", __func__);
 			return  -ENOMEM;
 		}
 
 		ret = xgmac_probe_config_dt(pdev, plat_dat, &mac);
 		if (ret) {
-			pr_err("%s: main dt probe failed", __func__);
+			pr_err("%s: main dt probe failed\n", __func__);
 			return ret;
 		}
 	}
 
 	priv = xgmac_dvr_probe(&(pdev->dev), plat_dat, addr);
 	if (!priv) {
-		pr_err("%s: main driver probe failed", __func__);
+		pr_err("%s: main driver probe failed\n", __func__);
 		return -ENODEV;
 	}
 
@@ -176,7 +179,7 @@ static int xgmac_platform_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, priv->dev);
 
-	pr_debug("XGMAC platform driver registration completed");
+	pr_debug("platform driver registration completed\n");
 
 	return 0;
 }
@@ -261,7 +264,7 @@ int xgmac_register_platform(void)
 
 	err = platform_driver_register(&xgmac_platform_driver);
 	if (err)
-		pr_err("xgmac: failed to register the platform driver\n");
+		pr_err("failed to register the platform driver\n");
 
 	return err;
 }
-- 
1.8.1.2.459.gbcd45b4.dirty
