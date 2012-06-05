From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: [PATCH v3 net-next 2/5] gianfar: comment cleanup
Date: Tue,  5 Jun 2012 15:42:12 +0200
Message-ID: <1338903735-24527-3-git-send-email-jan.ceuleers@computer.org>
References: <1338903735-24527-1-git-send-email-jan.ceuleers@computer.org>
Cc: Jiajun Wu <b06378@freescale.com>, Joe Perches <joe@perches.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay012.isp.belgacom.be ([195.238.6.179]:49456 "EHLO
	mailrelay012.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756215Ab2FENpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 09:45:07 -0400
In-Reply-To: <1338903735-24527-1-git-send-email-jan.ceuleers@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jan Ceuleers <jan.ceuleers@computer.org>
---
 drivers/net/ethernet/freescale/gianfar.c |  155 ++++++++++++++++--------------
 1 file changed, 83 insertions(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 5ca7b9e..3144560 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1,5 +1,4 @@
-/*
- * drivers/net/ethernet/freescale/gianfar.c
+/* drivers/net/ethernet/freescale/gianfar.c
  *
  * Gianfar Ethernet Driver
  * This driver is designed for the non-CPM ethernet controllers
@@ -405,7 +404,8 @@ static void gfar_init_mac(struct net_device *ndev)
 	gfar_write(&regs->attreli, attrs);
 
 	/* Start with defaults, and add stashing or locking
-	 * depending on the approprate variables */
+	 * depending on the approprate variables
+	 */
 	attrs = ATTR_INIT_SETTINGS;
 
 	if (priv->bd_stash_en)
@@ -652,7 +652,7 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	priv->num_rx_queues = num_rx_qs;
 	priv->num_grps = 0x0;
 
-	/* Init Rx queue filer rule set linked list*/
+	/* Init Rx queue filer rule set linked list */
 	INIT_LIST_HEAD(&priv->rx_list.list);
 	priv->rx_list.count = 0;
 	mutex_init(&priv->rx_queue_access);
@@ -960,7 +960,8 @@ static void gfar_detect_errata(struct gfar_private *priv)
 }
 
 /* Set up the ethernet device structure, private data,
- * and anything else we need before we start */
+ * and anything else we need before we start
+ */
 static int gfar_probe(struct platform_device *ofdev)
 {
 	u32 tempval;
@@ -991,8 +992,9 @@ static int gfar_probe(struct platform_device *ofdev)
 
 	gfar_detect_errata(priv);
 
-	/* Stop the DMA engine now, in case it was running before */
-	/* (The firmware could have used it, and left it running). */
+	/* Stop the DMA engine now, in case it was running before
+	 * (The firmware could have used it, and left it running).
+	 */
 	gfar_halt(dev);
 
 	/* Reset MAC layer */
@@ -1098,7 +1100,8 @@ static int gfar_probe(struct platform_device *ofdev)
 
 	/* Need to reverse the bit maps as  bit_map's MSB is q0
 	 * but, for_each_set_bit parses from right to left, which
-	 * basically reverses the queue numbers */
+	 * basically reverses the queue numbers
+	 */
 	for (i = 0; i< priv->num_grps; i++) {
 		priv->gfargrp[i].tx_bit_map = reverse_bitmap(
 				priv->gfargrp[i].tx_bit_map, MAX_TX_QS);
@@ -1107,7 +1110,8 @@ static int gfar_probe(struct platform_device *ofdev)
 	}
 
 	/* Calculate RSTAT, TSTAT, RQUEUE and TQUEUE values,
-	 * also assign queues to groups */
+	 * also assign queues to groups
+	 */
 	for (grp_idx = 0; grp_idx < priv->num_grps; grp_idx++) {
 		priv->gfargrp[grp_idx].num_rx_queues = 0x0;
 		for_each_set_bit(i, &priv->gfargrp[grp_idx].rx_bit_map,
@@ -1149,7 +1153,7 @@ static int gfar_probe(struct platform_device *ofdev)
 		priv->rx_queue[i]->rxic = DEFAULT_RXIC;
 	}
 
-	/* always enable rx filer*/
+	/* always enable rx filer */
 	priv->rx_filer_enable = 1;
 	/* Enable most messages by default */
 	priv->msg_enable = (NETIF_MSG_IFUP << 1 ) - 1;
@@ -1189,8 +1193,9 @@ static int gfar_probe(struct platform_device *ofdev)
 	/* Print out the device info */
 	netdev_info(dev, "mac: %pM\n", dev->dev_addr);
 
-	/* Even more device info helps when determining which kernel */
-	/* provided which set of benchmarks. */
+	/* Even more device info helps when determining which kernel
+	 * provided which set of benchmarks.
+	 */
 	netdev_info(dev, "Running with NAPI enabled\n");
 	for (i = 0; i < priv->num_rx_queues; i++)
 		netdev_info(dev, "RX BD ring size for Q[%d]: %d\n",
@@ -1398,8 +1403,7 @@ static phy_interface_t gfar_get_interface(struct net_device *dev)
 		else {
 			phy_interface_t interface = priv->interface;
 
-			/*
-			 * This isn't autodetected right now, so it must
+			/* This isn't autodetected right now, so it must
 			 * be set by the device tree or platform code.
 			 */
 			if (interface == PHY_INTERFACE_MODE_RGMII_ID)
@@ -1453,8 +1457,7 @@ static int init_phy(struct net_device *dev)
 	return 0;
 }
 
-/*
- * Initialize TBI PHY interface for communicating with the
+/* Initialize TBI PHY interface for communicating with the
  * SERDES lynx PHY on the chip.  We communicate with this PHY
  * through the MDIO bus on each controller, treating it as a
  * "normal" PHY at the address found in the TBIPA register.  We assume
@@ -1479,8 +1482,7 @@ static void gfar_configure_serdes(struct net_device *dev)
 		return;
 	}
 
-	/*
-	 * If the link is already up, we must already be ok, and don't need to
+	/* If the link is already up, we must already be ok, and don't need to
 	 * configure and reset the TBI<->SerDes link.  Maybe U-Boot configured
 	 * everything for us?  Resetting it takes the link down and requires
 	 * several seconds for it to come back.
@@ -1554,15 +1556,13 @@ static int __gfar_is_rx_idle(struct gfar_private *priv)
 {
 	u32 res;
 
-	/*
-	 * Normaly TSEC should not hang on GRS commands, so we should
+	/* Normaly TSEC should not hang on GRS commands, so we should
 	 * actually wait for IEVENT_GRSC flag.
 	 */
 	if (likely(!gfar_has_errata(priv, GFAR_ERRATA_A002)))
 		return 0;
 
-	/*
-	 * Read the eTSEC register at offset 0xD1C. If bits 7-14 are
+	/* Read the eTSEC register at offset 0xD1C. If bits 7-14 are
 	 * the same as bits 23-30, the eTSEC Rx is assumed to be idle
 	 * and the Rx can be safely reset.
 	 */
@@ -1718,7 +1718,8 @@ static void free_skb_rx_queue(struct gfar_priv_rx_q *rx_queue)
 }
 
 /* If there are any tx skbs or rx skbs still around, free them.
- * Then free tx_skbuff and rx_skbuff */
+ * Then free tx_skbuff and rx_skbuff
+ */
 static void free_skb_resources(struct gfar_private *priv)
 {
 	struct gfar_priv_tx_q *tx_queue = NULL;
@@ -1827,10 +1828,12 @@ static int register_grp_irqs(struct gfar_priv_grp *grp)
 	int err;
 
 	/* If the device has multiple interrupts, register for
-	 * them.  Otherwise, only register for the one */
+	 * them.  Otherwise, only register for the one
+	 */
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
 		/* Install our interrupt handlers for Error,
-		 * Transmit, and Receive */
+		 * Transmit, and Receive
+		 */
 		if ((err = request_irq(grp->interruptError, gfar_error, 0,
 				grp->int_name_er,grp)) < 0) {
 			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
@@ -1914,8 +1917,9 @@ irq_fail:
 	return err;
 }
 
-/* Called when something needs to use the ethernet device */
-/* Returns 0 for success. */
+/* Called when something needs to use the ethernet device
+ * Returns 0 for success.
+ */
 static int gfar_enet_open(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
@@ -1970,8 +1974,9 @@ static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb,
 	 */
 	flags = TXFCB_DEFAULT;
 
-	/* Tell the controller what the protocol is */
-	/* And provide the already calculated phcs */
+	/* Tell the controller what the protocol is
+	 * And provide the already calculated phcs
+	 */
 	if (ip_hdr(skb)->protocol == IPPROTO_UDP) {
 		flags |= TXFCB_UDP;
 		fcb->phcs = udp_hdr(skb)->check;
@@ -1981,7 +1986,8 @@ static inline void gfar_tx_checksum(struct sk_buff *skb, struct txfcb *fcb,
 	/* l3os is the distance between the start of the
 	 * frame (skb->data) and the start of the IP hdr.
 	 * l4os is the distance between the start of the
-	 * l3 hdr and the l4 hdr */
+	 * l3 hdr and the l4 hdr
+	 */
 	fcb->l3os = (u16)(skb_network_offset(skb) - fcb_length);
 	fcb->l4os = skb_network_header_len(skb);
 
@@ -2008,8 +2014,9 @@ static inline struct txbd8 *next_txbd(struct txbd8 *bdp, struct txbd8 *base,
 	return skip_txbd(bdp, 1, base, ring_size);
 }
 
-/* This is called by the kernel when a frame is ready for transmission. */
-/* It is pointed to by the dev->hard_start_xmit function pointer */
+/* This is called by the kernel when a frame is ready for transmission.
+ * It is pointed to by the dev->hard_start_xmit function pointer
+ */
 static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
@@ -2024,8 +2031,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 	unsigned int nr_frags, nr_txbds, length, fcb_length = GMAC_FCB_LEN;
 
-	/*
-	 * TOE=1 frames larger than 2500 bytes may see excess delays
+	/* TOE=1 frames larger than 2500 bytes may see excess delays
 	 * before start of transmission.
 	 */
 	if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_76) &&
@@ -2177,8 +2183,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	txbdp_start->bufPtr = dma_map_single(&priv->ofdev->dev, skb->data,
 			skb_headlen(skb), DMA_TO_DEVICE);
 
-	/*
-	 * If time stamping is requested one additional TxBD must be set up. The
+	/* If time stamping is requested one additional TxBD must be set up. The
 	 * first TxBD points to the FCB and must have a data length of
 	 * GMAC_FCB_LEN. The second TxBD points to the actual frame data with
 	 * the full frame length.
@@ -2194,8 +2199,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	netdev_tx_sent_queue(txq, skb->len);
 
-	/*
-	 * We can work in parallel with gfar_clean_tx_ring(), except
+	/* We can work in parallel with gfar_clean_tx_ring(), except
 	 * when modifying num_txbdfree. Note that we didn't grab the lock
 	 * when we were reading the num_txbdfree and checking for available
 	 * space, that's because outside of this function it can only grow,
@@ -2208,8 +2212,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	spin_lock_irqsave(&tx_queue->txlock, flags);
 
-	/*
-	 * The powerpc-specific eieio() is used, as wmb() has too strong
+	/* The powerpc-specific eieio() is used, as wmb() has too strong
 	 * semantics (it requires synchronization between cacheable and
 	 * uncacheable mappings, which eieio doesn't provide and which we
 	 * don't need), thus requiring a more expensive sync instruction.  At
@@ -2225,7 +2228,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_queue->tx_skbuff[tx_queue->skb_curtx] = skb;
 
 	/* Update the current skb pointer to the next entry we will use
-	 * (wrapping if necessary) */
+	 * (wrapping if necessary)
+	 */
 	tx_queue->skb_curtx = (tx_queue->skb_curtx + 1) &
 		TX_RING_MOD_MASK(tx_queue->tx_ring_size);
 
@@ -2235,7 +2239,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_queue->num_txbdfree -= (nr_txbds);
 
 	/* If the next BD still needs to be cleaned up, then the bds
-	   are full.  We need to tell the kernel to stop sending us stuff. */
+	 * are full.  We need to tell the kernel to stop sending us stuff.
+	 */
 	if (!tx_queue->num_txbdfree) {
 		netif_tx_stop_queue(txq);
 
@@ -2365,7 +2370,8 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 	    INCREMENTAL_BUFFER_SIZE;
 
 	/* Only stop and start the controller if it isn't already
-	 * stopped, and we changed something */
+	 * stopped, and we changed something
+	 */
 	if ((oldsize != tempsize) && (dev->flags & IFF_UP))
 		stop_gfar(dev);
 
@@ -2378,7 +2384,8 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 
 	/* If the mtu is larger than the max size for standard
 	 * ethernet frames (ie, a jumbo frame), then set maccfg2
-	 * to allow huge frames, and to check the length */
+	 * to allow huge frames, and to check the length
+	 */
 	tempval = gfar_read(&regs->maccfg2);
 
 	if (priv->rx_buffer_size > DEFAULT_RX_BUFFER_SIZE ||
@@ -2464,8 +2471,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 
 		frags = skb_shinfo(skb)->nr_frags;
 
-		/*
-		 * When time stamping, one additional TxBD must be freed.
+		/* When time stamping, one additional TxBD must be freed.
 		 * Also, we need to dma_unmap_single() the TxPAL.
 		 */
 		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
@@ -2516,8 +2522,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 
 		bytes_sent += skb->len;
 
-		/*
-		 * If there's room in the queue (limit it to rx_buffer_size)
+		/* If there's room in the queue (limit it to rx_buffer_size)
 		 * we add this skb back into the pool, if it's the right size
 		 */
 		if (skb_queue_len(&priv->rx_recycle) < rx_queue->rx_ring_size &&
@@ -2561,8 +2566,7 @@ static void gfar_schedule_cleanup(struct gfar_priv_grp *gfargrp)
 		gfar_write(&gfargrp->regs->imask, IMASK_RTX_DISABLED);
 		__napi_schedule(&gfargrp->napi);
 	} else {
-		/*
-		 * Clear IEVENT, so interrupts aren't called again
+		/* Clear IEVENT, so interrupts aren't called again
 		 * because of the packets that have already arrived.
 		 */
 		gfar_write(&gfargrp->regs->ievent, IEVENT_RTX_MASK);
@@ -2622,8 +2626,7 @@ static inline void count_errors(unsigned short status, struct net_device *dev)
 	struct net_device_stats *stats = &dev->stats;
 	struct gfar_extra_stats *estats = &priv->extra_stats;
 
-	/* If the packet was truncated, none of the other errors
-	 * matter */
+	/* If the packet was truncated, none of the other errors matter */
 	if (status & RXBD_TRUNCATED) {
 		stats->rx_length_errors++;
 
@@ -2664,7 +2667,8 @@ static inline void gfar_rx_checksum(struct sk_buff *skb, struct rxfcb *fcb)
 {
 	/* If valid headers were found, and valid sums
 	 * were verified, then we tell the kernel that no
-	 * checksumming is necessary.  Otherwise, it is */
+	 * checksumming is necessary.  Otherwise, it is [FIXME]
+	 */
 	if ((fcb->flags & RXFCB_CSUM_MASK) == (RXFCB_CIP | RXFCB_CTU))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	else
@@ -2672,8 +2676,7 @@ static inline void gfar_rx_checksum(struct sk_buff *skb, struct rxfcb *fcb)
 }
 
 
-/* gfar_process_frame() -- handle one incoming packet if skb
- * isn't NULL.  */
+/* gfar_process_frame() -- handle one incoming packet if skb isn't NULL. */
 static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 			      int amount_pull, struct napi_struct *napi)
 {
@@ -2685,8 +2688,9 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	/* fcb is at the beginning if exists */
 	fcb = (struct rxfcb *)skb->data;
 
-	/* Remove the FCB from the skb */
-	/* Remove the padded bytes, if there are any */
+	/* Remove the FCB from the skb
+	 * Remove the padded bytes, if there are any
+	 */
 	if (amount_pull) {
 		skb_record_rx_queue(skb, fcb->rq);
 		skb_pull(skb, amount_pull);
@@ -2709,8 +2713,7 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	/* Tell the skb what kind of packet this is */
 	skb->protocol = eth_type_trans(skb, dev);
 
-	/*
-	 * There's need to check for NETIF_F_HW_VLAN_RX here.
+	/* There's need to check for NETIF_F_HW_VLAN_RX here.
 	 * Even if vlan rx accel is disabled, on some chips
 	 * RXFCB_VLN is pseudo randomly set.
 	 */
@@ -2831,7 +2834,8 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	budget_per_queue = budget/num_queues;
 
 	/* Clear IEVENT, so interrupts aren't called again
-	 * because of the packets that have already arrived */
+	 * because of the packets that have already arrived
+	 */
 	gfar_write(&regs->ievent, IEVENT_RTX_MASK);
 
 	while (num_queues && left_over_budget) {
@@ -2869,8 +2873,9 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 
 		gfar_write(&regs->imask, IMASK_DEFAULT);
 
-		/* If we are coalescing interrupts, update the timer */
-		/* Otherwise, clear it */
+		/* If we are coalescing interrupts, update the timer
+		 * Otherwise, clear it
+		 */
 		gfar_configure_coalescing(priv,
 				gfargrp->rx_bit_map, gfargrp->tx_bit_map);
 	}
@@ -2879,8 +2884,7 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-/*
- * Polling 'interrupt' - used by things like netconsole to send skbs
+/* Polling 'interrupt' - used by things like netconsole to send skbs
  * without having to re-enable interrupts. It's not called while
  * the interrupt routine is executing.
  */
@@ -2957,7 +2961,8 @@ static void adjust_link(struct net_device *dev)
 		u32 ecntrl = gfar_read(&regs->ecntrl);
 
 		/* Now we make sure that we can be in full duplex mode.
-		 * If not, we operate in half-duplex mode. */
+		 * If not, we operate in half-duplex mode.
+		 */
 		if (phydev->duplex != priv->oldduplex) {
 			new_state = 1;
 			if (!(phydev->duplex))
@@ -2983,7 +2988,8 @@ static void adjust_link(struct net_device *dev)
 				    ((tempval & ~(MACCFG2_IF)) | MACCFG2_MII);
 
 				/* Reduced mode distinguishes
-				 * between 10 and 100 */
+				 * between 10 and 100
+				 */
 				if (phydev->speed == SPEED_100)
 					ecntrl |= ECNTRL_R100;
 				else
@@ -3022,7 +3028,8 @@ static void adjust_link(struct net_device *dev)
 /* Update the hash table based on the current list of multicast
  * addresses we subscribe to.  Also, change the promiscuity of
  * the device based on the flags (this function is called
- * whenever dev->flags is changed */
+ * whenever dev->flags is changed
+ */
 static void gfar_set_multi(struct net_device *dev)
 {
 	struct netdev_hw_addr *ha;
@@ -3084,7 +3091,8 @@ static void gfar_set_multi(struct net_device *dev)
 
 		/* If we have extended hash tables, we need to
 		 * clear the exact match registers to prepare for
-		 * setting them */
+		 * setting them
+		 */
 		if (priv->extended_hash) {
 			em_num = GFAR_EM_NUM + 1;
 			gfar_clear_exact_match(dev);
@@ -3110,7 +3118,8 @@ static void gfar_set_multi(struct net_device *dev)
 
 
 /* Clears each of the exact match registers to zero, so they
- * don't interfere with normal reception */
+ * don't interfere with normal reception
+ */
 static void gfar_clear_exact_match(struct net_device *dev)
 {
 	int idx;
@@ -3132,7 +3141,8 @@ static void gfar_clear_exact_match(struct net_device *dev)
  * hash index which gaddr register to use, and the 5 other bits
  * indicate which bit (assuming an IBM numbering scheme, which
  * for PowerPC (tm) is usually the case) in the register holds
- * the entry. */
+ * the entry.
+ */
 static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr)
 {
 	u32 tempval;
@@ -3164,8 +3174,9 @@ static void gfar_set_mac_for_addr(struct net_device *dev, int num,
 
 	macptr += num*2;
 
-	/* Now copy it into the mac registers backwards, cuz */
-	/* little endian is silly */
+	/* Now copy it into the mac registers backwards, cuz
+	 * little endian is silly
+	 */
 	for (idx = 0; idx < ETH_ALEN; idx++)
 		tmpbuf[ETH_ALEN - 1 - idx] = addr[idx];
 
-- 
1.7.9.5
