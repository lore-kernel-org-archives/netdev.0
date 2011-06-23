From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/8] lib8390: Use pr_<level> and netdev_<level>
Date: Wed, 22 Jun 2011 23:38:55 -0700
Message-ID: <dd7c55885549035ba2426e136e63dc9eea02c646.1308810463.git.joe@perches.com>
References: <cover.1308810463.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1308810463.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the current logging styles.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/lib8390.c |   86 ++++++++++++++++++++++++------------------------
 1 files changed, 43 insertions(+), 43 deletions(-)

diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 70eb207..59d5414 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -267,9 +267,10 @@ static void __ei_tx_timeout(struct net_device *dev)
 	isr = ei_inb(e8390_base+EN0_ISR);
 	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 
-	printk(KERN_DEBUG "%s: Tx timed out, %s TSR=%#2x, ISR=%#2x, t=%d.\n",
-		dev->name, (txsr & ENTSR_ABT) ? "excess collisions." :
-		(isr) ? "lost interrupt?" : "cable problem?", txsr, isr, tickssofar);
+	netdev_dbg(dev, "Tx timed out, %s TSR=%#2x, ISR=%#2x, t=%d\n",
+		   (txsr & ENTSR_ABT) ? "excess collisions." :
+		   (isr) ? "lost interrupt?" : "cable problem?",
+		   txsr, isr, tickssofar);
 
 	if (!isr && !dev->stats.tx_packets)
 	{
@@ -349,22 +350,22 @@ static netdev_tx_t __ei_start_xmit(struct sk_buff *skb,
 		output_page = ei_local->tx_start_page;
 		ei_local->tx1 = send_length;
 		if (ei_debug  &&  ei_local->tx2 > 0)
-			printk(KERN_DEBUG "%s: idle transmitter tx2=%d, lasttx=%d, txing=%d.\n",
-				dev->name, ei_local->tx2, ei_local->lasttx, ei_local->txing);
+			netdev_dbg(dev, "idle transmitter tx2=%d, lasttx=%d, txing=%d\n",
+				   ei_local->tx2, ei_local->lasttx, ei_local->txing);
 	}
 	else if (ei_local->tx2 == 0)
 	{
 		output_page = ei_local->tx_start_page + TX_PAGES/2;
 		ei_local->tx2 = send_length;
 		if (ei_debug  &&  ei_local->tx1 > 0)
-			printk(KERN_DEBUG "%s: idle transmitter, tx1=%d, lasttx=%d, txing=%d.\n",
-				dev->name, ei_local->tx1, ei_local->lasttx, ei_local->txing);
+			netdev_dbg(dev, "idle transmitter, tx1=%d, lasttx=%d, txing=%d\n",
+				   ei_local->tx1, ei_local->lasttx, ei_local->txing);
 	}
 	else
 	{	/* We should never get here. */
 		if (ei_debug)
-			printk(KERN_DEBUG "%s: No Tx buffers free! tx1=%d tx2=%d last=%d\n",
-				dev->name, ei_local->tx1, ei_local->tx2, ei_local->lasttx);
+			netdev_dbg(dev, "No Tx buffers free! tx1=%d tx2=%d last=%d\n",
+				   ei_local->tx1, ei_local->tx2, ei_local->lasttx);
 		ei_local->irqlock = 0;
 		netif_stop_queue(dev);
 		ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
@@ -448,9 +449,8 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 		 * This might just be an interrupt for a PCI device sharing
 		 * this line
 		 */
-		printk("%s: Interrupted while interrupts are masked!"
-			   " isr=%#2x imr=%#2x.\n",
-			   dev->name, ei_inb_p(e8390_base + EN0_ISR),
+		netdev_err(dev, "Interrupted while interrupts are masked! isr=%#2x imr=%#2x\n",
+			   ei_inb_p(e8390_base + EN0_ISR),
 			   ei_inb_p(e8390_base + EN0_IMR));
 		spin_unlock(&ei_local->page_lock);
 		return IRQ_NONE;
@@ -459,7 +459,7 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 	/* Change to page 0 and read the intr status reg. */
 	ei_outb_p(E8390_NODMA+E8390_PAGE0, e8390_base + E8390_CMD);
 	if (ei_debug > 3)
-		printk(KERN_DEBUG "%s: interrupt(isr=%#2.2x).\n", dev->name,
+		netdev_dbg(dev, "interrupt(isr=%#2.2x)\n",
 			   ei_inb_p(e8390_base + EN0_ISR));
 
 	/* !!Assumption!! -- we stay in page 0.	 Don't break this. */
@@ -467,7 +467,7 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 	       ++nr_serviced < MAX_SERVICE)
 	{
 		if (!netif_running(dev)) {
-			printk(KERN_WARNING "%s: interrupt from stopped card\n", dev->name);
+			netdev_warn(dev, "interrupt from stopped card\n");
 			/* rmk - acknowledge the interrupts */
 			ei_outb_p(interrupts, e8390_base + EN0_ISR);
 			interrupts = 0;
@@ -510,11 +510,11 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 		{
 			/* 0xFF is valid for a card removal */
 			if(interrupts!=0xFF)
-				printk(KERN_WARNING "%s: Too much work at interrupt, status %#2.2x\n",
-				   dev->name, interrupts);
+				netdev_warn(dev, "Too much work at interrupt, status %#2.2x\n",
+					    interrupts);
 			ei_outb_p(ENISR_ALL, e8390_base + EN0_ISR); /* Ack. most intrs. */
 		} else {
-			printk(KERN_WARNING "%s: unknown interrupt %#2x\n", dev->name, interrupts);
+			netdev_warn(dev, "unknown interrupt %#2x\n", interrupts);
 			ei_outb_p(0xff, e8390_base + EN0_ISR); /* Ack. all intrs. */
 		}
 	}
@@ -554,18 +554,18 @@ static void ei_tx_err(struct net_device *dev)
 	unsigned char tx_was_aborted = txsr & (ENTSR_ABT+ENTSR_FU);
 
 #ifdef VERBOSE_ERROR_DUMP
-	printk(KERN_DEBUG "%s: transmitter error (%#2x): ", dev->name, txsr);
+	netdev_dbg(dev, "transmitter error (%#2x):", txsr);
 	if (txsr & ENTSR_ABT)
-		printk("excess-collisions ");
+		pr_cont(" excess-collisions ");
 	if (txsr & ENTSR_ND)
-		printk("non-deferral ");
+		pr_cont(" non-deferral ");
 	if (txsr & ENTSR_CRS)
-		printk("lost-carrier ");
+		pr_cont(" lost-carrier ");
 	if (txsr & ENTSR_FU)
-		printk("FIFO-underrun ");
+		pr_cont(" FIFO-underrun ");
 	if (txsr & ENTSR_CDH)
-		printk("lost-heartbeat ");
-	printk("\n");
+		pr_cont(" lost-heartbeat ");
+	pr_cont("\n");
 #endif
 
 	ei_outb_p(ENISR_TX_ERR, e8390_base + EN0_ISR); /* Ack intr. */
@@ -606,8 +606,8 @@ static void ei_tx_intr(struct net_device *dev)
 	if (ei_local->tx1 < 0)
 	{
 		if (ei_local->lasttx != 1 && ei_local->lasttx != -1)
-			printk(KERN_ERR "%s: bogus last_tx_buffer %d, tx1=%d.\n",
-				ei_local->name, ei_local->lasttx, ei_local->tx1);
+			pr_err("%s: bogus last_tx_buffer %d, tx1=%d\n",
+			       ei_local->name, ei_local->lasttx, ei_local->tx1);
 		ei_local->tx1 = 0;
 		if (ei_local->tx2 > 0)
 		{
@@ -622,8 +622,8 @@ static void ei_tx_intr(struct net_device *dev)
 	else if (ei_local->tx2 < 0)
 	{
 		if (ei_local->lasttx != 2  &&  ei_local->lasttx != -2)
-			printk("%s: bogus last_tx_buffer %d, tx2=%d.\n",
-				ei_local->name, ei_local->lasttx, ei_local->tx2);
+			pr_err("%s: bogus last_tx_buffer %d, tx2=%d\n",
+			       ei_local->name, ei_local->lasttx, ei_local->tx2);
 		ei_local->tx2 = 0;
 		if (ei_local->tx1 > 0)
 		{
@@ -703,8 +703,8 @@ static void ei_receive(struct net_device *dev)
 		   is that some clones crash in roughly the same way.
 		 */
 		if (ei_debug > 0  &&  this_frame != ei_local->current_page && (this_frame!=0x0 || rxing_page!=0xFF))
-			printk(KERN_ERR "%s: mismatched read page pointers %2x vs %2x.\n",
-				   dev->name, this_frame, ei_local->current_page);
+			netdev_err(dev, "mismatched read page pointers %2x vs %2x\n",
+				   this_frame, ei_local->current_page);
 
 		if (this_frame == rxing_page)	/* Read all the frames? */
 			break;				/* Done for now */
@@ -733,8 +733,8 @@ static void ei_receive(struct net_device *dev)
 		if (pkt_len < 60  ||  pkt_len > 1518)
 		{
 			if (ei_debug)
-				printk(KERN_DEBUG "%s: bogus packet size: %d, status=%#2x nxpg=%#2x.\n",
-					   dev->name, rx_frame.count, rx_frame.status,
+				netdev_dbg(dev, "bogus packet size: %d, status=%#2x nxpg=%#2x\n",
+					   rx_frame.count, rx_frame.status,
 					   rx_frame.next);
 			dev->stats.rx_errors++;
 			dev->stats.rx_length_errors++;
@@ -747,8 +747,8 @@ static void ei_receive(struct net_device *dev)
 			if (skb == NULL)
 			{
 				if (ei_debug > 1)
-					printk(KERN_DEBUG "%s: Couldn't allocate a sk_buff of size %d.\n",
-						   dev->name, pkt_len);
+					netdev_dbg(dev, "Couldn't allocate a sk_buff of size %d\n",
+						   pkt_len);
 				dev->stats.rx_dropped++;
 				break;
 			}
@@ -769,8 +769,8 @@ static void ei_receive(struct net_device *dev)
 		else
 		{
 			if (ei_debug)
-				printk(KERN_DEBUG "%s: bogus packet: status=%#2x nxpg=%#2x size=%d\n",
-					   dev->name, rx_frame.status, rx_frame.next,
+				netdev_dbg(dev, "bogus packet: status=%#2x nxpg=%#2x size=%d\n",
+					   rx_frame.status, rx_frame.next,
 					   rx_frame.count);
 			dev->stats.rx_errors++;
 			/* NB: The NIC counts CRC, frame and missed errors. */
@@ -781,8 +781,8 @@ static void ei_receive(struct net_device *dev)
 
 		/* This _should_ never happen: it's here for avoiding bad clones. */
 		if (next_frame >= ei_local->stop_page) {
-			printk("%s: next frame inconsistency, %#2x\n", dev->name,
-				   next_frame);
+			netdev_notice(dev, "next frame inconsistency, %#2x\n",
+				      next_frame);
 			next_frame = ei_local->rx_start_page;
 		}
 		ei_local->current_page = next_frame;
@@ -822,7 +822,7 @@ static void ei_rx_overrun(struct net_device *dev)
 	ei_outb_p(E8390_NODMA+E8390_PAGE0+E8390_STOP, e8390_base+E8390_CMD);
 
 	if (ei_debug > 1)
-		printk(KERN_DEBUG "%s: Receiver overrun.\n", dev->name);
+		netdev_dbg(dev, "Receiver overrun\n");
 	dev->stats.rx_over_errors++;
 
 	/*
@@ -960,7 +960,8 @@ static void do_set_multicast_list(struct net_device *dev)
 		ei_outb_p(ei_local->mcfilter[i], e8390_base + EN1_MULT_SHIFT(i));
 #ifndef BUG_83C690
 		if(ei_inb_p(e8390_base + EN1_MULT_SHIFT(i))!=ei_local->mcfilter[i])
-			printk(KERN_ERR "Multicast filter read/write mismap %d\n",i);
+			netdev_err(dev, "Multicast filter read/write mismap %d\n",
+				   i);
 #endif
 	}
 	ei_outb_p(E8390_NODMA + E8390_PAGE0, e8390_base + E8390_CMD);
@@ -1072,7 +1073,7 @@ static void __NS8390_init(struct net_device *dev, int startp)
 	{
 		ei_outb_p(dev->dev_addr[i], e8390_base + EN1_PHYS_SHIFT(i));
 		if (ei_debug > 1 && ei_inb_p(e8390_base + EN1_PHYS_SHIFT(i))!=dev->dev_addr[i])
-			printk(KERN_ERR "Hw. address read/write mismap %d\n",i);
+			netdev_err(dev, "Hw. address read/write mismap %d\n", i);
 	}
 
 	ei_outb_p(ei_local->rx_start_page, e8390_base + EN1_CURPAG);
@@ -1106,8 +1107,7 @@ static void NS8390_trigger_send(struct net_device *dev, unsigned int length,
 
 	if (ei_inb_p(e8390_base + E8390_CMD) & E8390_TRANS)
 	{
-		printk(KERN_WARNING "%s: trigger_send() called with the transmitter busy.\n",
-			dev->name);
+		netdev_warn(dev, "trigger_send() called with the transmitter busy\n");
 		return;
 	}
 	ei_outb_p(length & 0xff, e8390_base + EN0_TCNTLO);
-- 
1.7.6.rc3
