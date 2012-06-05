From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: [PATCH v3 net-next 3/5] gianfar: various coding style and whitespace cleanups
Date: Tue,  5 Jun 2012 15:42:13 +0200
Message-ID: <1338903735-24527-4-git-send-email-jan.ceuleers@computer.org>
References: <1338903735-24527-1-git-send-email-jan.ceuleers@computer.org>
Cc: Jiajun Wu <b06378@freescale.com>, Joe Perches <joe@perches.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay012.isp.belgacom.be ([195.238.6.179]:49477 "EHLO
	mailrelay012.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932207Ab2FENpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 09:45:08 -0400
In-Reply-To: <1338903735-24527-1-git-send-email-jan.ceuleers@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jan Ceuleers <jan.ceuleers@computer.org>
---
 drivers/net/ethernet/freescale/gianfar.c |  298 +++++++++++++++---------------
 1 file changed, 154 insertions(+), 144 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 3144560..ed0b136 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -113,7 +113,7 @@ static void gfar_timeout(struct net_device *dev);
 static int gfar_close(struct net_device *dev);
 struct sk_buff *gfar_new_skb(struct net_device *dev);
 static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
-		struct sk_buff *skb);
+			   struct sk_buff *skb);
 static int gfar_set_mac_address(struct net_device *dev);
 static int gfar_change_mtu(struct net_device *dev, int new_mtu);
 static irqreturn_t gfar_error(int irq, void *dev_id);
@@ -265,8 +265,8 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 		tx_queue->tx_bd_dma_base = addr;
 		tx_queue->dev = ndev;
 		/* enet DMA only understands physical addresses */
-		addr    += sizeof(struct txbd8) * tx_queue->tx_ring_size;
-		vaddr   += sizeof(struct txbd8) * tx_queue->tx_ring_size;
+		addr  += sizeof(struct txbd8) * tx_queue->tx_ring_size;
+		vaddr += sizeof(struct txbd8) * tx_queue->tx_ring_size;
 	}
 
 	/* Start the rx descriptor ring where the tx ring leaves off */
@@ -275,15 +275,16 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 		rx_queue->rx_bd_base = vaddr;
 		rx_queue->rx_bd_dma_base = addr;
 		rx_queue->dev = ndev;
-		addr    += sizeof(struct rxbd8) * rx_queue->rx_ring_size;
-		vaddr   += sizeof(struct rxbd8) * rx_queue->rx_ring_size;
+		addr  += sizeof(struct rxbd8) * rx_queue->rx_ring_size;
+		vaddr += sizeof(struct rxbd8) * rx_queue->rx_ring_size;
 	}
 
 	/* Setup the skbuff rings */
 	for (i = 0; i < priv->num_tx_queues; i++) {
 		tx_queue = priv->tx_queue[i];
 		tx_queue->tx_skbuff = kmalloc(sizeof(*tx_queue->tx_skbuff) *
-				  tx_queue->tx_ring_size, GFP_KERNEL);
+					      tx_queue->tx_ring_size,
+					      GFP_KERNEL);
 		if (!tx_queue->tx_skbuff) {
 			netif_err(priv, ifup, ndev,
 				  "Could not allocate tx_skbuff\n");
@@ -297,7 +298,8 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 	for (i = 0; i < priv->num_rx_queues; i++) {
 		rx_queue = priv->rx_queue[i];
 		rx_queue->rx_skbuff = kmalloc(sizeof(*rx_queue->rx_skbuff) *
-				  rx_queue->rx_ring_size, GFP_KERNEL);
+					      rx_queue->rx_ring_size,
+					      GFP_KERNEL);
 
 		if (!rx_queue->rx_skbuff) {
 			netif_err(priv, ifup, ndev,
@@ -326,15 +328,15 @@ static void gfar_init_tx_rx_base(struct gfar_private *priv)
 	int i;
 
 	baddr = &regs->tbase0;
-	for(i = 0; i < priv->num_tx_queues; i++) {
+	for (i = 0; i < priv->num_tx_queues; i++) {
 		gfar_write(baddr, priv->tx_queue[i]->tx_bd_dma_base);
-		baddr	+= 2;
+		baddr += 2;
 	}
 
 	baddr = &regs->rbase0;
-	for(i = 0; i < priv->num_rx_queues; i++) {
+	for (i = 0; i < priv->num_rx_queues; i++) {
 		gfar_write(baddr, priv->rx_queue[i]->rx_bd_dma_base);
-		baddr   += 2;
+		baddr += 2;
 	}
 }
 
@@ -430,12 +432,12 @@ static struct net_device_stats *gfar_get_stats(struct net_device *dev)
 
 	for (i = 0; i < priv->num_rx_queues; i++) {
 		rx_packets += priv->rx_queue[i]->stats.rx_packets;
-		rx_bytes += priv->rx_queue[i]->stats.rx_bytes;
+		rx_bytes   += priv->rx_queue[i]->stats.rx_bytes;
 		rx_dropped += priv->rx_queue[i]->stats.rx_dropped;
 	}
 
 	dev->stats.rx_packets = rx_packets;
-	dev->stats.rx_bytes = rx_bytes;
+	dev->stats.rx_bytes   = rx_bytes;
 	dev->stats.rx_dropped = rx_dropped;
 
 	for (i = 0; i < priv->num_tx_queues; i++) {
@@ -443,7 +445,7 @@ static struct net_device_stats *gfar_get_stats(struct net_device *dev)
 		tx_packets += priv->tx_queue[i]->stats.tx_packets;
 	}
 
-	dev->stats.tx_bytes = tx_bytes;
+	dev->stats.tx_bytes   = tx_bytes;
 	dev->stats.tx_packets = tx_packets;
 
 	return &dev->stats;
@@ -508,8 +510,8 @@ static bool gfar_is_vlan_on(struct gfar_private *priv)
 static inline int gfar_uses_fcb(struct gfar_private *priv)
 {
 	return gfar_is_vlan_on(priv) ||
-		(priv->ndev->features & NETIF_F_RXCSUM) ||
-		(priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER);
+	       (priv->ndev->features & NETIF_F_RXCSUM) ||
+	       (priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER);
 }
 
 static void free_tx_pointers(struct gfar_private *priv)
@@ -554,7 +556,7 @@ static void enable_napi(struct gfar_private *priv)
 }
 
 static int gfar_parse_group(struct device_node *np,
-		struct gfar_private *priv, const char *model)
+			    struct gfar_private *priv, const char *model)
 {
 	u32 *queue_mask;
 
@@ -580,15 +582,13 @@ static int gfar_parse_group(struct device_node *np,
 	priv->gfargrp[priv->num_grps].grp_id = priv->num_grps;
 	priv->gfargrp[priv->num_grps].priv = priv;
 	spin_lock_init(&priv->gfargrp[priv->num_grps].grplock);
-	if(priv->mode == MQ_MG_MODE) {
-		queue_mask = (u32 *)of_get_property(np,
-					"fsl,rx-bit-map", NULL);
-		priv->gfargrp[priv->num_grps].rx_bit_map =
-			queue_mask ?  *queue_mask :(DEFAULT_MAPPING >> priv->num_grps);
-		queue_mask = (u32 *)of_get_property(np,
-					"fsl,tx-bit-map", NULL);
-		priv->gfargrp[priv->num_grps].tx_bit_map =
-			queue_mask ? *queue_mask : (DEFAULT_MAPPING >> priv->num_grps);
+	if (priv->mode == MQ_MG_MODE) {
+		queue_mask = (u32 *)of_get_property(np, "fsl,rx-bit-map", NULL);
+		priv->gfargrp[priv->num_grps].rx_bit_map = queue_mask ?
+			*queue_mask : (DEFAULT_MAPPING >> priv->num_grps);
+		queue_mask = (u32 *)of_get_property(np, "fsl,tx-bit-map", NULL);
+		priv->gfargrp[priv->num_grps].tx_bit_map = queue_mask ?
+			*queue_mask : (DEFAULT_MAPPING >> priv->num_grps);
 	} else {
 		priv->gfargrp[priv->num_grps].rx_bit_map = 0xFF;
 		priv->gfargrp[priv->num_grps].tx_bit_map = 0xFF;
@@ -673,7 +673,7 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	} else {
 		priv->mode = SQ_SG_MODE;
 		err = gfar_parse_group(np, priv, model);
-		if(err)
+		if (err)
 			goto err_grp_init;
 	}
 
@@ -730,27 +730,27 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 		priv->device_flags |= FSL_GIANFAR_DEV_HAS_BUF_STASHING;
 
 	mac_addr = of_get_mac_address(np);
+
 	if (mac_addr)
 		memcpy(dev->dev_addr, mac_addr, ETH_ALEN);
 
 	if (model && !strcasecmp(model, "TSEC"))
-		priv->device_flags =
-			FSL_GIANFAR_DEV_HAS_GIGABIT |
-			FSL_GIANFAR_DEV_HAS_COALESCE |
-			FSL_GIANFAR_DEV_HAS_RMON |
-			FSL_GIANFAR_DEV_HAS_MULTI_INTR;
+		priv->device_flags = FSL_GIANFAR_DEV_HAS_GIGABIT |
+				     FSL_GIANFAR_DEV_HAS_COALESCE |
+				     FSL_GIANFAR_DEV_HAS_RMON |
+				     FSL_GIANFAR_DEV_HAS_MULTI_INTR;
+
 	if (model && !strcasecmp(model, "eTSEC"))
-		priv->device_flags =
-			FSL_GIANFAR_DEV_HAS_GIGABIT |
-			FSL_GIANFAR_DEV_HAS_COALESCE |
-			FSL_GIANFAR_DEV_HAS_RMON |
-			FSL_GIANFAR_DEV_HAS_MULTI_INTR |
-			FSL_GIANFAR_DEV_HAS_PADDING |
-			FSL_GIANFAR_DEV_HAS_CSUM |
-			FSL_GIANFAR_DEV_HAS_VLAN |
-			FSL_GIANFAR_DEV_HAS_MAGIC_PACKET |
-			FSL_GIANFAR_DEV_HAS_EXTENDED_HASH |
-			FSL_GIANFAR_DEV_HAS_TIMER;
+		priv->device_flags = FSL_GIANFAR_DEV_HAS_GIGABIT |
+				     FSL_GIANFAR_DEV_HAS_COALESCE |
+				     FSL_GIANFAR_DEV_HAS_RMON |
+				     FSL_GIANFAR_DEV_HAS_MULTI_INTR |
+				     FSL_GIANFAR_DEV_HAS_PADDING |
+				     FSL_GIANFAR_DEV_HAS_CSUM |
+				     FSL_GIANFAR_DEV_HAS_VLAN |
+				     FSL_GIANFAR_DEV_HAS_MAGIC_PACKET |
+				     FSL_GIANFAR_DEV_HAS_EXTENDED_HASH |
+				     FSL_GIANFAR_DEV_HAS_TIMER;
 
 	ctype = of_get_property(np, "phy-connection-type", NULL);
 
@@ -781,7 +781,7 @@ err_grp_init:
 }
 
 static int gfar_hwtstamp_ioctl(struct net_device *netdev,
-			struct ifreq *ifr, int cmd)
+			       struct ifreq *ifr, int cmd)
 {
 	struct hwtstamp_config config;
 	struct gfar_private *priv = netdev_priv(netdev);
@@ -851,6 +851,7 @@ static unsigned int reverse_bitmap(unsigned int bit_map, unsigned int max_qs)
 {
 	unsigned int new_bit_map = 0x0;
 	int mask = 0x1 << (max_qs - 1), i;
+
 	for (i = 0; i < max_qs; i++) {
 		if (bit_map & mask)
 			new_bit_map = new_bit_map + (1 << i);
@@ -936,22 +937,22 @@ static void gfar_detect_errata(struct gfar_private *priv)
 
 	/* MPC8313 Rev 2.0 and higher; All MPC837x */
 	if ((pvr == 0x80850010 && mod == 0x80b0 && rev >= 0x0020) ||
-			(pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
+	    (pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
 		priv->errata |= GFAR_ERRATA_74;
 
 	/* MPC8313 and MPC837x all rev */
 	if ((pvr == 0x80850010 && mod == 0x80b0) ||
-			(pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
+	    (pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
 		priv->errata |= GFAR_ERRATA_76;
 
 	/* MPC8313 and MPC837x all rev */
 	if ((pvr == 0x80850010 && mod == 0x80b0) ||
-			(pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
+	    (pvr == 0x80861010 && (mod & 0xfff9) == 0x80c0))
 		priv->errata |= GFAR_ERRATA_A002;
 
 	/* MPC8313 Rev < 2.0, MPC8548 rev 2.0 */
 	if ((pvr == 0x80850010 && mod == 0x80b0 && rev < 0x0020) ||
-			(pvr == 0x80210020 && mod == 0x8030 && rev == 0x0020))
+	    (pvr == 0x80210020 && mod == 0x8030 && rev == 0x0020))
 		priv->errata |= GFAR_ERRATA_12;
 
 	if (priv->errata)
@@ -1028,13 +1029,14 @@ static int gfar_probe(struct platform_device *ofdev)
 
 	/* Register for napi ...We are registering NAPI for each grp */
 	for (i = 0; i < priv->num_grps; i++)
-		netif_napi_add(dev, &priv->gfargrp[i].napi, gfar_poll, GFAR_DEV_WEIGHT);
+		netif_napi_add(dev, &priv->gfargrp[i].napi, gfar_poll,
+			       GFAR_DEV_WEIGHT);
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM) {
 		dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
-			NETIF_F_RXCSUM;
+				   NETIF_F_RXCSUM;
 		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG |
-			NETIF_F_RXCSUM | NETIF_F_HIGHDMA;
+				 NETIF_F_RXCSUM | NETIF_F_HIGHDMA;
 	}
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_VLAN) {
@@ -1083,7 +1085,7 @@ static int gfar_probe(struct platform_device *ofdev)
 		priv->padding = 0;
 
 	if (dev->features & NETIF_F_IP_CSUM ||
-			priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER)
+	    priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER)
 		dev->needed_headroom = GMAC_FCB_LEN;
 
 	/* Program the isrg regs only if number of grps > 1 */
@@ -1103,10 +1105,10 @@ static int gfar_probe(struct platform_device *ofdev)
 	 * basically reverses the queue numbers
 	 */
 	for (i = 0; i< priv->num_grps; i++) {
-		priv->gfargrp[i].tx_bit_map = reverse_bitmap(
-				priv->gfargrp[i].tx_bit_map, MAX_TX_QS);
-		priv->gfargrp[i].rx_bit_map = reverse_bitmap(
-				priv->gfargrp[i].rx_bit_map, MAX_RX_QS);
+		priv->gfargrp[i].tx_bit_map =
+			reverse_bitmap(priv->gfargrp[i].tx_bit_map, MAX_TX_QS);
+		priv->gfargrp[i].rx_bit_map =
+			reverse_bitmap(priv->gfargrp[i].rx_bit_map, MAX_RX_QS);
 	}
 
 	/* Calculate RSTAT, TSTAT, RQUEUE and TQUEUE values,
@@ -1114,16 +1116,18 @@ static int gfar_probe(struct platform_device *ofdev)
 	 */
 	for (grp_idx = 0; grp_idx < priv->num_grps; grp_idx++) {
 		priv->gfargrp[grp_idx].num_rx_queues = 0x0;
+
 		for_each_set_bit(i, &priv->gfargrp[grp_idx].rx_bit_map,
-				priv->num_rx_queues) {
+				 priv->num_rx_queues) {
 			priv->gfargrp[grp_idx].num_rx_queues++;
 			priv->rx_queue[i]->grp = &priv->gfargrp[grp_idx];
 			rstat = rstat | (RSTAT_CLEAR_RHALT >> i);
 			rqueue = rqueue | ((RQUEUE_EN0 | RQUEUE_EX0) >> i);
 		}
 		priv->gfargrp[grp_idx].num_tx_queues = 0x0;
+
 		for_each_set_bit(i, &priv->gfargrp[grp_idx].tx_bit_map,
-				priv->num_tx_queues) {
+				 priv->num_tx_queues) {
 			priv->gfargrp[grp_idx].num_tx_queues++;
 			priv->tx_queue[i]->grp = &priv->gfargrp[grp_idx];
 			tstat = tstat | (TSTAT_CLEAR_THALT >> i);
@@ -1169,7 +1173,8 @@ static int gfar_probe(struct platform_device *ofdev)
 	}
 
 	device_init_wakeup(&dev->dev,
-		priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
+			   priv->device_flags &
+			   FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
 
 	/* fill out IRQ number and name fields */
 	for (i = 0; i < priv->num_grps; i++) {
@@ -1200,7 +1205,7 @@ static int gfar_probe(struct platform_device *ofdev)
 	for (i = 0; i < priv->num_rx_queues; i++)
 		netdev_info(dev, "RX BD ring size for Q[%d]: %d\n",
 			    i, priv->rx_queue[i]->rx_ring_size);
-	for(i = 0; i < priv->num_tx_queues; i++)
+	for (i = 0; i < priv->num_tx_queues; i++)
 		netdev_info(dev, "TX BD ring size for Q[%d]: %d\n",
 			    i, priv->tx_queue[i]->tx_ring_size);
 
@@ -1247,7 +1252,8 @@ static int gfar_suspend(struct device *dev)
 	u32 tempval;
 
 	int magic_packet = priv->wol_en &&
-		(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
+			   (priv->device_flags &
+			    FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
 
 	netif_device_detach(ndev);
 
@@ -1299,7 +1305,8 @@ static int gfar_resume(struct device *dev)
 	unsigned long flags;
 	u32 tempval;
 	int magic_packet = priv->wol_en &&
-		(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
+			   (priv->device_flags &
+			    FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
 
 	if (!netif_running(ndev)) {
 		netif_device_attach(ndev);
@@ -1398,8 +1405,9 @@ static phy_interface_t gfar_get_interface(struct net_device *dev)
 	}
 
 	if (ecntrl & ECNTRL_REDUCED_MODE) {
-		if (ecntrl & ECNTRL_REDUCED_MII_MODE)
+		if (ecntrl & ECNTRL_REDUCED_MII_MODE) {
 			return PHY_INTERFACE_MODE_RMII;
+		}
 		else {
 			phy_interface_t interface = priv->interface;
 
@@ -1494,11 +1502,12 @@ static void gfar_configure_serdes(struct net_device *dev)
 	phy_write(tbiphy, MII_TBICON, TBICON_CLK_SELECT);
 
 	phy_write(tbiphy, MII_ADVERTISE,
-			ADVERTISE_1000XFULL | ADVERTISE_1000XPAUSE |
-			ADVERTISE_1000XPSE_ASYM);
+		  ADVERTISE_1000XFULL | ADVERTISE_1000XPAUSE |
+		  ADVERTISE_1000XPSE_ASYM);
 
-	phy_write(tbiphy, MII_BMCR, BMCR_ANENABLE |
-			BMCR_ANRESTART | BMCR_FULLDPLX | BMCR_SPEED1000);
+	phy_write(tbiphy, MII_BMCR,
+		  BMCR_ANENABLE | BMCR_ANRESTART | BMCR_FULLDPLX |
+		  BMCR_SPEED1000);
 }
 
 static void init_registers(struct net_device *dev)
@@ -1594,8 +1603,8 @@ static void gfar_halt_nodisable(struct net_device *dev)
 	regs = priv->gfargrp[0].regs;
 	/* Stop the DMA, and wait for it to stop */
 	tempval = gfar_read(&regs->dmactrl);
-	if ((tempval & (DMACTRL_GRS | DMACTRL_GTS))
-	    != (DMACTRL_GRS | DMACTRL_GTS)) {
+	if ((tempval & (DMACTRL_GRS | DMACTRL_GTS)) !=
+	    (DMACTRL_GRS | DMACTRL_GTS)) {
 		int ret;
 
 		tempval |= (DMACTRL_GRS | DMACTRL_GTS);
@@ -1660,7 +1669,7 @@ void stop_gfar(struct net_device *dev)
 	} else {
 		for (i = 0; i < priv->num_grps; i++)
 			free_irq(priv->gfargrp[i].interruptTransmit,
-					&priv->gfargrp[i]);
+				 &priv->gfargrp[i]);
 	}
 
 	free_skb_resources(priv);
@@ -1679,13 +1688,13 @@ static void free_skb_tx_queue(struct gfar_priv_tx_q *tx_queue)
 			continue;
 
 		dma_unmap_single(&priv->ofdev->dev, txbdp->bufPtr,
-				txbdp->length, DMA_TO_DEVICE);
+				 txbdp->length, DMA_TO_DEVICE);
 		txbdp->lstatus = 0;
 		for (j = 0; j < skb_shinfo(tx_queue->tx_skbuff[i])->nr_frags;
-				j++) {
+		     j++) {
 			txbdp++;
 			dma_unmap_page(&priv->ofdev->dev, txbdp->bufPtr,
-					txbdp->length, DMA_TO_DEVICE);
+				       txbdp->length, DMA_TO_DEVICE);
 		}
 		txbdp++;
 		dev_kfree_skb_any(tx_queue->tx_skbuff[i]);
@@ -1705,8 +1714,8 @@ static void free_skb_rx_queue(struct gfar_priv_rx_q *rx_queue)
 	for (i = 0; i < rx_queue->rx_ring_size; i++) {
 		if (rx_queue->rx_skbuff[i]) {
 			dma_unmap_single(&priv->ofdev->dev,
-					rxbdp->bufPtr, priv->rx_buffer_size,
-					DMA_FROM_DEVICE);
+					 rxbdp->bufPtr, priv->rx_buffer_size,
+					 DMA_FROM_DEVICE);
 			dev_kfree_skb_any(rx_queue->rx_skbuff[i]);
 			rx_queue->rx_skbuff[i] = NULL;
 		}
@@ -1729,24 +1738,25 @@ static void free_skb_resources(struct gfar_private *priv)
 	/* Go through all the buffer descriptors and free their data buffers */
 	for (i = 0; i < priv->num_tx_queues; i++) {
 		struct netdev_queue *txq;
+
 		tx_queue = priv->tx_queue[i];
 		txq = netdev_get_tx_queue(tx_queue->dev, tx_queue->qindex);
-		if(tx_queue->tx_skbuff)
+		if (tx_queue->tx_skbuff)
 			free_skb_tx_queue(tx_queue);
 		netdev_tx_reset_queue(txq);
 	}
 
 	for (i = 0; i < priv->num_rx_queues; i++) {
 		rx_queue = priv->rx_queue[i];
-		if(rx_queue->rx_skbuff)
+		if (rx_queue->rx_skbuff)
 			free_skb_rx_queue(rx_queue);
 	}
 
 	dma_free_coherent(&priv->ofdev->dev,
-			sizeof(struct txbd8) * priv->total_tx_ring_size +
-			sizeof(struct rxbd8) * priv->total_rx_ring_size,
-			priv->tx_queue[0]->tx_bd_base,
-			priv->tx_queue[0]->tx_bd_dma_base);
+			  sizeof(struct txbd8) * priv->total_tx_ring_size +
+			  sizeof(struct rxbd8) * priv->total_rx_ring_size,
+			  priv->tx_queue[0]->tx_bd_base,
+			  priv->tx_queue[0]->tx_bd_dma_base);
 	skb_queue_purge(&priv->rx_recycle);
 }
 
@@ -1785,7 +1795,7 @@ void gfar_start(struct net_device *dev)
 }
 
 void gfar_configure_coalescing(struct gfar_private *priv,
-	unsigned long tx_mask, unsigned long rx_mask)
+			       unsigned long tx_mask, unsigned long rx_mask)
 {
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
 	u32 __iomem *baddr;
@@ -1795,11 +1805,11 @@ void gfar_configure_coalescing(struct gfar_private *priv,
 	 * multiple queues, there's only single reg to program
 	 */
 	gfar_write(&regs->txic, 0);
-	if(likely(priv->tx_queue[0]->txcoalescing))
+	if (likely(priv->tx_queue[0]->txcoalescing))
 		gfar_write(&regs->txic, priv->tx_queue[0]->txic);
 
 	gfar_write(&regs->rxic, 0);
-	if(unlikely(priv->rx_queue[0]->rxcoalescing))
+	if (unlikely(priv->rx_queue[0]->rxcoalescing))
 		gfar_write(&regs->rxic, priv->rx_queue[0]->rxic);
 
 	if (priv->mode == MQ_MG_MODE) {
@@ -1834,8 +1844,8 @@ static int register_grp_irqs(struct gfar_priv_grp *grp)
 		/* Install our interrupt handlers for Error,
 		 * Transmit, and Receive
 		 */
-		if ((err = request_irq(grp->interruptError, gfar_error, 0,
-				grp->int_name_er,grp)) < 0) {
+		if ((err = request_irq(grp->interruptError, gfar_error,
+				       0, grp->int_name_er, grp)) < 0) {
 			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
 				  grp->interruptError);
 
@@ -1843,21 +1853,21 @@ static int register_grp_irqs(struct gfar_priv_grp *grp)
 		}
 
 		if ((err = request_irq(grp->interruptTransmit, gfar_transmit,
-				0, grp->int_name_tx, grp)) < 0) {
+				       0, grp->int_name_tx, grp)) < 0) {
 			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
 				  grp->interruptTransmit);
 			goto tx_irq_fail;
 		}
 
-		if ((err = request_irq(grp->interruptReceive, gfar_receive, 0,
-				grp->int_name_rx, grp)) < 0) {
+		if ((err = request_irq(grp->interruptReceive, gfar_receive,
+				       0, grp->int_name_rx, grp)) < 0) {
 			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
 				  grp->interruptReceive);
 			goto rx_irq_fail;
 		}
 	} else {
-		if ((err = request_irq(grp->interruptTransmit, gfar_interrupt, 0,
-				grp->int_name_tx, grp)) < 0) {
+		if ((err = request_irq(grp->interruptTransmit, gfar_interrupt,
+				       0, grp->int_name_tx, grp)) < 0) {
 			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
 				  grp->interruptTransmit);
 			goto err_irq_fail;
@@ -1964,7 +1974,7 @@ static inline struct txfcb *gfar_add_fcb(struct sk_buff *skb)
 }
 
 static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb,
-		int fcb_length)
+				    int fcb_length)
 {
 	u8 flags = 0;
 
@@ -2001,7 +2011,7 @@ void inline gfar_tx_vlan(struct sk_buff *skb, struct txfcb *fcb)
 }
 
 static inline struct txbd8 *skip_txbd(struct txbd8 *bdp, int stride,
-			       struct txbd8 *base, int ring_size)
+				      struct txbd8 *base, int ring_size)
 {
 	struct txbd8 *new_bd = bdp + stride;
 
@@ -2009,7 +2019,7 @@ static inline struct txbd8 *skip_txbd(struct txbd8 *bdp, int stride,
 }
 
 static inline struct txbd8 *next_txbd(struct txbd8 *bdp, struct txbd8 *base,
-		int ring_size)
+				      int ring_size)
 {
 	return skip_txbd(bdp, 1, base, ring_size);
 }
@@ -2035,8 +2045,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * before start of transmission.
 	 */
 	if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_76) &&
-			skb->ip_summed == CHECKSUM_PARTIAL &&
-			skb->len > 2500)) {
+		     skb->ip_summed == CHECKSUM_PARTIAL &&
+		     skb->len > 2500)) {
 		int ret;
 
 		ret = skb_checksum_help(skb);
@@ -2052,16 +2062,16 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* check if time stamp should be generated */
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
-			priv->hwts_tx_en)) {
+		     priv->hwts_tx_en)) {
 		do_tstamp = 1;
 		fcb_length = GMAC_FCB_LEN + GMAC_TXPAL_LEN;
 	}
 
 	/* make space for additional header when fcb is needed */
 	if (((skb->ip_summed == CHECKSUM_PARTIAL) ||
-			vlan_tx_tag_present(skb) ||
-			unlikely(do_tstamp)) &&
-			(skb_headroom(skb) < fcb_length)) {
+	     vlan_tx_tag_present(skb) ||
+	     unlikely(do_tstamp)) &&
+	    (skb_headroom(skb) < fcb_length)) {
 		struct sk_buff *skb_new;
 
 		skb_new = skb_realloc_headroom(skb, fcb_length);
@@ -2105,12 +2115,12 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Time stamp insertion requires one additional TxBD */
 	if (unlikely(do_tstamp))
 		txbdp_tstamp = txbdp = next_txbd(txbdp, base,
-				tx_queue->tx_ring_size);
+						 tx_queue->tx_ring_size);
 
 	if (nr_frags == 0) {
 		if (unlikely(do_tstamp))
 			txbdp_tstamp->lstatus |= BD_LFLAG(TXBD_LAST |
-					TXBD_INTERRUPT);
+							  TXBD_INTERRUPT);
 		else
 			lstatus |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
 	} else {
@@ -2122,7 +2132,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			length = skb_shinfo(skb)->frags[i].size;
 
 			lstatus = txbdp->lstatus | length |
-				BD_LFLAG(TXBD_READY);
+				  BD_LFLAG(TXBD_READY);
 
 			/* Handle the last BD specially */
 			if (i == nr_frags - 1)
@@ -2152,8 +2162,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (CHECKSUM_PARTIAL == skb->ip_summed) {
 		fcb = gfar_add_fcb(skb);
 		/* as specified by errata */
-		if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_12)
-			     && ((unsigned long)fcb % 0x20) > 0x18)) {
+		if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_12) &&
+			     ((unsigned long)fcb % 0x20) > 0x18)) {
 			__skb_pull(skb, GMAC_FCB_LEN);
 			skb_checksum_help(skb);
 		} else {
@@ -2181,7 +2191,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	txbdp_start->bufPtr = dma_map_single(&priv->ofdev->dev, skb->data,
-			skb_headlen(skb), DMA_TO_DEVICE);
+					     skb_headlen(skb), DMA_TO_DEVICE);
 
 	/* If time stamping is requested one additional TxBD must be set up. The
 	 * first TxBD points to the FCB and must have a data length of
@@ -2191,7 +2201,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(do_tstamp)) {
 		txbdp_tstamp->bufPtr = txbdp_start->bufPtr + fcb_length;
 		txbdp_tstamp->lstatus |= BD_LFLAG(TXBD_READY) |
-				(skb_headlen(skb) - fcb_length);
+					 (skb_headlen(skb) - fcb_length);
 		lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | GMAC_FCB_LEN;
 	} else {
 		lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | skb_headlen(skb);
@@ -2231,7 +2241,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * (wrapping if necessary)
 	 */
 	tx_queue->skb_curtx = (tx_queue->skb_curtx + 1) &
-		TX_RING_MOD_MASK(tx_queue->tx_ring_size);
+			      TX_RING_MOD_MASK(tx_queue->tx_ring_size);
 
 	tx_queue->cur_tx = next_txbd(txbdp, base, tx_queue->tx_ring_size);
 
@@ -2365,9 +2375,8 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 
 	frame_size += priv->padding;
 
-	tempsize =
-	    (frame_size & ~(INCREMENTAL_BUFFER_SIZE - 1)) +
-	    INCREMENTAL_BUFFER_SIZE;
+	tempsize = (frame_size & ~(INCREMENTAL_BUFFER_SIZE - 1)) +
+		   INCREMENTAL_BUFFER_SIZE;
 
 	/* Only stop and start the controller if it isn't already
 	 * stopped, and we changed something
@@ -2389,7 +2398,7 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 	tempval = gfar_read(&regs->maccfg2);
 
 	if (priv->rx_buffer_size > DEFAULT_RX_BUFFER_SIZE ||
-			gfar_has_errata(priv, GFAR_ERRATA_74))
+	    gfar_has_errata(priv, GFAR_ERRATA_74))
 		tempval |= (MACCFG2_HUGEFRAME | MACCFG2_LENGTHCHECK);
 	else
 		tempval &= ~(MACCFG2_HUGEFRAME | MACCFG2_LENGTHCHECK);
@@ -2410,7 +2419,7 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 static void gfar_reset_task(struct work_struct *work)
 {
 	struct gfar_private *priv = container_of(work, struct gfar_private,
-			reset_task);
+						 reset_task);
 	struct net_device *dev = priv->ndev;
 
 	if (dev->flags & IFF_UP) {
@@ -2437,7 +2446,7 @@ static void gfar_align_skb(struct sk_buff *skb)
 	 * as many bytes as needed to align the data properly
 	 */
 	skb_reserve(skb, RXBUF_ALIGNMENT -
-		(((unsigned long) skb->data) & (RXBUF_ALIGNMENT - 1)));
+		    (((unsigned long) skb->data) & (RXBUF_ALIGNMENT - 1)));
 }
 
 /* Interrupt Handler for Transmit complete */
@@ -2485,7 +2494,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 
 		/* Only clean completed frames */
 		if ((lstatus & BD_LFLAG(TXBD_READY)) &&
-				(lstatus & BD_LENGTH_MASK))
+		    (lstatus & BD_LENGTH_MASK))
 			break;
 
 		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)) {
@@ -2495,11 +2504,12 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 			buflen = bdp->length;
 
 		dma_unmap_single(&priv->ofdev->dev, bdp->bufPtr,
-				buflen, DMA_TO_DEVICE);
+				 buflen, DMA_TO_DEVICE);
 
 		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)) {
 			struct skb_shared_hwtstamps shhwtstamps;
 			u64 *ns = (u64*) (((u32)skb->data + 0x10) & ~0x7);
+
 			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
 			shhwtstamps.hwtstamp = ns_to_ktime(*ns);
 			skb_pull(skb, GMAC_FCB_LEN + GMAC_TXPAL_LEN);
@@ -2512,10 +2522,8 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 		bdp = next_txbd(bdp, base, tx_ring_size);
 
 		for (i = 0; i < frags; i++) {
-			dma_unmap_page(&priv->ofdev->dev,
-					bdp->bufPtr,
-					bdp->length,
-					DMA_TO_DEVICE);
+			dma_unmap_page(&priv->ofdev->dev, bdp->bufPtr,
+				       bdp->length, DMA_TO_DEVICE);
 			bdp->lstatus &= BD_LFLAG(TXBD_WRAP);
 			bdp = next_txbd(bdp, base, tx_ring_size);
 		}
@@ -2526,8 +2534,8 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 		 * we add this skb back into the pool, if it's the right size
 		 */
 		if (skb_queue_len(&priv->rx_recycle) < rx_queue->rx_ring_size &&
-				skb_recycle_check(skb, priv->rx_buffer_size +
-					RXBUF_ALIGNMENT)) {
+		    skb_recycle_check(skb, priv->rx_buffer_size +
+				      RXBUF_ALIGNMENT)) {
 			gfar_align_skb(skb);
 			skb_queue_head(&priv->rx_recycle, skb);
 		} else
@@ -2536,7 +2544,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 		tx_queue->tx_skbuff[skb_dirtytx] = NULL;
 
 		skb_dirtytx = (skb_dirtytx + 1) &
-			TX_RING_MOD_MASK(tx_ring_size);
+			      TX_RING_MOD_MASK(tx_ring_size);
 
 		howmany++;
 		spin_lock_irqsave(&tx_queue->txlock, flags);
@@ -2583,7 +2591,7 @@ static irqreturn_t gfar_transmit(int irq, void *grp_id)
 }
 
 static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
-		struct sk_buff *skb)
+			   struct sk_buff *skb)
 {
 	struct net_device *dev = rx_queue->dev;
 	struct gfar_private *priv = netdev_priv(dev);
@@ -2700,6 +2708,7 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	if (priv->hwts_rx_en) {
 		struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
 		u64 *ns = (u64 *) skb->data;
+
 		memset(shhwtstamps, 0, sizeof(*shhwtstamps));
 		shhwtstamps->hwtstamp = ns_to_ktime(*ns);
 	}
@@ -2752,6 +2761,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 
 	while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
 		struct sk_buff *newskb;
+
 		rmb();
 
 		/* Add another skb for the future */
@@ -2760,15 +2770,15 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 		skb = rx_queue->rx_skbuff[rx_queue->skb_currx];
 
 		dma_unmap_single(&priv->ofdev->dev, bdp->bufPtr,
-				priv->rx_buffer_size, DMA_FROM_DEVICE);
+				 priv->rx_buffer_size, DMA_FROM_DEVICE);
 
 		if (unlikely(!(bdp->status & RXBD_ERR) &&
-				bdp->length > priv->rx_buffer_size))
+			     bdp->length > priv->rx_buffer_size))
 			bdp->status = RXBD_LARGE;
 
 		/* We drop the frame if we failed to allocate a new buffer */
 		if (unlikely(!newskb || !(bdp->status & RXBD_LAST) ||
-				 bdp->status & RXBD_ERR)) {
+			     bdp->status & RXBD_ERR)) {
 			count_errors(bdp->status, dev);
 
 			if (unlikely(!newskb))
@@ -2787,7 +2797,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 				rx_queue->stats.rx_bytes += pkt_len;
 				skb_record_rx_queue(skb, rx_queue->qindex);
 				gfar_process_frame(dev, skb, amount_pull,
-						&rx_queue->grp->napi);
+						   &rx_queue->grp->napi);
 
 			} else {
 				netif_warn(priv, rx_err, dev, "Missing skb!\n");
@@ -2806,9 +2816,8 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 		bdp = next_bd(bdp, base, rx_queue->rx_ring_size);
 
 		/* update to point at the next skb */
-		rx_queue->skb_currx =
-		    (rx_queue->skb_currx + 1) &
-		    RX_RING_MOD_MASK(rx_queue->rx_ring_size);
+		rx_queue->skb_currx = (rx_queue->skb_currx + 1) &
+				      RX_RING_MOD_MASK(rx_queue->rx_ring_size);
 	}
 
 	/* Update the current rxbd pointer to be the next one */
@@ -2819,8 +2828,8 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 
 static int gfar_poll(struct napi_struct *napi, int budget)
 {
-	struct gfar_priv_grp *gfargrp = container_of(napi,
-			struct gfar_priv_grp, napi);
+	struct gfar_priv_grp *gfargrp =
+		container_of(napi, struct gfar_priv_grp, napi);
 	struct gfar_private *priv = gfargrp->priv;
 	struct gfar __iomem *regs = gfargrp->regs;
 	struct gfar_priv_tx_q *tx_queue = NULL;
@@ -2839,7 +2848,6 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	gfar_write(&regs->ievent, IEVENT_RTX_MASK);
 
 	while (num_queues && left_over_budget) {
-
 		budget_per_queue = left_over_budget/num_queues;
 		left_over_budget = 0;
 
@@ -2850,12 +2858,13 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 			tx_queue = priv->tx_queue[rx_queue->qindex];
 
 			tx_cleaned += gfar_clean_tx_ring(tx_queue);
-			rx_cleaned_per_queue = gfar_clean_rx_ring(rx_queue,
-							budget_per_queue);
+			rx_cleaned_per_queue =
+				gfar_clean_rx_ring(rx_queue, budget_per_queue);
 			rx_cleaned += rx_cleaned_per_queue;
-			if(rx_cleaned_per_queue < budget_per_queue) {
+			if (rx_cleaned_per_queue < budget_per_queue) {
 				left_over_budget = left_over_budget +
-					(budget_per_queue - rx_cleaned_per_queue);
+					(budget_per_queue -
+					 rx_cleaned_per_queue);
 				set_bit(i, &serviced_queues);
 				num_queues--;
 			}
@@ -2876,8 +2885,8 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 		/* If we are coalescing interrupts, update the timer
 		 * Otherwise, clear it
 		 */
-		gfar_configure_coalescing(priv,
-				gfargrp->rx_bit_map, gfargrp->tx_bit_map);
+		gfar_configure_coalescing(priv, gfargrp->rx_bit_map,
+					  gfargrp->tx_bit_map);
 	}
 
 	return rx_cleaned;
@@ -2900,7 +2909,7 @@ static void gfar_netpoll(struct net_device *dev)
 			disable_irq(priv->gfargrp[i].interruptReceive);
 			disable_irq(priv->gfargrp[i].interruptError);
 			gfar_interrupt(priv->gfargrp[i].interruptTransmit,
-						&priv->gfargrp[i]);
+				       &priv->gfargrp[i]);
 			enable_irq(priv->gfargrp[i].interruptError);
 			enable_irq(priv->gfargrp[i].interruptReceive);
 			enable_irq(priv->gfargrp[i].interruptTransmit);
@@ -2909,7 +2918,7 @@ static void gfar_netpoll(struct net_device *dev)
 		for (i = 0; i < priv->num_grps; i++) {
 			disable_irq(priv->gfargrp[i].interruptTransmit);
 			gfar_interrupt(priv->gfargrp[i].interruptTransmit,
-						&priv->gfargrp[i]);
+				       &priv->gfargrp[i]);
 			enable_irq(priv->gfargrp[i].interruptTransmit);
 		}
 	}
@@ -3125,7 +3134,7 @@ static void gfar_clear_exact_match(struct net_device *dev)
 	int idx;
 	static const u8 zero_arr[ETH_ALEN] = {0, 0, 0, 0, 0, 0};
 
-	for(idx = 1;idx < GFAR_EM_NUM + 1;idx++)
+	for (idx = 1; idx < GFAR_EM_NUM + 1; idx++)
 		gfar_set_mac_for_addr(dev, idx, zero_arr);
 }
 
@@ -3208,7 +3217,8 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 
 	/* Hmm... */
 	if (netif_msg_rx_err(priv) || netif_msg_tx_err(priv))
-		netdev_dbg(dev, "error interrupt (ievent=0x%08x imask=0x%08x)\n",
+		netdev_dbg(dev,
+			   "error interrupt (ievent=0x%08x imask=0x%08x)\n",
 			   events, gfar_read(&regs->imask));
 
 	/* Update the error counters */
-- 
1.7.9.5
