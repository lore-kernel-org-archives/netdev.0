From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 2/2] 3c5xx: convert printk() to pr_foo()
Date: Tue, 19 May 2009 22:08:59 +0400
Message-ID: <1242756539-19049-2-git-send-email-a.beregalov@gmail.com>
References: <1242756539-19049-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:44617 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754385AbZESSJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 14:09:16 -0400
Received: by fxm2 with SMTP id 2so4041645fxm.37
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 11:09:15 -0700 (PDT)
In-Reply-To: <1242756539-19049-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

Compile tested.


 drivers/net/3c515.c |  115 +++++++++++++++----------------
 drivers/net/3c523.c |   86 +++++++++++-----------
 drivers/net/3c527.c |   46 ++++++-------
 drivers/net/3c59x.c |  194 +++++++++++++++++++++++++-------------------------
 4 files changed, 217 insertions(+), 224 deletions(-)

diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 167bf23..3bc0889 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -420,7 +420,7 @@ int init_module(void)
 	if (debug >= 0)
 		corkscrew_debug = debug;
 	if (corkscrew_debug)
-		printk(version);
+		pr_debug("%s", version);
 	while (corkscrew_scan(-1))
 		found++;
 	return found ? 0 : -ENODEV;
@@ -437,7 +437,7 @@ struct net_device *tc515_probe(int unit)
 
 	if (corkscrew_debug > 0 && !printed) {
 		printed = 1;
-		printk(version);
+		pr_debug("%s", version);
 	}
 
 	return dev;
@@ -516,7 +516,7 @@ static struct net_device *corkscrew_scan(int unit)
 			if (pnp_device_attach(idev) < 0)
 				continue;
 			if (pnp_activate_dev(idev) < 0) {
-				printk("pnp activate failed (out of resources?)\n");
+				pr_warning("pnp activate failed (out of resources?)\n");
 				pnp_device_detach(idev);
 				continue;
 			}
@@ -531,9 +531,9 @@ static struct net_device *corkscrew_scan(int unit)
 				continue;
 			}
 			if(corkscrew_debug)
-				printk ("ISAPNP reports %s at i/o 0x%x, irq %d\n",
+				pr_debug("ISAPNP reports %s at i/o 0x%x, irq %d\n",
 					(char*) corkscrew_isapnp_adapters[i].driver_data, ioaddr, irq);
-			printk(KERN_INFO "3c515 Resource configuration register %#4.4x, DCR %4.4x.\n",
+			pr_info("3c515 Resource configuration register %#4.4x, DCR %4.4x.\n",
 		     		inl(ioaddr + 0x2002), inw(ioaddr + 0x2000));
 			/* irq = inw(ioaddr + 0x2002) & 15; */ /* Use the irq from isapnp */
 			SET_NETDEV_DEV(dev, &idev->dev);
@@ -552,7 +552,7 @@ no_pnp:
 		if (!check_device(ioaddr))
 			continue;
 
-		printk(KERN_INFO "3c515 Resource configuration register %#4.4x, DCR %4.4x.\n",
+		pr_info("3c515 Resource configuration register %#4.4x, DCR %4.4x.\n",
 		     inl(ioaddr + 0x2002), inw(ioaddr + 0x2000));
 		err = corkscrew_setup(dev, ioaddr, NULL, cards_found++);
 		if (!err)
@@ -625,7 +625,7 @@ static int corkscrew_setup(struct net_device *dev, int ioaddr,
 	list_add(&vp->list, &root_corkscrew_dev);
 #endif
 
-	printk(KERN_INFO "%s: 3Com %s at %#3x,", dev->name, vp->product_name, ioaddr);
+	pr_info("%s: 3Com %s at %#3x,", dev->name, vp->product_name, ioaddr);
 
 	spin_lock_init(&vp->lock);
 
@@ -648,19 +648,19 @@ static int corkscrew_setup(struct net_device *dev, int ioaddr,
 	}
 	checksum = (checksum ^ (checksum >> 8)) & 0xff;
 	if (checksum != 0x00)
-		printk(" ***INVALID CHECKSUM %4.4x*** ", checksum);
-	printk(" %pM", dev->dev_addr);
+		pr_err(" ***INVALID CHECKSUM %4.4x*** ", checksum);
+	pr_info(" %pM", dev->dev_addr);
 	if (eeprom[16] == 0x11c7) {	/* Corkscrew */
 		if (request_dma(dev->dma, "3c515")) {
-			printk(", DMA %d allocation failed", dev->dma);
+			pr_warning(", DMA %d allocation failed", dev->dma);
 			dev->dma = 0;
 		} else
-			printk(", DMA %d", dev->dma);
+			pr_info(", DMA %d", dev->dma);
 	}
-	printk(", IRQ %d\n", dev->irq);
+	pr_info(", IRQ %d\n", dev->irq);
 	/* Tell them about an invalid IRQ. */
 	if (corkscrew_debug && (dev->irq <= 0 || dev->irq > 15))
-		printk(KERN_WARNING " *** Warning: this IRQ is unlikely to work! ***\n");
+		pr_warning(" *** Warning: this IRQ is unlikely to work! ***\n");
 
 	{
 		char *ram_split[] = { "5:3", "3:1", "1:1", "3:5" };
@@ -669,9 +669,9 @@ static int corkscrew_setup(struct net_device *dev, int ioaddr,
 		vp->available_media = inw(ioaddr + Wn3_Options);
 		config = inl(ioaddr + Wn3_Config);
 		if (corkscrew_debug > 1)
-			printk(KERN_INFO "  Internal config register is %4.4x, transceivers %#x.\n",
+			pr_info("  Internal config register is %4.4x, transceivers %#x.\n",
 				config, inw(ioaddr + Wn3_Options));
-		printk(KERN_INFO "  %dK %s-wide RAM %s Rx:Tx split, %s%s interface.\n",
+		pr_info("  %dK %s-wide RAM %s Rx:Tx split, %s%s interface.\n",
 			8 << config & Ram_size,
 			config & Ram_width ? "word" : "byte",
 			ram_split[(config & Ram_split) >> Ram_split_shift],
@@ -682,7 +682,7 @@ static int corkscrew_setup(struct net_device *dev, int ioaddr,
 		dev->if_port = vp->default_media;
 	}
 	if (vp->media_override != 7) {
-		printk(KERN_INFO "  Media override to transceiver type %d (%s).\n",
+		pr_info("  Media override to transceiver type %d (%s).\n",
 		       vp->media_override,
 		       media_tbl[vp->media_override].name);
 		dev->if_port = vp->media_override;
@@ -718,7 +718,7 @@ static int corkscrew_open(struct net_device *dev)
 
 	if (vp->media_override != 7) {
 		if (corkscrew_debug > 1)
-			printk(KERN_INFO "%s: Media override to transceiver %d (%s).\n",
+			pr_info("%s: Media override to transceiver %d (%s).\n",
 				dev->name, vp->media_override,
 				media_tbl[vp->media_override].name);
 		dev->if_port = vp->media_override;
@@ -729,7 +729,7 @@ static int corkscrew_open(struct net_device *dev)
 			dev->if_port = media_tbl[dev->if_port].next;
 
 		if (corkscrew_debug > 1)
-			printk("%s: Initial media type %s.\n",
+			pr_debug("%s: Initial media type %s.\n",
 			       dev->name, media_tbl[dev->if_port].name);
 
 		init_timer(&vp->timer);
@@ -744,7 +744,7 @@ static int corkscrew_open(struct net_device *dev)
 	outl(config, ioaddr + Wn3_Config);
 
 	if (corkscrew_debug > 1) {
-		printk("%s: corkscrew_open() InternalConfig %8.8x.\n",
+		pr_debug("%s: corkscrew_open() InternalConfig %8.8x.\n",
 		       dev->name, config);
 	}
 
@@ -777,7 +777,7 @@ static int corkscrew_open(struct net_device *dev)
 
 	if (corkscrew_debug > 1) {
 		EL3WINDOW(4);
-		printk("%s: corkscrew_open() irq %d media status %4.4x.\n",
+		pr_debug("%s: corkscrew_open() irq %d media status %4.4x.\n",
 		       dev->name, dev->irq, inw(ioaddr + Wn4_Media));
 	}
 
@@ -814,8 +814,7 @@ static int corkscrew_open(struct net_device *dev)
 	if (vp->full_bus_master_rx) {	/* Boomerang bus master. */
 		vp->cur_rx = vp->dirty_rx = 0;
 		if (corkscrew_debug > 2)
-			printk("%s:  Filling in the Rx ring.\n",
-			       dev->name);
+			pr_debug("%s:  Filling in the Rx ring.\n", dev->name);
 		for (i = 0; i < RX_RING_SIZE; i++) {
 			struct sk_buff *skb;
 			if (i < (RX_RING_SIZE - 1))
@@ -877,7 +876,7 @@ static void corkscrew_timer(unsigned long data)
 	int ok = 0;
 
 	if (corkscrew_debug > 1)
-		printk("%s: Media selection timer tick happened, %s.\n",
+		pr_debug("%s: Media selection timer tick happened, %s.\n",
 		       dev->name, media_tbl[dev->if_port].name);
 
 	spin_lock_irqsave(&vp->lock, flags);
@@ -894,12 +893,12 @@ static void corkscrew_timer(unsigned long data)
 			if (media_status & Media_LnkBeat) {
 				ok = 1;
 				if (corkscrew_debug > 1)
-					printk("%s: Media %s has link beat, %x.\n",
+					pr_debug("%s: Media %s has link beat, %x.\n",
 						dev->name,
 						media_tbl[dev->if_port].name,
 						media_status);
 			} else if (corkscrew_debug > 1)
-				printk("%s: Media %s is has no link beat, %x.\n",
+				pr_debug("%s: Media %s is has no link beat, %x.\n",
 					dev->name,
 					media_tbl[dev->if_port].name,
 					media_status);
@@ -907,7 +906,7 @@ static void corkscrew_timer(unsigned long data)
 			break;
 		default:	/* Other media types handled by Tx timeouts. */
 			if (corkscrew_debug > 1)
-				printk("%s: Media %s is has no indication, %x.\n",
+				pr_debug("%s: Media %s is has no indication, %x.\n",
 					dev->name,
 					media_tbl[dev->if_port].name,
 					media_status);
@@ -925,12 +924,12 @@ static void corkscrew_timer(unsigned long data)
 			if (dev->if_port == 8) {	/* Go back to default. */
 				dev->if_port = vp->default_media;
 				if (corkscrew_debug > 1)
-					printk("%s: Media selection failing, using default %s port.\n",
+					pr_debug("%s: Media selection failing, using default %s port.\n",
 						dev->name,
 						media_tbl[dev->if_port].name);
 			} else {
 				if (corkscrew_debug > 1)
-					printk("%s: Media selection failed, now trying %s port.\n",
+					pr_debug("%s: Media selection failed, now trying %s port.\n",
 						dev->name,
 						media_tbl[dev->if_port].name);
 				vp->timer.expires = jiffies + media_tbl[dev->if_port].wait;
@@ -953,7 +952,7 @@ static void corkscrew_timer(unsigned long data)
 
 	spin_unlock_irqrestore(&vp->lock, flags);
 	if (corkscrew_debug > 1)
-		printk("%s: Media selection timer finished, %s.\n",
+		pr_debug("%s: Media selection timer finished, %s.\n",
 		       dev->name, media_tbl[dev->if_port].name);
 
 #endif				/* AUTOMEDIA */
@@ -966,23 +965,21 @@ static void corkscrew_timeout(struct net_device *dev)
 	struct corkscrew_private *vp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
-	printk(KERN_WARNING
-	       "%s: transmit timed out, tx_status %2.2x status %4.4x.\n",
+	pr_warning("%s: transmit timed out, tx_status %2.2x status %4.4x.\n",
 	       dev->name, inb(ioaddr + TxStatus),
 	       inw(ioaddr + EL3_STATUS));
 	/* Slight code bloat to be user friendly. */
 	if ((inb(ioaddr + TxStatus) & 0x88) == 0x88)
-		printk(KERN_WARNING
-		       "%s: Transmitter encountered 16 collisions -- network"
+		pr_warning("%s: Transmitter encountered 16 collisions --"
 		       " network cable problem?\n", dev->name);
 #ifndef final_version
-	printk("  Flags; bus-master %d, full %d; dirty %d current %d.\n",
+	pr_debug("  Flags; bus-master %d, full %d; dirty %d current %d.\n",
 	       vp->full_bus_master_tx, vp->tx_full, vp->dirty_tx,
 	       vp->cur_tx);
-	printk("  Down list %8.8x vs. %p.\n", inl(ioaddr + DownListPtr),
+	pr_debug("  Down list %8.8x vs. %p.\n", inl(ioaddr + DownListPtr),
 	       &vp->tx_ring[0]);
 	for (i = 0; i < TX_RING_SIZE; i++) {
-		printk("  %d: %p  length %8.8x status %8.8x\n", i,
+		pr_debug("  %d: %p  length %8.8x status %8.8x\n", i,
 		       &vp->tx_ring[i],
 		       vp->tx_ring[i].length, vp->tx_ring[i].status);
 	}
@@ -1023,7 +1020,7 @@ static int corkscrew_start_xmit(struct sk_buff *skb,
 		else
 			prev_entry = NULL;
 		if (corkscrew_debug > 3)
-			printk("%s: Trying to send a packet, Tx index %d.\n",
+			pr_debug("%s: Trying to send a packet, Tx index %d.\n",
 				dev->name, vp->cur_tx);
 		/* vp->tx_full = 1; */
 		vp->tx_skbuff[entry] = skb;
@@ -1102,7 +1099,7 @@ static int corkscrew_start_xmit(struct sk_buff *skb,
 		while (--i > 0 && (tx_status = inb(ioaddr + TxStatus)) > 0) {
 			if (tx_status & 0x3C) {	/* A Tx-disabling error occurred.  */
 				if (corkscrew_debug > 2)
-					printk("%s: Tx error, status %2.2x.\n",
+					pr_debug("%s: Tx error, status %2.2x.\n",
 						dev->name, tx_status);
 				if (tx_status & 0x04)
 					dev->stats.tx_fifo_errors++;
@@ -1143,7 +1140,7 @@ static irqreturn_t corkscrew_interrupt(int irq, void *dev_id)
 	status = inw(ioaddr + EL3_STATUS);
 
 	if (corkscrew_debug > 4)
-		printk("%s: interrupt, status %4.4x, timer %d.\n",
+		pr_debug("%s: interrupt, status %4.4x, timer %d.\n",
 			dev->name, status, latency);
 	if ((status & 0xE000) != 0xE000) {
 		static int donedidthis;
@@ -1151,7 +1148,7 @@ static irqreturn_t corkscrew_interrupt(int irq, void *dev_id)
 		   Ignore a single early interrupt, but don't hang the machine for
 		   other interrupt problems. */
 		if (donedidthis++ > 100) {
-			printk(KERN_ERR "%s: Bogus interrupt, bailing. Status %4.4x, start=%d.\n",
+			pr_err("%s: Bogus interrupt, bailing. Status %4.4x, start=%d.\n",
 				   dev->name, status, netif_running(dev));
 			free_irq(dev->irq, dev);
 			dev->irq = -1;
@@ -1160,14 +1157,14 @@ static irqreturn_t corkscrew_interrupt(int irq, void *dev_id)
 
 	do {
 		if (corkscrew_debug > 5)
-			printk("%s: In interrupt loop, status %4.4x.\n",
+			pr_debug("%s: In interrupt loop, status %4.4x.\n",
 			       dev->name, status);
 		if (status & RxComplete)
 			corkscrew_rx(dev);
 
 		if (status & TxAvailable) {
 			if (corkscrew_debug > 5)
-				printk("	TX room bit was handled.\n");
+				pr_debug("	TX room bit was handled.\n");
 			/* There's room in the FIFO for a full-sized packet. */
 			outw(AckIntr | TxAvailable, ioaddr + EL3_CMD);
 			netif_wake_queue(dev);
@@ -1212,19 +1209,19 @@ static irqreturn_t corkscrew_interrupt(int irq, void *dev_id)
 			if (status & StatsFull) {	/* Empty statistics. */
 				static int DoneDidThat;
 				if (corkscrew_debug > 4)
-					printk("%s: Updating stats.\n", dev->name);
+					pr_debug("%s: Updating stats.\n", dev->name);
 				update_stats(ioaddr, dev);
 				/* DEBUG HACK: Disable statistics as an interrupt source. */
 				/* This occurs when we have the wrong media type! */
 				if (DoneDidThat == 0 && inw(ioaddr + EL3_STATUS) & StatsFull) {
 					int win, reg;
-					printk("%s: Updating stats failed, disabling stats as an"
+					pr_notice("%s: Updating stats failed, disabling stats as an"
 					     " interrupt source.\n", dev->name);
 					for (win = 0; win < 8; win++) {
 						EL3WINDOW(win);
-						printk("\n Vortex window %d:", win);
+						pr_notice("\n Vortex window %d:", win);
 						for (reg = 0; reg < 16; reg++)
-							printk(" %2.2x", inb(ioaddr + reg));
+							pr_notice(" %2.2x", inb(ioaddr + reg));
 					}
 					EL3WINDOW(7);
 					outw(SetIntrEnb | TxAvailable |
@@ -1246,7 +1243,7 @@ static irqreturn_t corkscrew_interrupt(int irq, void *dev_id)
 		}
 
 		if (--i < 0) {
-			printk(KERN_ERR "%s: Too much work in interrupt, status %4.4x.  "
+			pr_err("%s: Too much work in interrupt, status %4.4x.  "
 			     "Disabling functions (%4.4x).\n", dev->name,
 			     status, SetStatusEnb | ((~status) & 0x7FE));
 			/* Disable all pending interrupts. */
@@ -1262,7 +1259,7 @@ static irqreturn_t corkscrew_interrupt(int irq, void *dev_id)
 	spin_unlock(&lp->lock);
 
 	if (corkscrew_debug > 4)
-		printk("%s: exiting interrupt, status %4.4x.\n", dev->name, status);
+		pr_debug("%s: exiting interrupt, status %4.4x.\n", dev->name, status);
 	return IRQ_HANDLED;
 }
 
@@ -1273,13 +1270,13 @@ static int corkscrew_rx(struct net_device *dev)
 	short rx_status;
 
 	if (corkscrew_debug > 5)
-		printk("   In rx_packet(), status %4.4x, rx_status %4.4x.\n",
+		pr_debug("   In rx_packet(), status %4.4x, rx_status %4.4x.\n",
 		     inw(ioaddr + EL3_STATUS), inw(ioaddr + RxStatus));
 	while ((rx_status = inw(ioaddr + RxStatus)) > 0) {
 		if (rx_status & 0x4000) {	/* Error, update stats. */
 			unsigned char rx_error = inb(ioaddr + RxErrors);
 			if (corkscrew_debug > 2)
-				printk(" Rx error: status %2.2x.\n",
+				pr_debug(" Rx error: status %2.2x.\n",
 				       rx_error);
 			dev->stats.rx_errors++;
 			if (rx_error & 0x01)
@@ -1299,7 +1296,7 @@ static int corkscrew_rx(struct net_device *dev)
 
 			skb = dev_alloc_skb(pkt_len + 5 + 2);
 			if (corkscrew_debug > 4)
-				printk("Receiving packet size %d status %4.4x.\n",
+				pr_debug("Receiving packet size %d status %4.4x.\n",
 				     pkt_len, rx_status);
 			if (skb != NULL) {
 				skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
@@ -1318,7 +1315,7 @@ static int corkscrew_rx(struct net_device *dev)
 						break;
 				continue;
 			} else if (corkscrew_debug)
-				printk("%s: Couldn't allocate a sk_buff of size %d.\n", dev->name, pkt_len);
+				pr_debug("%s: Couldn't allocate a sk_buff of size %d.\n", dev->name, pkt_len);
 		}
 		outw(RxDiscard, ioaddr + EL3_CMD);
 		dev->stats.rx_dropped++;
@@ -1338,13 +1335,13 @@ static int boomerang_rx(struct net_device *dev)
 	int rx_status;
 
 	if (corkscrew_debug > 5)
-		printk("   In boomerang_rx(), status %4.4x, rx_status %4.4x.\n",
+		pr_debug("   In boomerang_rx(), status %4.4x, rx_status %4.4x.\n",
 			inw(ioaddr + EL3_STATUS), inw(ioaddr + RxStatus));
 	while ((rx_status = vp->rx_ring[entry].status) & RxDComplete) {
 		if (rx_status & RxDError) {	/* Error, update stats. */
 			unsigned char rx_error = rx_status >> 16;
 			if (corkscrew_debug > 2)
-				printk(" Rx error: status %2.2x.\n",
+				pr_debug(" Rx error: status %2.2x.\n",
 				       rx_error);
 			dev->stats.rx_errors++;
 			if (rx_error & 0x01)
@@ -1364,7 +1361,7 @@ static int boomerang_rx(struct net_device *dev)
 
 			dev->stats.rx_bytes += pkt_len;
 			if (corkscrew_debug > 4)
-				printk("Receiving packet size %d status %4.4x.\n",
+				pr_debug("Receiving packet size %d status %4.4x.\n",
 				     pkt_len, rx_status);
 
 			/* Check if the packet is long enough to just accept without
@@ -1385,7 +1382,7 @@ static int boomerang_rx(struct net_device *dev)
 				temp = skb_put(skb, pkt_len);
 				/* Remove this checking code for final release. */
 				if (isa_bus_to_virt(vp->rx_ring[entry].addr) != temp)
-					    printk("%s: Warning -- the skbuff addresses do not match"
+					pr_warning("%s: Warning -- the skbuff addresses do not match"
 					     " in boomerang_rx: %p vs. %p / %p.\n",
 					     dev->name,
 					     isa_bus_to_virt(vp->
@@ -1427,10 +1424,10 @@ static int corkscrew_close(struct net_device *dev)
 	netif_stop_queue(dev);
 
 	if (corkscrew_debug > 1) {
-		printk("%s: corkscrew_close() status %4.4x, Tx status %2.2x.\n",
+		pr_debug("%s: corkscrew_close() status %4.4x, Tx status %2.2x.\n",
 		     dev->name, inw(ioaddr + EL3_STATUS),
 		     inb(ioaddr + TxStatus));
-		printk("%s: corkscrew close stats: rx_nocopy %d rx_copy %d"
+		pr_debug("%s: corkscrew close stats: rx_nocopy %d rx_copy %d"
 		       " tx_queued %d.\n", dev->name, rx_nocopy, rx_copy,
 		       queued_packet);
 	}
@@ -1534,7 +1531,7 @@ static void set_rx_mode(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC) {
 		if (corkscrew_debug > 3)
-			printk("%s: Setting promiscuous mode.\n",
+			pr_debug("%s: Setting promiscuous mode.\n",
 			       dev->name);
 		new_mode = SetRxFilter | RxStation | RxMulticast | RxBroadcast | RxProm;
 	} else if ((dev->mc_list) || (dev->flags & IFF_ALLMULTI)) {
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index 8f734d7..b3cfb2f 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -176,7 +176,7 @@ sizeof(nop_cmd) = 8;
     if(!p->scb->cmd) break; \
     DELAY_16(); \
     if(i == 1023) { \
-      printk(KERN_WARNING "%s:%d: scb_cmd timed out .. resetting i82586\n",\
+      pr_warning("%s:%d: scb_cmd timed out .. resetting i82586\n",\
       	dev->name,__LINE__); \
       elmc_id_reset586(); } } }
 
@@ -291,7 +291,7 @@ static int elmc_open(struct net_device *dev)
 	ret = request_irq(dev->irq, &elmc_interrupt, IRQF_SHARED | IRQF_SAMPLE_RANDOM,
 			  dev->name, dev);
 	if (ret) {
-		printk(KERN_ERR "%s: couldn't get irq %d\n", dev->name, dev->irq);
+		pr_err("%s: couldn't get irq %d\n", dev->name, dev->irq);
 		elmc_id_reset586();
 		return ret;
 	}
@@ -371,9 +371,9 @@ static void alloc586(struct net_device *dev)
 
 	DELAY(2);
 
-	if (p->iscp->busy) {
-		printk(KERN_ERR "%s: Init-Problems (alloc).\n", dev->name);
-	}
+	if (p->iscp->busy)
+		pr_err("%s: Init-Problems (alloc).\n", dev->name);
+
 	memset((char *) p->scb, 0, sizeof(struct scb_struct));
 }
 
@@ -470,7 +470,7 @@ static int __init do_elmc_probe(struct net_device *dev)
 	mca_set_adapter_procfn(slot, (MCA_ProcFn) elmc_getinfo, dev);
 
 	/* if we get this far, adapter has been found - carry on */
-	printk(KERN_INFO "%s: 3c523 adapter found in slot %d\n", dev->name, slot + 1);
+	pr_info("%s: 3c523 adapter found in slot %d\n", dev->name, slot + 1);
 
 	/* Now we extract configuration info from the card.
 	   The 3c523 provides information in two of the POS registers, but
@@ -507,7 +507,7 @@ static int __init do_elmc_probe(struct net_device *dev)
 	memset(pr, 0, sizeof(struct priv));
 	pr->slot = slot;
 
-	printk(KERN_INFO "%s: 3Com 3c523 Rev 0x%x at %#lx\n", dev->name, (int) revision,
+	pr_info("%s: 3Com 3c523 Rev 0x%x at %#lx\n", dev->name, (int) revision,
 	       dev->base_addr);
 
 	/* Determine if we're using the on-board transceiver (i.e. coax) or
@@ -529,7 +529,7 @@ static int __init do_elmc_probe(struct net_device *dev)
 
 	size = 0x4000;		/* check for 16K mem */
 	if (!check586(dev, dev->mem_start, size)) {
-		printk(KERN_ERR "%s: memprobe, Can't find memory at 0x%lx!\n", dev->name,
+		pr_err("%s: memprobe, Can't find memory at 0x%lx!\n", dev->name,
 		       dev->mem_start);
 		retval = -ENODEV;
 		goto err_out;
@@ -546,7 +546,7 @@ static int __init do_elmc_probe(struct net_device *dev)
 	pr->num_recv_buffs = NUM_RECV_BUFFS_16;
 
 	/* dump all the assorted information */
-	printk(KERN_INFO "%s: IRQ %d, %sternal xcvr, memory %#lx-%#lx.\n", dev->name,
+	pr_info("%s: IRQ %d, %sternal xcvr, memory %#lx-%#lx.\n", dev->name,
 	       dev->irq, dev->if_port ? "ex" : "in",
 	       dev->mem_start, dev->mem_end - 1);
 
@@ -555,7 +555,7 @@ static int __init do_elmc_probe(struct net_device *dev)
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = inb(dev->base_addr + i);
 
-	printk(KERN_INFO "%s: hardware address %pM\n",
+	pr_info("%s: hardware address %pM\n",
 	       dev->name, dev->dev_addr);
 
 	dev->netdev_ops = &netdev_ops;
@@ -660,7 +660,7 @@ static int init586(struct net_device *dev)
 	}
 
 	if ((cfg_cmd->cmd_status & (STAT_OK | STAT_COMPL)) != (STAT_COMPL | STAT_OK)) {
-		printk(KERN_WARNING "%s (elmc): configure command failed: %x\n", dev->name, cfg_cmd->cmd_status);
+		pr_warning("%s (elmc): configure command failed: %x\n", dev->name, cfg_cmd->cmd_status);
 		return 1;
 	}
 	/*
@@ -686,7 +686,7 @@ static int init586(struct net_device *dev)
 	}
 
 	if ((ias_cmd->cmd_status & (STAT_OK | STAT_COMPL)) != (STAT_OK | STAT_COMPL)) {
-		printk(KERN_WARNING "%s (elmc): individual address setup command failed: %04x\n", dev->name, ias_cmd->cmd_status);
+		pr_warning("%s (elmc): individual address setup command failed: %04x\n", dev->name, ias_cmd->cmd_status);
 		return 1;
 	}
 	/*
@@ -707,7 +707,7 @@ static int init586(struct net_device *dev)
 	s = jiffies;
 	while (!(tdr_cmd->cmd_status & STAT_COMPL)) {
 		if (time_after(jiffies, s + 30*HZ/100)) {
-			printk(KERN_WARNING "%s: %d Problems while running the TDR.\n", dev->name, __LINE__);
+			pr_warning("%s: %d Problems while running the TDR.\n", dev->name, __LINE__);
 			result = 1;
 			break;
 		}
@@ -723,14 +723,14 @@ static int init586(struct net_device *dev)
 		if (result & TDR_LNK_OK) {
 			/* empty */
 		} else if (result & TDR_XCVR_PRB) {
-			printk(KERN_WARNING "%s: TDR: Transceiver problem!\n", dev->name);
+			pr_warning("%s: TDR: Transceiver problem!\n", dev->name);
 		} else if (result & TDR_ET_OPN) {
-			printk(KERN_WARNING "%s: TDR: No correct termination %d clocks away.\n", dev->name, result & TDR_TIMEMASK);
+			pr_warning("%s: TDR: No correct termination %d clocks away.\n", dev->name, result & TDR_TIMEMASK);
 		} else if (result & TDR_ET_SRT) {
 			if (result & TDR_TIMEMASK)	/* time == 0 -> strange :-) */
-				printk(KERN_WARNING "%s: TDR: Detected a short circuit %d clocks away.\n", dev->name, result & TDR_TIMEMASK);
+				pr_warning("%s: TDR: Detected a short circuit %d clocks away.\n", dev->name, result & TDR_TIMEMASK);
 		} else {
-			printk(KERN_WARNING "%s: TDR: Unknown status %04x\n", dev->name, result);
+			pr_warning("%s: TDR: Unknown status %04x\n", dev->name, result);
 		}
 	}
 	/*
@@ -774,11 +774,11 @@ static int init586(struct net_device *dev)
 		/* I don't understand this: do we really need memory after the init? */
 		int len = ((char *) p->iscp - (char *) ptr - 8) / 6;
 		if (len <= 0) {
-			printk(KERN_ERR "%s: Ooooops, no memory for MC-Setup!\n", dev->name);
+			pr_err("%s: Ooooops, no memory for MC-Setup!\n", dev->name);
 		} else {
 			if (len < num_addrs) {
 				num_addrs = len;
-				printk(KERN_WARNING "%s: Sorry, can only apply %d MC-Address(es).\n",
+				pr_warning("%s: Sorry, can only apply %d MC-Address(es).\n",
 				       dev->name, num_addrs);
 			}
 			mc_cmd = (struct mcsetup_cmd_struct *) ptr;
@@ -799,7 +799,7 @@ static int init586(struct net_device *dev)
 					break;
 			}
 			if (!(mc_cmd->cmd_status & STAT_COMPL)) {
-				printk(KERN_WARNING "%s: Can't apply multicast-address-list.\n", dev->name);
+				pr_warning("%s: Can't apply multicast-address-list.\n", dev->name);
 			}
 		}
 	}
@@ -812,7 +812,7 @@ static int init586(struct net_device *dev)
 		p->xmit_buffs[i] = (struct tbd_struct *) ptr;	/* TBD */
 		ptr = (char *) ptr + sizeof(struct tbd_struct);
 		if ((void *) ptr > (void *) p->iscp) {
-			printk(KERN_ERR "%s: not enough shared-mem for your configuration!\n", dev->name);
+			pr_err("%s: not enough shared-mem for your configuration!\n", dev->name);
 			return 1;
 		}
 		memset((char *) (p->xmit_cmds[i]), 0, sizeof(struct transmit_cmd_struct));
@@ -936,7 +936,7 @@ elmc_interrupt(int irq, void *dev_id)
 		if (stat & STAT_CNA) {
 			/* CU went 'not ready' */
 			if (netif_running(dev)) {
-				printk(KERN_WARNING "%s: oops! CU has left active state. stat: %04x/%04x.\n", dev->name, (int) stat, (int) p->scb->status);
+				pr_warning("%s: oops! CU has left active state. stat: %04x/%04x.\n", dev->name, (int) stat, (int) p->scb->status);
 			}
 		}
 #endif
@@ -951,7 +951,7 @@ elmc_interrupt(int irq, void *dev_id)
 				p->scb->cmd = RUC_RESUME;
 				elmc_attn586();
 			} else {
-				printk(KERN_WARNING "%s: Receiver-Unit went 'NOT READY': %04x/%04x.\n", dev->name, (int) stat, (int) p->scb->status);
+				pr_warning("%s: Receiver-Unit went 'NOT READY': %04x/%04x.\n", dev->name, (int) stat, (int) p->scb->status);
 				elmc_rnr_int(dev);
 			}
 		}
@@ -995,11 +995,11 @@ static void elmc_rcv_int(struct net_device *dev)
 					dev->stats.rx_dropped++;
 				}
 			} else {
-				printk(KERN_WARNING "%s: received oversized frame.\n", dev->name);
+				pr_warning("%s: received oversized frame.\n", dev->name);
 				dev->stats.rx_dropped++;
 			}
 		} else {	/* frame !(ok), only with 'save-bad-frames' */
-			printk(KERN_WARNING "%s: oops! rfd-error-status: %04x\n", dev->name, status);
+			pr_warning("%s: oops! rfd-error-status: %04x\n", dev->name, status);
 			dev->stats.rx_errors++;
 		}
 		p->rfd_top->status = 0;
@@ -1028,7 +1028,7 @@ static void elmc_rnr_int(struct net_device *dev)
 	alloc_rfa(dev, (char *) p->rfd_first);
 	startrecv586(dev);	/* restart RU */
 
-	printk(KERN_WARNING "%s: Receive-Unit restarted. Status: %04x\n", dev->name, p->scb->status);
+	pr_warning("%s: Receive-Unit restarted. Status: %04x\n", dev->name, p->scb->status);
 
 }
 
@@ -1043,7 +1043,7 @@ static void elmc_xmt_int(struct net_device *dev)
 
 	status = p->xmit_cmds[p->xmit_last]->cmd_status;
 	if (!(status & STAT_COMPL)) {
-		printk(KERN_WARNING "%s: strange .. xmit-int without a 'COMPLETE'\n", dev->name);
+		pr_warning("%s: strange .. xmit-int without a 'COMPLETE'\n", dev->name);
 	}
 	if (status & STAT_OK) {
 		dev->stats.tx_packets++;
@@ -1051,18 +1051,18 @@ static void elmc_xmt_int(struct net_device *dev)
 	} else {
 		dev->stats.tx_errors++;
 		if (status & TCMD_LATECOLL) {
-			printk(KERN_WARNING "%s: late collision detected.\n", dev->name);
+			pr_warning("%s: late collision detected.\n", dev->name);
 			dev->stats.collisions++;
 		} else if (status & TCMD_NOCARRIER) {
 			dev->stats.tx_carrier_errors++;
-			printk(KERN_WARNING "%s: no carrier detected.\n", dev->name);
+			pr_warning("%s: no carrier detected.\n", dev->name);
 		} else if (status & TCMD_LOSTCTS) {
-			printk(KERN_WARNING "%s: loss of CTS detected.\n", dev->name);
+			pr_warning("%s: loss of CTS detected.\n", dev->name);
 		} else if (status & TCMD_UNDERRUN) {
 			dev->stats.tx_fifo_errors++;
-			printk(KERN_WARNING "%s: DMA underrun detected.\n", dev->name);
+			pr_warning("%s: DMA underrun detected.\n", dev->name);
 		} else if (status & TCMD_MAXCOLL) {
-			printk(KERN_WARNING "%s: Max. collisions exceeded.\n", dev->name);
+			pr_warning("%s: Max. collisions exceeded.\n", dev->name);
 			dev->stats.collisions += 16;
 		}
 	}
@@ -1099,10 +1099,11 @@ static void elmc_timeout(struct net_device *dev)
 	struct priv *p = netdev_priv(dev);
 	/* COMMAND-UNIT active? */
 	if (p->scb->status & CU_ACTIVE) {
-#ifdef DEBUG
-		printk("%s: strange ... timeout with CU active?!?\n", dev->name);
-		printk("%s: X0: %04x N0: %04x N1: %04x %d\n", dev->name, (int) p->xmit_cmds[0]->cmd_status, (int) p->nop_cmds[0]->cmd_status, (int) p->nop_cmds[1]->cmd_status, (int) p->nop_point);
-#endif
+		pr_debug("%s: strange ... timeout with CU active?!?\n", dev->name);
+		pr_debug("%s: X0: %04x N0: %04x N1: %04x %d\n", dev->name,
+			(int)p->xmit_cmds[0]->cmd_status,
+			(int)p->nop_cmds[0]->cmd_status,
+			(int)p->nop_cmds[1]->cmd_status, (int)p->nop_point);
 		p->scb->cmd = CUC_ABORT;
 		elmc_attn586();
 		WAIT_4_SCB_CMD();
@@ -1112,10 +1113,8 @@ static void elmc_timeout(struct net_device *dev)
 		WAIT_4_SCB_CMD();
 		netif_wake_queue(dev);
 	} else {
-#ifdef DEBUG
-		printk("%s: xmitter timed out, try to restart! stat: %04x\n", dev->name, p->scb->status);
-		printk("%s: command-stats: %04x %04x\n", dev->name, p->xmit_cmds[0]->cmd_status, p->xmit_cmds[1]->cmd_status);
-#endif
+		pr_debug("%s: xmitter timed out, try to restart! stat: %04x\n", dev->name, p->scb->status);
+		pr_debug("%s: command-stats: %04x %04x\n", dev->name, p->xmit_cmds[0]->cmd_status, p->xmit_cmds[1]->cmd_status);
 		elmc_close(dev);
 		elmc_open(dev);
 	}
@@ -1162,7 +1161,7 @@ static int elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
 			break;
 		}
 		if (i == 15) {
-			printk(KERN_WARNING "%s: Can't start transmit-command.\n", dev->name);
+			pr_warning("%s: Can't start transmit-command.\n", dev->name);
 		}
 	}
 #else
@@ -1287,11 +1286,12 @@ int __init init_module(void)
 		free_netdev(dev);
 		if (io[this_dev]==0)
 			break;
-		printk(KERN_WARNING "3c523.c: No 3c523 card found at io=%#x\n",io[this_dev]);
+		pr_warning("3c523.c: No 3c523 card found at io=%#x\n",io[this_dev]);
 	}
 
 	if(found==0) {
-		if(io[0]==0) printk(KERN_NOTICE "3c523.c: No 3c523 cards found\n");
+		if (io[0]==0)
+			pr_notice("3c523.c: No 3c523 cards found\n");
 		return -ENXIO;
 	} else return 0;
 }
diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index b61073c..d93eb70 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -125,8 +125,6 @@ static const char* cardname = DRV_NAME;
 #define NET_DEBUG 2
 #endif
 
-#undef DEBUG_IRQ
-
 static unsigned int mc32_debug = NET_DEBUG;
 
 /* The number of low I/O ports used by the ethercard. */
@@ -351,15 +349,15 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 	/* Time to play MCA games */
 
 	if (mc32_debug  &&  version_printed++ == 0)
-		printk(KERN_DEBUG "%s", version);
+		pr_debug("%s", version);
 
-	printk(KERN_INFO "%s: %s found in slot %d:", dev->name, cardname, slot);
+	pr_info("%s: %s found in slot %d:", dev->name, cardname, slot);
 
 	POS = mca_read_stored_pos(slot, 2);
 
 	if(!(POS&1))
 	{
-		printk(" disabled.\n");
+		pr_info(" disabled.\n");
 		return -ENODEV;
 	}
 
@@ -370,7 +368,7 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 	POS = mca_read_stored_pos(slot, 4);
 	if(!(POS&1))
 	{
-		printk("memory window disabled.\n");
+		pr_info("memory window disabled.\n");
 		return -ENODEV;
 	}
 
@@ -379,7 +377,7 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 	i=(POS>>4)&3;
 	if(i==3)
 	{
-		printk("invalid memory window.\n");
+		pr_info("invalid memory window.\n");
 		return -ENODEV;
 	}
 
@@ -392,11 +390,11 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 
 	if(!request_region(dev->base_addr, MC32_IO_EXTENT, cardname))
 	{
-		printk("io 0x%3lX, which is busy.\n", dev->base_addr);
+		pr_info("io 0x%3lX, which is busy.\n", dev->base_addr);
 		return -EBUSY;
 	}
 
-	printk("io 0x%3lX irq %d mem 0x%lX (%dK)\n",
+	pr_info("io 0x%3lX irq %d mem 0x%lX (%dK)\n",
 		dev->base_addr, dev->irq, dev->mem_start, i/1024);
 
 
@@ -416,7 +414,7 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 		dev->dev_addr[i] = mca_read_pos(slot,3);
 	}
 
-	printk("%s: Address %pM", dev->name, dev->dev_addr);
+	pr_info("%s: Address %pM", dev->name, dev->dev_addr);
 
 	mca_write_pos(slot, 6, 0);
 	mca_write_pos(slot, 7, 0);
@@ -424,9 +422,9 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 	POS = mca_read_stored_pos(slot, 4);
 
 	if(POS&2)
-		printk(" : BNC port selected.\n");
+		pr_info(" : BNC port selected.\n");
 	else
-		printk(" : AUI port selected.\n");
+		pr_info(" : AUI port selected.\n");
 
 	POS=inb(dev->base_addr+HOST_CTRL);
 	POS|=HOST_CTRL_ATTN|HOST_CTRL_RESET;
@@ -447,7 +445,7 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 	err = request_irq(dev->irq, &mc32_interrupt, IRQF_SHARED | IRQF_SAMPLE_RANDOM, DRV_NAME, dev);
 	if (err) {
 		release_region(dev->base_addr, MC32_IO_EXTENT);
-		printk(KERN_ERR "%s: unable to get IRQ %d.\n", DRV_NAME, dev->irq);
+		pr_err("%s: unable to get IRQ %d.\n", DRV_NAME, dev->irq);
 		goto err_exit_ports;
 	}
 
@@ -463,7 +461,7 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 		i++;
 		if(i == 1000)
 		{
-			printk(KERN_ERR "%s: failed to boot adapter.\n", dev->name);
+			pr_err("%s: failed to boot adapter.\n", dev->name);
 			err = -ENODEV;
 			goto err_exit_irq;
 		}
@@ -475,10 +473,10 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 	if(base>0)
 	{
 		if(base < 0x0C)
-			printk(KERN_ERR "%s: %s%s.\n", dev->name, failures[base-1],
+			pr_err("%s: %s%s.\n", dev->name, failures[base-1],
 				base<0x0A?" test failure":"");
 		else
-			printk(KERN_ERR "%s: unknown failure %d.\n", dev->name, base);
+			pr_err("%s: unknown failure %d.\n", dev->name, base);
 		err = -ENODEV;
 		goto err_exit_irq;
 	}
@@ -494,7 +492,7 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 			udelay(50);
 			if(n>100)
 			{
-				printk(KERN_ERR "%s: mailbox read fail (%d).\n", dev->name, i);
+				pr_err("%s: mailbox read fail (%d).\n", dev->name, i);
 				err = -ENODEV;
 				goto err_exit_irq;
 			}
@@ -527,7 +525,7 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 	init_completion(&lp->execution_cmd);
 	init_completion(&lp->xceiver_cmd);
 
-	printk("%s: Firmware Rev %d. %d RX buffers, %d TX buffers. Base of 0x%08X.\n",
+	pr_info("%s: Firmware Rev %d. %d RX buffers, %d TX buffers. Base of 0x%08X.\n",
 		dev->name, lp->exec_box->data[12], lp->rx_len, lp->tx_len, lp->base);
 
 	dev->netdev_ops		= &netdev_ops;
@@ -939,7 +937,7 @@ static int mc32_open(struct net_device *dev)
 	 */
 
 	if(mc32_command(dev, 8, descnumbuffs, 4)) {
-		printk("%s: %s rejected our buffer configuration!\n",
+		pr_info("%s: %s rejected our buffer configuration!\n",
 	 	       dev->name, cardname);
 		mc32_close(dev);
 		return -ENOBUFS;
@@ -995,7 +993,7 @@ static int mc32_open(struct net_device *dev)
 
 static void mc32_timeout(struct net_device *dev)
 {
-	printk(KERN_WARNING "%s: transmit timed out?\n", dev->name);
+	pr_warning("%s: transmit timed out?\n", dev->name);
 	/* Try to restart the adaptor. */
 	netif_wake_queue(dev);
 }
@@ -1335,11 +1333,9 @@ static irqreturn_t mc32_interrupt(int irq, void *dev_id)
 	{
 		status=inb(ioaddr+HOST_CMD);
 
-#ifdef DEBUG_IRQ
-		printk("Status TX%d RX%d EX%d OV%d BC%d\n",
+		pr_debug("Status TX%d RX%d EX%d OV%d BC%d\n",
 			(status&7), (status>>3)&7, (status>>6)&1,
 			(status>>7)&1, boguscount);
-#endif
 
 		switch(status&7)
 		{
@@ -1354,7 +1350,7 @@ static irqreturn_t mc32_interrupt(int irq, void *dev_id)
 				complete(&lp->xceiver_cmd);
 				break;
 			default:
-				printk("%s: strange tx ack %d\n", dev->name, status&7);
+				pr_notice("%s: strange tx ack %d\n", dev->name, status&7);
 		}
 		status>>=3;
 		switch(status&7)
@@ -1376,7 +1372,7 @@ static irqreturn_t mc32_interrupt(int irq, void *dev_id)
 				mc32_start_transceiver(dev);
 				break;
 			default:
-				printk("%s: strange rx ack %d\n",
+				pr_notice("%s: strange rx ack %d\n",
 					dev->name, status&7);
 		}
 		status>>=3;
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index c566984..89a8c92 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -828,14 +828,14 @@ static int vortex_resume(struct pci_dev *pdev)
 		pci_restore_state(pdev);
 		err = pci_enable_device(pdev);
 		if (err) {
-			printk(KERN_WARNING "%s: Could not enable device \n",
+			pr_warning("%s: Could not enable device \n",
 				dev->name);
 			return err;
 		}
 		pci_set_master(pdev);
 		if (request_irq(dev->irq, vp->full_bus_master_rx ?
 				&boomerang_interrupt : &vortex_interrupt, IRQF_SHARED, dev->name, dev)) {
-			printk(KERN_WARNING "%s: Could not reserve IRQ %d\n", dev->name, dev->irq);
+			pr_warning("%s: Could not reserve IRQ %d\n", dev->name, dev->irq);
 			pci_disable_device(pdev);
 			return -EBUSY;
 		}
@@ -894,7 +894,7 @@ static int __devexit vortex_eisa_remove(struct device *device)
 	dev = eisa_get_drvdata(edev);
 
 	if (!dev) {
-		printk("vortex_eisa_remove called for Compaq device!\n");
+		pr_err("vortex_eisa_remove called for Compaq device!\n");
 		BUG();
 	}
 
@@ -1051,7 +1051,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 	struct eisa_device *edev = NULL;
 
 	if (!printed_version) {
-		printk (version);
+		pr_info("%s", version);
 		printed_version = 1;
 	}
 
@@ -1068,7 +1068,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 	dev = alloc_etherdev(sizeof(*vp));
 	retval = -ENOMEM;
 	if (!dev) {
-		printk (KERN_ERR PFX "unable to allocate etherdev, aborting\n");
+		pr_err(PFX "unable to allocate etherdev, aborting\n");
 		goto out;
 	}
 	SET_NETDEV_DEV(dev, gendev);
@@ -1100,9 +1100,9 @@ static int __devinit vortex_probe1(struct device *gendev,
 
 	print_info = (vortex_debug > 1);
 	if (print_info)
-		printk (KERN_INFO "See Documentation/networking/vortex.txt\n");
+		pr_info("See Documentation/networking/vortex.txt\n");
 
-	printk(KERN_INFO "%s: 3Com %s %s at %p.\n",
+	pr_info("%s: 3Com %s %s at %p.\n",
 	       print_name,
 	       pdev ? "PCI" : "EISA",
 	       vci->name,
@@ -1144,7 +1144,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 			   chip only. */
 			pci_read_config_byte(pdev, PCI_LATENCY_TIMER, &pci_latency);
 			if (pci_latency < new_latency) {
-				printk(KERN_INFO "%s: Overriding PCI latency"
+				pr_info("%s: Overriding PCI latency"
 					" timer (CFLT) setting of %d, new value is %d.\n",
 					print_name, pci_latency, new_latency);
 					pci_write_config_byte(pdev, PCI_LATENCY_TIMER, new_latency);
@@ -1236,17 +1236,17 @@ static int __devinit vortex_probe1(struct device *gendev,
 		checksum = (checksum ^ (checksum >> 8)) & 0xff;
 	}
 	if ((checksum != 0x00) && !(vci->drv_flags & IS_TORNADO))
-		printk(" ***INVALID CHECKSUM %4.4x*** ", checksum);
+		pr_err(" ***INVALID CHECKSUM %4.4x*** ", checksum);
 	for (i = 0; i < 3; i++)
 		((__be16 *)dev->dev_addr)[i] = htons(eeprom[i + 10]);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 	if (print_info)
-		printk(" %pM", dev->dev_addr);
+		pr_info(" %pM", dev->dev_addr);
 	/* Unfortunately an all zero eeprom passes the checksum and this
 	   gets found in the wild in failure cases. Crypto is hard 8) */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
 		retval = -EINVAL;
-		printk(KERN_ERR "*** EEPROM MAC address is invalid.\n");
+		pr_err("*** EEPROM MAC address is invalid.\n");
 		goto free_ring;	/* With every pack */
 	}
 	EL3WINDOW(2);
@@ -1254,16 +1254,16 @@ static int __devinit vortex_probe1(struct device *gendev,
 		iowrite8(dev->dev_addr[i], ioaddr + i);
 
 	if (print_info)
-		printk(", IRQ %d\n", dev->irq);
+		pr_info(", IRQ %d\n", dev->irq);
 	/* Tell them about an invalid IRQ. */
 	if (dev->irq <= 0 || dev->irq >= nr_irqs)
-		printk(KERN_WARNING " *** Warning: IRQ %d is unlikely to work! ***\n",
+		pr_warning(" *** Warning: IRQ %d is unlikely to work! ***\n",
 			   dev->irq);
 
 	EL3WINDOW(4);
 	step = (ioread8(ioaddr + Wn4_NetDiag) & 0x1e) >> 1;
 	if (print_info) {
-		printk(KERN_INFO "  product code %02x%02x rev %02x.%d date %02d-"
+		pr_info("  product code %02x%02x rev %02x.%d date %02d-"
 			"%02d-%02d\n", eeprom[6]&0xff, eeprom[6]>>8, eeprom[0x14],
 			step, (eeprom[4]>>5) & 15, eeprom[4] & 31, eeprom[4]>>9);
 	}
@@ -1279,7 +1279,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 		}
 
 		if (print_info) {
-			printk(KERN_INFO "%s: CardBus functions mapped "
+			pr_info("%s: CardBus functions mapped "
 				"%16.16llx->%p\n",
 				print_name,
 				(unsigned long long)pci_resource_start(pdev, 2),
@@ -1307,7 +1307,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 	if (vp->info1 & 0x8000) {
 		vp->full_duplex = 1;
 		if (print_info)
-			printk(KERN_INFO "Full duplex capable\n");
+			pr_info("Full duplex capable\n");
 	}
 
 	{
@@ -1319,9 +1319,9 @@ static int __devinit vortex_probe1(struct device *gendev,
 			vp->available_media = 0x40;
 		config = ioread32(ioaddr + Wn3_Config);
 		if (print_info) {
-			printk(KERN_DEBUG "  Internal config register is %4.4x, "
+			pr_debug("  Internal config register is %4.4x, "
 				   "transceivers %#x.\n", config, ioread16(ioaddr + Wn3_Options));
-			printk(KERN_INFO "  %dK %s-wide RAM %s Rx:Tx split, %s%s interface.\n",
+			pr_info("  %dK %s-wide RAM %s Rx:Tx split, %s%s interface.\n",
 				   8 << RAM_SIZE(config),
 				   RAM_WIDTH(config) ? "word" : "byte",
 				   ram_split[RAM_SPLIT(config)],
@@ -1336,7 +1336,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 	}
 
 	if (vp->media_override != 7) {
-		printk(KERN_INFO "%s:  Media override to transceiver type %d (%s).\n",
+		pr_info("%s:  Media override to transceiver type %d (%s).\n",
 				print_name, vp->media_override,
 				media_tbl[vp->media_override].name);
 		dev->if_port = vp->media_override;
@@ -1369,7 +1369,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 			if (mii_status  &&  mii_status != 0xffff) {
 				vp->phys[phy_idx++] = phyx;
 				if (print_info) {
-					printk(KERN_INFO "  MII transceiver found at address %d,"
+					pr_info("  MII transceiver found at address %d,"
 						" status %4x.\n", phyx, mii_status);
 				}
 				if ((mii_status & 0x0040) == 0)
@@ -1378,7 +1378,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 		}
 		mii_preamble_required--;
 		if (phy_idx == 0) {
-			printk(KERN_WARNING"  ***WARNING*** No MII transceivers found!\n");
+			pr_warning("  ***WARNING*** No MII transceivers found!\n");
 			vp->phys[0] = 24;
 		} else {
 			vp->advertising = mdio_read(dev, vp->phys[0], MII_ADVERTISE);
@@ -1394,7 +1394,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 	if (vp->capabilities & CapBusMaster) {
 		vp->full_bus_master_tx = 1;
 		if (print_info) {
-			printk(KERN_INFO "  Enabling bus-master transmits and %s receives.\n",
+			pr_info("  Enabling bus-master transmits and %s receives.\n",
 			(vp->info2 & 1) ? "early" : "whole-frame" );
 		}
 		vp->full_bus_master_rx = (vp->info2 & 1) ? 1 : 2;
@@ -1414,7 +1414,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 		dev->netdev_ops =  &vortex_netdev_ops;
 
 	if (print_info) {
-		printk(KERN_INFO "%s: scatter/gather %sabled. h/w checksums %sabled\n",
+		pr_info("%s: scatter/gather %sabled. h/w checksums %sabled\n",
 				print_name,
 				(dev->features & NETIF_F_SG) ? "en":"dis",
 				(dev->features & NETIF_F_IP_CSUM) ? "en":"dis");
@@ -1442,7 +1442,7 @@ free_region:
 	if (vp->must_free_region)
 		release_region(dev->base_addr, vci->io_size);
 	free_netdev(dev);
-	printk(KERN_ERR PFX "vortex_probe1 fails.  Returns %d\n", retval);
+	pr_err(PFX "vortex_probe1 fails.  Returns %d\n", retval);
 out:
 	return retval;
 }
@@ -1464,13 +1464,13 @@ issue_and_wait(struct net_device *dev, int cmd)
 	for (i = 0; i < 100000; i++) {
 		if (!(ioread16(ioaddr + EL3_STATUS) & CmdInProgress)) {
 			if (vortex_debug > 1)
-				printk(KERN_INFO "%s: command 0x%04x took %d usecs\n",
+				pr_info("%s: command 0x%04x took %d usecs\n",
 					   dev->name, cmd, i * 10);
 			return;
 		}
 		udelay(10);
 	}
-	printk(KERN_ERR "%s: command 0x%04x did not complete! Status=0x%x\n",
+	pr_err("%s: command 0x%04x did not complete! Status=0x%x\n",
 			   dev->name, cmd, ioread16(ioaddr + EL3_STATUS));
 }
 
@@ -1480,7 +1480,7 @@ vortex_set_duplex(struct net_device *dev)
 	struct vortex_private *vp = netdev_priv(dev);
 	void __iomem *ioaddr = vp->ioaddr;
 
-	printk(KERN_INFO "%s:  setting %s-duplex.\n",
+	pr_info("%s:  setting %s-duplex.\n",
 		dev->name, (vp->full_duplex) ? "full" : "half");
 
 	EL3WINDOW(3);
@@ -1522,7 +1522,7 @@ vortex_up(struct net_device *dev)
 			pci_restore_state(VORTEX_PCI(vp));
 		err = pci_enable_device(VORTEX_PCI(vp));
 		if (err) {
-			printk(KERN_WARNING "%s: Could not enable device \n",
+			pr_warning("%s: Could not enable device \n",
 				dev->name);
 			goto err_out;
 		}
@@ -1533,14 +1533,14 @@ vortex_up(struct net_device *dev)
 	config = ioread32(ioaddr + Wn3_Config);
 
 	if (vp->media_override != 7) {
-		printk(KERN_INFO "%s: Media override to transceiver %d (%s).\n",
+		pr_info("%s: Media override to transceiver %d (%s).\n",
 			   dev->name, vp->media_override,
 			   media_tbl[vp->media_override].name);
 		dev->if_port = vp->media_override;
 	} else if (vp->autoselect) {
 		if (vp->has_nway) {
 			if (vortex_debug > 1)
-				printk(KERN_INFO "%s: using NWAY device table, not %d\n",
+				pr_info("%s: using NWAY device table, not %d\n",
 								dev->name, dev->if_port);
 			dev->if_port = XCVR_NWAY;
 		} else {
@@ -1549,13 +1549,13 @@ vortex_up(struct net_device *dev)
 			while (! (vp->available_media & media_tbl[dev->if_port].mask))
 				dev->if_port = media_tbl[dev->if_port].next;
 			if (vortex_debug > 1)
-				printk(KERN_INFO "%s: first available media type: %s\n",
+				pr_info("%s: first available media type: %s\n",
 					dev->name, media_tbl[dev->if_port].name);
 		}
 	} else {
 		dev->if_port = vp->default_media;
 		if (vortex_debug > 1)
-			printk(KERN_INFO "%s: using default media %s\n",
+			pr_info("%s: using default media %s\n",
 				dev->name, media_tbl[dev->if_port].name);
 	}
 
@@ -1570,13 +1570,13 @@ vortex_up(struct net_device *dev)
 	vp->rx_oom_timer.function = rx_oom_timer;
 
 	if (vortex_debug > 1)
-		printk(KERN_DEBUG "%s: Initial media type %s.\n",
+		pr_debug("%s: Initial media type %s.\n",
 			   dev->name, media_tbl[dev->if_port].name);
 
 	vp->full_duplex = vp->mii.force_media;
 	config = BFINS(config, dev->if_port, 20, 4);
 	if (vortex_debug > 6)
-		printk(KERN_DEBUG "vortex_up(): writing 0x%x to InternalConfig\n", config);
+		pr_debug("vortex_up(): writing 0x%x to InternalConfig\n", config);
 	iowrite32(config, ioaddr + Wn3_Config);
 
 	if (dev->if_port == XCVR_MII || dev->if_port == XCVR_NWAY) {
@@ -1602,7 +1602,7 @@ vortex_up(struct net_device *dev)
 
 	if (vortex_debug > 1) {
 		EL3WINDOW(4);
-		printk(KERN_DEBUG "%s: vortex_up() irq %d media status %4.4x.\n",
+		pr_debug("%s: vortex_up() irq %d media status %4.4x.\n",
 			   dev->name, dev->irq, ioread16(ioaddr + Wn4_Media));
 	}
 
@@ -1704,13 +1704,13 @@ vortex_open(struct net_device *dev)
 	/* Use the now-standard shared IRQ implementation. */
 	if ((retval = request_irq(dev->irq, vp->full_bus_master_rx ?
 				&boomerang_interrupt : &vortex_interrupt, IRQF_SHARED, dev->name, dev))) {
-		printk(KERN_ERR "%s: Could not reserve IRQ %d\n", dev->name, dev->irq);
+		pr_err("%s: Could not reserve IRQ %d\n", dev->name, dev->irq);
 		goto err;
 	}
 
 	if (vp->full_bus_master_rx) { /* Boomerang bus master. */
 		if (vortex_debug > 2)
-			printk(KERN_DEBUG "%s:  Filling in the Rx ring.\n", dev->name);
+			pr_debug("%s:  Filling in the Rx ring.\n", dev->name);
 		for (i = 0; i < RX_RING_SIZE; i++) {
 			struct sk_buff *skb;
 			vp->rx_ring[i].next = cpu_to_le32(vp->rx_ring_dma + sizeof(struct boom_rx_desc) * (i+1));
@@ -1728,7 +1728,7 @@ vortex_open(struct net_device *dev)
 		}
 		if (i != RX_RING_SIZE) {
 			int j;
-			printk(KERN_EMERG "%s: no memory for rx ring\n", dev->name);
+			pr_emerg("%s: no memory for rx ring\n", dev->name);
 			for (j = 0; j < i; j++) {
 				if (vp->rx_skbuff[j]) {
 					dev_kfree_skb(vp->rx_skbuff[j]);
@@ -1750,7 +1750,7 @@ err_free_irq:
 	free_irq(dev->irq, dev);
 err:
 	if (vortex_debug > 1)
-		printk(KERN_ERR "%s: vortex_open() fails: returning %d\n", dev->name, retval);
+		pr_err("%s: vortex_open() fails: returning %d\n", dev->name, retval);
 out:
 	return retval;
 }
@@ -1766,9 +1766,9 @@ vortex_timer(unsigned long data)
 	int media_status, old_window;
 
 	if (vortex_debug > 2) {
-		printk(KERN_DEBUG "%s: Media selection timer tick happened, %s.\n",
+		pr_debug("%s: Media selection timer tick happened, %s.\n",
 			   dev->name, media_tbl[dev->if_port].name);
-		printk(KERN_DEBUG "dev->watchdog_timeo=%d\n", dev->watchdog_timeo);
+		pr_debug("dev->watchdog_timeo=%d\n", dev->watchdog_timeo);
 	}
 
 	disable_irq_lockdep(dev->irq);
@@ -1781,12 +1781,12 @@ vortex_timer(unsigned long data)
 			netif_carrier_on(dev);
 			ok = 1;
 			if (vortex_debug > 1)
-				printk(KERN_DEBUG "%s: Media %s has link beat, %x.\n",
+				pr_debug("%s: Media %s has link beat, %x.\n",
 					   dev->name, media_tbl[dev->if_port].name, media_status);
 		} else {
 			netif_carrier_off(dev);
 			if (vortex_debug > 1) {
-				printk(KERN_DEBUG "%s: Media %s has no link beat, %x.\n",
+				pr_debug("%s: Media %s has no link beat, %x.\n",
 					   dev->name, media_tbl[dev->if_port].name, media_status);
 			}
 		}
@@ -1802,7 +1802,7 @@ vortex_timer(unsigned long data)
 		break;
 	  default:					/* Other media types handled by Tx timeouts. */
 		if (vortex_debug > 1)
-		  printk(KERN_DEBUG "%s: Media %s has no indication, %x.\n",
+		  pr_debug("%s: Media %s has no indication, %x.\n",
 				 dev->name, media_tbl[dev->if_port].name, media_status);
 		ok = 1;
 	}
@@ -1822,12 +1822,12 @@ vortex_timer(unsigned long data)
 		if (dev->if_port == XCVR_Default) { /* Go back to default. */
 		  dev->if_port = vp->default_media;
 		  if (vortex_debug > 1)
-			printk(KERN_DEBUG "%s: Media selection failing, using default "
+			pr_debug("%s: Media selection failing, using default "
 				   "%s port.\n",
 				   dev->name, media_tbl[dev->if_port].name);
 		} else {
 			if (vortex_debug > 1)
-				printk(KERN_DEBUG "%s: Media selection failed, now trying "
+				pr_debug("%s: Media selection failed, now trying "
 					   "%s port.\n",
 					   dev->name, media_tbl[dev->if_port].name);
 			next_tick = media_tbl[dev->if_port].wait;
@@ -1843,13 +1843,13 @@ vortex_timer(unsigned long data)
 		iowrite16(dev->if_port == XCVR_10base2 ? StartCoax : StopCoax,
 			 ioaddr + EL3_CMD);
 		if (vortex_debug > 1)
-			printk(KERN_DEBUG "wrote 0x%08x to Wn3_Config\n", config);
+			pr_debug("wrote 0x%08x to Wn3_Config\n", config);
 		/* AKPM: FIXME: Should reset Rx & Tx here.  P60 of 3c90xc.pdf */
 	}
 
 leave_media_alone:
 	if (vortex_debug > 2)
-	  printk(KERN_DEBUG "%s: Media selection timer finished, %s.\n",
+	  pr_debug("%s: Media selection timer finished, %s.\n",
 			 dev->name, media_tbl[dev->if_port].name);
 
 	EL3WINDOW(old_window);
@@ -1865,21 +1865,21 @@ static void vortex_tx_timeout(struct net_device *dev)
 	struct vortex_private *vp = netdev_priv(dev);
 	void __iomem *ioaddr = vp->ioaddr;
 
-	printk(KERN_ERR "%s: transmit timed out, tx_status %2.2x status %4.4x.\n",
+	pr_err("%s: transmit timed out, tx_status %2.2x status %4.4x.\n",
 		   dev->name, ioread8(ioaddr + TxStatus),
 		   ioread16(ioaddr + EL3_STATUS));
 	EL3WINDOW(4);
-	printk(KERN_ERR "  diagnostics: net %04x media %04x dma %08x fifo %04x\n",
+	pr_err("  diagnostics: net %04x media %04x dma %08x fifo %04x\n",
 			ioread16(ioaddr + Wn4_NetDiag),
 			ioread16(ioaddr + Wn4_Media),
 			ioread32(ioaddr + PktStatus),
 			ioread16(ioaddr + Wn4_FIFODiag));
 	/* Slight code bloat to be user friendly. */
 	if ((ioread8(ioaddr + TxStatus) & 0x88) == 0x88)
-		printk(KERN_ERR "%s: Transmitter encountered 16 collisions --"
+		pr_err("%s: Transmitter encountered 16 collisions --"
 			   " network cable problem?\n", dev->name);
 	if (ioread16(ioaddr + EL3_STATUS) & IntLatch) {
-		printk(KERN_ERR "%s: Interrupt posted but not delivered --"
+		pr_err("%s: Interrupt posted but not delivered --"
 			   " IRQ blocked by another device?\n", dev->name);
 		/* Bad idea here.. but we might as well handle a few events. */
 		{
@@ -1903,7 +1903,7 @@ static void vortex_tx_timeout(struct net_device *dev)
 
 	dev->stats.tx_errors++;
 	if (vp->full_bus_master_tx) {
-		printk(KERN_DEBUG "%s: Resetting the Tx ring pointer.\n", dev->name);
+		pr_debug("%s: Resetting the Tx ring pointer.\n", dev->name);
 		if (vp->cur_tx - vp->dirty_tx > 0  &&  ioread32(ioaddr + DownListPtr) == 0)
 			iowrite32(vp->tx_ring_dma + (vp->dirty_tx % TX_RING_SIZE) * sizeof(struct boom_tx_desc),
 				 ioaddr + DownListPtr);
@@ -1938,7 +1938,7 @@ vortex_error(struct net_device *dev, int status)
 	unsigned char tx_status = 0;
 
 	if (vortex_debug > 2) {
-		printk(KERN_ERR "%s: vortex_error(), status=0x%x\n", dev->name, status);
+		pr_err("%s: vortex_error(), status=0x%x\n", dev->name, status);
 	}
 
 	if (status & TxComplete) {			/* Really "TxError" for us. */
@@ -1946,10 +1946,10 @@ vortex_error(struct net_device *dev, int status)
 		/* Presumably a tx-timeout. We must merely re-enable. */
 		if (vortex_debug > 2
 			|| (tx_status != 0x88 && vortex_debug > 0)) {
-			printk(KERN_ERR "%s: Transmit error, Tx status register %2.2x.\n",
+			pr_err("%s: Transmit error, Tx status register %2.2x.\n",
 				   dev->name, tx_status);
 			if (tx_status == 0x82) {
-				printk(KERN_ERR "Probably a duplex mismatch.  See "
+				pr_err("Probably a duplex mismatch.  See "
 						"Documentation/networking/vortex.txt\n");
 			}
 			dump_tx_ring(dev);
@@ -1975,13 +1975,13 @@ vortex_error(struct net_device *dev, int status)
 	if (status & StatsFull) {			/* Empty statistics. */
 		static int DoneDidThat;
 		if (vortex_debug > 4)
-			printk(KERN_DEBUG "%s: Updating stats.\n", dev->name);
+			pr_debug("%s: Updating stats.\n", dev->name);
 		update_stats(ioaddr, dev);
 		/* HACK: Disable statistics as an interrupt source. */
 		/* This occurs when we have the wrong media type! */
 		if (DoneDidThat == 0  &&
 			ioread16(ioaddr + EL3_STATUS) & StatsFull) {
-			printk(KERN_WARNING "%s: Updating statistics failed, disabling "
+			pr_warning("%s: Updating statistics failed, disabling "
 				   "stats as an interrupt source.\n", dev->name);
 			EL3WINDOW(5);
 			iowrite16(SetIntrEnb | (ioread16(ioaddr + 10) & ~StatsFull), ioaddr + EL3_CMD);
@@ -1998,7 +1998,7 @@ vortex_error(struct net_device *dev, int status)
 		u16 fifo_diag;
 		EL3WINDOW(4);
 		fifo_diag = ioread16(ioaddr + Wn4_FIFODiag);
-		printk(KERN_ERR "%s: Host error, FIFO diagnostic register %4.4x.\n",
+		pr_err("%s: Host error, FIFO diagnostic register %4.4x.\n",
 			   dev->name, fifo_diag);
 		/* Adapter failure requires Tx/Rx reset and reinit. */
 		if (vp->full_bus_master_tx) {
@@ -2006,7 +2006,7 @@ vortex_error(struct net_device *dev, int status)
 			/* 0x80000000 PCI master abort. */
 			/* 0x40000000 PCI target abort. */
 			if (vortex_debug)
-				printk(KERN_ERR "%s: PCI bus error, bus status %8.8x\n", dev->name, bus_status);
+				pr_err("%s: PCI bus error, bus status %8.8x\n", dev->name, bus_status);
 
 			/* In this case, blow the card away */
 			/* Must not enter D3 or we can't legally issue the reset! */
@@ -2075,7 +2075,7 @@ vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		while (--i > 0	&&	(tx_status = ioread8(ioaddr + TxStatus)) > 0) {
 			if (tx_status & 0x3C) {		/* A Tx-disabling error occurred.  */
 				if (vortex_debug > 2)
-				  printk(KERN_DEBUG "%s: Tx error, status %2.2x.\n",
+				  pr_debug("%s: Tx error, status %2.2x.\n",
 						 dev->name, tx_status);
 				if (tx_status & 0x04) dev->stats.tx_fifo_errors++;
 				if (tx_status & 0x38) dev->stats.tx_aborted_errors++;
@@ -2101,14 +2101,14 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 
 	if (vortex_debug > 6) {
-		printk(KERN_DEBUG "boomerang_start_xmit()\n");
-		printk(KERN_DEBUG "%s: Trying to send a packet, Tx index %d.\n",
+		pr_debug("boomerang_start_xmit()\n");
+		pr_debug("%s: Trying to send a packet, Tx index %d.\n",
 			   dev->name, vp->cur_tx);
 	}
 
 	if (vp->cur_tx - vp->dirty_tx >= TX_RING_SIZE) {
 		if (vortex_debug > 0)
-			printk(KERN_WARNING "%s: BUG! Tx Ring full, refusing to send buffer.\n",
+			pr_warning("%s: BUG! Tx Ring full, refusing to send buffer.\n",
 				   dev->name);
 		netif_stop_queue(dev);
 		return 1;
@@ -2204,7 +2204,7 @@ vortex_interrupt(int irq, void *dev_id)
 	status = ioread16(ioaddr + EL3_STATUS);
 
 	if (vortex_debug > 6)
-		printk("vortex_interrupt(). status=0x%4x\n", status);
+		pr_debug("vortex_interrupt(). status=0x%4x\n", status);
 
 	if ((status & IntLatch) == 0)
 		goto handler_exit;		/* No interrupt: shared IRQs cause this */
@@ -2219,19 +2219,19 @@ vortex_interrupt(int irq, void *dev_id)
 		goto handler_exit;
 
 	if (vortex_debug > 4)
-		printk(KERN_DEBUG "%s: interrupt, status %4.4x, latency %d ticks.\n",
+		pr_debug("%s: interrupt, status %4.4x, latency %d ticks.\n",
 			   dev->name, status, ioread8(ioaddr + Timer));
 
 	do {
 		if (vortex_debug > 5)
-				printk(KERN_DEBUG "%s: In interrupt loop, status %4.4x.\n",
+				pr_debug("%s: In interrupt loop, status %4.4x.\n",
 					   dev->name, status);
 		if (status & RxComplete)
 			vortex_rx(dev);
 
 		if (status & TxAvailable) {
 			if (vortex_debug > 5)
-				printk(KERN_DEBUG "	TX room bit was handled.\n");
+				pr_debug("	TX room bit was handled.\n");
 			/* There's room in the FIFO for a full-sized packet. */
 			iowrite16(AckIntr | TxAvailable, ioaddr + EL3_CMD);
 			netif_wake_queue (dev);
@@ -2263,7 +2263,7 @@ vortex_interrupt(int irq, void *dev_id)
 		}
 
 		if (--work_done < 0) {
-			printk(KERN_WARNING "%s: Too much work in interrupt, status "
+			pr_warning("%s: Too much work in interrupt, status "
 				   "%4.4x.\n", dev->name, status);
 			/* Disable all pending interrupts. */
 			do {
@@ -2281,7 +2281,7 @@ vortex_interrupt(int irq, void *dev_id)
 	} while ((status = ioread16(ioaddr + EL3_STATUS)) & (IntLatch | RxComplete));
 
 	if (vortex_debug > 4)
-		printk(KERN_DEBUG "%s: exiting interrupt, status %4.4x.\n",
+		pr_debug("%s: exiting interrupt, status %4.4x.\n",
 			   dev->name, status);
 handler_exit:
 	spin_unlock(&vp->lock);
@@ -2313,14 +2313,14 @@ boomerang_interrupt(int irq, void *dev_id)
 	status = ioread16(ioaddr + EL3_STATUS);
 
 	if (vortex_debug > 6)
-		printk(KERN_DEBUG "boomerang_interrupt. status=0x%4x\n", status);
+		pr_debug("boomerang_interrupt. status=0x%4x\n", status);
 
 	if ((status & IntLatch) == 0)
 		goto handler_exit;		/* No interrupt: shared IRQs can cause this */
 
 	if (status == 0xffff) {		/* h/w no longer present (hotplug)? */
 		if (vortex_debug > 1)
-			printk(KERN_DEBUG "boomerang_interrupt(1): status = 0xffff\n");
+			pr_debug("boomerang_interrupt(1): status = 0xffff\n");
 		goto handler_exit;
 	}
 
@@ -2330,16 +2330,16 @@ boomerang_interrupt(int irq, void *dev_id)
 	}
 
 	if (vortex_debug > 4)
-		printk(KERN_DEBUG "%s: interrupt, status %4.4x, latency %d ticks.\n",
+		pr_debug("%s: interrupt, status %4.4x, latency %d ticks.\n",
 			   dev->name, status, ioread8(ioaddr + Timer));
 	do {
 		if (vortex_debug > 5)
-				printk(KERN_DEBUG "%s: In interrupt loop, status %4.4x.\n",
+				pr_debug("%s: In interrupt loop, status %4.4x.\n",
 					   dev->name, status);
 		if (status & UpComplete) {
 			iowrite16(AckIntr | UpComplete, ioaddr + EL3_CMD);
 			if (vortex_debug > 5)
-				printk(KERN_DEBUG "boomerang_interrupt->boomerang_rx\n");
+				pr_debug("boomerang_interrupt->boomerang_rx\n");
 			boomerang_rx(dev);
 		}
 
@@ -2374,7 +2374,7 @@ boomerang_interrupt(int irq, void *dev_id)
 					dev_kfree_skb_irq(skb);
 					vp->tx_skbuff[entry] = NULL;
 				} else {
-					printk(KERN_DEBUG "boomerang_interrupt: no skb!\n");
+					pr_debug("boomerang_interrupt: no skb!\n");
 				}
 				/* dev->stats.tx_packets++;  Counted below. */
 				dirty_tx++;
@@ -2382,7 +2382,7 @@ boomerang_interrupt(int irq, void *dev_id)
 			vp->dirty_tx = dirty_tx;
 			if (vp->cur_tx - dirty_tx <= TX_RING_SIZE - 1) {
 				if (vortex_debug > 6)
-					printk(KERN_DEBUG "boomerang_interrupt: wake queue\n");
+					pr_debug("boomerang_interrupt: wake queue\n");
 				netif_wake_queue (dev);
 			}
 		}
@@ -2392,7 +2392,7 @@ boomerang_interrupt(int irq, void *dev_id)
 			vortex_error(dev, status);
 
 		if (--work_done < 0) {
-			printk(KERN_WARNING "%s: Too much work in interrupt, status "
+			pr_warning("%s: Too much work in interrupt, status "
 				   "%4.4x.\n", dev->name, status);
 			/* Disable all pending interrupts. */
 			do {
@@ -2413,7 +2413,7 @@ boomerang_interrupt(int irq, void *dev_id)
 	} while ((status = ioread16(ioaddr + EL3_STATUS)) & IntLatch);
 
 	if (vortex_debug > 4)
-		printk(KERN_DEBUG "%s: exiting interrupt, status %4.4x.\n",
+		pr_debug("%s: exiting interrupt, status %4.4x.\n",
 			   dev->name, status);
 handler_exit:
 	spin_unlock(&vp->lock);
@@ -2428,13 +2428,13 @@ static int vortex_rx(struct net_device *dev)
 	short rx_status;
 
 	if (vortex_debug > 5)
-		printk(KERN_DEBUG "vortex_rx(): status %4.4x, rx_status %4.4x.\n",
+		pr_debug("vortex_rx(): status %4.4x, rx_status %4.4x.\n",
 			   ioread16(ioaddr+EL3_STATUS), ioread16(ioaddr+RxStatus));
 	while ((rx_status = ioread16(ioaddr + RxStatus)) > 0) {
 		if (rx_status & 0x4000) { /* Error, update stats. */
 			unsigned char rx_error = ioread8(ioaddr + RxErrors);
 			if (vortex_debug > 2)
-				printk(KERN_DEBUG " Rx error: status %2.2x.\n", rx_error);
+				pr_debug(" Rx error: status %2.2x.\n", rx_error);
 			dev->stats.rx_errors++;
 			if (rx_error & 0x01)  dev->stats.rx_over_errors++;
 			if (rx_error & 0x02)  dev->stats.rx_length_errors++;
@@ -2448,7 +2448,7 @@ static int vortex_rx(struct net_device *dev)
 
 			skb = dev_alloc_skb(pkt_len + 5);
 			if (vortex_debug > 4)
-				printk(KERN_DEBUG "Receiving packet size %d status %4.4x.\n",
+				pr_debug("Receiving packet size %d status %4.4x.\n",
 					   pkt_len, rx_status);
 			if (skb != NULL) {
 				skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
@@ -2478,7 +2478,7 @@ static int vortex_rx(struct net_device *dev)
 						break;
 				continue;
 			} else if (vortex_debug > 0)
-				printk(KERN_NOTICE "%s: No memory to allocate a sk_buff of "
+				pr_notice("%s: No memory to allocate a sk_buff of "
 					   "size %d.\n", dev->name, pkt_len);
 			dev->stats.rx_dropped++;
 		}
@@ -2498,7 +2498,7 @@ boomerang_rx(struct net_device *dev)
 	int rx_work_limit = vp->dirty_rx + RX_RING_SIZE - vp->cur_rx;
 
 	if (vortex_debug > 5)
-		printk(KERN_DEBUG "boomerang_rx(): status %4.4x\n", ioread16(ioaddr+EL3_STATUS));
+		pr_debug("boomerang_rx(): status %4.4x\n", ioread16(ioaddr+EL3_STATUS));
 
 	while ((rx_status = le32_to_cpu(vp->rx_ring[entry].status)) & RxDComplete){
 		if (--rx_work_limit < 0)
@@ -2506,7 +2506,7 @@ boomerang_rx(struct net_device *dev)
 		if (rx_status & RxDError) { /* Error, update stats. */
 			unsigned char rx_error = rx_status >> 16;
 			if (vortex_debug > 2)
-				printk(KERN_DEBUG " Rx error: status %2.2x.\n", rx_error);
+				pr_debug(" Rx error: status %2.2x.\n", rx_error);
 			dev->stats.rx_errors++;
 			if (rx_error & 0x01)  dev->stats.rx_over_errors++;
 			if (rx_error & 0x02)  dev->stats.rx_length_errors++;
@@ -2520,7 +2520,7 @@ boomerang_rx(struct net_device *dev)
 			dma_addr_t dma = le32_to_cpu(vp->rx_ring[entry].addr);
 
 			if (vortex_debug > 4)
-				printk(KERN_DEBUG "Receiving packet size %d status %4.4x.\n",
+				pr_debug("Receiving packet size %d status %4.4x.\n",
 					   pkt_len, rx_status);
 
 			/* Check if the packet is long enough to just accept without
@@ -2566,7 +2566,7 @@ boomerang_rx(struct net_device *dev)
 			if (skb == NULL) {
 				static unsigned long last_jif;
 				if (time_after(jiffies, last_jif + 10 * HZ)) {
-					printk(KERN_WARNING "%s: memory shortage\n", dev->name);
+					pr_warning("%s: memory shortage\n", dev->name);
 					last_jif = jiffies;
 				}
 				if ((vp->cur_rx - vp->dirty_rx) == RX_RING_SIZE)
@@ -2598,7 +2598,7 @@ rx_oom_timer(unsigned long arg)
 	if ((vp->cur_rx - vp->dirty_rx) == RX_RING_SIZE)	/* This test is redundant, but makes me feel good */
 		boomerang_rx(dev);
 	if (vortex_debug > 1) {
-		printk(KERN_DEBUG "%s: rx_oom_timer %s\n", dev->name,
+		pr_debug("%s: rx_oom_timer %s\n", dev->name,
 			((vp->cur_rx - vp->dirty_rx) != RX_RING_SIZE) ? "succeeded" : "retrying");
 	}
 	spin_unlock_irq(&vp->lock);
@@ -2655,9 +2655,9 @@ vortex_close(struct net_device *dev)
 		vortex_down(dev, 1);
 
 	if (vortex_debug > 1) {
-		printk(KERN_DEBUG"%s: vortex_close() status %4.4x, Tx status %2.2x.\n",
+		pr_debug("%s: vortex_close() status %4.4x, Tx status %2.2x.\n",
 			   dev->name, ioread16(ioaddr + EL3_STATUS), ioread8(ioaddr + TxStatus));
-		printk(KERN_DEBUG "%s: vortex close stats: rx_nocopy %d rx_copy %d"
+		pr_debug("%s: vortex close stats: rx_nocopy %d rx_copy %d"
 			   " tx_queued %d Rx pre-checksummed %d.\n",
 			   dev->name, vp->rx_nocopy, vp->rx_copy, vp->queued_packet, vp->rx_csumhits);
 	}
@@ -2666,7 +2666,7 @@ vortex_close(struct net_device *dev)
 	if (vp->rx_csumhits &&
 	    (vp->drv_flags & HAS_HWCKSM) == 0 &&
 	    (vp->card_idx >= MAX_UNITS || hw_checksums[vp->card_idx] == -1)) {
-			printk(KERN_WARNING "%s supports hardware checksums, and we're "
+			pr_warning("%s supports hardware checksums, and we're "
 						"not using them!\n", dev->name);
 	}
 #endif
@@ -2717,16 +2717,16 @@ dump_tx_ring(struct net_device *dev)
 			int i;
 			int stalled = ioread32(ioaddr + PktStatus) & 0x04;	/* Possible racy. But it's only debug stuff */
 
-			printk(KERN_ERR "  Flags; bus-master %d, dirty %d(%d) current %d(%d)\n",
+			pr_err("  Flags; bus-master %d, dirty %d(%d) current %d(%d)\n",
 					vp->full_bus_master_tx,
 					vp->dirty_tx, vp->dirty_tx % TX_RING_SIZE,
 					vp->cur_tx, vp->cur_tx % TX_RING_SIZE);
-			printk(KERN_ERR "  Transmit list %8.8x vs. %p.\n",
+			pr_err("  Transmit list %8.8x vs. %p.\n",
 				   ioread32(ioaddr + DownListPtr),
 				   &vp->tx_ring[vp->dirty_tx % TX_RING_SIZE]);
 			issue_and_wait(dev, DownStall);
 			for (i = 0; i < TX_RING_SIZE; i++) {
-				printk(KERN_ERR "  %d: @%p  length %8.8x status %8.8x\n", i,
+				pr_err("  %d: @%p  length %8.8x status %8.8x\n", i,
 					   &vp->tx_ring[i],
 #if DO_ZEROCOPY
 					   le32_to_cpu(vp->tx_ring[i].frag[0].length),
@@ -2970,7 +2970,7 @@ static void set_rx_mode(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC) {
 		if (vortex_debug > 3)
-			printk(KERN_NOTICE "%s: Setting promiscuous mode.\n", dev->name);
+			pr_notice("%s: Setting promiscuous mode.\n", dev->name);
 		new_mode = SetRxFilter|RxStation|RxMulticast|RxBroadcast|RxProm;
 	} else	if ((dev->mc_list)  ||  (dev->flags & IFF_ALLMULTI)) {
 		new_mode = SetRxFilter|RxStation|RxMulticast|RxBroadcast;
@@ -3145,7 +3145,7 @@ static void acpi_set_WOL(struct net_device *dev)
 		iowrite16(RxEnable, ioaddr + EL3_CMD);
 
 		if (pci_enable_wake(VORTEX_PCI(vp), PCI_D3hot, 1)) {
-			printk(KERN_INFO "%s: WOL not supported.\n",
+			pr_info("%s: WOL not supported.\n",
 					pci_name(VORTEX_PCI(vp)));
 
 			vp->enable_wol = 0;
@@ -3164,7 +3164,7 @@ static void __devexit vortex_remove_one(struct pci_dev *pdev)
 	struct vortex_private *vp;
 
 	if (!dev) {
-		printk("vortex_remove_one called for Compaq device!\n");
+		pr_err("vortex_remove_one called for Compaq device!\n");
 		BUG();
 	}
 
-- 
1.6.3.1

