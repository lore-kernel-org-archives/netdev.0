From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/5] samsung: xgmac: Use more current logging style
Date: Wed,  5 Mar 2014 11:20:17 -0800
Message-ID: <3e022ca7f7a59951cd7825277f53591d06e92b84.1394046997.git.joe@perches.com>
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

Use netdev_<level> and netif_<level> where appropriate.
Remove else and unnecessary indentation around if goto else.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/samsung/xgmac_ethtool.c  |   2 +-
 drivers/net/ethernet/samsung/xgmac_main.c     | 185 ++++++++++++--------------
 drivers/net/ethernet/samsung/xgmac_mdio.c     |  13 +-
 drivers/net/ethernet/samsung/xgmac_platform.c |   4 +-
 4 files changed, 95 insertions(+), 109 deletions(-)

diff --git a/drivers/net/ethernet/samsung/xgmac_ethtool.c b/drivers/net/ethernet/samsung/xgmac_ethtool.c
index 576b23e..378f6f1 100644
--- a/drivers/net/ethernet/samsung/xgmac_ethtool.c
+++ b/drivers/net/ethernet/samsung/xgmac_ethtool.c
@@ -203,7 +203,7 @@ static int xgmac_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 		return -EOPNOTSUPP;
 
 	if (wol->wolopts) {
-		pr_info("wakeup enable\n");
+		netdev_info(dev, "wakeup enable\n");
 		device_set_wakeup_enable(priv->device, true);
 		enable_irq_wake(priv->wol_irq);
 	} else {
diff --git a/drivers/net/ethernet/samsung/xgmac_main.c b/drivers/net/ethernet/samsung/xgmac_main.c
index a212abf..f642c99 100644
--- a/drivers/net/ethernet/samsung/xgmac_main.c
+++ b/drivers/net/ethernet/samsung/xgmac_main.c
@@ -267,9 +267,9 @@ static void xgmac_adjust_link(struct net_device *dev)
 				speed = XGMAC_SPEED_1G;
 				break;
 			default:
-				if (netif_msg_link(priv))
-					pr_err("%s: Speed (%d) not supported\n",
-					       dev->name, phydev->speed);
+				netif_err(priv, link, dev,
+					  "Speed (%d) not supported\n",
+					  phydev->speed);
 			}
 
 			priv->speed = phydev->speed;
@@ -323,12 +323,12 @@ static int xgmac_init_phy(struct net_device *ndev)
 
 	snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
 		 priv->plat->phy_addr);
-	pr_debug("%s: trying to attach to %s\n", __func__, phy_id_fmt);
+	netdev_dbg(ndev, "%s: trying to attach to %s\n", __func__, phy_id_fmt);
 
 	phydev = phy_connect(ndev, phy_id_fmt, &xgmac_adjust_link, phy_iface);
 
 	if (IS_ERR(phydev)) {
-		pr_err("%s: Could not attach to PHY\n", ndev->name);
+		netdev_err(ndev, "Could not attach to PHY\n");
 		return PTR_ERR(phydev);
 	}
 
@@ -342,8 +342,8 @@ static int xgmac_init_phy(struct net_device *ndev)
 		return -ENODEV;
 	}
 
-	pr_debug("%s: %s: attached to PHY (UID 0x%x) Link = %d\n",
-		 __func__, ndev->name, phydev->phy_id, phydev->link);
+	netdev_dbg(ndev, "%s: attached to PHY (UID 0x%x) Link = %d\n",
+		   __func__, phydev->phy_id, phydev->link);
 
 	/* save phy device in private structure */
 	priv->phydev = phydev;
@@ -387,7 +387,7 @@ static int xgmac_init_rx_buffers(struct net_device *dev,
 
 	skb = __netdev_alloc_skb(dev, dma_buf_sz, GFP_KERNEL);
 	if (!skb) {
-		pr_err("%s: Rx init fails; skb is NULL\n", __func__);
+		netdev_err(dev, "%s: Rx init fails; skb is NULL\n", __func__);
 		return -ENOMEM;
 	}
 	skb_reserve(skb, NET_IP_ALIGN);
@@ -397,9 +397,9 @@ static int xgmac_init_rx_buffers(struct net_device *dev,
 						dma_buf_sz, DMA_FROM_DEVICE);
 
 	if (dma_mapping_error(priv->device, rx_ring->rx_skbuff_dma[i])) {
-			pr_err("%s: DMA mapping error\n", __func__);
-			dev_kfree_skb_any(skb);
-			return -EINVAL;
+		netdev_err(dev, "%s: DMA mapping error\n", __func__);
+		dev_kfree_skb_any(skb);
+		return -EINVAL;
 	}
 
 	p->rdes23.rx_rd_des23.buf2_addr = rx_ring->rx_skbuff_dma[i];
@@ -499,60 +499,51 @@ static int init_rx_ring(struct net_device *dev, u8 queue_no,
 	/* Set the max buffer size according to the MTU. */
 	bfsize = ALIGN(dev->mtu + ETH_HLEN + ETH_FCS_LEN + NET_IP_ALIGN, 8);
 
-	if (netif_msg_probe(priv))
-		pr_debug("%s: bfsize %d\n", __func__, bfsize);
+	netif_dbg(priv, probe, dev, "%s: bfsize %d\n", __func__, bfsize);
 
 	/* RX ring is not allcoated */
 	if (rx_ring == NULL) {
-		pr_err("No memory for RX queue\n");
+		netdev_err(dev, "No memory for RX queue\n");
 		goto error;
-	} else {
-		/* assign queue number */
-		rx_ring->queue_no = queue_no;
-
-		/* allocate memory for RX descriptors */
-		rx_ring->dma_rx = dma_zalloc_coherent(priv->device,
-				rx_rsize * sizeof(struct xgmac_rx_norm_desc),
-				&rx_ring->dma_rx_phy, GFP_KERNEL);
-
-		if (rx_ring->dma_rx == NULL) {
-			pr_err("No memory for RX desc\n");
-			goto error;
-		}
+	}
 
-		/* allocate memory for RX skbuff array */
-		rx_ring->rx_skbuff_dma = kmalloc_array(rx_rsize,
-					sizeof(dma_addr_t), GFP_KERNEL);
+	/* assign queue number */
+	rx_ring->queue_no = queue_no;
 
-		if (rx_ring->rx_skbuff_dma == NULL) {
-			pr_err("No memory for RX skbuffs DMA\n");
-			goto dmamem_err;
-		}
+	/* allocate memory for RX descriptors */
+	rx_ring->dma_rx = dma_zalloc_coherent(priv->device,
+					      rx_rsize * sizeof(struct xgmac_rx_norm_desc),
+					      &rx_ring->dma_rx_phy, GFP_KERNEL);
 
-		rx_ring->rx_skbuff = kmalloc_array(rx_rsize,
-					sizeof(struct sk_buff *), GFP_KERNEL);
+	if (rx_ring->dma_rx == NULL)
+		goto error;
 
-		if (rx_ring->rx_skbuff == NULL) {
-			pr_err("No memory for RX skbuffs\n");
-			goto rxbuff_err;
-		}
+	/* allocate memory for RX skbuff array */
+	rx_ring->rx_skbuff_dma = kmalloc_array(rx_rsize,
+					       sizeof(dma_addr_t), GFP_KERNEL);
+	if (rx_ring->rx_skbuff_dma == NULL)
+		goto dmamem_err;
 
-		/* initalise the buffers */
-		for (desc_index = 0; desc_index < rx_rsize; desc_index++) {
-			struct xgmac_rx_norm_desc *p;
-			p = rx_ring->dma_rx + desc_index;
-			ret = xgmac_init_rx_buffers(dev, p, desc_index,
-							bfsize, rx_ring);
-			if (ret)
-				goto err_init_rx_buffers;
-		}
+	rx_ring->rx_skbuff = kmalloc_array(rx_rsize,
+					   sizeof(struct sk_buff *), GFP_KERNEL);
+	if (rx_ring->rx_skbuff == NULL)
+		goto rxbuff_err;
 
-		/* initalise counters */
-		rx_ring->cur_rx = 0;
-		rx_ring->dirty_rx = (unsigned int)(desc_index - rx_rsize);
-		priv->dma_buf_sz = bfsize;
+	/* initialise the buffers */
+	for (desc_index = 0; desc_index < rx_rsize; desc_index++) {
+		struct xgmac_rx_norm_desc *p;
+		p = rx_ring->dma_rx + desc_index;
+		ret = xgmac_init_rx_buffers(dev, p, desc_index,
+					    bfsize, rx_ring);
+		if (ret)
+			goto err_init_rx_buffers;
 	}
 
+	/* initalise counters */
+	rx_ring->cur_rx = 0;
+	rx_ring->dirty_rx = (unsigned int)(desc_index - rx_rsize);
+	priv->dma_buf_sz = bfsize;
+
 	return 0;
 
 err_init_rx_buffers:
@@ -616,7 +607,7 @@ static int init_dma_desc_rings(struct net_device *netd)
 		ret = init_rx_ring(netd, queue_num,
 				   priv->rxq[queue_num], rx_rsize);
 		if (ret) {
-			pr_err("RX DMA ring allocation failed!!\n");
+			netdev_err(netd, "RX DMA ring allocation failed!!\n");
 			goto rxalloc_err;
 		}
 
@@ -717,10 +708,8 @@ static int rxring_mem_alloc(struct xgmac_priv_data *priv)
 	XGMAC_FOR_EACH_QUEUE(XGMAC_RX_QUEUES, queue_num) {
 		priv->rxq[queue_num] = devm_kmalloc(priv->device,
 				sizeof(struct xgmac_rx_queue), GFP_KERNEL);
-		if (!priv->rxq[queue_num]) {
-			pr_err("No memory for RX queue of XGMAC\n");
+		if (!priv->rxq[queue_num])
 			return -ENOMEM;
-		}
 	}
 
 	return 0;
@@ -1115,7 +1104,8 @@ static int xgmac_open(struct net_device *dev)
 	/* Init the phy */
 	ret = xgmac_init_phy(dev);
 	if (ret) {
-		pr_err("%s: Cannot attach to PHY (error: %d)\n", __func__, ret);
+		netdev_err(dev, "%s: Cannot attach to PHY (error: %d)\n",
+			   __func__, ret);
 		goto phy_error;
 	}
 
@@ -1128,7 +1118,7 @@ static int xgmac_open(struct net_device *dev)
 	/* DMA initialization and SW reset */
 	ret = xgmac_init_dma_engine(priv);
 	if (ret < 0) {
-		pr_err("%s: DMA initialization failed\n", __func__);
+		netdev_err(dev, "%s: DMA initialization failed\n", __func__);
 		goto init_error;
 	}
 
@@ -1145,8 +1135,8 @@ static int xgmac_open(struct net_device *dev)
 	ret = devm_request_irq(priv->device, dev->irq, xgmac_common_interrupt,
 			  IRQF_SHARED, dev->name, dev);
 	if (unlikely(ret < 0)) {
-		pr_err("%s: ERROR: allocating the IRQ %d (error: %d)\n",
-		       __func__, dev->irq, ret);
+		netdev_err(dev, "%s: ERROR: allocating the IRQ %d (error: %d)\n",
+			   __func__, dev->irq, ret);
 		goto init_error;
 	}
 
@@ -1156,8 +1146,8 @@ static int xgmac_open(struct net_device *dev)
 				xgmac_common_interrupt, IRQF_SHARED,
 				dev->name, dev);
 		if (unlikely(ret < 0)) {
-			pr_err("%s: ERROR: allocating the WoL IRQ %d (%d)\n",
-			       __func__, priv->wol_irq, ret);
+			netdev_err(dev, "%s: ERROR: allocating the WoL IRQ %d (%d)\n",
+				   __func__, priv->wol_irq, ret);
 			goto init_error;
 		}
 	}
@@ -1170,8 +1160,8 @@ static int xgmac_open(struct net_device *dev)
 				       xgmac_common_interrupt,
 				       IRQF_SHARED, dev->name, dev);
 		if (unlikely(ret < 0)) {
-			pr_err("%s: ERROR: allocating the LPI IRQ %d (%d)\n",
-			       __func__, priv->lpi_irq, ret);
+			netdev_err(dev, "%s: ERROR: allocating the LPI IRQ %d (%d)\n",
+				   __func__, priv->lpi_irq, ret);
 			goto init_error;
 		}
 	}
@@ -1183,8 +1173,8 @@ static int xgmac_open(struct net_device *dev)
 					xgmac_tx_interrupt, 0,
 					dev->name, priv->txq[queue_num]);
 		if (unlikely(ret < 0)) {
-			pr_err("%s: ERROR: allocating TX IRQ %d (error: %d)\n",
-			       __func__, dev->irq, ret);
+			netdev_err(dev, "%s: ERROR: allocating TX IRQ %d (error: %d)\n",
+				   __func__, dev->irq, ret);
 			goto init_error;
 		}
 	}
@@ -1196,8 +1186,8 @@ static int xgmac_open(struct net_device *dev)
 					xgmac_rx_interrupt, 0,
 					dev->name, priv->rxq[queue_num]);
 		if (unlikely(ret < 0)) {
-			pr_err("%s: ERROR: allocating TX IRQ %d (error: %d)\n",
-			       __func__, dev->irq, ret);
+			netdev_err(dev, "%s: ERROR: allocating TX IRQ %d (error: %d)\n",
+				   __func__, dev->irq, ret);
 			goto init_error;
 		}
 	}
@@ -1216,7 +1206,7 @@ static int xgmac_open(struct net_device *dev)
 	priv->xstats.rx_threshold = rx_tc;
 
 	/* Start the ball rolling... */
-	pr_debug("%s: DMA RX/TX processes started...\n", dev->name);
+	netdev_dbg(dev, "DMA RX/TX processes started...\n");
 	priv->hw->dma->start_tx(priv->ioaddr, XGMAC_TX_QUEUES);
 	priv->hw->dma->start_rx(priv->ioaddr, XGMAC_RX_QUEUES);
 
@@ -1362,8 +1352,8 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(xgmac_tx_avail(tqueue, tx_rsize) < nr_frags + 1)) {
 		if (!netif_tx_queue_stopped(dev_txq)) {
 			netif_tx_stop_queue(dev_txq);
-			pr_err("%s: Tx Ring is full when %d queue is awake\n",
-			       __func__, txq_index);
+			netdev_err(dev, "%s: Tx Ring is full when %d queue is awake\n",
+				   __func__, txq_index);
 		}
 		/* release the spin lock in case of BUSY */
 		spin_unlock(&tqueue->tx_lock);
@@ -1398,8 +1388,8 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 			tx_desc->tdes01 = dma_map_single(priv->device,
 					skb->data, no_pagedlen, DMA_TO_DEVICE);
 			if (dma_mapping_error(priv->device, tx_desc->tdes01))
-				pr_err("%s: TX dma mapping failed!!\n",
-				       __func__);
+				netdev_err(dev, "%s: TX dma mapping failed!!\n",
+					   __func__);
 
 			priv->hw->desc->prepare_tx_desc(tx_desc, 1, no_pagedlen,
 					no_pagedlen, cksum_flag);
@@ -1453,18 +1443,18 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* display current ring */
 	if (netif_msg_pktdata(priv)) {
-		pr_debug("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d\n",
-			 __func__, (tqueue->cur_tx % tx_rsize),
-			 (tqueue->dirty_tx % tx_rsize), entry,
-			 first_desc, nr_frags);
+		netdev_dbg(dev, "%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d\n",
+			   __func__, (tqueue->cur_tx % tx_rsize),
+			   (tqueue->dirty_tx % tx_rsize), entry,
+			   first_desc, nr_frags);
 
-		pr_debug(">>> xgmac: tx frame to be transmitted:\n");
+		pr_debug(">>> tx frame to be transmitted:\n");
 		print_pkt(skb->data, skb->len);
 	}
 
 	if (unlikely(xgmac_tx_avail(tqueue, tx_rsize) <= (MAX_SKB_FRAGS + 1))) {
-		if (netif_msg_hw(priv))
-			pr_debug("%s: stop transmitted packets\n", __func__);
+		netif_dbg(priv, hw, dev, "%s: stop transmitted packets\n",
+			  __func__);
 		netif_tx_stop_queue(dev_txq);
 	}
 
@@ -1578,10 +1568,8 @@ static int xgmac_rx(struct xgmac_priv_data *priv, int limit)
 
 		skb = priv->rxq[qnum]->rx_skbuff[entry];
 
-		if (unlikely(!skb)) {
-			pr_err("%s: rx descriptor is not in consistent\n",
-			       priv->dev->name);
-		}
+		if (unlikely(!skb))
+			netdev_err(priv->dev, "rx descriptor is not consistent\n");
 
 		prefetch(skb->data - NET_IP_ALIGN);
 		priv->rxq[qnum]->rx_skbuff[entry] = NULL;
@@ -1855,8 +1843,8 @@ static int xgmac_change_mtu(struct net_device *dev, int new_mtu)
 	 * a datagram of 68 octets without further fragmentation."
 	 */
 	if (new_mtu < MIN_MTU || (new_mtu > MAX_MTU)) {
-		pr_err("%s: invalid MTU, MTU should be in between %d and %d\n",
-		       dev->name, MIN_MTU, MAX_MTU);
+		netdev_err(dev, "invalid MTU, MTU should be in between %d and %d\n",
+			   MIN_MTU, MAX_MTU);
 		return -EINVAL;
 	}
 
@@ -1911,8 +1899,8 @@ static void xgmac_set_rx_mode(struct net_device *dev)
 	struct netdev_hw_addr *ha;
 	int reg = 1;
 
-	pr_debug("%s: # mcasts %d, # unicast %d\n",
-		 __func__, netdev_mc_count(dev), netdev_uc_count(dev));
+	netdev_dbg(dev, "%s: # mcasts %d, # unicast %d\n",
+		   __func__, netdev_mc_count(dev), netdev_uc_count(dev));
 
 	if (dev->flags & IFF_PROMISC) {
 		value = XGMAC_FRAME_FILTER_PR;
@@ -1959,8 +1947,8 @@ static void xgmac_set_rx_mode(struct net_device *dev)
 #endif
 	writel(value, ioaddr + XGMAC_FRAME_FILTER);
 
-	pr_debug("Filter: 0x%08x\n\tHash: HI 0x%08x, LO 0x%08x\n",
-		 readl(ioaddr + XGMAC_FRAME_FILTER),
+	netdev_dbg(dev, "Filter: 0x%08x\n\tHash: HI 0x%08x, LO 0x%08x\n",
+		   readl(ioaddr + XGMAC_FRAME_FILTER),
 	readl(ioaddr + XGMAC_HASH_HIGH), readl(ioaddr + XGMAC_HASH_LOW));
 }
 
@@ -1982,13 +1970,13 @@ static int xgmac_config(struct net_device *dev, struct ifmap *map)
 
 	/* Don't allow changing the I/O address */
 	if (map->base_addr != dev->base_addr) {
-		pr_warn("%s: can't change I/O address\n", dev->name);
+		netdev_warn(dev, "can't change I/O address\n");
 		return -EOPNOTSUPP;
 	}
 
 	/* Don't allow changing the IRQ */
 	if (map->irq != dev->irq) {
-		pr_warn("%s: not change IRQ number %d\n", dev->name, dev->irq);
+		netdev_warn(dev, "not change IRQ number %d\n", dev->irq);
 		return -EOPNOTSUPP;
 	}
 
@@ -2098,7 +2086,7 @@ static int xgmac_hw_init(struct xgmac_priv_data * const priv)
 	ctrl_ids = priv->hw->mac->get_controller_version(priv->ioaddr);
 	priv->hw->ctrl_uid = (ctrl_ids & 0x00ff0000) >> 16;
 	priv->hw->ctrl_id = (ctrl_ids & 0x000000ff);
-	pr_info("xgmac - user ID: 0x%x, Controller ID: 0x%x\n",
+	pr_info("user ID: 0x%x, Controller ID: 0x%x\n",
 		priv->hw->ctrl_uid, priv->hw->ctrl_id);
 
 	/* get the H/W features */
@@ -2242,7 +2230,8 @@ struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
 
 	priv->xgmac_clk = clk_get(priv->device, XGMAC_RESOURCE_NAME);
 	if (IS_ERR(priv->xgmac_clk)) {
-		pr_warn("%s: warning: cannot get CSR clock\n", __func__);
+		netdev_warn(ndev, "%s: warning: cannot get CSR clock\n",
+			    __func__);
 		goto error_clk_get;
 	}
 
@@ -2260,8 +2249,8 @@ struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
 	/* MDIO bus Registration */
 	ret = xgmac_mdio_register(ndev);
 	if (ret < 0) {
-		pr_debug("%s: MDIO bus (id: %d) registration failed\n",
-			 __func__, priv->plat->bus_id);
+		netdev_dbg(ndev, "%s: MDIO bus (id: %d) registration failed\n",
+			   __func__, priv->plat->bus_id);
 		goto error_mdio_register;
 	}
 
@@ -2292,7 +2281,7 @@ int xgmac_dvr_remove(struct net_device *ndev)
 {
 	struct xgmac_priv_data *priv = netdev_priv(ndev);
 
-	pr_info("%s: removing driver\n", __func__);
+	netdev_info(ndev, "%s: removing driver\n", __func__);
 
 	priv->hw->dma->stop_rx(priv->ioaddr, XGMAC_RX_QUEUES);
 	priv->hw->dma->stop_tx(priv->ioaddr, XGMAC_TX_QUEUES);
diff --git a/drivers/net/ethernet/samsung/xgmac_mdio.c b/drivers/net/ethernet/samsung/xgmac_mdio.c
index 98cd311..5e1e40e 100644
--- a/drivers/net/ethernet/samsung/xgmac_mdio.c
+++ b/drivers/net/ethernet/samsung/xgmac_mdio.c
@@ -176,7 +176,7 @@ int xgmac_mdio_register(struct net_device *ndev)
 	/* allocate the new mdio bus */
 	mdio_bus = mdiobus_alloc();
 	if (!mdio_bus) {
-		pr_err("%s: mii bus allocation failed\n", __func__);
+		netdev_err(ndev, "%s: mii bus allocation failed\n", __func__);
 		return -ENOMEM;
 	}
 
@@ -198,7 +198,7 @@ int xgmac_mdio_register(struct net_device *ndev)
 	/* register with kernel subsystem */
 	err = mdiobus_register(mdio_bus);
 	if (err != 0) {
-		pr_err("mdiobus register failed\n");
+		netdev_err(ndev, "mdiobus register failed\n");
 		goto mdiobus_err;
 	}
 
@@ -236,16 +236,15 @@ int xgmac_mdio_register(struct net_device *ndev)
 				irq_str = irq_num;
 				break;
 			}
-			pr_info("%s: PHY ID %08x at %d IRQ %s (%s)%s\n",
-				ndev->name, phy->phy_id, phy_addr,
-				irq_str, dev_name(&phy->dev),
-				act ? " active" : "");
+			netdev_info(ndev, "PHY ID %08x at %d IRQ %s (%s)%s\n",
+				    phy->phy_id, phy_addr, irq_str,
+				    dev_name(&phy->dev), act ? " active" : "");
 			phy_found = 1;
 		}
 	}
 
 	if (!phy_found) {
-		pr_err("%s: PHY not found\n", ndev->name);
+		netdev_err(ndev, "PHY not found\n");
 		mdiobus_unregister(mdio_bus);
 		mdiobus_free(mdio_bus);
 		return -ENODEV;
diff --git a/drivers/net/ethernet/samsung/xgmac_platform.c b/drivers/net/ethernet/samsung/xgmac_platform.c
index f6b3d20..fb80c2c 100644
--- a/drivers/net/ethernet/samsung/xgmac_platform.c
+++ b/drivers/net/ethernet/samsung/xgmac_platform.c
@@ -121,10 +121,8 @@ static int xgmac_platform_probe(struct platform_device *pdev)
 			plat_dat = devm_kzalloc(&pdev->dev,
 					sizeof(struct xgmac_plat_data),
 					GFP_KERNEL);
-		if (!plat_dat) {
-			pr_err("%s: ERROR: no memory\n", __func__);
+		if (!plat_dat)
 			return  -ENOMEM;
-		}
 
 		ret = xgmac_probe_config_dt(pdev, plat_dat, &mac);
 		if (ret) {
-- 
1.8.1.2.459.gbcd45b4.dirty
