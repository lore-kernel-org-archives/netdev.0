From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/8] lib8390: Normalize source code spacing
Date: Wed, 22 Jun 2011 23:38:57 -0700
Message-ID: <5170446ed5906531ad21548be5d0ee097bce59a6.1308810463.git.joe@perches.com>
References: <cover.1308810463.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1308810463.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make more conformant to normal kernel style.

Long line lengths > 80 columns ignored.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/lib8390.c |   81 ++++++++++++++++++++++++++----------------------
 1 files changed, 44 insertions(+), 37 deletions(-)

diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 9ace5a7..b0ee6f6 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -36,7 +36,7 @@
   Paul Gortmaker	: tweak ANK's above multicast changes a bit.
   Paul Gortmaker	: update packet statistics for v2.1.x
   Alan Cox		: support arbitrary stupid port mappings on the
-  			  68K Macintosh. Support >16bit I/O spaces
+			  68K Macintosh. Support >16bit I/O spaces
   Paul Gortmaker	: add kmod support for auto-loading of the 8390
 			  module by all drivers that require it.
   Alan Cox		: Spinlocking work, added 'BUG_83C690'
@@ -206,19 +206,19 @@ static int __ei_open(struct net_device *dev)
 	struct ei_device *ei_local = netdev_priv(dev);
 
 	if (dev->watchdog_timeo <= 0)
-		 dev->watchdog_timeo = TX_TIMEOUT;
+		dev->watchdog_timeo = TX_TIMEOUT;
 
 	/*
 	 *	Grab the page lock so we own the register set, then call
 	 *	the init function.
 	 */
 
-      	spin_lock_irqsave(&ei_local->page_lock, flags);
+	spin_lock_irqsave(&ei_local->page_lock, flags);
 	__NS8390_init(dev, 1);
 	/* Set the flag before we drop the lock, That way the IRQ arrives
 	   after its set and we get no silly warnings */
 	netif_start_queue(dev);
-      	spin_unlock_irqrestore(&ei_local->page_lock, flags);
+	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 	ei_local->irqlock = 0;
 	return 0;
 }
@@ -238,9 +238,9 @@ static int __ei_close(struct net_device *dev)
 	 *	Hold the page lock during close
 	 */
 
-      	spin_lock_irqsave(&ei_local->page_lock, flags);
+	spin_lock_irqsave(&ei_local->page_lock, flags);
 	__NS8390_init(dev, 0);
-      	spin_unlock_irqrestore(&ei_local->page_lock, flags);
+	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 	netif_stop_queue(dev);
 	return 0;
 }
@@ -377,7 +377,7 @@ static netdev_tx_t __ei_start_xmit(struct sk_buff *skb,
 
 	ei_block_output(dev, send_length, data, output_page);
 
-	if (! ei_local->txing) {
+	if (!ei_local->txing) {
 		ei_local->txing = 1;
 		NS8390_trigger_send(dev, send_length, output_page);
 		if (output_page == ei_local->tx_start_page) {
@@ -402,7 +402,7 @@ static netdev_tx_t __ei_start_xmit(struct sk_buff *skb,
 	spin_unlock(&ei_local->page_lock);
 	enable_irq_lockdep_irqrestore(dev->irq, &flags);
 	skb_tx_timestamp(skb);
-	dev_kfree_skb (skb);
+	dev_kfree_skb(skb);
 	dev->stats.tx_bytes += send_length;
 
 	return NETDEV_TX_OK;
@@ -476,7 +476,7 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 		if (interrupts & ENISR_COUNTERS) {
 			dev->stats.rx_frame_errors += ei_inb_p(e8390_base + EN0_COUNTER0);
 			dev->stats.rx_crc_errors   += ei_inb_p(e8390_base + EN0_COUNTER1);
-			dev->stats.rx_missed_errors+= ei_inb_p(e8390_base + EN0_COUNTER2);
+			dev->stats.rx_missed_errors += ei_inb_p(e8390_base + EN0_COUNTER2);
 			ei_outb_p(ENISR_COUNTERS, e8390_base + EN0_ISR); /* Ack intr. */
 		}
 
@@ -491,7 +491,7 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 		ei_outb_p(E8390_NODMA+E8390_PAGE0+E8390_START, e8390_base + E8390_CMD);
 		if (nr_serviced >= MAX_SERVICE) {
 			/* 0xFF is valid for a card removal */
-			if(interrupts!=0xFF)
+			if (interrupts != 0xFF)
 				netdev_warn(dev, "Too much work at interrupt, status %#2.2x\n",
 					    interrupts);
 			ei_outb_p(ENISR_ALL, e8390_base + EN0_ISR); /* Ack. most intrs. */
@@ -556,9 +556,12 @@ static void ei_tx_err(struct net_device *dev)
 		ei_tx_intr(dev);
 	else {
 		dev->stats.tx_errors++;
-		if (txsr & ENTSR_CRS) dev->stats.tx_carrier_errors++;
-		if (txsr & ENTSR_CDH) dev->stats.tx_heartbeat_errors++;
-		if (txsr & ENTSR_OWC) dev->stats.tx_window_errors++;
+		if (txsr & ENTSR_CRS)
+			dev->stats.tx_carrier_errors++;
+		if (txsr & ENTSR_CDH)
+			dev->stats.tx_heartbeat_errors++;
+		if (txsr & ENTSR_OWC)
+			dev->stats.tx_window_errors++;
 	}
 }
 
@@ -610,9 +613,10 @@ static void ei_tx_intr(struct net_device *dev)
 			ei_local->lasttx = 1;
 		} else
 			ei_local->lasttx = 10, ei_local->txing = 0;
-	}
-//	else printk(KERN_WARNING "%s: unexpected TX-done interrupt, lasttx=%d.\n",
-//			dev->name, ei_local->lasttx);
+	} /* else
+		netdev_warn(dev, "unexpected TX-done interrupt, lasttx=%d\n",
+			    ei_local->lasttx);
+*/
 
 	/* Minimize Tx latency: update the statistics after we restart TXing. */
 	if (status & ENTSR_COL)
@@ -674,7 +678,9 @@ static void ei_receive(struct net_device *dev)
 		   Keep quiet if it looks like a card removal. One problem here
 		   is that some clones crash in roughly the same way.
 		 */
-		if (ei_debug > 0  &&  this_frame != ei_local->current_page && (this_frame!=0x0 || rxing_page!=0xFF))
+		if (ei_debug > 0 &&
+		    this_frame != ei_local->current_page &&
+		    (this_frame != 0x0 || rxing_page != 0xFF))
 			netdev_err(dev, "mismatched read page pointers %2x vs %2x\n",
 				   this_frame, ei_local->current_page);
 
@@ -720,10 +726,10 @@ static void ei_receive(struct net_device *dev)
 				dev->stats.rx_dropped++;
 				break;
 			} else {
-				skb_reserve(skb,2);	/* IP headers on 16 byte boundaries */
+				skb_reserve(skb, 2);	/* IP headers on 16 byte boundaries */
 				skb_put(skb, pkt_len);	/* Make room */
 				ei_block_input(dev, pkt_len, skb, current_offset + sizeof(rx_frame));
-				skb->protocol=eth_type_trans(skb,dev);
+				skb->protocol = eth_type_trans(skb, dev);
 				if (!skb_defer_rx_timestamp(skb))
 					netif_rx(skb);
 				dev->stats.rx_packets++;
@@ -833,7 +839,7 @@ static void ei_rx_overrun(struct net_device *dev)
 	 */
 	ei_outb_p(E8390_TXCONFIG, e8390_base + EN0_TXCR);
 	if (must_resend)
-    		ei_outb_p(E8390_NODMA + E8390_PAGE0 + E8390_START + E8390_TRANS, e8390_base + E8390_CMD);
+		ei_outb_p(E8390_NODMA + E8390_PAGE0 + E8390_START + E8390_TRANS, e8390_base + E8390_CMD);
 }
 
 /*
@@ -850,11 +856,11 @@ static struct net_device_stats *__ei_get_stats(struct net_device *dev)
 	if (!netif_running(dev))
 		return &dev->stats;
 
-	spin_lock_irqsave(&ei_local->page_lock,flags);
+	spin_lock_irqsave(&ei_local->page_lock, flags);
 	/* Read the counter registers, assuming we are in page 0. */
-	dev->stats.rx_frame_errors += ei_inb_p(ioaddr + EN0_COUNTER0);
-	dev->stats.rx_crc_errors   += ei_inb_p(ioaddr + EN0_COUNTER1);
-	dev->stats.rx_missed_errors+= ei_inb_p(ioaddr + EN0_COUNTER2);
+	dev->stats.rx_frame_errors  += ei_inb_p(ioaddr + EN0_COUNTER0);
+	dev->stats.rx_crc_errors    += ei_inb_p(ioaddr + EN0_COUNTER1);
+	dev->stats.rx_missed_errors += ei_inb_p(ioaddr + EN0_COUNTER2);
 	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 
 	return &dev->stats;
@@ -916,23 +922,23 @@ static void do_set_multicast_list(struct net_device *dev)
 	if (netif_running(dev))
 		ei_outb_p(E8390_RXCONFIG, e8390_base + EN0_RXCR);
 	ei_outb_p(E8390_NODMA + E8390_PAGE1, e8390_base + E8390_CMD);
-	for(i = 0; i < 8; i++) {
+	for (i = 0; i < 8; i++) {
 		ei_outb_p(ei_local->mcfilter[i], e8390_base + EN1_MULT_SHIFT(i));
 #ifndef BUG_83C690
-		if(ei_inb_p(e8390_base + EN1_MULT_SHIFT(i))!=ei_local->mcfilter[i])
+		if (ei_inb_p(e8390_base + EN1_MULT_SHIFT(i)) != ei_local->mcfilter[i])
 			netdev_err(dev, "Multicast filter read/write mismap %d\n",
 				   i);
 #endif
 	}
 	ei_outb_p(E8390_NODMA + E8390_PAGE0, e8390_base + E8390_CMD);
 
-  	if(dev->flags&IFF_PROMISC)
-  		ei_outb_p(E8390_RXCONFIG | 0x18, e8390_base + EN0_RXCR);
+	if (dev->flags&IFF_PROMISC)
+		ei_outb_p(E8390_RXCONFIG | 0x18, e8390_base + EN0_RXCR);
 	else if (dev->flags & IFF_ALLMULTI || !netdev_mc_empty(dev))
-  		ei_outb_p(E8390_RXCONFIG | 0x08, e8390_base + EN0_RXCR);
-  	else
-  		ei_outb_p(E8390_RXCONFIG, e8390_base + EN0_RXCR);
- }
+		ei_outb_p(E8390_RXCONFIG | 0x08, e8390_base + EN0_RXCR);
+	else
+		ei_outb_p(E8390_RXCONFIG, e8390_base + EN0_RXCR);
+}
 
 /*
  *	Called without lock held. This is invoked from user context and may
@@ -1004,8 +1010,8 @@ static void __NS8390_init(struct net_device *dev, int startp)
 	    ? (0x48 | ENDCFG_WTS | (ei_local->bigendian ? ENDCFG_BOS : 0))
 	    : 0x48;
 
-	if(sizeof(struct e8390_pkt_hdr)!=4)
-    		panic("8390.c: header struct mispacked\n");
+	if (sizeof(struct e8390_pkt_hdr) != 4)
+		panic("8390.c: header struct mispacked\n");
 	/* Follow National Semi's recommendations for initing the DP83902. */
 	ei_outb_p(E8390_NODMA+E8390_PAGE0+E8390_STOP, e8390_base+E8390_CMD); /* 0x21 */
 	ei_outb_p(endcfg, e8390_base + EN0_DCFG);	/* 0x48 or 0x49 */
@@ -1029,9 +1035,10 @@ static void __NS8390_init(struct net_device *dev, int startp)
 	/* Copy the station address into the DS8390 registers. */
 
 	ei_outb_p(E8390_NODMA + E8390_PAGE1 + E8390_STOP, e8390_base+E8390_CMD); /* 0x61 */
-	for(i = 0; i < 6; i++) {
+	for (i = 0; i < 6; i++) {
 		ei_outb_p(dev->dev_addr[i], e8390_base + EN1_PHYS_SHIFT(i));
-		if (ei_debug > 1 && ei_inb_p(e8390_base + EN1_PHYS_SHIFT(i))!=dev->dev_addr[i])
+		if (ei_debug > 1 &&
+		    ei_inb_p(e8390_base + EN1_PHYS_SHIFT(i)) != dev->dev_addr[i])
 			netdev_err(dev, "Hw. address read/write mismap %d\n", i);
 	}
 
@@ -1059,7 +1066,7 @@ static void NS8390_trigger_send(struct net_device *dev, unsigned int length,
 								int start_page)
 {
 	unsigned long e8390_base = dev->base_addr;
- 	struct ei_device *ei_local __attribute((unused)) = netdev_priv(dev);
+	struct ei_device *ei_local __attribute((unused)) = netdev_priv(dev);
 
 	ei_outb_p(E8390_NODMA+E8390_PAGE0, e8390_base+E8390_CMD);
 
-- 
1.7.6.rc3
