From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: [PATCH 2/5] net: macb: Fix coding style warnings
Date: Sun, 13 Mar 2016 12:10:44 -0700
Message-ID: <1457896247-25934-3-git-send-email-moritz.fischer@ettus.com>
References: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
Cc: michal.simek@xilinx.com, joe@perches.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	moritz.fischer.private@gmail.com,
	Moritz Fischer <moritz.fischer@ettus.com>
To: nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34869 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891AbcCMTLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 15:11:07 -0400
Received: by mail-pa0-f54.google.com with SMTP id td3so112935717pab.2
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2016 12:11:06 -0700 (PDT)
In-Reply-To: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit takes care of the coding style warnings
that are mostly due to a different comment style and
lines over 80 chars, as well as a dangling else.

Signed-off-by: Moritz Fischer <moritz.fischer@ettus.com>
---
 drivers/net/ethernet/cadence/macb.c | 101 +++++++++++++++---------------------
 1 file changed, 43 insertions(+), 58 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 4370f37..c2d31c5 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -58,8 +58,7 @@
 
 #define GEM_MTU_MIN_SIZE	68
 
-/*
- * Graceful stop timeouts in us. We should allow up to
+/* Graceful stop timeouts in us. We should allow up to
  * 1 frame time (10 Mbits/s, full-duplex, ignoring collisions)
  */
 #define MACB_HALT_TIMEOUT	1230
@@ -127,8 +126,7 @@ static void hw_writel(struct macb *bp, int offset, u32 value)
 	writel_relaxed(value, bp->regs + offset);
 }
 
-/*
- * Find the CPU endianness by using the loopback bit of NCR register. When the
+/* Find the CPU endianness by using the loopback bit of NCR register. When the
  * CPU is in big endian we need to program swaped mode for management
  * descriptor access.
  */
@@ -383,7 +381,8 @@ static int macb_mii_probe(struct net_device *dev)
 
 	pdata = dev_get_platdata(&bp->pdev->dev);
 	if (pdata && gpio_is_valid(pdata->phy_irq_pin)) {
-		ret = devm_gpio_request(&bp->pdev->dev, pdata->phy_irq_pin, "phy int");
+		ret = devm_gpio_request(&bp->pdev->dev, pdata->phy_irq_pin,
+					"phy int");
 		if (!ret) {
 			phy_irq = gpio_to_irq(pdata->phy_irq_pin);
 			phydev->irq = (phy_irq < 0) ? PHY_POLL : phy_irq;
@@ -449,7 +448,8 @@ static int macb_mii_init(struct macb *bp)
 		err = of_mdiobus_register(bp->mii_bus, np);
 
 		/* fallback to standard phy registration if no phy were
-		   found during dt phy registration */
+		 * found during dt phy registration
+		 */
 		if (!err && !phy_find_first(bp->mii_bus)) {
 			for (i = 0; i < PHY_MAX_ADDR; i++) {
 				struct phy_device *phydev;
@@ -564,8 +564,7 @@ static void macb_tx_error_task(struct work_struct *work)
 	/* Make sure nobody is trying to queue up new packets */
 	netif_tx_stop_all_queues(bp->dev);
 
-	/*
-	 * Stop transmission now
+	/* Stop transmission now
 	 * (in case we have just queued new packets)
 	 * macb/gem must be halted to write TBQP register
 	 */
@@ -573,8 +572,7 @@ static void macb_tx_error_task(struct work_struct *work)
 		/* Just complain for now, reinitializing TX path can be good */
 		netdev_err(bp->dev, "BUG: halt tx timed out\n");
 
-	/*
-	 * Treat frames in TX queue including the ones that caused the error.
+	/* Treat frames in TX queue including the ones that caused the error.
 	 * Free transmit buffers in upper layer.
 	 */
 	for (tail = queue->tx_tail; tail != queue->tx_head; tail++) {
@@ -604,10 +602,9 @@ static void macb_tx_error_task(struct work_struct *work)
 				bp->stats.tx_bytes += skb->len;
 			}
 		} else {
-			/*
-			 * "Buffers exhausted mid-frame" errors may only happen
-			 * if the driver is buggy, so complain loudly about those.
-			 * Statistics are updated by hardware.
+			/* "Buffers exhausted mid-frame" errors may only happen
+			 * if the driver is buggy, so complain loudly about
+			 * those. Statistics are updated by hardware.
 			 */
 			if (ctrl & MACB_BIT(TX_BUF_EXHAUSTED))
 				netdev_err(bp->dev,
@@ -719,7 +716,8 @@ static void gem_rx_refill(struct macb *bp)
 	struct sk_buff		*skb;
 	dma_addr_t		paddr;
 
-	while (CIRC_SPACE(bp->rx_prepared_head, bp->rx_tail, RX_RING_SIZE) > 0) {
+	while (CIRC_SPACE(bp->rx_prepared_head, bp->rx_tail,
+			  RX_RING_SIZE) > 0) {
 		entry = macb_rx_ring_wrap(bp->rx_prepared_head);
 
 		/* Make hw descriptor updates visible to CPU */
@@ -738,7 +736,8 @@ static void gem_rx_refill(struct macb *bp)
 
 			/* now fill corresponding descriptor entry */
 			paddr = dma_map_single(&bp->pdev->dev, skb->data,
-					       bp->rx_buffer_size, DMA_FROM_DEVICE);
+					       bp->rx_buffer_size,
+					       DMA_FROM_DEVICE);
 			if (dma_mapping_error(&bp->pdev->dev, paddr)) {
 				dev_kfree_skb(skb);
 				break;
@@ -774,14 +773,14 @@ static void discard_partial_frame(struct macb *bp, unsigned int begin,
 
 	for (frag = begin; frag != end; frag++) {
 		struct macb_dma_desc *desc = macb_rx_desc(bp, frag);
+
 		desc->addr &= ~MACB_BIT(RX_USED);
 	}
 
 	/* Make descriptor updates visible to hardware */
 	wmb();
 
-	/*
-	 * When this happens, the hardware stats registers for
+	/* When this happens, the hardware stats registers for
 	 * whatever caused this is updated, so we don't have to record
 	 * anything.
 	 */
@@ -880,8 +879,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 		macb_rx_ring_wrap(first_frag),
 		macb_rx_ring_wrap(last_frag), len);
 
-	/*
-	 * The ethernet header starts NET_IP_ALIGN bytes into the
+	/* The ethernet header starts NET_IP_ALIGN bytes into the
 	 * first buffer. Since the header is 14 bytes, this makes the
 	 * payload word-aligned.
 	 *
@@ -969,6 +967,7 @@ static int macb_rx(struct macb *bp, int budget)
 
 		if (ctrl & MACB_BIT(RX_EOF)) {
 			int dropped;
+
 			BUG_ON(first_frag == -1);
 
 			dropped = macb_rx_frame(bp, first_frag, tail);
@@ -1050,8 +1049,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 			    (unsigned long)status);
 
 		if (status & MACB_RX_INT_FLAGS) {
-			/*
-			 * There's no point taking any more interrupts
+			/* There's no point taking any more interrupts
 			 * until we have processed the buffers. The
 			 * scheduling call may fail if the poll routine
 			 * is already scheduled, so disable interrupts
@@ -1080,8 +1078,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 		if (status & MACB_BIT(TCOMP))
 			macb_tx_interrupt(queue);
 
-		/*
-		 * Link change detection isn't possible with RMII, so we'll
+		/* Link change detection isn't possible with RMII, so we'll
 		 * add that if/when we get our hands on a full-blown MII PHY.
 		 */
 
@@ -1112,8 +1109,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 		}
 
 		if (status & MACB_BIT(HRESP)) {
-			/*
-			 * TODO: Reset the hardware, and maybe move the
+			/* TODO: Reset the hardware, and maybe move the
 			 * netdev_err to a lower-priority context as well
 			 * (work queue?)
 			 */
@@ -1132,8 +1128,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-/*
- * Polling receive - used by netconsole and other diagnostic tools
+/* Polling receive - used by netconsole and other diagnostic tools
  * to allow network i/o with interrupts disabled.
  */
 static void macb_poll_controller(struct net_device *dev)
@@ -1429,10 +1424,10 @@ static int gem_alloc_rx_buffers(struct macb *bp)
 	bp->rx_skbuff = kzalloc(size, GFP_KERNEL);
 	if (!bp->rx_skbuff)
 		return -ENOMEM;
-	else
-		netdev_dbg(bp->dev,
-			   "Allocated %d RX struct sk_buff entries at %p\n",
-			   RX_RING_SIZE, bp->rx_skbuff);
+
+	netdev_dbg(bp->dev,
+		   "Allocated %d RX struct sk_buff entries at %p\n",
+		   RX_RING_SIZE, bp->rx_skbuff);
 	return 0;
 }
 
@@ -1445,10 +1440,10 @@ static int macb_alloc_rx_buffers(struct macb *bp)
 					    &bp->rx_buffers_dma, GFP_KERNEL);
 	if (!bp->rx_buffers)
 		return -ENOMEM;
-	else
-		netdev_dbg(bp->dev,
-			   "Allocated RX buffers of %d bytes at %08lx (mapped %p)\n",
-			   size, (unsigned long)bp->rx_buffers_dma, bp->rx_buffers);
+
+	netdev_dbg(bp->dev,
+		   "Allocated RX buffers of %d bytes at %08lx (mapped %p)\n",
+		   size, (unsigned long)bp->rx_buffers_dma, bp->rx_buffers);
 	return 0;
 }
 
@@ -1546,8 +1541,7 @@ static void macb_reset_hw(struct macb *bp)
 	struct macb_queue *queue;
 	unsigned int q;
 
-	/*
-	 * Disable RX and TX (XXX: Should we halt the transmission
+	/* Disable RX and TX (XXX: Should we halt the transmission
 	 * more gracefully?)
 	 */
 	macb_writel(bp, NCR, 0);
@@ -1610,8 +1604,7 @@ static u32 macb_mdc_clk_div(struct macb *bp)
 	return config;
 }
 
-/*
- * Get the DMA bus width field of the network configuration register that we
+/* Get the DMA bus width field of the network configuration register that we
  * should program.  We find the width from decoding the design configuration
  * register to find the maximum supported data bus width.
  */
@@ -1631,8 +1624,7 @@ static u32 macb_dbw(struct macb *bp)
 	}
 }
 
-/*
- * Configure the receive DMA engine
+/* Configure the receive DMA engine
  * - use the correct receive buffer size
  * - set best burst length for DMA operations
  *   (if not supported by FIFO, it will fallback to default)
@@ -1720,8 +1712,7 @@ static void macb_init_hw(struct macb *bp)
 	macb_writel(bp, NCR, MACB_BIT(RE) | MACB_BIT(TE) | MACB_BIT(MPE));
 }
 
-/*
- * The hash address register is 64 bits long and takes up two
+/* The hash address register is 64 bits long and takes up two
  * locations in the memory map.  The least significant bits are stored
  * in EMAC_HSL and the most significant bits in EMAC_HSH.
  *
@@ -1761,9 +1752,7 @@ static inline int hash_bit_value(int bitnr, __u8 *addr)
 	return 0;
 }
 
-/*
- * Return the hash index value for the specified address.
- */
+/* Return the hash index value for the specified address. */
 static int hash_get_index(__u8 *addr)
 {
 	int i, j, bitval;
@@ -1779,9 +1768,7 @@ static int hash_get_index(__u8 *addr)
 	return hash_index;
 }
 
-/*
- * Add multicast addresses to the internal multicast-hash table.
- */
+/* Add multicast addresses to the internal multicast-hash table. */
 static void macb_sethashtable(struct net_device *dev)
 {
 	struct netdev_hw_addr *ha;
@@ -1800,9 +1787,7 @@ static void macb_sethashtable(struct net_device *dev)
 	macb_or_gem_writel(bp, HRT, mc_filter[1]);
 }
 
-/*
- * Enable/Disable promiscuous and multicast modes.
- */
+/* Enable/Disable promiscuous and multicast modes. */
 static void macb_set_rx_mode(struct net_device *dev)
 {
 	unsigned long cfg;
@@ -2119,9 +2104,8 @@ static void macb_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 
 	if (!(bp->caps & MACB_CAPS_USRIO_DISABLED))
 		regs_buff[12] = macb_or_gem_readl(bp, USRIO);
-	if (macb_is_gem(bp)) {
+	if (macb_is_gem(bp))
 		regs_buff[13] = gem_readl(bp, DMACFG);
-	}
 }
 
 static const struct ethtool_ops macb_ethtool_ops = {
@@ -2209,11 +2193,11 @@ static const struct net_device_ops macb_netdev_ops = {
 	.ndo_set_features	= macb_set_features,
 };
 
-/*
- * Configure peripheral capabilities according to device tree
+/* Configure peripheral capabilities according to device tree
  * and integration options used
  */
-static void macb_configure_caps(struct macb *bp, const struct macb_config *dt_conf)
+static void macb_configure_caps(struct macb *bp,
+				const struct macb_config *dt_conf)
 {
 	u32 dcfg;
 
@@ -2913,6 +2897,7 @@ static int macb_probe(struct platform_device *pdev)
 	phy_node =  of_get_next_available_child(np, NULL);
 	if (phy_node) {
 		int gpio = of_get_named_gpio(phy_node, "reset-gpios", 0);
+
 		if (gpio_is_valid(gpio))
 			bp->reset_gpio = gpio_to_desc(gpio);
 		gpiod_set_value(bp->reset_gpio, GPIOD_OUT_HIGH);
-- 
2.4.3
