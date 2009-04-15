From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 05/12] fec: Codingstyle cleanups
Date: Wed, 15 Apr 2009 13:32:18 +0200
Message-ID: <1239795145-27558-6-git-send-email-s.hauer@pengutronix.de>
References: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-2-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-3-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-4-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-5-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49277 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759939AbZDOLfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 07:35:38 -0400
In-Reply-To: <1239795145-27558-5-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |  354 +++++++++++++++++++++--------------------------------
 1 files changed, 139 insertions(+), 215 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 3a43d96..ab8e66b 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -86,8 +86,7 @@ static unsigned char	fec_mac_default[] = {
 #endif
 #endif /* CONFIG_M5272 */
 
-/* Forward declarations of some structures to support different PHYs
-*/
+/* Forward declarations of some structures to support different PHYs */
 
 typedef struct {
 	uint mii_data;
@@ -123,8 +122,7 @@ typedef struct {
 #error "FEC: descriptor ring size constants too large"
 #endif
 
-/* Interrupt events/masks.
-*/
+/* Interrupt events/masks. */
 #define FEC_ENET_HBERR	((uint)0x80000000)	/* Heartbeat error */
 #define FEC_ENET_BABR	((uint)0x40000000)	/* Babbling receiver */
 #define FEC_ENET_BABT	((uint)0x20000000)	/* Babbling transmitter */
@@ -177,15 +175,14 @@ struct fec_enet_private {
 	ushort	skb_cur;
 	ushort	skb_dirty;
 
-	/* CPM dual port RAM relative addresses.
-	*/
+	/* CPM dual port RAM relative addresses */
 	dma_addr_t	bd_dma;
-	/* Address of Rx and Tx buffers. */
+	/* Address of Rx and Tx buffers */
 	struct bufdesc	*rx_bd_base;
 	struct bufdesc	*tx_bd_base;
 	/* The next free ring entry */
 	struct bufdesc	*cur_rx, *cur_tx; 
-	/* The ring entries to be free()ed. */
+	/* The ring entries to be free()ed */
 	struct bufdesc	*dirty_tx;
 
 	uint	tx_full;
@@ -245,19 +242,16 @@ static mii_list_t	*mii_tail;
 static int	mii_queue(struct net_device *dev, int request,
 				void (*func)(uint, struct net_device *));
 
-/* Make MII read/write commands for the FEC.
-*/
+/* Make MII read/write commands for the FEC */
 #define mk_mii_read(REG)	(0x60020000 | ((REG & 0x1f) << 18))
 #define mk_mii_write(REG, VAL)	(0x50020000 | ((REG & 0x1f) << 18) | \
 						(VAL & 0xffff))
 #define mk_mii_end	0
 
-/* Transmitter timeout.
-*/
-#define TX_TIMEOUT (2*HZ)
+/* Transmitter timeout */
+#define TX_TIMEOUT (2 * HZ)
 
-/* Register definitions for the PHY.
-*/
+/* Register definitions for the PHY */
 
 #define MII_REG_CR          0  /* Control Register                         */
 #define MII_REG_SR          1  /* Status Register                          */
@@ -307,7 +301,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	bdp = fep->cur_tx;
 
 	status = bdp->cbd_sc;
-#ifndef final_version
+
 	if (status & BD_ENET_TX_READY) {
 		/* Ooops.  All transmit buffers are full.  Bail out.
 		 * This should not happen, since dev->tbusy should be set.
@@ -316,21 +310,18 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		spin_unlock_irqrestore(&fep->hw_lock, flags);
 		return 1;
 	}
-#endif
 
-	/* Clear all of the status flags.
-	 */
+	/* Clear all of the status flags */
 	status &= ~BD_ENET_TX_STATS;
 
-	/* Set buffer length and buffer pointer.
-	*/
+	/* Set buffer length and buffer pointer */
 	bdp->cbd_bufaddr = __pa(skb->data);
 	bdp->cbd_datlen = skb->len;
 
 	/*
-	 *	On some FEC implementations data must be aligned on
-	 *	4-byte boundaries. Use bounce buffers to copy data
-	 *	and get it aligned. Ugh.
+	 * On some FEC implementations data must be aligned on
+	 * 4-byte boundaries. Use bounce buffers to copy data
+	 * and get it aligned. Ugh.
 	 */
 	if (bdp->cbd_bufaddr & FEC_ALIGNMENT) {
 		unsigned int index;
@@ -339,8 +330,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		bdp->cbd_bufaddr = __pa(fep->tx_bounce[index]);
 	}
 
-	/* Save skb pointer.
-	*/
+	/* Save skb pointer */
 	fep->tx_skbuff[fep->skb_cur] = skb;
 
 	dev->stats.tx_bytes += skb->len;
@@ -355,7 +345,6 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
 	 * it's the last BD of the frame, and to put the CRC on the end.
 	 */
-
 	status |= (BD_ENET_TX_READY | BD_ENET_TX_INTR
 			| BD_ENET_TX_LAST | BD_ENET_TX_TC);
 	bdp->cbd_sc = status;
@@ -365,13 +354,11 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Trigger transmission start */
 	writel(0, fep->hwp + FEC_X_DES_ACTIVE);
 
-	/* If this was the last BD in the ring, start at the beginning again.
-	*/
-	if (status & BD_ENET_TX_WRAP) {
+	/* If this was the last BD in the ring, start at the beginning again. */
+	if (status & BD_ENET_TX_WRAP)
 		bdp = fep->tx_bd_base;
-	} else {
+	else
 		bdp++;
-	}
 
 	if (bdp == fep->dirty_tx) {
 		fep->tx_full = 1;
@@ -429,9 +416,6 @@ fec_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-/* The interrupt handler.
- * This is called from the MPC core interrupt.
- */
 static irqreturn_t
 fec_enet_interrupt(int irq, void * dev_id)
 {
@@ -440,12 +424,10 @@ fec_enet_interrupt(int irq, void * dev_id)
 	uint	int_events;
 	irqreturn_t ret = IRQ_NONE;
 
-	/* Get the interrupt events that caused us to be here. */
 	do {
 		int_events = readl(fep->hwp + FEC_IEVENT);
 		writel(int_events, fep->hwp + FEC_IEVENT);
 
-		/* Handle receive event in its own function. */
 		if (int_events & FEC_ENET_RXF) {
 			ret = IRQ_HANDLED;
 			fec_enet_rx(dev);
@@ -506,31 +488,27 @@ fec_enet_tx(struct net_device *dev)
 			dev->stats.tx_packets++;
 		}
 
-#ifndef final_version
 		if (status & BD_ENET_TX_READY)
 			printk("HEY! Enet xmit interrupt and TX_READY.\n");
-#endif
+
 		/* Deferred means some collisions occurred during transmit,
 		 * but we eventually sent the packet OK.
 		 */
 		if (status & BD_ENET_TX_DEF)
 			dev->stats.collisions++;
 
-		/* Free the sk buffer associated with this last transmit.
-		 */
+		/* Free the sk buffer associated with this last transmit */
 		dev_kfree_skb_any(skb);
 		fep->tx_skbuff[fep->skb_dirty] = NULL;
 		fep->skb_dirty = (fep->skb_dirty + 1) & TX_RING_MOD_MASK;
 
-		/* Update pointer to next buffer descriptor to be transmitted.
-		 */
+		/* Update pointer to next buffer descriptor to be transmitted */
 		if (status & BD_ENET_TX_WRAP)
 			bdp = fep->tx_bd_base;
 		else
 			bdp++;
 
-		/* Since we have freed up a buffer, the ring is no longer
-		 * full.
+		/* Since we have freed up a buffer, the ring is no longer full
 		 */
 		if (fep->tx_full) {
 			fep->tx_full = 0;
@@ -569,114 +547,93 @@ fec_enet_rx(struct net_device *dev)
 	 */
 	bdp = fep->cur_rx;
 
-while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
+	while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
 
-#ifndef final_version
-	/* Since we have allocated space to hold a complete frame,
-	 * the last indicator should be set.
-	 */
-	if ((status & BD_ENET_RX_LAST) == 0)
-		printk("FEC ENET: rcv is not +last\n");
-#endif
+		/* Since we have allocated space to hold a complete frame,
+		 * the last indicator should be set.
+		 */
+		if ((status & BD_ENET_RX_LAST) == 0)
+			printk("FEC ENET: rcv is not +last\n");
 
-	if (!fep->opened)
-		goto rx_processing_done;
+		if (!fep->opened)
+			goto rx_processing_done;
 
-	/* Check for errors. */
-	if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH | BD_ENET_RX_NO |
+		/* Check for errors. */
+		if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH | BD_ENET_RX_NO |
 			   BD_ENET_RX_CR | BD_ENET_RX_OV)) {
-		dev->stats.rx_errors++;
-		if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH)) {
-		/* Frame too long or too short. */
-			dev->stats.rx_length_errors++;
+			dev->stats.rx_errors++;
+			if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH)) {
+				/* Frame too long or too short. */
+				dev->stats.rx_length_errors++;
+			}
+			if (status & BD_ENET_RX_NO)	/* Frame alignment */
+				dev->stats.rx_frame_errors++;
+			if (status & BD_ENET_RX_CR)	/* CRC Error */
+				dev->stats.rx_crc_errors++;
+			if (status & BD_ENET_RX_OV)	/* FIFO overrun */
+				dev->stats.rx_fifo_errors++;
 		}
-		if (status & BD_ENET_RX_NO)	/* Frame alignment */
-			dev->stats.rx_frame_errors++;
-		if (status & BD_ENET_RX_CR)	/* CRC Error */
-			dev->stats.rx_crc_errors++;
-		if (status & BD_ENET_RX_OV)	/* FIFO overrun */
-			dev->stats.rx_fifo_errors++;
-	}
 
-	/* Report late collisions as a frame error.
-	 * On this error, the BD is closed, but we don't know what we
-	 * have in the buffer.  So, just drop this frame on the floor.
-	 */
-	if (status & BD_ENET_RX_CL) {
-		dev->stats.rx_errors++;
-		dev->stats.rx_frame_errors++;
-		goto rx_processing_done;
-	}
+		/* Report late collisions as a frame error.
+		 * On this error, the BD is closed, but we don't know what we
+		 * have in the buffer.  So, just drop this frame on the floor.
+		 */
+		if (status & BD_ENET_RX_CL) {
+			dev->stats.rx_errors++;
+			dev->stats.rx_frame_errors++;
+			goto rx_processing_done;
+		}
 
-	/* Process the incoming frame.
-	 */
-	dev->stats.rx_packets++;
-	pkt_len = bdp->cbd_datlen;
-	dev->stats.rx_bytes += pkt_len;
-	data = (__u8*)__va(bdp->cbd_bufaddr);
+		/* Process the incoming frame. */
+		dev->stats.rx_packets++;
+		pkt_len = bdp->cbd_datlen;
+		dev->stats.rx_bytes += pkt_len;
+		data = (__u8*)__va(bdp->cbd_bufaddr);
 
-	dma_sync_single(NULL, (unsigned long)__pa(data),
+		dma_sync_single(NULL, (unsigned long)__pa(data),
 			pkt_len - 4, DMA_FROM_DEVICE);
 
-	/* This does 16 byte alignment, exactly what we need.
-	 * The packet length includes FCS, but we don't want to
-	 * include that when passing upstream as it messes up
-	 * bridging applications.
-	 */
-	skb = dev_alloc_skb(pkt_len-4);
-
-	if (skb == NULL) {
-		printk("%s: Memory squeeze, dropping packet.\n", dev->name);
-		dev->stats.rx_dropped++;
-	} else {
-		skb_put(skb,pkt_len-4);	/* Make room */
-		skb_copy_to_linear_data(skb, data, pkt_len-4);
-		skb->protocol=eth_type_trans(skb,dev);
-		netif_rx(skb);
-	}
-  rx_processing_done:
-
-	/* Clear the status flags for this buffer.
-	*/
-	status &= ~BD_ENET_RX_STATS;
+		/* This does 16 byte alignment, exactly what we need.
+		 * The packet length includes FCS, but we don't want to
+		 * include that when passing upstream as it messes up
+		 * bridging applications.
+		 */
+		skb = dev_alloc_skb(pkt_len - 4);
 
-	/* Mark the buffer empty.
-	*/
-	status |= BD_ENET_RX_EMPTY;
-	bdp->cbd_sc = status;
+		if (skb == NULL) {
+			printk("%s: Memory squeeze, dropping packet.\n",
+					dev->name);
+			dev->stats.rx_dropped++;
+		} else {
+			skb_put(skb, pkt_len - 4);	/* Make room */
+			skb_copy_to_linear_data(skb, data, pkt_len - 4);
+			skb->protocol = eth_type_trans(skb, dev);
+			netif_rx(skb);
+		}
+rx_processing_done:
+		/* Clear the status flags for this buffer */
+		status &= ~BD_ENET_RX_STATS;
 
-	/* Update BD pointer to next entry.
-	*/
-	if (status & BD_ENET_RX_WRAP)
-		bdp = fep->rx_bd_base;
-	else
-		bdp++;
+		/* Mark the buffer empty */
+		status |= BD_ENET_RX_EMPTY;
+		bdp->cbd_sc = status;
 
-#if 1
-	/* Doing this here will keep the FEC running while we process
-	 * incoming frames.  On a heavily loaded network, we should be
-	 * able to keep up at the expense of system resources.
-	 */
-	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
-#endif
-   } /* while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) */
+		/* Update BD pointer to next entry */
+		if (status & BD_ENET_RX_WRAP)
+			bdp = fep->rx_bd_base;
+		else
+			bdp++;
+		/* Doing this here will keep the FEC running while we process
+		 * incoming frames.  On a heavily loaded network, we should be
+		 * able to keep up at the expense of system resources.
+		 */
+		writel(0, fep->hwp + FEC_R_DES_ACTIVE);
+	}
 	fep->cur_rx = bdp;
 
-#if 0
-	/* Doing this here will allow us to process all frames in the
-	 * ring before the FEC is allowed to put more there.  On a heavily
-	 * loaded network, some frames may be lost.  Unfortunately, this
-	 * increases the interrupt overhead since we can potentially work
-	 * our way back to the interrupt return only to come right back
-	 * here.
-	 */
-	fecp->fec_r_des_active = 0;
-#endif
-
 	spin_unlock_irq(&fep->hw_lock);
 }
 
-
 /* called from interrupt context */
 static void
 fec_enet_mii(struct net_device *dev)
@@ -714,8 +671,7 @@ mii_queue(struct net_device *dev, int regval, void (*func)(uint, struct net_devi
 	mii_list_t	*mip;
 	int		retval;
 
-	/* Add PHY address to register command.
-	*/
+	/* Add PHY address to register command */
 	fep = netdev_priv(dev);
 	spin_lock_irqsave(&fep->mii_lock, flags);
 
@@ -1359,11 +1315,6 @@ static void mii_relink(struct work_struct *work)
 		fec_restart(dev, duplex);
 	} else
 		fec_stop(dev);
-
-#if 0
-	enable_irq(fep->mii_irq);
-#endif
-
 }
 
 /* mii_queue_relink is called in interrupt context from mii_link_interrupt */
@@ -1372,12 +1323,12 @@ static void mii_queue_relink(uint mii_reg, struct net_device *dev)
 	struct fec_enet_private *fep = netdev_priv(dev);
 
 	/*
-	** We cannot queue phy_task twice in the workqueue.  It
-	** would cause an endless loop in the workqueue.
-	** Fortunately, if the last mii_relink entry has not yet been
-	** executed now, it will do the job for the current interrupt,
-	** which is just what we want.
-	*/
+	 * We cannot queue phy_task twice in the workqueue.  It
+	 * would cause an endless loop in the workqueue.
+	 * Fortunately, if the last mii_relink entry has not yet been
+	 * executed now, it will do the job for the current interrupt,
+	 * which is just what we want.
+	 */
 	if (fep->mii_phy_task_queued)
 		return;
 
@@ -1408,8 +1359,7 @@ phy_cmd_t const phy_cmd_config[] = {
 	{ mk_mii_end, }
 	};
 
-/* Read remainder of PHY ID.
-*/
+/* Read remainder of PHY ID. */
 static void
 mii_discover_phy3(uint mii_reg, struct net_device *dev)
 {
@@ -1448,8 +1398,7 @@ mii_discover_phy(uint mii_reg, struct net_device *dev)
 	if (fep->phy_addr < 32) {
 		if ((phytype = (mii_reg & 0xffff)) != 0xffff && phytype != 0) {
 
-			/* Got first part of ID, now get remainder.
-			*/
+			/* Got first part of ID, now get remainder */
 			fep->phy_id = phytype << 16;
 			mii_queue(dev, mk_mii_read(MII_REG_PHYIR2),
 							mii_discover_phy3);
@@ -1469,8 +1418,7 @@ mii_discover_phy(uint mii_reg, struct net_device *dev)
 	}
 }
 
-/* This interrupt occurs when the PHY detects a link change.
-*/
+/* This interrupt occurs when the PHY detects a link change */
 #ifdef HAVE_mii_link_interrupt
 static irqreturn_t
 mii_link_interrupt(int irq, void * dev_id)
@@ -1480,10 +1428,6 @@ mii_link_interrupt(int irq, void * dev_id)
 
 	fec_phy_ack_intr();
 
-#if 0
-	disable_irq(fep->mii_irq);  /* disable now, enable later */
-#endif
-
 	mii_do_cmd(dev, fep->phy->ack_int);
 	mii_do_cmd(dev, phy_cmd_relink);  /* restart and display status */
 
@@ -1534,7 +1478,7 @@ fec_enet_open(struct net_device *dev)
 
 	netif_start_queue(dev);
 	fep->opened = 1;
-	return 0;		/* Success */
+	return 0;
 }
 
 static int
@@ -1542,8 +1486,7 @@ fec_enet_close(struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
 
-	/* Don't know what to do yet.
-	*/
+	/* Don't know what to do yet. */
 	fep->opened = 0;
 	netif_stop_queue(dev);
 	fec_stop(dev);
@@ -1571,7 +1514,7 @@ static void set_multicast_list(struct net_device *dev)
 	unsigned int i, j, bit, data, crc, tmp;
 	unsigned char hash;
 
-	if (dev->flags&IFF_PROMISC) {
+	if (dev->flags & IFF_PROMISC) {
 		tmp = readl(fep->hwp + FEC_R_CNTRL);
 		tmp |= 0x8;
 		writel(tmp, fep->hwp + FEC_R_CNTRL);
@@ -1582,42 +1525,37 @@ static void set_multicast_list(struct net_device *dev)
 
 		if (dev->flags & IFF_ALLMULTI) {
 			/* Catch all multicast addresses, so set the
-			 * filter to all 1's.
+			 * filter to all 1's
 			 */
 			writel(0xffffffff, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
 			writel(0xffffffff, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
 		} else {
-			/* Clear filter and add the addresses in hash register.
-			*/
+			/* Clear filter and add the addresses in hash register
+			 */
 			writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
 			writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
 
 			dmi = dev->mc_list;
 
-			for (j = 0; j < dev->mc_count; j++, dmi = dmi->next)
-			{
-				/* Only support group multicast for now.
-				*/
+			for (j = 0; j < dev->mc_count; j++, dmi = dmi->next) {
+				/* Only support group multicast for now */
 				if (!(dmi->dmi_addr[0] & 1))
 					continue;
 
-				/* calculate crc32 value of mac address
-				*/
+				/* calculate crc32 value of mac address */
 				crc = 0xffffffff;
 
-				for (i = 0; i < dmi->dmi_addrlen; i++)
-				{
+				for (i = 0; i < dmi->dmi_addrlen; i++) {
 					data = dmi->dmi_addr[i];
-					for (bit = 0; bit < 8; bit++, data >>= 1)
-					{
+					for (bit = 0; bit < 8; bit++, data >>= 1) {
 						crc = (crc >> 1) ^
 						(((crc ^ data) & 1) ? CRC32_POLY : 0);
 					}
 				}
 
 				/* only upper 6 bits (HASH_BITS) are used
-				   which point to specific bit in he hash registers
-				*/
+				 * which point to specific bit in he hash registers
+				 */
 				hash = (crc >> (32 - HASH_BITS)) & 0x3f;
 
 				if (hash > 31) {
@@ -1634,8 +1572,7 @@ static void set_multicast_list(struct net_device *dev)
 	}
 }
 
-/* Set a MAC change in hardware.
- */
+/* Set a MAC change in hardware. */
 static void
 fec_set_mac_address(struct net_device *dev)
 {
@@ -1676,8 +1613,7 @@ int __init fec_enet_init(struct net_device *dev, int index)
 	fep->hwp = (void __iomem *)dev->base_addr;
 	fep->netdev = dev;
 
-	/* Whack a reset.  We should wait for this.
-	*/
+	/* Whack a reset.  We should wait for this. */
 	writel(1, fep->hwp + FEC_ECNTRL);
 	udelay(10);
 
@@ -1707,18 +1643,15 @@ int __init fec_enet_init(struct net_device *dev, int index)
 
 	fep->skb_cur = fep->skb_dirty = 0;
 
-	/* Initialize the receive buffer descriptors.
-	*/
+	/* Initialize the receive buffer descriptors. */
 	bdp = fep->rx_bd_base;
 	for (i=0; i<FEC_ENET_RX_PAGES; i++) {
 
-		/* Allocate a page.
-		*/
+		/* Allocate a page */
 		mem_addr = __get_free_page(GFP_KERNEL);
 		/* XXX: missing check for allocation failure */
 
-		/* Initialize the BD for every fragment in the page.
-		*/
+		/* Initialize the BD for every fragment in the page */
 		for (j=0; j<FEC_ENET_RX_FRPPG; j++) {
 			bdp->cbd_sc = BD_ENET_RX_EMPTY;
 			bdp->cbd_bufaddr = __pa(mem_addr);
@@ -1727,13 +1660,11 @@ int __init fec_enet_init(struct net_device *dev, int index)
 		}
 	}
 
-	/* Set the last buffer to wrap.
-	*/
+	/* Set the last buffer to wrap */
 	bdp--;
 	bdp->cbd_sc |= BD_SC_WRAP;
 
-	/* ...and the same for transmmit.
-	*/
+	/* ...and the same for transmit */
 	bdp = fep->tx_bd_base;
 	for (i=0, j=FEC_ENET_TX_FRPPG; i<TX_RING_SIZE; i++) {
 		if (j >= FEC_ENET_TX_FRPPG) {
@@ -1745,20 +1676,17 @@ int __init fec_enet_init(struct net_device *dev, int index)
 		}
 		fep->tx_bounce[i] = (unsigned char *) mem_addr;
 
-		/* Initialize the BD for every fragment in the page.
-		*/
+		/* Initialize the BD for every fragment in the page */
 		bdp->cbd_sc = 0;
 		bdp->cbd_bufaddr = 0;
 		bdp++;
 	}
 
-	/* Set the last buffer to wrap.
-	*/
+	/* Set the last buffer to wrap */
 	bdp--;
 	bdp->cbd_sc |= BD_SC_WRAP;
 
-	/* Set receive and transmit descriptor base.
-	*/
+	/* Set receive and transmit descriptor base */
 	writel(fep->bd_dma, fep->hwp + FEC_R_DES_START);
 	writel((unsigned long)fep->bd_dma + sizeof(struct bufdesc) * RX_RING_SIZE,
 			fep->hwp + FEC_X_DES_START);
@@ -1777,7 +1705,7 @@ int __init fec_enet_init(struct net_device *dev, int index)
 	writel(0, fep->hwp + FEC_HASH_TABLE_LOW);
 #endif
 
-	/* The FEC Ethernet specific entries in the device structure. */
+	/* The FEC Ethernet specific entries in the device structure */
 	dev->open = fec_enet_open;
 	dev->hard_start_xmit = fec_enet_start_xmit;
 	dev->tx_timeout = fec_timeout;
@@ -1793,9 +1721,7 @@ int __init fec_enet_init(struct net_device *dev, int index)
 	writel(OPT_FRAME_SIZE | 0x04, fep->hwp + FEC_R_CNTRL);
 	writel(0, fep->hwp + FEC_X_CNTRL);
 
-	/*
-	 * Set MII speed to 2.5 MHz
-	 */
+	/* Set MII speed to 2.5 MHz */
 	fep->phy_speed = ((((clk_get_rate(fep->clk) / 2 + 4999999)
 					/ 2500000) / 2) & 0x3F) << 1;
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
@@ -1854,8 +1780,8 @@ fec_restart(struct net_device *dev, int duplex)
 
 	/* Reset SKB transmit buffers. */
 	fep->skb_cur = fep->skb_dirty = 0;
-	for (i=0; i<=TX_RING_MOD_MASK; i++) {
-		if (fep->tx_skbuff[i] != NULL) {
+	for (i = 0; i <= TX_RING_MOD_MASK; i++) {
+		if (fep->tx_skbuff[i]) {
 			dev_kfree_skb_any(fep->tx_skbuff[i]);
 			fep->tx_skbuff[i] = NULL;
 		}
@@ -1863,20 +1789,20 @@ fec_restart(struct net_device *dev, int duplex)
 
 	/* Initialize the receive buffer descriptors. */
 	bdp = fep->rx_bd_base;
-	for (i=0; i<RX_RING_SIZE; i++) {
+	for (i = 0; i < RX_RING_SIZE; i++) {
 
 		/* Initialize the BD for every fragment in the page. */
 		bdp->cbd_sc = BD_ENET_RX_EMPTY;
 		bdp++;
 	}
 
-	/* Set the last buffer to wrap. */
+	/* Set the last buffer to wrap */
 	bdp--;
 	bdp->cbd_sc |= BD_SC_WRAP;
 
-	/* ...and the same for transmmit. */
+	/* ...and the same for transmit */
 	bdp = fep->tx_bd_base;
-	for (i=0; i<TX_RING_SIZE; i++) {
+	for (i = 0; i < TX_RING_SIZE; i++) {
 
 		/* Initialize the BD for every fragment in the page. */
 		bdp->cbd_sc = 0;
@@ -1884,11 +1810,11 @@ fec_restart(struct net_device *dev, int duplex)
 		bdp++;
 	}
 
-	/* Set the last buffer to wrap. */
+	/* Set the last buffer to wrap */
 	bdp--;
 	bdp->cbd_sc |= BD_SC_WRAP;
 
-	/* Enable MII mode. */
+	/* Enable MII mode */
 	if (duplex) {
 		/* MII enable / FD enable */
 		writel(OPT_FRAME_SIZE | 0x04, fep->hwp + FEC_R_CNTRL);
@@ -1900,14 +1826,14 @@ fec_restart(struct net_device *dev, int duplex)
 	}
 	fep->full_duplex = duplex;
 
-	/* Set MII speed. */
+	/* Set MII speed */
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 
-	/* And last, enable the transmit and receive processing. */
+	/* And last, enable the transmit and receive processing */
 	writel(2, fep->hwp + FEC_ECNTRL);
 	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
 
-	/* Enable interrupts we wish to service. */
+	/* Enable interrupts we wish to service */
 	writel(FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII,
 			fep->hwp + FEC_IMASK);
 }
@@ -1917,9 +1843,7 @@ fec_stop(struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
 
-	/*
-	** We cannot expect a graceful transmit stop without link !!!
-	*/
+	/* We cannot expect a graceful transmit stop without link !!! */
 	if (fep->link) {
 		writel(1, fep->hwp + FEC_X_CNTRL); /* Graceful transmit stop */
 		udelay(10);
-- 
1.6.2.1

