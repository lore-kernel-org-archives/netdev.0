From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/8] lib8390: Indent braces appropriately
Date: Wed, 22 Jun 2011 23:38:56 -0700
Message-ID: <642fa3da4ff8ee69bbad2e1ef014aaf9286f22fb.1308810463.git.joe@perches.com>
References: <cover.1308810463.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3151 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755542Ab1FWGjD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2011 02:39:03 -0400
In-Reply-To: <cover.1308810463.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the braces around to conform to kernel standard style.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/lib8390.c |  119 ++++++++++++++++---------------------------------
 1 files changed, 38 insertions(+), 81 deletions(-)

diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 59d5414..9ace5a7 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -272,8 +272,7 @@ static void __ei_tx_timeout(struct net_device *dev)
 		   (isr) ? "lost interrupt?" : "cable problem?",
 		   txsr, isr, tickssofar);
 
-	if (!isr && !dev->stats.tx_packets)
-	{
+	if (!isr && !dev->stats.tx_packets) {
 		/* The 8390 probably hasn't gotten on the cable yet. */
 		ei_local->interface_num ^= 1;   /* Try a different xcvr.  */
 	}
@@ -345,24 +344,19 @@ static netdev_tx_t __ei_start_xmit(struct sk_buff *skb,
 	 * card, leaving a substantial gap between each transmitted packet.
 	 */
 
-	if (ei_local->tx1 == 0)
-	{
+	if (ei_local->tx1 == 0) {
 		output_page = ei_local->tx_start_page;
 		ei_local->tx1 = send_length;
 		if (ei_debug  &&  ei_local->tx2 > 0)
 			netdev_dbg(dev, "idle transmitter tx2=%d, lasttx=%d, txing=%d\n",
 				   ei_local->tx2, ei_local->lasttx, ei_local->txing);
-	}
-	else if (ei_local->tx2 == 0)
-	{
+	} else if (ei_local->tx2 == 0) {
 		output_page = ei_local->tx_start_page + TX_PAGES/2;
 		ei_local->tx2 = send_length;
 		if (ei_debug  &&  ei_local->tx1 > 0)
 			netdev_dbg(dev, "idle transmitter, tx1=%d, lasttx=%d, txing=%d\n",
 				   ei_local->tx1, ei_local->lasttx, ei_local->txing);
-	}
-	else
-	{	/* We should never get here. */
+	} else {			/* We should never get here. */
 		if (ei_debug)
 			netdev_dbg(dev, "No Tx buffers free! tx1=%d tx2=%d last=%d\n",
 				   ei_local->tx1, ei_local->tx2, ei_local->lasttx);
@@ -383,22 +377,18 @@ static netdev_tx_t __ei_start_xmit(struct sk_buff *skb,
 
 	ei_block_output(dev, send_length, data, output_page);
 
-	if (! ei_local->txing)
-	{
+	if (! ei_local->txing) {
 		ei_local->txing = 1;
 		NS8390_trigger_send(dev, send_length, output_page);
-		if (output_page == ei_local->tx_start_page)
-		{
+		if (output_page == ei_local->tx_start_page) {
 			ei_local->tx1 = -1;
 			ei_local->lasttx = -1;
-		}
-		else
-		{
+		} else {
 			ei_local->tx2 = -1;
 			ei_local->lasttx = -2;
 		}
-	}
-	else ei_local->txqueue++;
+	} else
+		ei_local->txqueue++;
 
 	if (ei_local->tx1  &&  ei_local->tx2)
 		netif_stop_queue(dev);
@@ -443,8 +433,7 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 
 	spin_lock(&ei_local->page_lock);
 
-	if (ei_local->irqlock)
-	{
+	if (ei_local->irqlock) {
 		/*
 		 * This might just be an interrupt for a PCI device sharing
 		 * this line
@@ -464,8 +453,7 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 
 	/* !!Assumption!! -- we stay in page 0.	 Don't break this. */
 	while ((interrupts = ei_inb_p(e8390_base + EN0_ISR)) != 0 &&
-	       ++nr_serviced < MAX_SERVICE)
-	{
+	       ++nr_serviced < MAX_SERVICE) {
 		if (!netif_running(dev)) {
 			netdev_warn(dev, "interrupt from stopped card\n");
 			/* rmk - acknowledge the interrupts */
@@ -475,8 +463,7 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 		}
 		if (interrupts & ENISR_OVER)
 			ei_rx_overrun(dev);
-		else if (interrupts & (ENISR_RX+ENISR_RX_ERR))
-		{
+		else if (interrupts & (ENISR_RX+ENISR_RX_ERR)) {
 			/* Got a good (?) packet. */
 			ei_receive(dev);
 		}
@@ -486,8 +473,7 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 		else if (interrupts & ENISR_TX_ERR)
 			ei_tx_err(dev);
 
-		if (interrupts & ENISR_COUNTERS)
-		{
+		if (interrupts & ENISR_COUNTERS) {
 			dev->stats.rx_frame_errors += ei_inb_p(e8390_base + EN0_COUNTER0);
 			dev->stats.rx_crc_errors   += ei_inb_p(e8390_base + EN0_COUNTER1);
 			dev->stats.rx_missed_errors+= ei_inb_p(e8390_base + EN0_COUNTER2);
@@ -496,18 +482,14 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
 
 		/* Ignore any RDC interrupts that make it back to here. */
 		if (interrupts & ENISR_RDC)
-		{
 			ei_outb_p(ENISR_RDC, e8390_base + EN0_ISR);
-		}
 
 		ei_outb_p(E8390_NODMA+E8390_PAGE0+E8390_START, e8390_base + E8390_CMD);
 	}
 
-	if (interrupts && ei_debug)
-	{
+	if (interrupts && ei_debug) {
 		ei_outb_p(E8390_NODMA+E8390_PAGE0+E8390_START, e8390_base + E8390_CMD);
-		if (nr_serviced >= MAX_SERVICE)
-		{
+		if (nr_serviced >= MAX_SERVICE) {
 			/* 0xFF is valid for a card removal */
 			if(interrupts!=0xFF)
 				netdev_warn(dev, "Too much work at interrupt, status %#2.2x\n",
@@ -572,8 +554,7 @@ static void ei_tx_err(struct net_device *dev)
 
 	if (tx_was_aborted)
 		ei_tx_intr(dev);
-	else
-	{
+	else {
 		dev->stats.tx_errors++;
 		if (txsr & ENTSR_CRS) dev->stats.tx_carrier_errors++;
 		if (txsr & ENTSR_CDH) dev->stats.tx_heartbeat_errors++;
@@ -603,37 +584,31 @@ static void ei_tx_intr(struct net_device *dev)
 	 */
 	ei_local->txqueue--;
 
-	if (ei_local->tx1 < 0)
-	{
+	if (ei_local->tx1 < 0) {
 		if (ei_local->lasttx != 1 && ei_local->lasttx != -1)
 			pr_err("%s: bogus last_tx_buffer %d, tx1=%d\n",
 			       ei_local->name, ei_local->lasttx, ei_local->tx1);
 		ei_local->tx1 = 0;
-		if (ei_local->tx2 > 0)
-		{
+		if (ei_local->tx2 > 0) {
 			ei_local->txing = 1;
 			NS8390_trigger_send(dev, ei_local->tx2, ei_local->tx_start_page + 6);
 			dev->trans_start = jiffies;
 			ei_local->tx2 = -1,
 			ei_local->lasttx = 2;
-		}
-		else ei_local->lasttx = 20, ei_local->txing = 0;
-	}
-	else if (ei_local->tx2 < 0)
-	{
+		} else
+			ei_local->lasttx = 20, ei_local->txing = 0;
+	} else if (ei_local->tx2 < 0) {
 		if (ei_local->lasttx != 2  &&  ei_local->lasttx != -2)
 			pr_err("%s: bogus last_tx_buffer %d, tx2=%d\n",
 			       ei_local->name, ei_local->lasttx, ei_local->tx2);
 		ei_local->tx2 = 0;
-		if (ei_local->tx1 > 0)
-		{
+		if (ei_local->tx1 > 0) {
 			ei_local->txing = 1;
 			NS8390_trigger_send(dev, ei_local->tx1, ei_local->tx_start_page);
 			dev->trans_start = jiffies;
 			ei_local->tx1 = -1;
 			ei_local->lasttx = 1;
-		}
-		else
+		} else
 			ei_local->lasttx = 10, ei_local->txing = 0;
 	}
 //	else printk(KERN_WARNING "%s: unexpected TX-done interrupt, lasttx=%d.\n",
@@ -644,11 +619,9 @@ static void ei_tx_intr(struct net_device *dev)
 		dev->stats.collisions++;
 	if (status & ENTSR_PTX)
 		dev->stats.tx_packets++;
-	else
-	{
+	else {
 		dev->stats.tx_errors++;
-		if (status & ENTSR_ABT)
-		{
+		if (status & ENTSR_ABT) {
 			dev->stats.tx_aborted_errors++;
 			dev->stats.collisions += 16;
 		}
@@ -682,8 +655,7 @@ static void ei_receive(struct net_device *dev)
 	struct e8390_pkt_hdr rx_frame;
 	int num_rx_pages = ei_local->stop_page-ei_local->rx_start_page;
 
-	while (++rx_pkt_count < 10)
-	{
+	while (++rx_pkt_count < 10) {
 		int pkt_len, pkt_stat;
 
 		/* Get the rx page (incoming packet pointer). */
@@ -730,30 +702,24 @@ static void ei_receive(struct net_device *dev)
 			continue;
 		}
 
-		if (pkt_len < 60  ||  pkt_len > 1518)
-		{
+		if (pkt_len < 60  ||  pkt_len > 1518) {
 			if (ei_debug)
 				netdev_dbg(dev, "bogus packet size: %d, status=%#2x nxpg=%#2x\n",
 					   rx_frame.count, rx_frame.status,
 					   rx_frame.next);
 			dev->stats.rx_errors++;
 			dev->stats.rx_length_errors++;
-		}
-		 else if ((pkt_stat & 0x0F) == ENRSR_RXOK)
-		{
+		} else if ((pkt_stat & 0x0F) == ENRSR_RXOK) {
 			struct sk_buff *skb;
 
 			skb = dev_alloc_skb(pkt_len+2);
-			if (skb == NULL)
-			{
+			if (skb == NULL) {
 				if (ei_debug > 1)
 					netdev_dbg(dev, "Couldn't allocate a sk_buff of size %d\n",
 						   pkt_len);
 				dev->stats.rx_dropped++;
 				break;
-			}
-			else
-			{
+			} else {
 				skb_reserve(skb,2);	/* IP headers on 16 byte boundaries */
 				skb_put(skb, pkt_len);	/* Make room */
 				ei_block_input(dev, pkt_len, skb, current_offset + sizeof(rx_frame));
@@ -765,9 +731,7 @@ static void ei_receive(struct net_device *dev)
 				if (pkt_stat & ENRSR_PHY)
 					dev->stats.multicast++;
 			}
-		}
-		else
-		{
+		} else {
 			if (ei_debug)
 				netdev_dbg(dev, "bogus packet: status=%#2x nxpg=%#2x size=%d\n",
 					   rx_frame.status, rx_frame.next,
@@ -845,8 +809,7 @@ static void ei_rx_overrun(struct net_device *dev)
 	 * step is vital, and skipping it will cause no end of havoc.
 	 */
 
-	if (was_txing)
-	{
+	if (was_txing) {
 		unsigned char tx_completed = ei_inb_p(e8390_base+EN0_ISR) & (ENISR_TX+ENISR_TX_ERR);
 		if (!tx_completed)
 			must_resend = 1;
@@ -930,13 +893,11 @@ static void do_set_multicast_list(struct net_device *dev)
 	int i;
 	struct ei_device *ei_local = netdev_priv(dev);
 
-	if (!(dev->flags&(IFF_PROMISC|IFF_ALLMULTI)))
-	{
+	if (!(dev->flags&(IFF_PROMISC|IFF_ALLMULTI))) {
 		memset(ei_local->mcfilter, 0, 8);
 		if (!netdev_mc_empty(dev))
 			make_mc_bits(ei_local->mcfilter, dev);
-	}
-	else
+	} else
 		memset(ei_local->mcfilter, 0xFF, 8);	/* mcast set to accept-all */
 
 	/*
@@ -955,8 +916,7 @@ static void do_set_multicast_list(struct net_device *dev)
 	if (netif_running(dev))
 		ei_outb_p(E8390_RXCONFIG, e8390_base + EN0_RXCR);
 	ei_outb_p(E8390_NODMA + E8390_PAGE1, e8390_base + E8390_CMD);
-	for(i = 0; i < 8; i++)
-	{
+	for(i = 0; i < 8; i++) {
 		ei_outb_p(ei_local->mcfilter[i], e8390_base + EN1_MULT_SHIFT(i));
 #ifndef BUG_83C690
 		if(ei_inb_p(e8390_base + EN1_MULT_SHIFT(i))!=ei_local->mcfilter[i])
@@ -1069,8 +1029,7 @@ static void __NS8390_init(struct net_device *dev, int startp)
 	/* Copy the station address into the DS8390 registers. */
 
 	ei_outb_p(E8390_NODMA + E8390_PAGE1 + E8390_STOP, e8390_base+E8390_CMD); /* 0x61 */
-	for(i = 0; i < 6; i++)
-	{
+	for(i = 0; i < 6; i++) {
 		ei_outb_p(dev->dev_addr[i], e8390_base + EN1_PHYS_SHIFT(i));
 		if (ei_debug > 1 && ei_inb_p(e8390_base + EN1_PHYS_SHIFT(i))!=dev->dev_addr[i])
 			netdev_err(dev, "Hw. address read/write mismap %d\n", i);
@@ -1082,8 +1041,7 @@ static void __NS8390_init(struct net_device *dev, int startp)
 	ei_local->tx1 = ei_local->tx2 = 0;
 	ei_local->txing = 0;
 
-	if (startp)
-	{
+	if (startp) {
 		ei_outb_p(0xff,  e8390_base + EN0_ISR);
 		ei_outb_p(ENISR_ALL,  e8390_base + EN0_IMR);
 		ei_outb_p(E8390_NODMA+E8390_PAGE0+E8390_START, e8390_base+E8390_CMD);
@@ -1105,8 +1063,7 @@ static void NS8390_trigger_send(struct net_device *dev, unsigned int length,
 
 	ei_outb_p(E8390_NODMA+E8390_PAGE0, e8390_base+E8390_CMD);
 
-	if (ei_inb_p(e8390_base + E8390_CMD) & E8390_TRANS)
-	{
+	if (ei_inb_p(e8390_base + E8390_CMD) & E8390_TRANS) {
 		netdev_warn(dev, "trigger_send() called with the transmitter busy\n");
 		return;
 	}
-- 
1.7.6.rc3

