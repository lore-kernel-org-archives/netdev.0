From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] Massive net driver stats cleanup
Date: Sat, 1 Sep 2007 12:25:05 -0400
Message-ID: <20070901162505.GA2944@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:55768 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755269AbXIAQZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Sep 2007 12:25:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I would appreciate people building this on non-x86 architectures.  The
compile breakage is always the same:  naming of the local variable
representing struct net_device.

I pushed into into netdev-2.6.git#ALL so that it will show in -mm too.



commit e64060e11a401aa7c723d00270896d2cb99faac3
Author: Jeff Garzik <jeff@garzik.org>
Date:   Sat Sep 1 12:21:41 2007 -0400

    drivers/net: statistics cleanup #1 -- save memory and shrink code
    
    We now have struct net_device_stats embedded in struct net_device,
    and the default ->get_stats() hook does the obvious thing for us.
    
    Run through drivers/net/* and remove the driver-local storage of
    statistics, and driver-local ->get_stats() hook where applicable.
    
    This was just the low-hanging fruit in drivers/net; plenty more drivers
    remain to be updated.
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

 drivers/net/3c501.c        |   41 ++++-------------
 drivers/net/3c501.h        |    2 
 drivers/net/3c507.c        |   52 ++++++++--------------
 drivers/net/7990.c         |   47 ++++++++------------
 drivers/net/7990.h         |    2 
 drivers/net/82596.c        |   65 +++++++++++-----------------
 drivers/net/a2065.c        |   51 +++++++++-------------
 drivers/net/at1700.c       |   39 +++++-----------
 drivers/net/atarilance.c   |   58 ++++++++-----------------
 drivers/net/atp.c          |   49 +++++++--------------
 drivers/net/au1000_eth.c   |   23 +--------
 drivers/net/au1000_eth.h   |    1 
 drivers/net/bfin_mac.c     |   25 ++--------
 drivers/net/bfin_mac.h     |    2 
 drivers/net/bmac.c         |   48 ++++++++------------
 drivers/net/de600.c        |   15 +-----
 drivers/net/de600.h        |    1 
 drivers/net/de620.c        |   26 +++--------
 drivers/net/declance.c     |   52 +++++++++-------------
 drivers/net/depca.c        |   42 ++++++------------
 drivers/net/dgrs.c         |   24 +---------
 drivers/net/dm9000.c       |   29 +++---------
 drivers/net/e100.c         |   23 +++------
 drivers/net/eepro.c        |   47 +++++++-------------
 drivers/net/eexpress.c     |   56 +++++++++---------------
 drivers/net/eql.c          |   12 -----
 drivers/net/eth16i.c       |   49 ++++++++-------------
 drivers/net/ewrk3.c        |   37 +++++-----------
 drivers/net/fec.c          |   50 ++++++++-------------
 drivers/net/gianfar.c      |   40 ++++++-----------
 drivers/net/hplance.c      |    1 
 drivers/net/ibmlana.c      |   37 ++++++----------
 drivers/net/ibmlana.h      |    1 
 drivers/net/ibmveth.c      |   18 ++-----
 drivers/net/ifb.c          |   20 --------
 drivers/net/iseries_veth.c |   22 ++-------
 drivers/net/lib82596.c     |   64 +++++++++++----------------
 drivers/net/lp486e.c       |   56 +++++++++---------------
 drivers/net/mace.c         |   51 ++++++++--------------
 drivers/net/macmace.c      |   49 ++++++++-------------
 drivers/net/meth.c         |   28 ++++--------
 drivers/net/mipsnet.c      |   26 ++---------
 drivers/net/mv643xx_eth.c  |   25 +---------
 drivers/net/myri_sbus.c    |   20 +++-----
 drivers/net/myri_sbus.h    |    1 
 drivers/net/netx-eth.c     |   18 ++-----
 drivers/net/ni5010.c       |   47 +++++---------------
 drivers/net/pasemi_mac.c   |   17 +------
 drivers/net/pasemi_mac.h   |    1 
 drivers/net/pci-skeleton.c |   74 +++++++++-----------------------
 drivers/net/plip.c         |   32 ++++---------
 drivers/net/qla3xxx.c      |   23 +++------
 drivers/net/qla3xxx.h      |    1 
 drivers/net/rionet.c       |   20 ++------
 drivers/net/rrunner.c      |   31 ++++---------
 drivers/net/rrunner.h      |    2 
 drivers/net/saa9730.c      |   93 ++++++++++++++++++----------------------
 drivers/net/saa9730.h      |    1 
 drivers/net/sb1000.c       |   19 ++------
 drivers/net/sb1250-mac.c   |   37 +++-------------
 drivers/net/seeq8005.c     |   33 ++++----------
 drivers/net/sgiseeq.c      |   34 +++++---------
 drivers/net/shaper.c       |   15 +-----
 drivers/net/sis190.c       |   19 ++------
 drivers/net/sis900.c       |   56 ++++++++----------------
 drivers/net/smc911x.c      |   77 ++++++++++++---------------------
 drivers/net/smc9194.c      |   59 +++++++------------------
 drivers/net/smc91x.c       |   69 ++++++++++-------------------
 drivers/net/spider_net.c   |   31 +++----------
 drivers/net/spider_net.h   |    1 
 drivers/net/sun3lance.c    |   53 ++++++++--------------
 drivers/net/sunlance.c     |   87 ++++++++++++++++---------------------
 drivers/net/sunqe.c        |  104 ++++++++++++++++++++-------------------------
 drivers/net/sunqe.h        |    1 
 drivers/net/tun.c          |   23 +++------
 drivers/net/ucc_geth.c     |   27 +++--------
 drivers/net/ucc_geth.h     |    1 
 drivers/net/xen-netfront.c |   26 +++--------
 drivers/net/yellowfin.c    |   63 +++++++++++----------------
 drivers/net/znet.c         |   50 ++++++++-------------
 include/linux/if_eql.h     |    1 
 include/linux/if_shaper.h  |    1 
 include/linux/if_tun.h     |    1 
 83 files changed, 930 insertions(+), 1745 deletions(-)

e64060e11a401aa7c723d00270896d2cb99faac3
diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 4bee99b..44ad194 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -317,7 +317,6 @@ static int __init el1_probe1(struct net_device *dev, int ioaddr)
 	dev->tx_timeout = &el_timeout;
 	dev->watchdog_timeo = HZ;
 	dev->stop = &el1_close;
-	dev->get_stats = &el1_get_stats;
 	dev->set_multicast_list = &set_multicast_list;
 	dev->ethtool_ops = &netdev_ethtool_ops;
 	return 0;
@@ -376,7 +375,7 @@ static void el_timeout(struct net_device *dev)
 	if (el_debug)
 		printk (KERN_DEBUG "%s: transmit timed out, txsr %#2x axsr=%02x rxsr=%02x.\n",
 			dev->name, inb(TX_STATUS), inb(AX_STATUS), inb(RX_STATUS));
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	outb(TX_NORM, TX_CMD);
 	outb(RX_NORM, RX_CMD);
 	outb(AX_OFF, AX_CMD);	/* Just trigger a false interrupt. */
@@ -443,7 +442,7 @@ static int el_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		lp->tx_pkt_start = gp_start;
     		lp->collisions = 0;
 
-    		lp->stats.tx_bytes += skb->len;
+    		dev->stats.tx_bytes += skb->len;
 
 		/*
 		 *	Command mode with status cleared should [in theory]
@@ -590,7 +589,7 @@ static irqreturn_t el_interrupt(int irq, void *dev_id)
 				printk (KERN_DEBUG "%s: Transmit failed 16 times, Ethernet jammed?\n",dev->name);
 			outb(AX_SYS, AX_CMD);
 			lp->txing = 0;
-			lp->stats.tx_aborted_errors++;
+			dev->stats.tx_aborted_errors++;
 			netif_wake_queue(dev);
 		}
 		else if (txsr & TX_COLLISION)
@@ -608,7 +607,7 @@ static irqreturn_t el_interrupt(int irq, void *dev_id)
 			outb(AX_SYS, AX_CMD);
 			outw(lp->tx_pkt_start, GP_LOW);
 			outb(AX_XMIT, AX_CMD);
-			lp->stats.collisions++;
+			dev->stats.collisions++;
 			spin_unlock(&lp->lock);
 			goto out;
 		}
@@ -617,7 +616,7 @@ static irqreturn_t el_interrupt(int irq, void *dev_id)
 			/*
 			 *	It worked.. we will now fall through and receive
 			 */
-			lp->stats.tx_packets++;
+			dev->stats.tx_packets++;
 			if (el_debug > 6)
 				printk(KERN_DEBUG " Tx succeeded %s\n",
 		       			(txsr & TX_RDY) ? "." : "but tx is busy!");
@@ -642,10 +641,10 @@ static irqreturn_t el_interrupt(int irq, void *dev_id)
 		 *	Just reading rx_status fixes most errors.
 		 */
 		if (rxsr & RX_MISSED)
-			lp->stats.rx_missed_errors++;
+			dev->stats.rx_missed_errors++;
 		else if (rxsr & RX_RUNT)
 		{	/* Handled to avoid board lock-up. */
-			lp->stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 			if (el_debug > 5)
 				printk(KERN_DEBUG " runt.\n");
 		}
@@ -696,7 +695,6 @@ out:
 
 static void el_receive(struct net_device *dev)
 {
-	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int pkt_len;
 	struct sk_buff *skb;
@@ -710,7 +708,7 @@ static void el_receive(struct net_device *dev)
 	{
 		if (el_debug)
 			printk(KERN_DEBUG "%s: bogus packet, length=%d\n", dev->name, pkt_len);
-		lp->stats.rx_over_errors++;
+		dev->stats.rx_over_errors++;
 		return;
 	}
 
@@ -729,7 +727,7 @@ static void el_receive(struct net_device *dev)
 	if (skb == NULL)
 	{
 		printk(KERN_INFO "%s: Memory squeeze, dropping packet.\n", dev->name);
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 	else
@@ -744,8 +742,8 @@ static void el_receive(struct net_device *dev)
 		skb->protocol=eth_type_trans(skb,dev);
 		netif_rx(skb);
 		dev->last_rx = jiffies;
-		lp->stats.rx_packets++;
-		lp->stats.rx_bytes+=pkt_len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes+=pkt_len;
 	}
 	return;
 }
@@ -813,23 +811,6 @@ static int el1_close(struct net_device *dev)
 }
 
 /**
- * el1_get_stats:
- * @dev: The card to get the statistics for
- *
- * In smarter devices this function is needed to pull statistics off the
- * board itself. The 3c501 has no hardware statistics. We maintain them all
- * so they are by definition always up to date.
- *
- * Returns the statistics for the card from the card private data
- */
-
-static struct net_device_stats *el1_get_stats(struct net_device *dev)
-{
-	struct net_local *lp = netdev_priv(dev);
-	return &lp->stats;
-}
-
-/**
  * set_multicast_list:
  * @dev: The device to adjust
  *
diff --git a/drivers/net/3c501.h b/drivers/net/3c501.h
index c56a2c6..cfec64e 100644
--- a/drivers/net/3c501.h
+++ b/drivers/net/3c501.h
@@ -11,7 +11,6 @@ static irqreturn_t el_interrupt(int irq, void *dev_id);
 static void el_receive(struct net_device *dev);
 static void el_reset(struct net_device *dev);
 static int  el1_close(struct net_device *dev);
-static struct net_device_stats *el1_get_stats(struct net_device *dev);
 static void set_multicast_list(struct net_device *dev);
 static const struct ethtool_ops netdev_ethtool_ops;
 
@@ -29,7 +28,6 @@ static int el_debug = EL_DEBUG;
 
 struct net_local
 {
-	struct net_device_stats stats;
 	int		tx_pkt_start;	/* The length of the current Tx packet. */
 	int		collisions;	/* Tx collisions this packet */
 	int		loading;	/* Spot buffer load collisions */
diff --git a/drivers/net/3c507.c b/drivers/net/3c507.c
index eed4299..29a4600 100644
--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -118,7 +118,6 @@ enum commands {
 
 /* Information that need to be kept for each board. */
 struct net_local {
-	struct net_device_stats stats;
 	int last_restart;
 	ushort rx_head;
 	ushort rx_tail;
@@ -289,7 +288,6 @@ static int	el16_send_packet(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t el16_interrupt(int irq, void *dev_id);
 static void el16_rx(struct net_device *dev);
 static int	el16_close(struct net_device *dev);
-static struct net_device_stats *el16_get_stats(struct net_device *dev);
 static void el16_tx_timeout (struct net_device *dev);
 
 static void hardware_send_packet(struct net_device *dev, void *buf, short length, short pad);
@@ -457,7 +455,6 @@ static int __init el16_probe1(struct net_device *dev, int ioaddr)
  	dev->open = el16_open;
  	dev->stop = el16_close;
 	dev->hard_start_xmit = el16_send_packet;
-	dev->get_stats	= el16_get_stats;
 	dev->tx_timeout = el16_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 	dev->ethtool_ops = &netdev_ethtool_ops;
@@ -491,7 +488,7 @@ static void el16_tx_timeout (struct net_device *dev)
 			readw(shmem + iSCB_STATUS) & 0x8000 ? "IRQ conflict" :
 			"network cable problem");
 	/* Try to restart the adaptor. */
-	if (lp->last_restart == lp->stats.tx_packets) {
+	if (lp->last_restart == dev->stats.tx_packets) {
 		if (net_debug > 1)
 			printk ("Resetting board.\n");
 		/* Completely reset the adaptor. */
@@ -503,7 +500,7 @@ static void el16_tx_timeout (struct net_device *dev)
 			printk ("Kicking board.\n");
 		writew(0xf000 | CUC_START | RX_START, shmem + iSCB_CMD);
 		outb (0, ioaddr + SIGNAL_CA);	/* Issue channel-attn. */
-		lp->last_restart = lp->stats.tx_packets;
+		lp->last_restart = dev->stats.tx_packets;
 	}
 	dev->trans_start = jiffies;
 	netif_wake_queue (dev);
@@ -522,7 +519,7 @@ static int el16_send_packet (struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irqsave (&lp->lock, flags);
 
-	lp->stats.tx_bytes += length;
+	dev->stats.tx_bytes += length;
 	/* Disable the 82586's input to the interrupt line. */
 	outb (0x80, ioaddr + MISC_CTRL);
 
@@ -581,14 +578,14 @@ static irqreturn_t el16_interrupt(int irq, void *dev_id)
 	  }
 	  /* Tx unsuccessful or some interesting status bit set. */
 	  if (!(tx_status & 0x2000) || (tx_status & 0x0f3f)) {
-		lp->stats.tx_errors++;
-		if (tx_status & 0x0600)  lp->stats.tx_carrier_errors++;
-		if (tx_status & 0x0100)  lp->stats.tx_fifo_errors++;
-		if (!(tx_status & 0x0040))  lp->stats.tx_heartbeat_errors++;
-		if (tx_status & 0x0020)  lp->stats.tx_aborted_errors++;
-		lp->stats.collisions += tx_status & 0xf;
+		dev->stats.tx_errors++;
+		if (tx_status & 0x0600)  dev->stats.tx_carrier_errors++;
+		if (tx_status & 0x0100)  dev->stats.tx_fifo_errors++;
+		if (!(tx_status & 0x0040))  dev->stats.tx_heartbeat_errors++;
+		if (tx_status & 0x0020)  dev->stats.tx_aborted_errors++;
+		dev->stats.collisions += tx_status & 0xf;
 	  }
-	  lp->stats.tx_packets++;
+	  dev->stats.tx_packets++;
 	  if (net_debug > 5)
 		  printk("Reaped %x, Tx status %04x.\n" , lp->tx_reap, tx_status);
 	  lp->tx_reap += TX_BUF_SIZE;
@@ -667,17 +664,6 @@ static int el16_close(struct net_device *dev)
 	return 0;
 }
 
-/* Get the current statistics.	This may be called with the card open or
-   closed. */
-static struct net_device_stats *el16_get_stats(struct net_device *dev)
-{
-	struct net_local *lp = netdev_priv(dev);
-
-	/* ToDo: decide if there are any useful statistics from the SCB. */
-
-	return &lp->stats;
-}
-
 /* Initialize the Rx-block list. */
 static void init_rx_bufs(struct net_device *dev)
 {
@@ -854,12 +840,12 @@ static void el16_rx(struct net_device *dev)
 				   pkt_len);
 		} else if ((frame_status & 0x2000) == 0) {
 			/* Frame Rxed, but with error. */
-			lp->stats.rx_errors++;
-			if (frame_status & 0x0800) lp->stats.rx_crc_errors++;
-			if (frame_status & 0x0400) lp->stats.rx_frame_errors++;
-			if (frame_status & 0x0200) lp->stats.rx_fifo_errors++;
-			if (frame_status & 0x0100) lp->stats.rx_over_errors++;
-			if (frame_status & 0x0080) lp->stats.rx_length_errors++;
+			dev->stats.rx_errors++;
+			if (frame_status & 0x0800) dev->stats.rx_crc_errors++;
+			if (frame_status & 0x0400) dev->stats.rx_frame_errors++;
+			if (frame_status & 0x0200) dev->stats.rx_fifo_errors++;
+			if (frame_status & 0x0100) dev->stats.rx_over_errors++;
+			if (frame_status & 0x0080) dev->stats.rx_length_errors++;
 		} else {
 			/* Malloc up new buffer. */
 			struct sk_buff *skb;
@@ -868,7 +854,7 @@ static void el16_rx(struct net_device *dev)
 			skb = dev_alloc_skb(pkt_len+2);
 			if (skb == NULL) {
 				printk("%s: Memory squeeze, dropping packet.\n", dev->name);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				break;
 			}
 
@@ -880,8 +866,8 @@ static void el16_rx(struct net_device *dev)
 			skb->protocol=eth_type_trans(skb,dev);
 			netif_rx(skb);
 			dev->last_rx = jiffies;
-			lp->stats.rx_packets++;
-			lp->stats.rx_bytes += pkt_len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_len;
 		}
 
 		/* Clear the status word and set End-of-List on the rx frame. */
diff --git a/drivers/net/7990.c b/drivers/net/7990.c
index e89ace1..224e0bf 100644
--- a/drivers/net/7990.c
+++ b/drivers/net/7990.c
@@ -305,18 +305,18 @@ static int lance_rx (struct net_device *dev)
 
                 /* We got an incomplete frame? */
                 if ((bits & LE_R1_POK) != LE_R1_POK) {
-                        lp->stats.rx_over_errors++;
-                        lp->stats.rx_errors++;
+                        dev->stats.rx_over_errors++;
+                        dev->stats.rx_errors++;
                         continue;
                 } else if (bits & LE_R1_ERR) {
                         /* Count only the end frame as a rx error,
                          * not the beginning
                          */
-                        if (bits & LE_R1_BUF) lp->stats.rx_fifo_errors++;
-                        if (bits & LE_R1_CRC) lp->stats.rx_crc_errors++;
-                        if (bits & LE_R1_OFL) lp->stats.rx_over_errors++;
-                        if (bits & LE_R1_FRA) lp->stats.rx_frame_errors++;
-                        if (bits & LE_R1_EOP) lp->stats.rx_errors++;
+                        if (bits & LE_R1_BUF) dev->stats.rx_fifo_errors++;
+                        if (bits & LE_R1_CRC) dev->stats.rx_crc_errors++;
+                        if (bits & LE_R1_OFL) dev->stats.rx_over_errors++;
+                        if (bits & LE_R1_FRA) dev->stats.rx_frame_errors++;
+                        if (bits & LE_R1_EOP) dev->stats.rx_errors++;
                 } else {
                         len = (rd->mblength & 0xfff) - 4;
                         skb = dev_alloc_skb (len+2);
@@ -324,7 +324,7 @@ static int lance_rx (struct net_device *dev)
                         if (skb == 0) {
                                 printk ("%s: Memory squeeze, deferring packet.\n",
                                         dev->name);
-                                lp->stats.rx_dropped++;
+                                dev->stats.rx_dropped++;
                                 rd->mblength = 0;
                                 rd->rmd1_bits = LE_R1_OWN;
                                 lp->rx_new = (lp->rx_new + 1) & lp->rx_ring_mod_mask;
@@ -339,8 +339,8 @@ static int lance_rx (struct net_device *dev)
                         skb->protocol = eth_type_trans (skb, dev);
 			netif_rx (skb);
 			dev->last_rx = jiffies;
-			lp->stats.rx_packets++;
-			lp->stats.rx_bytes += len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += len;
                 }
 
                 /* Return the packet to the pool */
@@ -377,12 +377,12 @@ static int lance_tx (struct net_device *dev)
                 if (td->tmd1_bits & LE_T1_ERR) {
                         status = td->misc;
 
-                        lp->stats.tx_errors++;
-                        if (status & LE_T3_RTY)  lp->stats.tx_aborted_errors++;
-                        if (status & LE_T3_LCOL) lp->stats.tx_window_errors++;
+                        dev->stats.tx_errors++;
+                        if (status & LE_T3_RTY)  dev->stats.tx_aborted_errors++;
+                        if (status & LE_T3_LCOL) dev->stats.tx_window_errors++;
 
                         if (status & LE_T3_CLOS) {
-                                lp->stats.tx_carrier_errors++;
+                                dev->stats.tx_carrier_errors++;
                                 if (lp->auto_select) {
                                         lp->tpe = 1 - lp->tpe;
                                         printk("%s: Carrier Lost, trying %s\n",
@@ -400,7 +400,7 @@ static int lance_tx (struct net_device *dev)
                         /* buffer errors and underflows turn off the transmitter */
                         /* Restart the adapter */
                         if (status & (LE_T3_BUF|LE_T3_UFL)) {
-                                lp->stats.tx_fifo_errors++;
+                                dev->stats.tx_fifo_errors++;
 
                                 printk ("%s: Tx: ERR_BUF|ERR_UFL, restarting\n",
                                         dev->name);
@@ -420,13 +420,13 @@ static int lance_tx (struct net_device *dev)
 
                         /* One collision before packet was sent. */
                         if (td->tmd1_bits & LE_T1_EONE)
-                                lp->stats.collisions++;
+                                dev->stats.collisions++;
 
                         /* More than one collision, be optimistic. */
                         if (td->tmd1_bits & LE_T1_EMORE)
-                                lp->stats.collisions += 2;
+                                dev->stats.collisions += 2;
 
-                        lp->stats.tx_packets++;
+                        dev->stats.tx_packets++;
                 }
 
                 j = (j + 1) & lp->tx_ring_mod_mask;
@@ -471,9 +471,9 @@ lance_interrupt (int irq, void *dev_id)
 
         /* Log misc errors. */
         if (csr0 & LE_C0_BABL)
-                lp->stats.tx_errors++;       /* Tx babble. */
+                dev->stats.tx_errors++;       /* Tx babble. */
         if (csr0 & LE_C0_MISS)
-                lp->stats.rx_errors++;       /* Missed a Rx frame. */
+                dev->stats.rx_errors++;       /* Missed a Rx frame. */
         if (csr0 & LE_C0_MERR) {
                 printk("%s: Bus master arbitration failure, status %4.4x.\n",
                        dev->name, csr0);
@@ -589,13 +589,6 @@ int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
         return 0;
 }
 
-struct net_device_stats *lance_get_stats (struct net_device *dev)
-{
-        struct lance_private *lp = netdev_priv(dev);
-
-        return &lp->stats;
-}
-
 /* taken from the depca driver via a2065.c */
 static void lance_load_multicast (struct net_device *dev)
 {
diff --git a/drivers/net/7990.h b/drivers/net/7990.h
index b1212b5..0a5837b 100644
--- a/drivers/net/7990.h
+++ b/drivers/net/7990.h
@@ -111,7 +111,6 @@ struct lance_private
         int lance_log_rx_bufs, lance_log_tx_bufs;
         int rx_ring_mod_mask, tx_ring_mod_mask;
 
-        struct net_device_stats stats;
         int tpe;                                  /* TPE is selected */
         int auto_select;                          /* cable-selection is by carrier */
         unsigned short busmaster_regval;
@@ -246,7 +245,6 @@ struct lance_private
 extern int lance_open(struct net_device *dev);
 extern int lance_close (struct net_device *dev);
 extern int lance_start_xmit (struct sk_buff *skb, struct net_device *dev);
-extern struct net_device_stats *lance_get_stats (struct net_device *dev);
 extern void lance_set_multicast (struct net_device *dev);
 extern void lance_tx_timeout(struct net_device *dev);
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index d915837..4683955 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -326,7 +326,6 @@ struct i596_private {
 	struct i596_cmd *cmd_head;
 	int cmd_backlog;
 	unsigned long last_cmd;
-	struct net_device_stats stats;
 	struct i596_rfd rfds[RX_RING_SIZE];
 	struct i596_rbd rbds[RX_RING_SIZE];
 	struct tx_cmd tx_cmds[TX_RING_SIZE];
@@ -360,7 +359,6 @@ static int i596_open(struct net_device *dev);
 static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t i596_interrupt(int irq, void *dev_id);
 static int i596_close(struct net_device *dev);
-static struct net_device_stats *i596_get_stats(struct net_device *dev);
 static void i596_add_cmd(struct net_device *dev, struct i596_cmd *cmd);
 static void i596_tx_timeout (struct net_device *dev);
 static void print_eth(unsigned char *buf, char *str);
@@ -828,7 +826,7 @@ memory_squeeze:
 			if (skb == NULL) {
 				/* XXX tulip.c can defer packets here!! */
 				printk(KERN_WARNING "%s: i596_rx Memory squeeze, dropping packet.\n", dev->name);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 			}
 			else {
 				if (!rx_in_place) {
@@ -844,28 +842,28 @@ memory_squeeze:
 #endif
 				netif_rx(skb);
 				dev->last_rx = jiffies;
-				lp->stats.rx_packets++;
-				lp->stats.rx_bytes+=pkt_len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes+=pkt_len;
 			}
 		}
 		else {
 			DEB(DEB_ERRORS, printk(KERN_DEBUG "%s: Error, rfd.stat = 0x%04x\n",
 					dev->name, rfd->stat));
-			lp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			if ((rfd->stat) & 0x0001)
-				lp->stats.collisions++;
+				dev->stats.collisions++;
 			if ((rfd->stat) & 0x0080)
-				lp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			if ((rfd->stat) & 0x0100)
-				lp->stats.rx_over_errors++;
+				dev->stats.rx_over_errors++;
 			if ((rfd->stat) & 0x0200)
-				lp->stats.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 			if ((rfd->stat) & 0x0400)
-				lp->stats.rx_frame_errors++;
+				dev->stats.rx_frame_errors++;
 			if ((rfd->stat) & 0x0800)
-				lp->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 			if ((rfd->stat) & 0x1000)
-				lp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 		}
 
 		/* Clear the buffer descriptor count and EOF + F flags */
@@ -916,8 +914,8 @@ static void i596_cleanup_cmd(struct net_device *dev, struct i596_private *lp)
 
 				dev_kfree_skb(skb);
 
-				lp->stats.tx_errors++;
-				lp->stats.tx_aborted_errors++;
+				dev->stats.tx_errors++;
+				dev->stats.tx_aborted_errors++;
 
 				ptr->v_next = ptr->b_next = I596_NULL;
 				tx_cmd->cmd.command = 0;  /* Mark as free */
@@ -1038,10 +1036,10 @@ static void i596_tx_timeout (struct net_device *dev)
 	DEB(DEB_ERRORS,printk(KERN_ERR "%s: transmit timed out, status resetting.\n",
 			dev->name));
 
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 
 	/* Try to restart the adaptor */
-	if (lp->last_restart == lp->stats.tx_packets) {
+	if (lp->last_restart == dev->stats.tx_packets) {
 		DEB(DEB_ERRORS,printk(KERN_ERR "Resetting board.\n"));
 		/* Shutdown and restart */
 		i596_reset (dev, lp, ioaddr);
@@ -1050,7 +1048,7 @@ static void i596_tx_timeout (struct net_device *dev)
 		DEB(DEB_ERRORS,printk(KERN_ERR "Kicking board.\n"));
 		lp->scb.command = CUC_START | RX_START;
 		CA (dev);
-		lp->last_restart = lp->stats.tx_packets;
+		lp->last_restart = dev->stats.tx_packets;
 	}
 
 	dev->trans_start = jiffies;
@@ -1082,7 +1080,7 @@ static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (tx_cmd->cmd.command) {
 		printk(KERN_NOTICE "%s: xmit ring full, dropping packet.\n",
 				dev->name);
-		lp->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 
 		dev_kfree_skb(skb);
 	} else {
@@ -1107,8 +1105,8 @@ static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		DEB(DEB_TXADDR,print_eth(skb->data, "tx-queued"));
 		i596_add_cmd(dev, &tx_cmd->cmd);
 
-		lp->stats.tx_packets++;
-		lp->stats.tx_bytes += length;
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes += length;
 	}
 
 	netif_start_queue(dev);
@@ -1238,7 +1236,6 @@ struct net_device * __init i82596_probe(int unit)
 	dev->open = i596_open;
 	dev->stop = i596_close;
 	dev->hard_start_xmit = i596_start_xmit;
-	dev->get_stats = i596_get_stats;
 	dev->set_multicast_list = set_multicast_list;
 	dev->tx_timeout = i596_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
@@ -1344,17 +1341,17 @@ static irqreturn_t i596_interrupt(int irq, void *dev_id)
 				if ((ptr->status) & STAT_OK) {
 					DEB(DEB_TXADDR,print_eth(skb->data, "tx-done"));
 				} else {
-					lp->stats.tx_errors++;
+					dev->stats.tx_errors++;
 					if ((ptr->status) & 0x0020)
-						lp->stats.collisions++;
+						dev->stats.collisions++;
 					if (!((ptr->status) & 0x0040))
-						lp->stats.tx_heartbeat_errors++;
+						dev->stats.tx_heartbeat_errors++;
 					if ((ptr->status) & 0x0400)
-						lp->stats.tx_carrier_errors++;
+						dev->stats.tx_carrier_errors++;
 					if ((ptr->status) & 0x0800)
-						lp->stats.collisions++;
+						dev->stats.collisions++;
 					if ((ptr->status) & 0x1000)
-						lp->stats.tx_aborted_errors++;
+						dev->stats.tx_aborted_errors++;
 				}
 
 				dev_kfree_skb_irq(skb);
@@ -1409,8 +1406,8 @@ static irqreturn_t i596_interrupt(int irq, void *dev_id)
 			if (netif_running(dev)) {
 				DEB(DEB_ERRORS,printk(KERN_ERR "%s: i596 interrupt receive unit inactive, status 0x%x\n", dev->name, status));
 				ack_cmd |= RX_START;
-				lp->stats.rx_errors++;
-				lp->stats.rx_fifo_errors++;
+				dev->stats.rx_errors++;
+				dev->stats.rx_fifo_errors++;
 				rebuild_rx_bufs(dev);
 			}
 		}
@@ -1493,14 +1490,6 @@ static int i596_close(struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *
- i596_get_stats(struct net_device *dev)
-{
-	struct i596_private *lp = dev->priv;
-
-	return &lp->stats;
-}
-
 /*
  *    Set or clear the multicast filter for this adaptor.
  */
diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index a45de69..9d3e98f 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -119,7 +119,6 @@ struct lance_private {
 	int lance_log_rx_bufs, lance_log_tx_bufs;
 	int rx_ring_mod_mask, tx_ring_mod_mask;
 
-	struct net_device_stats stats;
 	int tpe;		      /* cable-selection is TPE */
 	int auto_select;	      /* cable-selection by carrier */
 	unsigned short busmaster_regval;
@@ -294,18 +293,18 @@ static int lance_rx (struct net_device *dev)
 
 		/* We got an incomplete frame? */
 		if ((bits & LE_R1_POK) != LE_R1_POK) {
-			lp->stats.rx_over_errors++;
-			lp->stats.rx_errors++;
+			dev->stats.rx_over_errors++;
+			dev->stats.rx_errors++;
 			continue;
 		} else if (bits & LE_R1_ERR) {
 			/* Count only the end frame as a rx error,
 			 * not the beginning
 			 */
-			if (bits & LE_R1_BUF) lp->stats.rx_fifo_errors++;
-			if (bits & LE_R1_CRC) lp->stats.rx_crc_errors++;
-			if (bits & LE_R1_OFL) lp->stats.rx_over_errors++;
-			if (bits & LE_R1_FRA) lp->stats.rx_frame_errors++;
-			if (bits & LE_R1_EOP) lp->stats.rx_errors++;
+			if (bits & LE_R1_BUF) dev->stats.rx_fifo_errors++;
+			if (bits & LE_R1_CRC) dev->stats.rx_crc_errors++;
+			if (bits & LE_R1_OFL) dev->stats.rx_over_errors++;
+			if (bits & LE_R1_FRA) dev->stats.rx_frame_errors++;
+			if (bits & LE_R1_EOP) dev->stats.rx_errors++;
 		} else {
 			len = (rd->mblength & 0xfff) - 4;
 			skb = dev_alloc_skb (len+2);
@@ -313,7 +312,7 @@ static int lance_rx (struct net_device *dev)
 			if (skb == 0) {
 				printk(KERN_WARNING "%s: Memory squeeze, "
 				       "deferring packet.\n", dev->name);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				rd->mblength = 0;
 				rd->rmd1_bits = LE_R1_OWN;
 				lp->rx_new = (lp->rx_new + 1) & lp->rx_ring_mod_mask;
@@ -328,8 +327,8 @@ static int lance_rx (struct net_device *dev)
 			skb->protocol = eth_type_trans (skb, dev);
 			netif_rx (skb);
 			dev->last_rx = jiffies;
-			lp->stats.rx_packets++;
-			lp->stats.rx_bytes += len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += len;
 		}
 
 		/* Return the packet to the pool */
@@ -364,12 +363,12 @@ static int lance_tx (struct net_device *dev)
 		if (td->tmd1_bits & LE_T1_ERR) {
 			status = td->misc;
 
-			lp->stats.tx_errors++;
-			if (status & LE_T3_RTY)  lp->stats.tx_aborted_errors++;
-			if (status & LE_T3_LCOL) lp->stats.tx_window_errors++;
+			dev->stats.tx_errors++;
+			if (status & LE_T3_RTY)  dev->stats.tx_aborted_errors++;
+			if (status & LE_T3_LCOL) dev->stats.tx_window_errors++;
 
 			if (status & LE_T3_CLOS) {
-				lp->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 				if (lp->auto_select) {
 					lp->tpe = 1 - lp->tpe;
 					printk(KERN_ERR "%s: Carrier Lost, "
@@ -388,7 +387,7 @@ static int lance_tx (struct net_device *dev)
 			/* buffer errors and underflows turn off the transmitter */
 			/* Restart the adapter */
 			if (status & (LE_T3_BUF|LE_T3_UFL)) {
-				lp->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 
 				printk(KERN_ERR "%s: Tx: ERR_BUF|ERR_UFL, "
 				       "restarting\n", dev->name);
@@ -408,13 +407,13 @@ static int lance_tx (struct net_device *dev)
 
 			/* One collision before packet was sent. */
 			if (td->tmd1_bits & LE_T1_EONE)
-				lp->stats.collisions++;
+				dev->stats.collisions++;
 
 			/* More than one collision, be optimistic. */
 			if (td->tmd1_bits & LE_T1_EMORE)
-				lp->stats.collisions += 2;
+				dev->stats.collisions += 2;
 
-			lp->stats.tx_packets++;
+			dev->stats.tx_packets++;
 		}
 
 		j = (j + 1) & lp->tx_ring_mod_mask;
@@ -459,9 +458,9 @@ static irqreturn_t lance_interrupt (int irq, void *dev_id)
 
 	/* Log misc errors. */
 	if (csr0 & LE_C0_BABL)
-		lp->stats.tx_errors++;       /* Tx babble. */
+		dev->stats.tx_errors++;       /* Tx babble. */
 	if (csr0 & LE_C0_MISS)
-		lp->stats.rx_errors++;       /* Missed a Rx frame. */
+		dev->stats.rx_errors++;       /* Missed a Rx frame. */
 	if (csr0 & LE_C0_MERR) {
 		printk(KERN_ERR "%s: Bus master arbitration failure, status "
 		       "%4.4x.\n", dev->name, csr0);
@@ -606,7 +605,7 @@ static int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	/* Now, give the packet to the lance */
 	ib->btx_ring [entry].tmd1_bits = (LE_T1_POK|LE_T1_OWN);
 	lp->tx_new = (lp->tx_new+1) & lp->tx_ring_mod_mask;
-	lp->stats.tx_bytes += skblen;
+	dev->stats.tx_bytes += skblen;
 
 	if (TX_BUFFS_AVAIL <= 0)
 		netif_stop_queue(dev);
@@ -621,13 +620,6 @@ static int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	return status;
 }
 
-static struct net_device_stats *lance_get_stats (struct net_device *dev)
-{
-	struct lance_private *lp = netdev_priv(dev);
-
-	return &lp->stats;
-}
-
 /* taken from the depca driver */
 static void lance_load_multicast (struct net_device *dev)
 {
@@ -783,7 +775,6 @@ static int __devinit a2065_init_one(struct zorro_dev *z,
 	dev->hard_start_xmit = &lance_start_xmit;
 	dev->tx_timeout = &lance_tx_timeout;
 	dev->watchdog_timeo = 5*HZ;
-	dev->get_stats = &lance_get_stats;
 	dev->set_multicast_list = &lance_set_multicast;
 	dev->dma = 0;
 
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index bed8e0e..bfac320 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -109,7 +109,6 @@ typedef unsigned char uchar;
 
 /* Information that need to be kept for each board. */
 struct net_local {
-	struct net_device_stats stats;
 	spinlock_t lock;
 	unsigned char mc_filter[8];
 	uint jumpered:1;			/* Set iff the board has jumper config. */
@@ -164,7 +163,6 @@ static int	net_send_packet(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t net_interrupt(int irq, void *dev_id);
 static void net_rx(struct net_device *dev);
 static int net_close(struct net_device *dev);
-static struct net_device_stats *net_get_stats(struct net_device *dev);
 static void set_rx_mode(struct net_device *dev);
 static void net_tx_timeout (struct net_device *dev);
 
@@ -458,7 +456,6 @@ found:
 	dev->open		= net_open;
 	dev->stop		= net_close;
 	dev->hard_start_xmit = net_send_packet;
-	dev->get_stats	= net_get_stats;
 	dev->set_multicast_list = &set_rx_mode;
 	dev->tx_timeout = net_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
@@ -573,7 +570,7 @@ static void net_tx_timeout (struct net_device *dev)
 	 dev->name, inw(ioaddr + TX_STATUS), inw(ioaddr + TX_INTR), inw(ioaddr + TX_MODE),
 		inw(ioaddr + CONFIG_0), inw(ioaddr + DATAPORT), inw(ioaddr + TX_START),
 		inw(ioaddr + MODE13 - 1), inw(ioaddr + RX_CTRL));
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	/* ToDo: We should try to restart the adaptor... */
 	outw(0xffff, ioaddr + MODE24);
 	outw (0xffff, ioaddr + TX_STATUS);
@@ -693,10 +690,10 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 				printk("%s: 16 Collision occur during Txing.\n", dev->name);
 			/* Cancel sending a packet. */
 			outb(0x03, ioaddr + COL16CNTL);
-			lp->stats.collisions++;
+			dev->stats.collisions++;
 		}
 		if (status & 0x82) {
-			lp->stats.tx_packets++;
+			dev->stats.tx_packets++;
 			/* The Tx queue has any packets and is not being
 			   transferred a packet from the host, start
 			   transmitting. */
@@ -721,7 +718,6 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 static void
 net_rx(struct net_device *dev)
 {
-	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int boguscount = 5;
 
@@ -740,11 +736,11 @@ net_rx(struct net_device *dev)
 #endif
 
 		if ((status & 0xF0) != 0x20) {	/* There was an error. */
-			lp->stats.rx_errors++;
-			if (status & 0x08) lp->stats.rx_length_errors++;
-			if (status & 0x04) lp->stats.rx_frame_errors++;
-			if (status & 0x02) lp->stats.rx_crc_errors++;
-			if (status & 0x01) lp->stats.rx_over_errors++;
+			dev->stats.rx_errors++;
+			if (status & 0x08) dev->stats.rx_length_errors++;
+			if (status & 0x04) dev->stats.rx_frame_errors++;
+			if (status & 0x02) dev->stats.rx_crc_errors++;
+			if (status & 0x01) dev->stats.rx_over_errors++;
 		} else {
 			/* Malloc up new buffer. */
 			struct sk_buff *skb;
@@ -755,7 +751,7 @@ net_rx(struct net_device *dev)
 				/* Prime the FIFO and then flush the packet. */
 				inw(ioaddr + DATAPORT); inw(ioaddr + DATAPORT);
 				outb(0x05, ioaddr + RX_CTRL);
-				lp->stats.rx_errors++;
+				dev->stats.rx_errors++;
 				break;
 			}
 			skb = dev_alloc_skb(pkt_len+3);
@@ -765,7 +761,7 @@ net_rx(struct net_device *dev)
 				/* Prime the FIFO and then flush the packet. */
 				inw(ioaddr + DATAPORT); inw(ioaddr + DATAPORT);
 				outb(0x05, ioaddr + RX_CTRL);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				break;
 			}
 			skb_reserve(skb,2);
@@ -774,8 +770,8 @@ net_rx(struct net_device *dev)
 			skb->protocol=eth_type_trans(skb, dev);
 			netif_rx(skb);
 			dev->last_rx = jiffies;
-			lp->stats.rx_packets++;
-			lp->stats.rx_bytes += pkt_len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_len;
 		}
 		if (--boguscount <= 0)
 			break;
@@ -824,17 +820,6 @@ static int net_close(struct net_device *dev)
 	return 0;
 }
 
-/* Get the current statistics.
-   This may be called with the card open or closed.
-   There are no on-chip counters, so this function is trivial.
-*/
-static struct net_device_stats *
-net_get_stats(struct net_device *dev)
-{
-	struct net_local *lp = netdev_priv(dev);
-	return &lp->stats;
-}
-
 /*
   Set the multicast/promiscuous mode for this adaptor.
 */
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index dfa8b9b..7da47f7 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -224,7 +224,6 @@ struct lance_private {
 	int			dirty_tx;		/* Ring entries to be freed. */
 				/* copy function */
 	void			*(*memcpy_f)( void *, const void *, size_t );
-	struct net_device_stats stats;
 /* This must be long for set_bit() */
 	long			tx_full;
 	spinlock_t		devlock;
@@ -347,7 +346,6 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev );
 static irqreturn_t lance_interrupt( int irq, void *dev_id );
 static int lance_rx( struct net_device *dev );
 static int lance_close( struct net_device *dev );
-static struct net_device_stats *lance_get_stats( struct net_device *dev );
 static void set_multicast_list( struct net_device *dev );
 static int lance_set_mac_address( struct net_device *dev, void *addr );
 static void lance_tx_timeout (struct net_device *dev);
@@ -632,7 +630,6 @@ static unsigned long __init lance_probe1( struct net_device *dev,
 	dev->open = &lance_open;
 	dev->hard_start_xmit = &lance_start_xmit;
 	dev->stop = &lance_close;
-	dev->get_stats = &lance_get_stats;
 	dev->set_multicast_list = &set_multicast_list;
 	dev->set_mac_address = &lance_set_mac_address;
 
@@ -640,13 +637,6 @@ static unsigned long __init lance_probe1( struct net_device *dev,
 	dev->tx_timeout = lance_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-
-#if 0
-	dev->start = 0;
-#endif
-
-	memset( &lp->stats, 0, sizeof(lp->stats) );
-
 	return( 1 );
 }
 
@@ -754,7 +744,7 @@ static void lance_tx_timeout (struct net_device *dev)
 	 * little endian mode.
 	 */
 	REGA( CSR3 ) = CSR3_BSWP | (lp->cardtype == PAM_CARD ? CSR3_ACON : 0);
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 #ifndef final_version
 		{	int i;
 			DPRINTK( 2, ( "Ring data: dirty_tx %d cur_tx %d%s cur_rx %d\n",
@@ -842,7 +832,7 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 	head->misc = 0;
 	lp->memcpy_f( PKTBUF_ADDR(head), (void *)skb->data, skb->len );
 	head->flag = TMD1_OWN_CHIP | TMD1_ENP | TMD1_STP;
-	lp->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 	dev_kfree_skb( skb );
 	lp->cur_tx++;
 	while( lp->cur_tx >= TX_RING_SIZE && lp->dirty_tx >= TX_RING_SIZE ) {
@@ -913,13 +903,13 @@ static irqreturn_t lance_interrupt( int irq, void *dev_id )
 				if (status & TMD1_ERR) {
 					/* There was an major error, log it. */
 					int err_status = MEM->tx_head[entry].misc;
-					lp->stats.tx_errors++;
-					if (err_status & TMD3_RTRY) lp->stats.tx_aborted_errors++;
-					if (err_status & TMD3_LCAR) lp->stats.tx_carrier_errors++;
-					if (err_status & TMD3_LCOL) lp->stats.tx_window_errors++;
+					dev->stats.tx_errors++;
+					if (err_status & TMD3_RTRY) dev->stats.tx_aborted_errors++;
+					if (err_status & TMD3_LCAR) dev->stats.tx_carrier_errors++;
+					if (err_status & TMD3_LCOL) dev->stats.tx_window_errors++;
 					if (err_status & TMD3_UFLO) {
 						/* Ackk!  On FIFO errors the Tx unit is turned off! */
-						lp->stats.tx_fifo_errors++;
+						dev->stats.tx_fifo_errors++;
 						/* Remove this verbosity later! */
 						DPRINTK( 1, ( "%s: Tx FIFO error! Status %04x\n",
 									  dev->name, csr0 ));
@@ -928,8 +918,8 @@ static irqreturn_t lance_interrupt( int irq, void *dev_id )
 					}
 				} else {
 					if (status & (TMD1_MORE | TMD1_ONE | TMD1_DEF))
-						lp->stats.collisions++;
-					lp->stats.tx_packets++;
+						dev->stats.collisions++;
+					dev->stats.tx_packets++;
 				}
 
 				/* XXX MSch: free skb?? */
@@ -956,8 +946,8 @@ static irqreturn_t lance_interrupt( int irq, void *dev_id )
 		}
 
 		/* Log misc errors. */
-		if (csr0 & CSR0_BABL) lp->stats.tx_errors++; /* Tx babble. */
-		if (csr0 & CSR0_MISS) lp->stats.rx_errors++; /* Missed a Rx frame. */
+		if (csr0 & CSR0_BABL) dev->stats.tx_errors++; /* Tx babble. */
+		if (csr0 & CSR0_MISS) dev->stats.rx_errors++; /* Missed a Rx frame. */
 		if (csr0 & CSR0_MERR) {
 			DPRINTK( 1, ( "%s: Bus master arbitration failure (?!?), "
 						  "status %04x.\n", dev->name, csr0 ));
@@ -998,11 +988,11 @@ static int lance_rx( struct net_device *dev )
 			   buffers it's possible for a jabber packet to use two
 			   buffers, with only the last correctly noting the error. */
 			if (status & RMD1_ENP)	/* Only count a general error at the */
-				lp->stats.rx_errors++; /* end of a packet.*/
-			if (status & RMD1_FRAM) lp->stats.rx_frame_errors++;
-			if (status & RMD1_OFLO) lp->stats.rx_over_errors++;
-			if (status & RMD1_CRC) lp->stats.rx_crc_errors++;
-			if (status & RMD1_BUFF) lp->stats.rx_fifo_errors++;
+				dev->stats.rx_errors++; /* end of a packet.*/
+			if (status & RMD1_FRAM) dev->stats.rx_frame_errors++;
+			if (status & RMD1_OFLO) dev->stats.rx_over_errors++;
+			if (status & RMD1_CRC) dev->stats.rx_crc_errors++;
+			if (status & RMD1_BUFF) dev->stats.rx_fifo_errors++;
 			head->flag &= (RMD1_ENP|RMD1_STP);
 		} else {
 			/* Malloc up new buffer, compatible with net-3. */
@@ -1011,7 +1001,7 @@ static int lance_rx( struct net_device *dev )
 
 			if (pkt_len < 60) {
 				printk( "%s: Runt packet!\n", dev->name );
-				lp->stats.rx_errors++;
+				dev->stats.rx_errors++;
 			}
 			else {
 				skb = dev_alloc_skb( pkt_len+2 );
@@ -1024,7 +1014,7 @@ static int lance_rx( struct net_device *dev )
 							break;
 
 					if (i > RX_RING_SIZE - 2) {
-						lp->stats.rx_dropped++;
+						dev->stats.rx_dropped++;
 						head->flag |= RMD1_OWN_CHIP;
 						lp->cur_rx++;
 					}
@@ -1053,8 +1043,8 @@ static int lance_rx( struct net_device *dev )
 				skb->protocol = eth_type_trans( skb, dev );
 				netif_rx( skb );
 				dev->last_rx = jiffies;
-				lp->stats.rx_packets++;
-				lp->stats.rx_bytes += pkt_len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += pkt_len;
 			}
 		}
 
@@ -1091,14 +1081,6 @@ static int lance_close( struct net_device *dev )
 }
 
 
-static struct net_device_stats *lance_get_stats( struct net_device *dev )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
-
-	return &lp->stats;
-}
-
-
 /* Set or clear the multicast filter for this adaptor.
    num_addrs == -1		Promiscuous mode, receive all packets
    num_addrs == 0		Normal mode, clear multicast list
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 82d78ff..44b7a88 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -171,7 +171,6 @@ static char mux_8012[] = { 0xff, 0xf7, 0xff, 0xfb, 0xf3, 0xfb, 0xff, 0xf7,};
 struct net_local {
     spinlock_t lock;
     struct net_device *next_module;
-    struct net_device_stats stats;
     struct timer_list timer;	/* Media selection timer. */
     long last_rx_time;		/* Last Rx, in jiffies, to handle Rx hang. */
     int saved_tx_size;
@@ -205,7 +204,6 @@ static irqreturn_t atp_interrupt(int irq, void *dev_id);
 static void net_rx(struct net_device *dev);
 static void read_block(long ioaddr, int length, unsigned char *buffer, int data_mode);
 static int net_close(struct net_device *dev);
-static struct net_device_stats *net_get_stats(struct net_device *dev);
 static void set_rx_mode_8002(struct net_device *dev);
 static void set_rx_mode_8012(struct net_device *dev);
 static void tx_timeout(struct net_device *dev);
@@ -349,7 +347,6 @@ static int __init atp_probe1(long ioaddr)
 	dev->open		= net_open;
 	dev->stop		= net_close;
 	dev->hard_start_xmit	= atp_send_packet;
-	dev->get_stats		= net_get_stats;
 	dev->set_multicast_list =
 	  lp->chip_type == RTL8002 ? &set_rx_mode_8002 : &set_rx_mode_8012;
 	dev->tx_timeout		= tx_timeout;
@@ -539,18 +536,17 @@ static void write_packet(long ioaddr, int length, unsigned char *packet, int pad
 
 static void tx_timeout(struct net_device *dev)
 {
-	struct net_local *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	printk(KERN_WARNING "%s: Transmit timed out, %s?\n", dev->name,
 		   inb(ioaddr + PAR_CONTROL) & 0x10 ? "network cable problem"
 		   :  "IRQ conflict");
-	np->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	/* Try to restart the adapter. */
 	hardware_init(dev);
 	dev->trans_start = jiffies;
 	netif_wake_queue(dev);
-	np->stats.tx_errors++;
+	dev->stats.tx_errors++;
 }
 
 static int atp_send_packet(struct sk_buff *skb, struct net_device *dev)
@@ -630,7 +626,7 @@ static irqreturn_t atp_interrupt(int irq, void *dev_instance)
 				/* We acknowledged the normal Rx interrupt, so if the interrupt
 				   is still outstanding we must have a Rx error. */
 				if (read_status & (CMR1_IRQ << 3)) { /* Overrun. */
-					lp->stats.rx_over_errors++;
+					dev->stats.rx_over_errors++;
 					/* Set to no-accept mode long enough to remove a packet. */
 					write_reg_high(ioaddr, CMR2, CMR2h_OFF);
 					net_rx(dev);
@@ -650,9 +646,9 @@ static irqreturn_t atp_interrupt(int irq, void *dev_instance)
 			   and reinitialize the adapter. */
 			write_reg(ioaddr, ISR, ISR_TxErr + ISR_TxOK);
 			if (status & (ISR_TxErr<<3)) {
-				lp->stats.collisions++;
+				dev->stats.collisions++;
 				if (++lp->re_tx > 15) {
-					lp->stats.tx_aborted_errors++;
+					dev->stats.tx_aborted_errors++;
 					hardware_init(dev);
 					break;
 				}
@@ -661,7 +657,7 @@ static irqreturn_t atp_interrupt(int irq, void *dev_instance)
 				write_reg(ioaddr, CMR1, CMR1_ReXmit + CMR1_Xmit);
 			} else {
 				/* Finish up the transmit. */
-				lp->stats.tx_packets++;
+				dev->stats.tx_packets++;
 				lp->pac_cnt_in_tx_buf--;
 				if ( lp->saved_tx_size) {
 					trigger_send(ioaddr, lp->saved_tx_size);
@@ -679,7 +675,7 @@ static irqreturn_t atp_interrupt(int irq, void *dev_instance)
 					   "%ld jiffies status %02x  CMR1 %02x.\n", dev->name,
 					   num_tx_since_rx, jiffies - dev->last_rx, status,
 					   (read_nibble(ioaddr, CMR1) >> 3) & 15);
-			lp->stats.rx_missed_errors++;
+			dev->stats.rx_missed_errors++;
 			hardware_init(dev);
 			num_tx_since_rx = 0;
 			break;
@@ -736,13 +732,13 @@ static void atp_timed_checker(unsigned long data)
 			struct net_local *lp = netdev_priv(atp_timed_dev);
 			write_reg_byte(ioaddr, PAR0 + i, atp_timed_dev->dev_addr[i]);
 			if (i == 2)
-			  lp->stats.tx_errors++;
+			  dev->stats.tx_errors++;
 			else if (i == 3)
-			  lp->stats.tx_dropped++;
+			  dev->stats.tx_dropped++;
 			else if (i == 4)
-			  lp->stats.collisions++;
+			  dev->stats.collisions++;
 			else
-			  lp->stats.rx_errors++;
+			  dev->stats.rx_errors++;
 		  }
 #endif
 	}
@@ -766,14 +762,14 @@ static void net_rx(struct net_device *dev)
 		printk(KERN_DEBUG " rx_count %04x %04x %04x %04x..", rx_head.pad,
 			   rx_head.rx_count, rx_head.rx_status, rx_head.cur_addr);
 	if ((rx_head.rx_status & 0x77) != 0x01) {
-		lp->stats.rx_errors++;
-		if (rx_head.rx_status & 0x0004) lp->stats.rx_frame_errors++;
-		else if (rx_head.rx_status & 0x0002) lp->stats.rx_crc_errors++;
+		dev->stats.rx_errors++;
+		if (rx_head.rx_status & 0x0004) dev->stats.rx_frame_errors++;
+		else if (rx_head.rx_status & 0x0002) dev->stats.rx_crc_errors++;
 		if (net_debug > 3)
 			printk(KERN_DEBUG "%s: Unknown ATP Rx error %04x.\n",
 				   dev->name, rx_head.rx_status);
 		if  (rx_head.rx_status & 0x0020) {
-			lp->stats.rx_fifo_errors++;
+			dev->stats.rx_fifo_errors++;
 			write_reg_high(ioaddr, CMR1, CMR1h_TxENABLE);
 			write_reg_high(ioaddr, CMR1, CMR1h_RxENABLE | CMR1h_TxENABLE);
 		} else if (rx_head.rx_status & 0x0050)
@@ -788,7 +784,7 @@ static void net_rx(struct net_device *dev)
 		if (skb == NULL) {
 			printk(KERN_ERR "%s: Memory squeeze, dropping packet.\n",
 				   dev->name);
-			lp->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			goto done;
 		}
 
@@ -797,8 +793,8 @@ static void net_rx(struct net_device *dev)
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
 		dev->last_rx = jiffies;
-		lp->stats.rx_packets++;
-		lp->stats.rx_bytes += pkt_len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += pkt_len;
 	}
  done:
 	write_reg(ioaddr, CMR1, CMR1_NextPkt);
@@ -850,15 +846,6 @@ net_close(struct net_device *dev)
 	return 0;
 }
 
-/* Get the current statistics.	This may be called with the card open or
-   closed. */
-static struct net_device_stats *
-net_get_stats(struct net_device *dev)
-{
-	struct net_local *lp = netdev_priv(dev);
-	return &lp->stats;
-}
-
 /*
  *	Set or clear the multicast filter for this adapter.
  */
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index e86b369..b46c5d8 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -90,7 +90,6 @@ static int au1000_rx(struct net_device *);
 static irqreturn_t au1000_interrupt(int, void *);
 static void au1000_tx_timeout(struct net_device *);
 static void set_rx_mode(struct net_device *);
-static struct net_device_stats *au1000_get_stats(struct net_device *);
 static int au1000_ioctl(struct net_device *, struct ifreq *, int);
 static int mdio_read(struct net_device *, int, int);
 static void mdio_write(struct net_device *, int, int, u16);
@@ -772,7 +771,6 @@ static struct net_device * au1000_probe(int port_num)
 	dev->open = au1000_open;
 	dev->hard_start_xmit = au1000_tx;
 	dev->stop = au1000_close;
-	dev->get_stats = au1000_get_stats;
 	dev->set_multicast_list = &set_rx_mode;
 	dev->do_ioctl = &au1000_ioctl;
 	SET_ETHTOOL_OPS(dev, &au1000_ethtool_ops);
@@ -1038,7 +1036,7 @@ static void __exit au1000_cleanup_module(void)
 static void update_tx_stats(struct net_device *dev, u32 status)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
-	struct net_device_stats *ps = &aup->stats;
+	struct net_device_stats *ps = &dev->stats;
 
 	if (status & TX_FRAME_ABORTED) {
 		if (!aup->phy_dev || (DUPLEX_FULL == aup->phy_dev->duplex)) {
@@ -1094,7 +1092,7 @@ static void au1000_tx_ack(struct net_device *dev)
 static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
-	struct net_device_stats *ps = &aup->stats;
+	struct net_device_stats *ps = &dev->stats;
 	volatile tx_dma_t *ptxd;
 	u32 buff_stat;
 	db_dest_t *pDB;
@@ -1148,7 +1146,7 @@ static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
 static inline void update_rx_stats(struct net_device *dev, u32 status)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
-	struct net_device_stats *ps = &aup->stats;
+	struct net_device_stats *ps = &dev->stats;
 
 	ps->rx_packets++;
 	if (status & RX_MCAST_FRAME)
@@ -1201,7 +1199,7 @@ static int au1000_rx(struct net_device *dev)
 				printk(KERN_ERR
 				       "%s: Memory squeeze, dropping packet.\n",
 				       dev->name);
-				aup->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				continue;
 			}
 			skb_reserve(skb, 2);	/* 16 byte IP header align */
@@ -1324,18 +1322,5 @@ static int au1000_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return phy_mii_ioctl(aup->phy_dev, if_mii(rq), cmd);
 }
 
-static struct net_device_stats *au1000_get_stats(struct net_device *dev)
-{
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
-
-	if (au1000_debug > 4)
-		printk("%s: au1000_get_stats: dev=%p\n", dev->name, dev);
-
-	if (netif_device_present(dev)) {
-		return &aup->stats;
-	}
-	return 0;
-}
-
 module_init(au1000_init_module);
 module_exit(au1000_cleanup_module);
diff --git a/drivers/net/au1000_eth.h b/drivers/net/au1000_eth.h
index 52fe00d..f3baeaa 100644
--- a/drivers/net/au1000_eth.h
+++ b/drivers/net/au1000_eth.h
@@ -115,6 +115,5 @@ struct au1000_private {
 	u32 vaddr;                /* virtual address of rx/tx buffers   */
 	dma_addr_t dma_addr;      /* dma address of rx/tx buffers       */
 
-	struct net_device_stats stats;
 	spinlock_t lock;       /* Serialise access to device */
 };
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 3354c53..0788d1c 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -579,8 +579,8 @@ out:
 	adjust_tx_list();
 	current_tx_ptr = current_tx_ptr->next;
 	dev->trans_start = jiffies;
-	lp->stats.tx_packets++;
-	lp->stats.tx_bytes += (skb->len);
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += (skb->len);
 	return 0;
 }
 
@@ -596,7 +596,7 @@ static void bf537mac_rx(struct net_device *dev)
 	if (!new_skb) {
 		printk(KERN_NOTICE DRV_NAME
 		       ": rx: low on mem - packet dropped\n");
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		goto out;
 	}
 	/* reserve 2 bytes for RXDWA padding */
@@ -618,8 +618,8 @@ static void bf537mac_rx(struct net_device *dev)
 #endif
 
 	netif_rx(skb);
-	lp->stats.rx_packets++;
-	lp->stats.rx_bytes += len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += len;
 	current_rx_ptr->status.status_word = 0x00000000;
 	current_rx_ptr = current_rx_ptr->next;
 
@@ -733,20 +733,6 @@ static void bf537mac_timeout(struct net_device *dev)
 }
 
 /*
- * Get the current statistics.
- * This may be called with the card open or closed.
- */
-static struct net_device_stats *bf537mac_query_statistics(struct net_device
-							  *dev)
-{
-	struct bf537mac_local *lp = netdev_priv(dev);
-
-	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
-
-	return &lp->stats;
-}
-
-/*
  * This routine will, depending on the values passed to it,
  * either make it accept multicast packets, go into
  * promiscuous mode (for TCPDUMP and cousins) or accept
@@ -891,7 +877,6 @@ static int __init bf537mac_probe(struct net_device *dev)
 	dev->stop = bf537mac_close;
 	dev->hard_start_xmit = bf537mac_hard_start_xmit;
 	dev->tx_timeout = bf537mac_timeout;
-	dev->get_stats = bf537mac_query_statistics;
 	dev->set_multicast_list = bf537mac_set_multicast_list;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = bf537mac_poll;
diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
index af87189..b827246 100644
--- a/drivers/net/bfin_mac.h
+++ b/drivers/net/bfin_mac.h
@@ -104,8 +104,6 @@ struct bf537mac_local {
 	 * can find out semi-useless statistics of how well the card is
 	 * performing
 	 */
-	struct net_device_stats stats;
-
 	int version;
 
 	int FlowEnabled;	/* record if data flow is active */
diff --git a/drivers/net/bmac.c b/drivers/net/bmac.c
index 1eb95b6..43237e7 100644
--- a/drivers/net/bmac.c
+++ b/drivers/net/bmac.c
@@ -75,7 +75,6 @@ struct bmac_data {
 	int tx_fill;
 	int tx_empty;
 	unsigned char tx_fullup;
-	struct net_device_stats stats;
 	struct timer_list tx_timeout;
 	int timeout_active;
 	int sleeping;
@@ -145,7 +144,6 @@ static unsigned char *bmac_emergency_rxbuf;
 static int bmac_open(struct net_device *dev);
 static int bmac_close(struct net_device *dev);
 static int bmac_transmit_packet(struct sk_buff *skb, struct net_device *dev);
-static struct net_device_stats *bmac_stats(struct net_device *dev);
 static void bmac_set_multicast(struct net_device *dev);
 static void bmac_reset_and_enable(struct net_device *dev);
 static void bmac_start_chip(struct net_device *dev);
@@ -668,7 +666,7 @@ static int bmac_transmit_packet(struct sk_buff *skb, struct net_device *dev)
 	bp->tx_bufs[bp->tx_fill] = skb;
 	bp->tx_fill = i;
 
-	bp->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 
 	dbdma_continue(td);
 
@@ -707,8 +705,8 @@ static irqreturn_t bmac_rxdma_intr(int irq, void *dev_id)
 		nb = RX_BUFLEN - residual - 2;
 		if (nb < (ETHERMINPACKET - ETHERCRC)) {
 			skb = NULL;
-			bp->stats.rx_length_errors++;
-			bp->stats.rx_errors++;
+			dev->stats.rx_length_errors++;
+			dev->stats.rx_errors++;
 		} else {
 			skb = bp->rx_bufs[i];
 			bp->rx_bufs[i] = NULL;
@@ -719,10 +717,10 @@ static irqreturn_t bmac_rxdma_intr(int irq, void *dev_id)
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
 			dev->last_rx = jiffies;
-			++bp->stats.rx_packets;
-			bp->stats.rx_bytes += nb;
+			++dev->stats.rx_packets;
+			dev->stats.rx_bytes += nb;
 		} else {
-			++bp->stats.rx_dropped;
+			++dev->stats.rx_dropped;
 		}
 		dev->last_rx = jiffies;
 		if ((skb = bp->rx_bufs[i]) == NULL) {
@@ -785,7 +783,7 @@ static irqreturn_t bmac_txdma_intr(int irq, void *dev_id)
 		}
 
 		if (bp->tx_bufs[bp->tx_empty]) {
-			++bp->stats.tx_packets;
+			++dev->stats.tx_packets;
 			dev_kfree_skb_irq(bp->tx_bufs[bp->tx_empty]);
 		}
 		bp->tx_bufs[bp->tx_empty] = NULL;
@@ -807,13 +805,6 @@ static irqreturn_t bmac_txdma_intr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static struct net_device_stats *bmac_stats(struct net_device *dev)
-{
-	struct bmac_data *p = netdev_priv(dev);
-
-	return &p->stats;
-}
-
 #ifndef SUNHME_MULTICAST
 /* Real fast bit-reversal algorithm, 6-bit values */
 static int reverse6[64] = {
@@ -1080,17 +1071,17 @@ static irqreturn_t bmac_misc_intr(int irq, void *dev_id)
 	}
 	/* XXDEBUG(("bmac_misc_intr, status=%#08x\n", status)); */
 	/*     bmac_txdma_intr_inner(irq, dev_id); */
-	/*   if (status & FrameReceived) bp->stats.rx_dropped++; */
-	if (status & RxErrorMask) bp->stats.rx_errors++;
-	if (status & RxCRCCntExp) bp->stats.rx_crc_errors++;
-	if (status & RxLenCntExp) bp->stats.rx_length_errors++;
-	if (status & RxOverFlow) bp->stats.rx_over_errors++;
-	if (status & RxAlignCntExp) bp->stats.rx_frame_errors++;
-
-	/*   if (status & FrameSent) bp->stats.tx_dropped++; */
-	if (status & TxErrorMask) bp->stats.tx_errors++;
-	if (status & TxUnderrun) bp->stats.tx_fifo_errors++;
-	if (status & TxNormalCollExp) bp->stats.collisions++;
+	/*   if (status & FrameReceived) dev->stats.rx_dropped++; */
+	if (status & RxErrorMask) dev->stats.rx_errors++;
+	if (status & RxCRCCntExp) dev->stats.rx_crc_errors++;
+	if (status & RxLenCntExp) dev->stats.rx_length_errors++;
+	if (status & RxOverFlow) dev->stats.rx_over_errors++;
+	if (status & RxAlignCntExp) dev->stats.rx_frame_errors++;
+
+	/*   if (status & FrameSent) dev->stats.tx_dropped++; */
+	if (status & TxErrorMask) dev->stats.tx_errors++;
+	if (status & TxUnderrun) dev->stats.tx_fifo_errors++;
+	if (status & TxNormalCollExp) dev->stats.collisions++;
 	return IRQ_HANDLED;
 }
 
@@ -1325,7 +1316,6 @@ static int __devinit bmac_probe(struct macio_dev *mdev, const struct of_device_i
 	dev->stop = bmac_close;
 	dev->ethtool_ops = &bmac_ethtool_ops;
 	dev->hard_start_xmit = bmac_output;
-	dev->get_stats = bmac_stats;
 	dev->set_multicast_list = bmac_set_multicast;
 	dev->set_mac_address = bmac_set_address;
 
@@ -1543,7 +1533,7 @@ static void bmac_tx_timeout(unsigned long data)
 	XXDEBUG((KERN_DEBUG "bmac: tx empty=%d fill=%d fullup=%d\n",
 		 bp->tx_empty, bp->tx_fill, bp->tx_fullup));
 	i = bp->tx_empty;
-	++bp->stats.tx_errors;
+	++dev->stats.tx_errors;
 	if (i != bp->tx_fill) {
 		dev_kfree_skb(bp->tx_bufs[i]);
 		bp->tx_bufs[i] = NULL;
diff --git a/drivers/net/de600.c b/drivers/net/de600.c
index dae97b8..dff8829 100644
--- a/drivers/net/de600.c
+++ b/drivers/net/de600.c
@@ -154,11 +154,6 @@ static int de600_close(struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *get_stats(struct net_device *dev)
-{
-	return (struct net_device_stats *)(dev->priv);
-}
-
 static inline void trigger_interrupt(struct net_device *dev)
 {
 	de600_put_command(FLIP_IRQ);
@@ -308,7 +303,7 @@ static int de600_tx_intr(struct net_device *dev, int irq_status)
 	if (!(irq_status & TX_FAILED16)) {
 		tx_fifo_out = (tx_fifo_out + 1) % TX_PAGES;
 		++free_tx_pages;
-		((struct net_device_stats *)(dev->priv))->tx_packets++;
+		dev->stats.tx_packets++;
 		netif_wake_queue(dev);
 	}
 
@@ -375,8 +370,8 @@ static void de600_rx_intr(struct net_device *dev)
 
 	/* update stats */
 	dev->last_rx = jiffies;
-	((struct net_device_stats *)(dev->priv))->rx_packets++; /* count all receives */
-	((struct net_device_stats *)(dev->priv))->rx_bytes += size; /* count all received bytes */
+	dev->stats.rx_packets++; /* count all receives */
+	dev->stats.rx_bytes += size; /* count all received bytes */
 
 	/*
 	 * If any worth-while packets have been received, netif_rx()
@@ -390,7 +385,7 @@ static struct net_device * __init de600_probe(void)
 	struct net_device *dev;
 	int err;
 
-	dev = alloc_etherdev(sizeof(struct net_device_stats));
+	dev = alloc_etherdev(0);
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
@@ -449,8 +444,6 @@ static struct net_device * __init de600_probe(void)
 		printk(":%02X",dev->dev_addr[i]);
 	printk("\n");
 
-	dev->get_stats = get_stats;
-
 	dev->open = de600_open;
 	dev->stop = de600_close;
 	dev->hard_start_xmit = &de600_start_xmit;
diff --git a/drivers/net/de600.h b/drivers/net/de600.h
index 1288e48..e80ecba 100644
--- a/drivers/net/de600.h
+++ b/drivers/net/de600.h
@@ -121,7 +121,6 @@ static u8	de600_read_byte(unsigned char type, struct net_device *dev);
 /* Put in the device structure. */
 static int	de600_open(struct net_device *dev);
 static int	de600_close(struct net_device *dev);
-static struct net_device_stats *get_stats(struct net_device *dev);
 static int	de600_start_xmit(struct sk_buff *skb, struct net_device *dev);
 
 /* Dispatch from interrupts. */
diff --git a/drivers/net/de620.c b/drivers/net/de620.c
index dc48924..f7497c0 100644
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -216,7 +216,6 @@ MODULE_PARM_DESC(de620_debug, "DE-620 debug level (0-2)");
 /* Put in the device structure. */
 static int	de620_open(struct net_device *);
 static int	de620_close(struct net_device *);
-static struct	net_device_stats *get_stats(struct net_device *);
 static void	de620_set_multicast_list(struct net_device *);
 static int	de620_start_xmit(struct sk_buff *, struct net_device *);
 
@@ -480,16 +479,6 @@ static int de620_close(struct net_device *dev)
 
 /*********************************************
  *
- * Return current statistics
- *
- */
-static struct net_device_stats *get_stats(struct net_device *dev)
-{
-	return (struct net_device_stats *)(dev->priv);
-}
-
-/*********************************************
- *
  * Set or clear the multicast filter for this adaptor.
  * (no real multicast implemented for the DE-620, but she can be promiscuous...)
  *
@@ -579,7 +568,7 @@ static int de620_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if(!(using_txbuf == (TXBF0 | TXBF1)))
 		netif_wake_queue(dev);
 
-	((struct net_device_stats *)(dev->priv))->tx_packets++;
+	dev->stats.tx_packets++;
 	spin_unlock_irqrestore(&de620_lock, flags);
 	dev_kfree_skb (skb);
 	return 0;
@@ -660,7 +649,7 @@ static int de620_rx_intr(struct net_device *dev)
 		/* You win some, you lose some. And sometimes plenty... */
 		adapter_init(dev);
 		netif_wake_queue(dev);
-		((struct net_device_stats *)(dev->priv))->rx_over_errors++;
+		dev->stats.rx_over_errors++;
 		return 0;
 	}
 
@@ -680,7 +669,7 @@ static int de620_rx_intr(struct net_device *dev)
 		next_rx_page = header_buf.Rx_NextPage; /* at least a try... */
 		de620_send_command(dev, W_DUMMY);
 		de620_set_register(dev, W_NPRF, next_rx_page);
-		((struct net_device_stats *)(dev->priv))->rx_over_errors++;
+		dev->stats.rx_over_errors++;
 		return 0;
 	}
 	next_rx_page = pagelink;
@@ -693,7 +682,7 @@ static int de620_rx_intr(struct net_device *dev)
 		skb = dev_alloc_skb(size+2);
 		if (skb == NULL) { /* Yeah, but no place to put it... */
 			printk(KERN_WARNING "%s: Couldn't allocate a sk_buff of size %d.\n", dev->name, size);
-			((struct net_device_stats *)(dev->priv))->rx_dropped++;
+			dev->stats.rx_dropped++;
 		}
 		else { /* Yep! Go get it! */
 			skb_reserve(skb,2);	/* Align */
@@ -706,8 +695,8 @@ static int de620_rx_intr(struct net_device *dev)
 			netif_rx(skb); /* deliver it "upstairs" */
 			dev->last_rx = jiffies;
 			/* count all receives */
-			((struct net_device_stats *)(dev->priv))->rx_packets++;
-			((struct net_device_stats *)(dev->priv))->rx_bytes += size;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += size;
 		}
 	}
 
@@ -819,7 +808,7 @@ struct net_device * __init de620_probe(int unit)
 	int err = -ENOMEM;
 	int i;
 
-	dev = alloc_etherdev(sizeof(struct net_device_stats));
+	dev = alloc_etherdev(0);
 	if (!dev)
 		goto out;
 
@@ -881,7 +870,6 @@ struct net_device * __init de620_probe(int unit)
 	else
 		printk(" UTP)\n");
 
-	dev->get_stats 		= get_stats;
 	dev->open 		= de620_open;
 	dev->stop 		= de620_close;
 	dev->hard_start_xmit 	= de620_start_xmit;
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index b2577f4..7e7ac33 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -258,8 +258,6 @@ struct lance_private {
 	int rx_new, tx_new;
 	int rx_old, tx_old;
 
-	struct net_device_stats stats;
-
 	unsigned short busmaster_regval;
 
 	struct timer_list       multicast_timer;
@@ -583,22 +581,22 @@ static int lance_rx(struct net_device *dev)
 
 		/* We got an incomplete frame? */
 		if ((bits & LE_R1_POK) != LE_R1_POK) {
-			lp->stats.rx_over_errors++;
-			lp->stats.rx_errors++;
+			dev->stats.rx_over_errors++;
+			dev->stats.rx_errors++;
 		} else if (bits & LE_R1_ERR) {
 			/* Count only the end frame as a rx error,
 			 * not the beginning
 			 */
 			if (bits & LE_R1_BUF)
-				lp->stats.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 			if (bits & LE_R1_CRC)
-				lp->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 			if (bits & LE_R1_OFL)
-				lp->stats.rx_over_errors++;
+				dev->stats.rx_over_errors++;
 			if (bits & LE_R1_FRA)
-				lp->stats.rx_frame_errors++;
+				dev->stats.rx_frame_errors++;
 			if (bits & LE_R1_EOP)
-				lp->stats.rx_errors++;
+				dev->stats.rx_errors++;
 		} else {
 			len = (*rds_ptr(rd, mblength, lp->type) & 0xfff) - 4;
 			skb = dev_alloc_skb(len + 2);
@@ -606,7 +604,7 @@ static int lance_rx(struct net_device *dev)
 			if (skb == 0) {
 				printk("%s: Memory squeeze, deferring packet.\n",
 				       dev->name);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				*rds_ptr(rd, mblength, lp->type) = 0;
 				*rds_ptr(rd, rmd1, lp->type) =
 					((lp->rx_buf_ptr_lnc[entry] >> 16) &
@@ -614,7 +612,7 @@ static int lance_rx(struct net_device *dev)
 				lp->rx_new = (entry + 1) & RX_RING_MOD_MASK;
 				return 0;
 			}
-			lp->stats.rx_bytes += len;
+			dev->stats.rx_bytes += len;
 
 			skb_reserve(skb, 2);	/* 16 byte align */
 			skb_put(skb, len);	/* make room */
@@ -625,7 +623,7 @@ static int lance_rx(struct net_device *dev)
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
 			dev->last_rx = jiffies;
-			lp->stats.rx_packets++;
+			dev->stats.rx_packets++;
 		}
 
 		/* Return the packet to the pool */
@@ -660,14 +658,14 @@ static void lance_tx(struct net_device *dev)
 		if (*tds_ptr(td, tmd1, lp->type) & LE_T1_ERR) {
 			status = *tds_ptr(td, misc, lp->type);
 
-			lp->stats.tx_errors++;
+			dev->stats.tx_errors++;
 			if (status & LE_T3_RTY)
-				lp->stats.tx_aborted_errors++;
+				dev->stats.tx_aborted_errors++;
 			if (status & LE_T3_LCOL)
-				lp->stats.tx_window_errors++;
+				dev->stats.tx_window_errors++;
 
 			if (status & LE_T3_CLOS) {
-				lp->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 				printk("%s: Carrier Lost\n", dev->name);
 				/* Stop the lance */
 				writereg(&ll->rap, LE_CSR0);
@@ -681,7 +679,7 @@ static void lance_tx(struct net_device *dev)
 			 * transmitter, restart the adapter.
 			 */
 			if (status & (LE_T3_BUF | LE_T3_UFL)) {
-				lp->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 
 				printk("%s: Tx: ERR_BUF|ERR_UFL, restarting\n",
 				       dev->name);
@@ -702,13 +700,13 @@ static void lance_tx(struct net_device *dev)
 
 			/* One collision before packet was sent. */
 			if (*tds_ptr(td, tmd1, lp->type) & LE_T1_EONE)
-				lp->stats.collisions++;
+				dev->stats.collisions++;
 
 			/* More than one collision, be optimistic. */
 			if (*tds_ptr(td, tmd1, lp->type) & LE_T1_EMORE)
-				lp->stats.collisions += 2;
+				dev->stats.collisions += 2;
 
-			lp->stats.tx_packets++;
+			dev->stats.tx_packets++;
 		}
 		j = (j + 1) & TX_RING_MOD_MASK;
 	}
@@ -754,10 +752,10 @@ static irqreturn_t lance_interrupt(const int irq, void *dev_id)
 		lance_tx(dev);
 
 	if (csr0 & LE_C0_BABL)
-		lp->stats.tx_errors++;
+		dev->stats.tx_errors++;
 
 	if (csr0 & LE_C0_MISS)
-		lp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 
 	if (csr0 & LE_C0_MERR) {
 		printk("%s: Memory error, status %04x\n", dev->name, csr0);
@@ -912,7 +910,7 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		len = ETH_ZLEN;
 	}
 
-	lp->stats.tx_bytes += len;
+	dev->stats.tx_bytes += len;
 
 	entry = lp->tx_new;
 	*lib_ptr(ib, btx_ring[entry].length, lp->type) = (-len);
@@ -938,13 +936,6 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
  	return 0;
 }
 
-static struct net_device_stats *lance_get_stats(struct net_device *dev)
-{
-	struct lance_private *lp = netdev_priv(dev);
-
-	return &lp->stats;
-}
-
 static void lance_load_multicast(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
@@ -1244,7 +1235,6 @@ static int __init dec_lance_probe(struct device *bdev, const int type)
 	dev->hard_start_xmit = &lance_start_xmit;
 	dev->tx_timeout = &lance_tx_timeout;
 	dev->watchdog_timeo = 5*HZ;
-	dev->get_stats = &lance_get_stats;
 	dev->set_multicast_list = &lance_set_multicast;
 
 	/* lp->ll is the location of the registers for lance card */
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 1834970..28fa2bd 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -485,7 +485,6 @@ struct depca_private {
 /* Kernel-only (not device) fields */
 	int rx_new, tx_new;	/* The next free ring entry               */
 	int rx_old, tx_old;	/* The ring entries to be free()ed.       */
-	struct net_device_stats stats;
 	spinlock_t lock;
 	struct {		/* Private stats counters                 */
 		u32 bins[DEPCA_PKT_STAT_SZ];
@@ -522,7 +521,6 @@ static irqreturn_t depca_interrupt(int irq, void *dev_id);
 static int depca_close(struct net_device *dev);
 static int depca_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static void depca_tx_timeout(struct net_device *dev);
-static struct net_device_stats *depca_get_stats(struct net_device *dev);
 static void set_multicast_list(struct net_device *dev);
 
 /*
@@ -801,7 +799,6 @@ static int __init depca_hw_init (struct net_device *dev, struct device *device)
 	dev->open = &depca_open;
 	dev->hard_start_xmit = &depca_start_xmit;
 	dev->stop = &depca_close;
-	dev->get_stats = &depca_get_stats;
 	dev->set_multicast_list = &set_multicast_list;
 	dev->do_ioctl = &depca_ioctl;
 	dev->tx_timeout = depca_tx_timeout;
@@ -1026,15 +1023,15 @@ static int depca_rx(struct net_device *dev)
 		}
 		if (status & R_ENP) {	/* Valid frame status */
 			if (status & R_ERR) {	/* There was an error. */
-				lp->stats.rx_errors++;	/* Update the error stats. */
+				dev->stats.rx_errors++;	/* Update the error stats. */
 				if (status & R_FRAM)
-					lp->stats.rx_frame_errors++;
+					dev->stats.rx_frame_errors++;
 				if (status & R_OFLO)
-					lp->stats.rx_over_errors++;
+					dev->stats.rx_over_errors++;
 				if (status & R_CRC)
-					lp->stats.rx_crc_errors++;
+					dev->stats.rx_crc_errors++;
 				if (status & R_BUFF)
-					lp->stats.rx_fifo_errors++;
+					dev->stats.rx_fifo_errors++;
 			} else {
 				short len, pkt_len = readw(&lp->rx_ring[entry].msg_length) - 4;
 				struct sk_buff *skb;
@@ -1063,8 +1060,8 @@ static int depca_rx(struct net_device *dev)
 					   ** Update stats
 					 */
 					dev->last_rx = jiffies;
-					lp->stats.rx_packets++;
-					lp->stats.rx_bytes += pkt_len;
+					dev->stats.rx_packets++;
+					dev->stats.rx_bytes += pkt_len;
 					for (i = 1; i < DEPCA_PKT_STAT_SZ - 1; i++) {
 						if (pkt_len < (i * DEPCA_PKT_BIN_SZ)) {
 							lp->pktStats.bins[i]++;
@@ -1087,7 +1084,7 @@ static int depca_rx(struct net_device *dev)
 					}
 				} else {
 					printk("%s: Memory squeeze, deferring packet.\n", dev->name);
-					lp->stats.rx_dropped++;	/* Really, deferred. */
+					dev->stats.rx_dropped++;	/* Really, deferred. */
 					break;
 				}
 			}
@@ -1125,24 +1122,24 @@ static int depca_tx(struct net_device *dev)
 			break;
 		} else if (status & T_ERR) {	/* An error occurred. */
 			status = readl(&lp->tx_ring[entry].misc);
-			lp->stats.tx_errors++;
+			dev->stats.tx_errors++;
 			if (status & TMD3_RTRY)
-				lp->stats.tx_aborted_errors++;
+				dev->stats.tx_aborted_errors++;
 			if (status & TMD3_LCAR)
-				lp->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 			if (status & TMD3_LCOL)
-				lp->stats.tx_window_errors++;
+				dev->stats.tx_window_errors++;
 			if (status & TMD3_UFLO)
-				lp->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 			if (status & (TMD3_BUFF | TMD3_UFLO)) {
 				/* Trigger an immediate send demand. */
 				outw(CSR0, DEPCA_ADDR);
 				outw(INEA | TDMD, DEPCA_DATA);
 			}
 		} else if (status & (T_MORE | T_ONE)) {
-			lp->stats.collisions++;
+			dev->stats.collisions++;
 		} else {
-			lp->stats.tx_packets++;
+			dev->stats.tx_packets++;
 		}
 
 		/* Update all the pointers */
@@ -1234,15 +1231,6 @@ static int InitRestartDepca(struct net_device *dev)
 	return status;
 }
 
-static struct net_device_stats *depca_get_stats(struct net_device *dev)
-{
-	struct depca_private *lp = (struct depca_private *) dev->priv;
-
-	/* Null body since there is no framing error counter */
-
-	return &lp->stats;
-}
-
 /*
 ** Set or clear the multicast filter for this adaptor.
 */
diff --git a/drivers/net/dgrs.c b/drivers/net/dgrs.c
index df62c02..2c81019 100644
--- a/drivers/net/dgrs.c
+++ b/drivers/net/dgrs.c
@@ -194,11 +194,6 @@ static int	dgrs_nicmode;
 typedef struct
 {
 	/*
-	 *	Stuff for generic ethercard I/F
-	 */
-	struct net_device_stats	stats;
-
-	/*
 	 *	DGRS specific data
 	 */
 	char		*vmem;
@@ -499,7 +494,7 @@ dgrs_rcv_frame(
 	if ((skb = dev_alloc_skb(len+5)) == NULL)
 	{
 		printk("%s: dev_alloc_skb failed for rcv buffer\n", devN->name);
-		++privN->stats.rx_dropped;
+		++dev0->stats.rx_dropped;
 		/* discarding the frame */
 		goto out;
 	}
@@ -667,8 +662,8 @@ again:
 	skb->protocol = eth_type_trans(skb, devN);
 	netif_rx(skb);
 	devN->last_rx = jiffies;
-	++privN->stats.rx_packets;
-	privN->stats.rx_bytes += len;
+	++devN->stats.rx_packets;
+	devN->stats.rx_bytes += len;
 
 out:
 	cbp->xmit.status = I596_CB_STATUS_C | I596_CB_STATUS_OK;
@@ -776,7 +771,7 @@ frame_done:
 	priv0->rfdp->status = I596_RFD_C | I596_RFD_OK;
 	priv0->rfdp = (I596_RFD *) S2H(priv0->rfdp->next);
 
-	++privN->stats.tx_packets;
+	++devN->stats.tx_packets;
 
 	dev_kfree_skb (skb);
 	return (0);
@@ -806,16 +801,6 @@ static int dgrs_close( struct net_device *dev )
 }
 
 /*
- *	Get statistics
- */
-static struct net_device_stats *dgrs_get_stats( struct net_device *dev )
-{
-	DGRS_PRIV	*priv = (DGRS_PRIV *) dev->priv;
-
-	return (&priv->stats);
-}
-
-/*
  *	Set multicast list and/or promiscuous mode
  */
 
@@ -1213,7 +1198,6 @@ dgrs_probe1(struct net_device *dev)
 	 */
 	dev->open = &dgrs_open;
 	dev->stop = &dgrs_close;
-	dev->get_stats = &dgrs_get_stats;
 	dev->hard_start_xmit = &dgrs_start_xmit;
 	dev->set_multicast_list = &dgrs_set_multicast_list;
 	dev->do_ioctl = &dgrs_ioctl;
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 738aa59..d9936ea 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -148,7 +148,6 @@ typedef struct board_info {
 	struct resource *irq_res;
 
 	struct timer_list timer;
-	struct net_device_stats stats;
 	unsigned char srom[128];
 	spinlock_t lock;
 
@@ -166,8 +165,6 @@ static int dm9000_stop(struct net_device *);
 static void dm9000_timer(unsigned long);
 static void dm9000_init_dm9000(struct net_device *);
 
-static struct net_device_stats *dm9000_get_stats(struct net_device *);
-
 static irqreturn_t dm9000_interrupt(int, void *);
 
 static int dm9000_phy_read(struct net_device *dev, int phyaddr_unsused, int reg);
@@ -559,7 +556,6 @@ dm9000_probe(struct platform_device *pdev)
 	ndev->tx_timeout         = &dm9000_timeout;
 	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
 	ndev->stop		 = &dm9000_stop;
-	ndev->get_stats		 = &dm9000_get_stats;
 	ndev->set_multicast_list = &dm9000_hash_table;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	ndev->poll_controller	 = &dm9000_poll_controller;
@@ -714,7 +710,7 @@ dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	writeb(DM9000_MWCMD, db->io_addr);
 
 	(db->outblk)(db->io_data, skb->data, skb->len);
-	db->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 
 	db->tx_pkt_cnt++;
 	/* TX control: First packet immediately send, second packet queue */
@@ -791,7 +787,7 @@ dm9000_tx_done(struct net_device *dev, board_info_t * db)
 	if (tx_status & (NSR_TX2END | NSR_TX1END)) {
 		/* One packet sent complete */
 		db->tx_pkt_cnt--;
-		db->stats.tx_packets++;
+		dev->stats.tx_packets++;
 
 		/* Queue packet check & send */
 		if (db->tx_pkt_cnt > 0) {
@@ -853,17 +849,6 @@ dm9000_interrupt(int irq, void *dev_id)
 }
 
 /*
- *  Get statistics from driver.
- */
-static struct net_device_stats *
-dm9000_get_stats(struct net_device *dev)
-{
-	board_info_t *db = (board_info_t *) dev->priv;
-	return &db->stats;
-}
-
-
-/*
  *  A periodic timer routine
  *  Dynamic media sense, allocated Rx buffer...
  */
@@ -940,15 +925,15 @@ dm9000_rx(struct net_device *dev)
 			GoodPacket = false;
 			if (rxhdr.RxStatus & 0x100) {
 				PRINTK1("fifo error\n");
-				db->stats.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 			}
 			if (rxhdr.RxStatus & 0x200) {
 				PRINTK1("crc error\n");
-				db->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 			}
 			if (rxhdr.RxStatus & 0x8000) {
 				PRINTK1("length error\n");
-				db->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			}
 		}
 
@@ -961,12 +946,12 @@ dm9000_rx(struct net_device *dev)
 			/* Read received packet from RX SRAM */
 
 			(db->inblk)(db->io_data, rdptr, RxLen);
-			db->stats.rx_bytes += RxLen;
+			dev->stats.rx_bytes += RxLen;
 
 			/* Pass to upper layer */
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
-			db->stats.rx_packets++;
+			dev->stats.rx_packets++;
 
 		} else {
 			/* need to dump the packet's data */
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 280313b..a65cbbc 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -557,7 +557,6 @@ struct nic {
 	enum mac mac;
 	enum phy phy;
 	struct params params;
-	struct net_device_stats net_stats;
 	struct timer_list watchdog;
 	struct timer_list blink_timer;
 	struct mii_if_info mii;
@@ -1482,7 +1481,8 @@ static void e100_set_multicast_list(struct net_device *netdev)
 
 static void e100_update_stats(struct nic *nic)
 {
-	struct net_device_stats *ns = &nic->net_stats;
+	struct net_device *dev = nic->netdev;
+	struct net_device_stats *ns = &dev->stats;
 	struct stats *s = &nic->mem->stats;
 	u32 *complete = (nic->mac < mac_82558_D101_A4) ? &s->fc_xmt_pause :
 		(nic->mac < mac_82559_D101M) ? (u32 *)&s->xmt_tco_frames :
@@ -1659,6 +1659,7 @@ static int e100_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 static int e100_tx_clean(struct nic *nic)
 {
+	struct net_device *dev = nic->netdev;
 	struct cb *cb;
 	int tx_cleaned = 0;
 
@@ -1673,8 +1674,8 @@ static int e100_tx_clean(struct nic *nic)
 		        cb->status);
 
 		if(likely(cb->skb != NULL)) {
-			nic->net_stats.tx_packets++;
-			nic->net_stats.tx_bytes += cb->skb->len;
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes += cb->skb->len;
 
 			pci_unmap_single(nic->pdev,
 				le32_to_cpu(cb->u.tcb.tbd.buf_addr),
@@ -1805,6 +1806,7 @@ static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
 static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 	unsigned int *work_done, unsigned int work_to_do)
 {
+	struct net_device *dev = nic->netdev;
 	struct sk_buff *skb = rx->skb;
 	struct rfd *rfd = (struct rfd *)skb->data;
 	u16 rfd_status, actual_size;
@@ -1849,8 +1851,8 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 		nic->rx_over_length_errors++;
 		dev_kfree_skb_any(skb);
 	} else {
-		nic->net_stats.rx_packets++;
-		nic->net_stats.rx_bytes += actual_size;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += actual_size;
 		nic->netdev->last_rx = jiffies;
 		netif_receive_skb(skb);
 		if(work_done)
@@ -2017,12 +2019,6 @@ static void e100_netpoll(struct net_device *netdev)
 }
 #endif
 
-static struct net_device_stats *e100_get_stats(struct net_device *netdev)
-{
-	struct nic *nic = netdev_priv(netdev);
-	return &nic->net_stats;
-}
-
 static int e100_set_mac_address(struct net_device *netdev, void *p)
 {
 	struct nic *nic = netdev_priv(netdev);
@@ -2459,7 +2455,7 @@ static void e100_get_ethtool_stats(struct net_device *netdev,
 	int i;
 
 	for(i = 0; i < E100_NET_STATS_LEN; i++)
-		data[i] = ((unsigned long *)&nic->net_stats)[i];
+		data[i] = ((unsigned long *)&netdev->stats)[i];
 
 	data[i++] = nic->tx_deferred;
 	data[i++] = nic->tx_single_collisions;
@@ -2564,7 +2560,6 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	netdev->open = e100_open;
 	netdev->stop = e100_close;
 	netdev->hard_start_xmit = e100_xmit_frame;
-	netdev->get_stats = e100_get_stats;
 	netdev->set_multicast_list = e100_set_multicast_list;
 	netdev->set_mac_address = e100_set_mac_address;
 	netdev->change_mtu = e100_change_mtu;
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 4768023..9813426 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -192,7 +192,6 @@ static unsigned int net_debug = NET_DEBUG;
 
 /* Information that need to be kept for each board. */
 struct eepro_local {
-	struct net_device_stats stats;
 	unsigned rx_start;
 	unsigned tx_start; /* start of the transmit chain */
 	int tx_last;  /* pointer to last packet in the transmit chain */
@@ -315,7 +314,6 @@ static irqreturn_t eepro_interrupt(int irq, void *dev_id);
 static void 	eepro_rx(struct net_device *dev);
 static void 	eepro_transmit_interrupt(struct net_device *dev);
 static int	eepro_close(struct net_device *dev);
-static struct net_device_stats *eepro_get_stats(struct net_device *dev);
 static void     set_multicast_list(struct net_device *dev);
 static void     eepro_tx_timeout (struct net_device *dev);
 
@@ -514,7 +512,7 @@ buffer (transmit-buffer = 32K - receive-buffer).
 
 /* a complete sel reset */
 #define eepro_complete_selreset(ioaddr) { \
-						lp->stats.tx_errors++;\
+						dev->stats.tx_errors++;\
 						eepro_sel_reset(ioaddr);\
 						lp->tx_end = \
 							lp->xmt_lower_limit;\
@@ -860,7 +858,6 @@ static int __init eepro_probe1(struct net_device *dev, int autoprobe)
  	dev->open               = eepro_open;
  	dev->stop               = eepro_close;
  	dev->hard_start_xmit    = eepro_send_packet;
- 	dev->get_stats          = eepro_get_stats;
  	dev->set_multicast_list = &set_multicast_list;
  	dev->tx_timeout		= eepro_tx_timeout;
  	dev->watchdog_timeo	= TX_TIMEOUT;
@@ -1158,9 +1155,9 @@ static int eepro_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 		if (hardware_send_packet(dev, buf, length))
 			/* we won't wake queue here because we're out of space */
-			lp->stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 		else {
-		lp->stats.tx_bytes+=skb->len;
+		dev->stats.tx_bytes+=skb->len;
 		dev->trans_start = jiffies;
 			netif_wake_queue(dev);
 		}
@@ -1170,7 +1167,7 @@ static int eepro_send_packet(struct sk_buff *skb, struct net_device *dev)
 	dev_kfree_skb (skb);
 
 	/* You might need to clean up and record Tx statistics here. */
-	/* lp->stats.tx_aborted_errors++; */
+	/* dev->stats.tx_aborted_errors++; */
 
 	if (net_debug > 5)
 		printk(KERN_DEBUG "%s: exiting eepro_send_packet routine.\n", dev->name);
@@ -1277,16 +1274,6 @@ static int eepro_close(struct net_device *dev)
 	return 0;
 }
 
-/* Get the current statistics.	This may be called with the card open or
-   closed. */
-static struct net_device_stats *
-eepro_get_stats(struct net_device *dev)
-{
-	struct eepro_local *lp = netdev_priv(dev);
-
-	return &lp->stats;
-}
-
 /* Set or clear the multicast filter for this adaptor.
  */
 static void
@@ -1579,12 +1566,12 @@ eepro_rx(struct net_device *dev)
 			/* Malloc up new buffer. */
 			struct sk_buff *skb;
 
-			lp->stats.rx_bytes+=rcv_size;
+			dev->stats.rx_bytes+=rcv_size;
 			rcv_size &= 0x3fff;
 			skb = dev_alloc_skb(rcv_size+5);
 			if (skb == NULL) {
 				printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n", dev->name);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				rcv_car = lp->rx_start + RCV_HEADER + rcv_size;
 				lp->rx_start = rcv_next_frame;
 				outw(rcv_next_frame, ioaddr + HOST_ADDRESS_REG);
@@ -1606,28 +1593,28 @@ eepro_rx(struct net_device *dev)
 			skb->protocol = eth_type_trans(skb,dev);
 			netif_rx(skb);
 			dev->last_rx = jiffies;
-			lp->stats.rx_packets++;
+			dev->stats.rx_packets++;
 		}
 
 		else { /* Not sure will ever reach here,
 			I set the 595 to discard bad received frames */
-			lp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 
 			if (rcv_status & 0x0100)
-				lp->stats.rx_over_errors++;
+				dev->stats.rx_over_errors++;
 
 			else if (rcv_status & 0x0400)
-				lp->stats.rx_frame_errors++;
+				dev->stats.rx_frame_errors++;
 
 			else if (rcv_status & 0x0800)
-				lp->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 
 			printk(KERN_DEBUG "%s: event = %#x, status = %#x, next = %#x, size = %#x\n",
 				dev->name, rcv_event, rcv_status, rcv_next_frame, rcv_size);
 		}
 
 		if (rcv_status & 0x1000)
-			lp->stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 
 		rcv_car = lp->rx_start + RCV_HEADER + rcv_size;
 		lp->rx_start = rcv_next_frame;
@@ -1670,11 +1657,11 @@ eepro_transmit_interrupt(struct net_device *dev)
 		netif_wake_queue (dev);
 
 		if (xmt_status & TX_OK)
-			lp->stats.tx_packets++;
+			dev->stats.tx_packets++;
 		else {
-			lp->stats.tx_errors++;
+			dev->stats.tx_errors++;
 			if (xmt_status & 0x0400) {
-				lp->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 				printk(KERN_DEBUG "%s: carrier error\n",
 					dev->name);
 				printk(KERN_DEBUG "%s: XMT status = %#x\n",
@@ -1688,11 +1675,11 @@ eepro_transmit_interrupt(struct net_device *dev)
 			}
 		}
 		if (xmt_status & 0x000f) {
-			lp->stats.collisions += (xmt_status & 0x000f);
+			dev->stats.collisions += (xmt_status & 0x000f);
 		}
 
 		if ((xmt_status & 0x0040) == 0x0) {
-			lp->stats.tx_heartbeat_errors++;
+			dev->stats.tx_heartbeat_errors++;
 		}
 	}
 }
diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 7934ea3..234e8f1 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -135,7 +135,6 @@
 
 struct net_local
 {
-	struct net_device_stats stats;
 	unsigned long last_tx;       /* jiffies when last transmit started */
 	unsigned long init_time;     /* jiffies when eexp_hw_init586 called */
 	unsigned short rx_first;     /* first rx buf, same as RX_BUF_START */
@@ -247,7 +246,6 @@ static char mca_irqmap[] = { 12, 9, 3, 4, 5, 10, 11, 15 };
 static int eexp_open(struct net_device *dev);
 static int eexp_close(struct net_device *dev);
 static void eexp_timeout(struct net_device *dev);
-static struct net_device_stats *eexp_stats(struct net_device *dev);
 static int eexp_xmit(struct sk_buff *buf, struct net_device *dev);
 
 static irqreturn_t eexp_irq(int irq, void *dev_addr);
@@ -535,17 +533,6 @@ static int eexp_close(struct net_device *dev)
 }
 
 /*
- * Return interface stats
- */
-
-static struct net_device_stats *eexp_stats(struct net_device *dev)
-{
-	struct net_local *lp = netdev_priv(dev);
-
-	return &lp->stats;
-}
-
-/*
  * This gets called when a higher level thinks we are broken.  Check that
  * nothing has become jammed in the CU.
  */
@@ -648,7 +635,7 @@ static void eexp_timeout(struct net_device *dev)
 	printk(KERN_INFO "%s: transmit timed out, %s?\n", dev->name,
 	       (SCB_complete(status)?"lost interrupt":
 		"board on fire"));
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	lp->last_tx = jiffies;
 	if (!SCB_complete(status)) {
 		scb_command(dev, SCB_CUabort);
@@ -696,7 +683,7 @@ static int eexp_xmit(struct sk_buff *buf, struct net_device *dev)
 	{
 		unsigned short *data = (unsigned short *)buf->data;
 
-		lp->stats.tx_bytes += length;
+		dev->stats.tx_bytes += length;
 
 	        eexp_hw_tx_pio(dev,data,length);
 	}
@@ -845,7 +832,7 @@ static irqreturn_t eexp_irq(int irq, void *dev_info)
 			outw(rbd+8, ioaddr+READ_PTR);
 			printk("[%04x]\n", inw(ioaddr+DATAPORT));
 #endif
-			lp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 #if 1
 		        eexp_hw_rxinit(dev);
 #else
@@ -954,17 +941,17 @@ static void eexp_hw_rx_pio(struct net_device *dev)
   			}
   			else if (!FD_OK(status))
 			{
-				lp->stats.rx_errors++;
+				dev->stats.rx_errors++;
 				if (FD_CRC(status))
-					lp->stats.rx_crc_errors++;
+					dev->stats.rx_crc_errors++;
 				if (FD_Align(status))
-					lp->stats.rx_frame_errors++;
+					dev->stats.rx_frame_errors++;
 				if (FD_Resrc(status))
-					lp->stats.rx_fifo_errors++;
+					dev->stats.rx_fifo_errors++;
 				if (FD_DMA(status))
-					lp->stats.rx_over_errors++;
+					dev->stats.rx_over_errors++;
 				if (FD_Short(status))
-					lp->stats.rx_length_errors++;
+					dev->stats.rx_length_errors++;
 			}
 			else
 			{
@@ -974,7 +961,7 @@ static void eexp_hw_rx_pio(struct net_device *dev)
 				if (skb == NULL)
 				{
 					printk(KERN_WARNING "%s: Memory squeeze, dropping packet\n",dev->name);
-					lp->stats.rx_dropped++;
+					dev->stats.rx_dropped++;
 					break;
 				}
 				skb_reserve(skb, 2);
@@ -983,8 +970,8 @@ static void eexp_hw_rx_pio(struct net_device *dev)
 				skb->protocol = eth_type_trans(skb,dev);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
-				lp->stats.rx_packets++;
-				lp->stats.rx_bytes += pkt_len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += pkt_len;
 			}
 			outw(rx_block, ioaddr+WRITE_PTR);
 			outw(0, ioaddr+DATAPORT);
@@ -1055,7 +1042,7 @@ static void eexp_hw_tx_pio(struct net_device *dev, unsigned short *buf,
 		outw(0xFFFF, ioaddr+SIGNAL_CA);
 	}
 
-	lp->stats.tx_packets++;
+	dev->stats.tx_packets++;
 	lp->last_tx = jiffies;
 }
 
@@ -1182,7 +1169,6 @@ static int __init eexp_hw_probe(struct net_device *dev, unsigned short ioaddr)
 	dev->open = eexp_open;
 	dev->stop = eexp_close;
 	dev->hard_start_xmit = eexp_xmit;
-	dev->get_stats = eexp_stats;
 	dev->set_multicast_list = &eexp_set_multicast;
 	dev->tx_timeout = eexp_timeout;
 	dev->watchdog_timeo = 2*HZ;
@@ -1265,35 +1251,35 @@ static unsigned short eexp_hw_lasttxstat(struct net_device *dev)
 		else
 		{
 			lp->last_tx_restart = 0;
-			lp->stats.collisions += Stat_NoColl(status);
+			dev->stats.collisions += Stat_NoColl(status);
 			if (!Stat_OK(status))
 			{
 				char *whatsup = NULL;
-				lp->stats.tx_errors++;
+				dev->stats.tx_errors++;
   				if (Stat_Abort(status))
-  					lp->stats.tx_aborted_errors++;
+  					dev->stats.tx_aborted_errors++;
 				if (Stat_TNoCar(status)) {
 					whatsup = "aborted, no carrier";
-					lp->stats.tx_carrier_errors++;
+					dev->stats.tx_carrier_errors++;
 				}
 				if (Stat_TNoCTS(status)) {
 					whatsup = "aborted, lost CTS";
-  					lp->stats.tx_carrier_errors++;
+  					dev->stats.tx_carrier_errors++;
 				}
 				if (Stat_TNoDMA(status)) {
 					whatsup = "FIFO underran";
-  					lp->stats.tx_fifo_errors++;
+  					dev->stats.tx_fifo_errors++;
 				}
 				if (Stat_TXColl(status)) {
 					whatsup = "aborted, too many collisions";
-					lp->stats.tx_aborted_errors++;
+					dev->stats.tx_aborted_errors++;
 				}
 				if (whatsup)
 					printk(KERN_INFO "%s: transmit %s\n",
 					       dev->name, whatsup);
 			}
 			else
-				lp->stats.tx_packets++;
+				dev->stats.tx_packets++;
 		}
 		if (tx_block == TX_BUF_START+((lp->num_tx_bufs-1)*TX_BUF_SIZE))
 			lp->tx_reap = tx_block = TX_BUF_START;
diff --git a/drivers/net/eql.c b/drivers/net/eql.c
index 102218c..c843c3d 100644
--- a/drivers/net/eql.c
+++ b/drivers/net/eql.c
@@ -127,7 +127,6 @@ static int eql_open(struct net_device *dev);
 static int eql_close(struct net_device *dev);
 static int eql_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 static int eql_slave_xmit(struct sk_buff *skb, struct net_device *dev);
-static struct net_device_stats *eql_get_stats(struct net_device *dev);
 
 #define eql_is_slave(dev)	((dev->flags & IFF_SLAVE) == IFF_SLAVE)
 #define eql_is_master(dev)	((dev->flags & IFF_MASTER) == IFF_MASTER)
@@ -181,7 +180,6 @@ static void __init eql_setup(struct net_device *dev)
 	dev->stop		= eql_close;
 	dev->do_ioctl		= eql_ioctl;
 	dev->hard_start_xmit	= eql_slave_xmit;
-	dev->get_stats		= eql_get_stats;
 
 	/*
 	 *	Now we undo some of the things that eth_setup does
@@ -338,9 +336,9 @@ static int eql_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 		skb->priority = 1;
 		slave->bytes_queued += skb->len;
 		dev_queue_xmit(skb);
-		eql->stats.tx_packets++;
+		dev->stats.tx_packets++;
 	} else {
-		eql->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		dev_kfree_skb(skb);
 	}
 
@@ -349,12 +347,6 @@ static int eql_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats * eql_get_stats(struct net_device *dev)
-{
-	equalizer_t *eql = netdev_priv(dev);
-	return &eql->stats;
-}
-
 /*
  *	Private ioctl functions
  */
diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
index 04abf59..d15abe4 100644
--- a/drivers/net/eth16i.c
+++ b/drivers/net/eth16i.c
@@ -380,7 +380,6 @@ static unsigned int eth16i_debug = ETH16I_DEBUG;
 /* Information for each board */
 
 struct eth16i_local {
-	struct net_device_stats stats;
 	unsigned char     tx_started;
 	unsigned char     tx_buf_busy;
 	unsigned short    tx_queue;  /* Number of packets in transmit buffer */
@@ -426,8 +425,6 @@ static int     eth16i_set_irq(struct net_device *dev);
 static ushort  eth16i_parse_mediatype(const char* s);
 #endif
 
-static struct net_device_stats *eth16i_get_stats(struct net_device *dev);
-
 static char cardname[] __initdata = "ICL EtherTeam 16i/32";
 
 static int __init do_eth16i_probe(struct net_device *dev)
@@ -559,7 +556,6 @@ static int __init eth16i_probe1(struct net_device *dev, int ioaddr)
 	dev->open               = eth16i_open;
 	dev->stop               = eth16i_close;
 	dev->hard_start_xmit    = eth16i_tx;
-	dev->get_stats          = eth16i_get_stats;
 	dev->set_multicast_list = eth16i_multicast;
 	dev->tx_timeout 	= eth16i_timeout;
 	dev->watchdog_timeo	= TX_TIMEOUT;
@@ -1047,7 +1043,7 @@ static void eth16i_timeout(struct net_device *dev)
 		printk(KERN_DEBUG "lp->tx_queue_len = %d\n", lp->tx_queue_len);
 		printk(KERN_DEBUG "lp->tx_started = %d\n", lp->tx_started);
 	}
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	eth16i_reset(dev);
 	dev->trans_start = jiffies;
 	outw(ETH16I_INTR_ON, ioaddr + TX_INTR_REG);
@@ -1132,7 +1128,6 @@ static int eth16i_tx(struct sk_buff *skb, struct net_device *dev)
 
 static void eth16i_rx(struct net_device *dev)
 {
-	struct eth16i_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int boguscount = MAX_RX_LOOP;
 
@@ -1151,16 +1146,16 @@ static void eth16i_rx(struct net_device *dev)
 			       inb(ioaddr + RECEIVE_MODE_REG), status);
 
 		if( !(status & PKT_GOOD) ) {
-			lp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 
 			if( (pkt_len < ETH_ZLEN) || (pkt_len > ETH_FRAME_LEN) ) {
-				lp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 				eth16i_reset(dev);
 				return;
 			}
 			else {
 				eth16i_skip_packet(dev);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 			}
 		}
 		else {   /* Ok so now we should have a good packet */
@@ -1171,7 +1166,7 @@ static void eth16i_rx(struct net_device *dev)
 				printk(KERN_WARNING "%s: Could'n allocate memory for packet (len %d)\n",
 				       dev->name, pkt_len);
 				eth16i_skip_packet(dev);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				break;
 			}
 
@@ -1214,8 +1209,8 @@ static void eth16i_rx(struct net_device *dev)
 			}
 			netif_rx(skb);
 			dev->last_rx = jiffies;
-			lp->stats.rx_packets++;
-			lp->stats.rx_bytes += pkt_len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_len;
 
 		} /* else */
 
@@ -1252,32 +1247,32 @@ static irqreturn_t eth16i_interrupt(int irq, void *dev_id)
 
 	if( status & 0x7f00 ) {
 
-		lp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 
 		if(status & (BUS_RD_ERR << 8) )
 			printk(KERN_WARNING "%s: Bus read error.\n",dev->name);
-		if(status & (SHORT_PKT_ERR << 8) )   lp->stats.rx_length_errors++;
-		if(status & (ALIGN_ERR << 8) )       lp->stats.rx_frame_errors++;
-		if(status & (CRC_ERR << 8) )	    lp->stats.rx_crc_errors++;
-		if(status & (RX_BUF_OVERFLOW << 8) ) lp->stats.rx_over_errors++;
+		if(status & (SHORT_PKT_ERR << 8) )   dev->stats.rx_length_errors++;
+		if(status & (ALIGN_ERR << 8) )       dev->stats.rx_frame_errors++;
+		if(status & (CRC_ERR << 8) )	    dev->stats.rx_crc_errors++;
+		if(status & (RX_BUF_OVERFLOW << 8) ) dev->stats.rx_over_errors++;
 	}
 	if( status & 0x001a) {
 
-		lp->stats.tx_errors++;
+		dev->stats.tx_errors++;
 
-		if(status & CR_LOST) lp->stats.tx_carrier_errors++;
-		if(status & TX_JABBER_ERR) lp->stats.tx_window_errors++;
+		if(status & CR_LOST) dev->stats.tx_carrier_errors++;
+		if(status & TX_JABBER_ERR) dev->stats.tx_window_errors++;
 
 #if 0
 		if(status & COLLISION) {
-			lp->stats.collisions +=
+			dev->stats.collisions +=
 				((inb(ioaddr+TRANSMIT_MODE_REG) & 0xF0) >> 4);
 		}
 #endif
 		if(status & COLLISIONS_16) {
 			if(lp->col_16 < MAX_COL_16) {
 				lp->col_16++;
-				lp->stats.collisions++;
+				dev->stats.collisions++;
 				/* Resume transmitting, skip failed packet */
 				outb(0x02, ioaddr + COL_16_REG);
 			}
@@ -1290,8 +1285,8 @@ static irqreturn_t eth16i_interrupt(int irq, void *dev_id)
 	if( status & 0x00ff ) {          /* Let's check the transmit status reg */
 
 		if(status & TX_DONE) {         /* The transmit has been done */
-			lp->stats.tx_packets = lp->tx_buffered_packets;
-			lp->stats.tx_bytes += lp->tx_buffered_bytes;
+			dev->stats.tx_packets = lp->tx_buffered_packets;
+			dev->stats.tx_bytes += lp->tx_buffered_bytes;
 			lp->col_16 = 0;
 
 			if(lp->tx_queue) {           /* Is there still packets ? */
@@ -1371,12 +1366,6 @@ static void eth16i_multicast(struct net_device *dev)
 	}
 }
 
-static struct net_device_stats *eth16i_get_stats(struct net_device *dev)
-{
-	struct eth16i_local *lp = netdev_priv(dev);
-	return &lp->stats;
-}
-
 static void eth16i_select_regbank(unsigned char banknbr, int ioaddr)
 {
 	unsigned char data;
diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index cb0792c..2e9e5c7 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -275,7 +275,6 @@ struct ewrk3_private {
 	u_long shmem_base;	/* Shared memory start address */
 	void __iomem *shmem;
 	u_long shmem_length;	/* Shared memory window length */
-	struct net_device_stats stats;	/* Public stats */
 	struct ewrk3_stats pktStats; /* Private stats counters */
 	u_char irq_mask;	/* Adapter IRQ mask bits */
 	u_char mPage;		/* Maximum 2kB Page number */
@@ -302,7 +301,6 @@ static int ewrk3_open(struct net_device *dev);
 static int ewrk3_queue_pkt(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t ewrk3_interrupt(int irq, void *dev_id);
 static int ewrk3_close(struct net_device *dev);
-static struct net_device_stats *ewrk3_get_stats(struct net_device *dev);
 static void set_multicast_list(struct net_device *dev);
 static int ewrk3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static const struct ethtool_ops ethtool_ops_203;
@@ -612,7 +610,6 @@ ewrk3_hw_init(struct net_device *dev, u_long iobase)
 	dev->open = ewrk3_open;
 	dev->hard_start_xmit = ewrk3_queue_pkt;
 	dev->stop = ewrk3_close;
-	dev->get_stats = ewrk3_get_stats;
 	dev->set_multicast_list = set_multicast_list;
 	dev->do_ioctl = ewrk3_ioctl;
 	if (lp->adapter_name[4] == '3')
@@ -864,7 +861,7 @@ static int ewrk3_queue_pkt (struct sk_buff *skb, struct net_device *dev)
 	ENABLE_IRQs;
 	spin_unlock_irq (&lp->hw_lock);
 
-	lp->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 	dev->trans_start = jiffies;
 	dev_kfree_skb (skb);
 
@@ -981,13 +978,13 @@ static int ewrk3_rx(struct net_device *dev)
 				}
 
 				if (!(rx_status & R_ROK)) {	/* There was an error. */
-					lp->stats.rx_errors++;	/* Update the error stats. */
+					dev->stats.rx_errors++;	/* Update the error stats. */
 					if (rx_status & R_DBE)
-						lp->stats.rx_frame_errors++;
+						dev->stats.rx_frame_errors++;
 					if (rx_status & R_CRC)
-						lp->stats.rx_crc_errors++;
+						dev->stats.rx_crc_errors++;
 					if (rx_status & R_PLL)
-						lp->stats.rx_fifo_errors++;
+						dev->stats.rx_fifo_errors++;
 				} else {
 					struct sk_buff *skb;
 
@@ -1038,11 +1035,11 @@ static int ewrk3_rx(struct net_device *dev)
 						   ** Update stats
 						 */
 						dev->last_rx = jiffies;
-						lp->stats.rx_packets++;
-						lp->stats.rx_bytes += pkt_len;
+						dev->stats.rx_packets++;
+						dev->stats.rx_bytes += pkt_len;
 					} else {
 						printk("%s: Insufficient memory; nuking packet.\n", dev->name);
-						lp->stats.rx_dropped++;		/* Really, deferred. */
+						dev->stats.rx_dropped++;		/* Really, deferred. */
 						break;
 					}
 				}
@@ -1072,11 +1069,11 @@ static int ewrk3_tx(struct net_device *dev)
 	while ((tx_status = inb(EWRK3_TDQ)) > 0) {	/* Whilst there's old buffers */
 		if (tx_status & T_VSTS) {	/* The status is valid */
 			if (tx_status & T_TXE) {
-				lp->stats.tx_errors++;
+				dev->stats.tx_errors++;
 				if (tx_status & T_NCL)
-					lp->stats.tx_carrier_errors++;
+					dev->stats.tx_carrier_errors++;
 				if (tx_status & T_LCL)
-					lp->stats.tx_window_errors++;
+					dev->stats.tx_window_errors++;
 				if (tx_status & T_CTU) {
 					if ((tx_status & T_COLL) ^ T_XUR) {
 						lp->pktStats.tx_underruns++;
@@ -1085,13 +1082,13 @@ static int ewrk3_tx(struct net_device *dev)
 					}
 				} else if (tx_status & T_COLL) {
 					if ((tx_status & T_COLL) ^ T_XCOLL) {
-						lp->stats.collisions++;
+						dev->stats.collisions++;
 					} else {
 						lp->pktStats.excessive_collisions++;
 					}
 				}
 			} else {
-				lp->stats.tx_packets++;
+				dev->stats.tx_packets++;
 			}
 		}
 	}
@@ -1134,14 +1131,6 @@ static int ewrk3_close(struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *ewrk3_get_stats(struct net_device *dev)
-{
-	struct ewrk3_private *lp = netdev_priv(dev);
-
-	/* Null body since there is no framing error counter */
-	return &lp->stats;
-}
-
 /*
    ** Set or clear the multicast filter for this adapter.
  */
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 4e8df91..4419c3c 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -204,7 +204,6 @@ struct fec_enet_private {
 	cbd_t	*tx_bd_base;
 	cbd_t	*cur_rx, *cur_tx;		/* The next free ring entry */
 	cbd_t	*dirty_tx;	/* The ring entries to be free()ed. */
-	struct	net_device_stats stats;
 	uint	tx_full;
 	spinlock_t lock;
 
@@ -234,7 +233,6 @@ static irqreturn_t fec_enet_interrupt(int irq, void * dev_id);
 static void fec_enet_tx(struct net_device *dev);
 static void fec_enet_rx(struct net_device *dev);
 static int fec_enet_close(struct net_device *dev);
-static struct net_device_stats *fec_enet_get_stats(struct net_device *dev);
 static void set_multicast_list(struct net_device *dev);
 static void fec_restart(struct net_device *dev, int duplex);
 static void fec_stop(struct net_device *dev);
@@ -359,7 +357,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	*/
 	fep->tx_skbuff[fep->skb_cur] = skb;
 
-	fep->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 	fep->skb_cur = (fep->skb_cur+1) & TX_RING_MOD_MASK;
 
 	/* Push the data cache so the CPM does not get stale memory
@@ -409,7 +407,7 @@ fec_timeout(struct net_device *dev)
 	struct fec_enet_private *fep = netdev_priv(dev);
 
 	printk("%s: transmit timed out.\n", dev->name);
-	fep->stats.tx_errors++;
+	dev->stats.tx_errors++;
 #ifndef final_version
 	{
 	int	i;
@@ -511,19 +509,19 @@ fec_enet_tx(struct net_device *dev)
 		if (status & (BD_ENET_TX_HB | BD_ENET_TX_LC |
 				   BD_ENET_TX_RL | BD_ENET_TX_UN |
 				   BD_ENET_TX_CSL)) {
-			fep->stats.tx_errors++;
+			dev->stats.tx_errors++;
 			if (status & BD_ENET_TX_HB)  /* No heartbeat */
-				fep->stats.tx_heartbeat_errors++;
+				dev->stats.tx_heartbeat_errors++;
 			if (status & BD_ENET_TX_LC)  /* Late collision */
-				fep->stats.tx_window_errors++;
+				dev->stats.tx_window_errors++;
 			if (status & BD_ENET_TX_RL)  /* Retrans limit */
-				fep->stats.tx_aborted_errors++;
+				dev->stats.tx_aborted_errors++;
 			if (status & BD_ENET_TX_UN)  /* Underrun */
-				fep->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 			if (status & BD_ENET_TX_CSL) /* Carrier lost */
-				fep->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 		} else {
-			fep->stats.tx_packets++;
+			dev->stats.tx_packets++;
 		}
 
 #ifndef final_version
@@ -534,7 +532,7 @@ fec_enet_tx(struct net_device *dev)
 		 * but we eventually sent the packet OK.
 		 */
 		if (status & BD_ENET_TX_DEF)
-			fep->stats.collisions++;
+			dev->stats.collisions++;
 
 		/* Free the sk buffer associated with this last transmit.
 		 */
@@ -607,17 +605,17 @@ while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
 	/* Check for errors. */
 	if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH | BD_ENET_RX_NO |
 			   BD_ENET_RX_CR | BD_ENET_RX_OV)) {
-		fep->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH)) {
 		/* Frame too long or too short. */
-			fep->stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 		}
 		if (status & BD_ENET_RX_NO)	/* Frame alignment */
-			fep->stats.rx_frame_errors++;
+			dev->stats.rx_frame_errors++;
 		if (status & BD_ENET_RX_CR)	/* CRC Error */
-			fep->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 		if (status & BD_ENET_RX_OV)	/* FIFO overrun */
-			fep->stats.rx_fifo_errors++;
+			dev->stats.rx_fifo_errors++;
 	}
 
 	/* Report late collisions as a frame error.
@@ -625,16 +623,16 @@ while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
 	 * have in the buffer.  So, just drop this frame on the floor.
 	 */
 	if (status & BD_ENET_RX_CL) {
-		fep->stats.rx_errors++;
-		fep->stats.rx_frame_errors++;
+		dev->stats.rx_errors++;
+		dev->stats.rx_frame_errors++;
 		goto rx_processing_done;
 	}
 
 	/* Process the incoming frame.
 	 */
-	fep->stats.rx_packets++;
+	dev->stats.rx_packets++;
 	pkt_len = bdp->cbd_datlen;
-	fep->stats.rx_bytes += pkt_len;
+	dev->stats.rx_bytes += pkt_len;
 	data = (__u8*)__va(bdp->cbd_bufaddr);
 
 	/* This does 16 byte alignment, exactly what we need.
@@ -646,7 +644,7 @@ while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
 
 	if (skb == NULL) {
 		printk("%s: Memory squeeze, dropping packet.\n", dev->name);
-		fep->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 	} else {
 		skb_put(skb,pkt_len-4);	/* Make room */
 		skb_copy_to_linear_data(skb, data, pkt_len-4);
@@ -2220,13 +2218,6 @@ fec_enet_close(struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *fec_enet_get_stats(struct net_device *dev)
-{
-	struct fec_enet_private *fep = netdev_priv(dev);
-
-	return &fep->stats;
-}
-
 /* Set or clear the multicast filter for this adaptor.
  * Skeleton taken from sunlance driver.
  * The CPM Ethernet implementation allows Multicast as well as individual
@@ -2462,7 +2453,6 @@ int __init fec_enet_init(struct net_device *dev)
 	dev->tx_timeout = fec_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 	dev->stop = fec_enet_close;
-	dev->get_stats = fec_enet_get_stats;
 	dev->set_multicast_list = set_multicast_list;
 
 	for (i=0; i<NMII-1; i++)
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index f926905..11ff0ef 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -116,7 +116,6 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static void gfar_timeout(struct net_device *dev);
 static int gfar_close(struct net_device *dev);
 struct sk_buff *gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp);
-static struct net_device_stats *gfar_get_stats(struct net_device *dev);
 static int gfar_set_mac_address(struct net_device *dev);
 static int gfar_change_mtu(struct net_device *dev, int new_mtu);
 static irqreturn_t gfar_error(int irq, void *dev_id);
@@ -269,7 +268,6 @@ static int gfar_probe(struct platform_device *pdev)
 	dev->poll_controller = gfar_netpoll;
 #endif
 	dev->stop = gfar_close;
-	dev->get_stats = gfar_get_stats;
 	dev->change_mtu = gfar_change_mtu;
 	dev->mtu = 1500;
 	dev->set_multicast_list = gfar_set_multi;
@@ -1010,7 +1008,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 
 	/* Update transmit stats */
-	priv->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 
 	/* Lock priv now */
 	spin_lock_irqsave(&priv->txlock, flags);
@@ -1083,7 +1081,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (txbdp == priv->dirty_tx) {
 		netif_stop_queue(dev);
 
-		priv->stats.tx_fifo_errors++;
+		dev->stats.tx_fifo_errors++;
 	}
 
 	/* Update the current txbd to the next one */
@@ -1113,14 +1111,6 @@ static int gfar_close(struct net_device *dev)
 	return 0;
 }
 
-/* returns a net_device_stats structure pointer */
-static struct net_device_stats * gfar_get_stats(struct net_device *dev)
-{
-	struct gfar_private *priv = netdev_priv(dev);
-
-	return &(priv->stats);
-}
-
 /* Changes the mac address if the controller is not running. */
 int gfar_set_mac_address(struct net_device *dev)
 {
@@ -1232,7 +1222,7 @@ static void gfar_timeout(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 
-	priv->stats.tx_errors++;
+	dev->stats.tx_errors++;
 
 	if (dev->flags & IFF_UP) {
 		stop_gfar(dev);
@@ -1262,12 +1252,12 @@ static irqreturn_t gfar_transmit(int irq, void *dev_id)
 		if ((bdp == priv->cur_tx) && (netif_queue_stopped(dev) == 0))
 			break;
 
-		priv->stats.tx_packets++;
+		dev->stats.tx_packets++;
 
 		/* Deferred means some collisions occurred during transmit, */
 		/* but we eventually sent the packet. */
 		if (bdp->status & TXBD_DEF)
-			priv->stats.collisions++;
+			dev->stats.collisions++;
 
 		/* Free the sk buffer associated with this TxBD */
 		dev_kfree_skb_irq(priv->tx_skbuff[priv->skb_dirtytx]);
@@ -1339,7 +1329,7 @@ struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
 
 static inline void count_errors(unsigned short status, struct gfar_private *priv)
 {
-	struct net_device_stats *stats = &priv->stats;
+	struct net_device_stats *stats = &dev->stats;
 	struct gfar_extra_stats *estats = &priv->extra_stats;
 
 	/* If the packet was truncated, none of the other errors
@@ -1464,7 +1454,7 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	if (NULL == skb) {
 		if (netif_msg_rx_err(priv))
 			printk(KERN_WARNING "%s: Missing skb!!.\n", dev->name);
-		priv->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		priv->extra_stats.rx_skbmissing++;
 	} else {
 		int ret;
@@ -1522,7 +1512,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 		      (RXBD_LARGE | RXBD_SHORT | RXBD_NONOCTET
 		       | RXBD_CRCERR | RXBD_OVERRUN | RXBD_TRUNCATED))) {
 			/* Increment the number of packets */
-			priv->stats.rx_packets++;
+			dev->stats.rx_packets++;
 			howmany++;
 
 			/* Remove the FCS from the packet length */
@@ -1530,7 +1520,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 
 			gfar_process_frame(dev, skb, pkt_len);
 
-			priv->stats.rx_bytes += pkt_len;
+			dev->stats.rx_bytes += pkt_len;
 		} else {
 			count_errors(bdp->status, priv);
 
@@ -1918,17 +1908,17 @@ static irqreturn_t gfar_error(int irq, void *dev_id)
 
 	/* Update the error counters */
 	if (events & IEVENT_TXE) {
-		priv->stats.tx_errors++;
+		dev->stats.tx_errors++;
 
 		if (events & IEVENT_LC)
-			priv->stats.tx_window_errors++;
+			dev->stats.tx_window_errors++;
 		if (events & IEVENT_CRL)
-			priv->stats.tx_aborted_errors++;
+			dev->stats.tx_aborted_errors++;
 		if (events & IEVENT_XFUN) {
 			if (netif_msg_tx_err(priv))
 				printk(KERN_DEBUG "%s: TX FIFO underrun, "
 				       "packet dropped.\n", dev->name);
-			priv->stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 			priv->extra_stats.tx_underrun++;
 
 			/* Reactivate the Tx Queues */
@@ -1938,7 +1928,7 @@ static irqreturn_t gfar_error(int irq, void *dev_id)
 			printk(KERN_DEBUG "%s: Transmit Error\n", dev->name);
 	}
 	if (events & IEVENT_BSY) {
-		priv->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		priv->extra_stats.rx_bsy++;
 
 		gfar_receive(irq, dev_id);
@@ -1953,7 +1943,7 @@ static irqreturn_t gfar_error(int irq, void *dev_id)
 			       dev->name, gfar_read(&priv->regs->rstat));
 	}
 	if (events & IEVENT_BABR) {
-		priv->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		priv->extra_stats.rx_babr++;
 
 		if (netif_msg_rx_err(priv))
diff --git a/drivers/net/hplance.c b/drivers/net/hplance.c
index c991cb8..be6e5bc 100644
--- a/drivers/net/hplance.c
+++ b/drivers/net/hplance.c
@@ -141,7 +141,6 @@ static void __init hplance_init(struct net_device *dev, struct dio_dev *d)
         dev->poll_controller = lance_poll;
 #endif
         dev->hard_start_xmit = &lance_start_xmit;
-        dev->get_stats = &lance_get_stats;
         dev->set_multicast_list = &lance_set_multicast;
         dev->dma = 0;
 
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index fe85d6f..f399254 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -591,7 +591,7 @@ static void irqrx_handler(struct net_device *dev)
 
 			skb = dev_alloc_skb(rda.length + 2);
 			if (skb == NULL)
-				priv->stat.rx_dropped++;
+				dev->stats.rx_dropped++;
 			else {
 				/* copy out data */
 
@@ -606,8 +606,8 @@ static void irqrx_handler(struct net_device *dev)
 
 				/* bookkeeping */
 				dev->last_rx = jiffies;
-				priv->stat.rx_packets++;
-				priv->stat.rx_bytes += rda.length;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += rda.length;
 
 				/* pass to the upper layers */
 				netif_rx(skb);
@@ -617,11 +617,11 @@ static void irqrx_handler(struct net_device *dev)
 		/* otherwise check error status bits and increase statistics */
 
 		else {
-			priv->stat.rx_errors++;
+			dev->stats.rx_errors++;
 			if (rda.status & RCREG_FAER)
-				priv->stat.rx_frame_errors++;
+				dev->stats.rx_frame_errors++;
 			if (rda.status & RCREG_CRCR)
-				priv->stat.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 		}
 
 		/* descriptor processed, will become new last descriptor in queue */
@@ -656,8 +656,8 @@ static void irqtx_handler(struct net_device *dev)
 	memcpy_fromio(&tda, priv->base + priv->tdastart + (priv->currtxdescr * sizeof(tda_t)), sizeof(tda_t));
 
 	/* update statistics */
-	priv->stat.tx_packets++;
-	priv->stat.tx_bytes += tda.length;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += tda.length;
 
 	/* update our pointers */
 	priv->txused[priv->currtxdescr] = 0;
@@ -680,15 +680,15 @@ static void irqtxerr_handler(struct net_device *dev)
 	memcpy_fromio(&tda, priv->base + priv->tdastart + (priv->currtxdescr * sizeof(tda_t)), sizeof(tda_t));
 
 	/* update statistics */
-	priv->stat.tx_errors++;
+	dev->stats.tx_errors++;
 	if (tda.status & (TCREG_NCRS | TCREG_CRSL))
-		priv->stat.tx_carrier_errors++;
+		dev->stats.tx_carrier_errors++;
 	if (tda.status & TCREG_EXC)
-		priv->stat.tx_aborted_errors++;
+		dev->stats.tx_aborted_errors++;
 	if (tda.status & TCREG_OWC)
-		priv->stat.tx_window_errors++;
+		dev->stats.tx_window_errors++;
 	if (tda.status & TCREG_FU)
-		priv->stat.tx_fifo_errors++;
+		dev->stats.tx_fifo_errors++;
 
 	/* update our pointers */
 	priv->txused[priv->currtxdescr] = 0;
@@ -824,7 +824,7 @@ static int ibmlana_tx(struct sk_buff *skb, struct net_device *dev)
 
 	if (priv->txusedcnt >= TXBUFCNT) {
 		retval = -EIO;
-		priv->stat.tx_dropped++;
+		dev->stats.tx_dropped++;
 		goto tx_done;
 	}
 
@@ -876,14 +876,6 @@ tx_done:
 	return retval;
 }
 
-/* return pointer to Ethernet statistics */
-
-static struct net_device_stats *ibmlana_stats(struct net_device *dev)
-{
-	ibmlana_priv *priv = netdev_priv(dev);
-	return &priv->stat;
-}
-
 /* switch receiver mode. */
 
 static void ibmlana_set_multicast_list(struct net_device *dev)
@@ -980,7 +972,6 @@ static int ibmlana_probe(struct net_device *dev)
 	dev->stop = ibmlana_close;
 	dev->hard_start_xmit = ibmlana_tx;
 	dev->do_ioctl = NULL;
-	dev->get_stats = ibmlana_stats;
 	dev->set_multicast_list = ibmlana_set_multicast_list;
 	dev->flags |= IFF_MULTICAST;
 
diff --git a/drivers/net/ibmlana.h b/drivers/net/ibmlana.h
index 6b58bab..aa3ddbd 100644
--- a/drivers/net/ibmlana.h
+++ b/drivers/net/ibmlana.h
@@ -26,7 +26,6 @@ typedef enum {
 
 typedef struct {
 	unsigned int slot;		/* MCA-Slot-#                       */
-	struct net_device_stats stat;	/* packet statistics            */
 	int realirq;			/* memorizes actual IRQ, even when
 					   currently not allocated          */
 	ibmlana_medium medium;		/* physical cannector               */
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index c9d91a3..7e46df1 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -86,7 +86,6 @@ static int ibmveth_close(struct net_device *dev);
 static int ibmveth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 static int ibmveth_poll(struct net_device *dev, int *budget);
 static int ibmveth_start_xmit(struct sk_buff *skb, struct net_device *dev);
-static struct net_device_stats *ibmveth_get_stats(struct net_device *dev);
 static void ibmveth_set_multicast_list(struct net_device *dev);
 static int ibmveth_change_mtu(struct net_device *dev, int new_mtu);
 static void ibmveth_proc_register_driver(void);
@@ -898,9 +897,9 @@ static int ibmveth_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 			 skb->len, DMA_TO_DEVICE);
 
 out:	spin_lock_irqsave(&adapter->stats_lock, flags);
-	adapter->stats.tx_dropped += tx_dropped;
-	adapter->stats.tx_bytes += tx_bytes;
-	adapter->stats.tx_packets += tx_packets;
+	dev->stats.tx_dropped += tx_dropped;
+	dev->stats.tx_bytes += tx_bytes;
+	dev->stats.tx_packets += tx_packets;
 	adapter->tx_send_failed += tx_send_failed;
 	adapter->tx_map_failed += tx_map_failed;
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
@@ -948,8 +947,8 @@ static int ibmveth_poll(struct net_device *netdev, int *budget)
 
 				netif_receive_skb(skb);	/* send it up */
 
-				adapter->stats.rx_packets++;
-				adapter->stats.rx_bytes += length;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += length;
 				frames_processed++;
 				netdev->last_rx = jiffies;
 			}
@@ -1003,12 +1002,6 @@ static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance)
 	return IRQ_HANDLED;
 }
 
-static struct net_device_stats *ibmveth_get_stats(struct net_device *dev)
-{
-	struct ibmveth_adapter *adapter = dev->priv;
-	return &adapter->stats;
-}
-
 static void ibmveth_set_multicast_list(struct net_device *netdev)
 {
 	struct ibmveth_adapter *adapter = netdev->priv;
@@ -1172,7 +1165,6 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
 	netdev->weight             = 16;
 	netdev->stop               = ibmveth_close;
 	netdev->hard_start_xmit    = ibmveth_start_xmit;
-	netdev->get_stats          = ibmveth_get_stats;
 	netdev->set_multicast_list = ibmveth_set_multicast_list;
 	netdev->do_ioctl           = ibmveth_ioctl;
 	netdev->ethtool_ops           = &netdev_ethtool_ops;
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index f5c3598..9af671b 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -39,7 +39,6 @@
 
 #define TX_Q_LIMIT    32
 struct ifb_private {
-	struct net_device_stats stats;
 	struct tasklet_struct   ifb_tasklet;
 	int     tasklet_pending;
 	/* mostly debug stats leave in for now */
@@ -60,7 +59,6 @@ static int numifbs = 2;
 
 static void ri_tasklet(unsigned long dev);
 static int ifb_xmit(struct sk_buff *skb, struct net_device *dev);
-static struct net_device_stats *ifb_get_stats(struct net_device *dev);
 static int ifb_open(struct net_device *dev);
 static int ifb_close(struct net_device *dev);
 
@@ -69,7 +67,7 @@ static void ri_tasklet(unsigned long dev)
 
 	struct net_device *_dev = (struct net_device *)dev;
 	struct ifb_private *dp = netdev_priv(_dev);
-	struct net_device_stats *stats = &dp->stats;
+	struct net_device_stats *stats = &_dev->stats;
 	struct sk_buff *skb;
 
 	dp->st_task_enter++;
@@ -139,7 +137,6 @@ resched:
 static void ifb_setup(struct net_device *dev)
 {
 	/* Initialize the device structure. */
-	dev->get_stats = ifb_get_stats;
 	dev->hard_start_xmit = ifb_xmit;
 	dev->open = &ifb_open;
 	dev->stop = &ifb_close;
@@ -158,7 +155,7 @@ static void ifb_setup(struct net_device *dev)
 static int ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
-	struct net_device_stats *stats = &dp->stats;
+	struct net_device_stats *stats = &dev->stats;
 	int ret = 0;
 	u32 from = G_TC_FROM(skb->tc_verd);
 
@@ -185,19 +182,6 @@ static int ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 	return ret;
 }
 
-static struct net_device_stats *ifb_get_stats(struct net_device *dev)
-{
-	struct ifb_private *dp = netdev_priv(dev);
-	struct net_device_stats *stats = &dp->stats;
-
-	pr_debug("tasklets stats %ld:%ld:%ld:%ld:%ld:%ld:%ld:%ld:%ld \n",
-		dp->st_task_enter, dp->st_txq_refl_try, dp->st_rxq_enter,
-		dp->st_rx2tx_tran, dp->st_rxq_notenter, dp->st_rx_frm_egr,
-		dp->st_rx_frm_ing, dp->st_rxq_check, dp->st_rxq_rsch);
-
-	return stats;
-}
-
 static int ifb_close(struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index 0433c41..5aec7f0 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -196,7 +196,6 @@ struct veth_lpar_connection {
 
 struct veth_port {
 	struct device *dev;
-	struct net_device_stats stats;
 	u64 mac_addr;
 	HvLpIndexMap lpar_map;
 
@@ -936,9 +935,6 @@ static void veth_release_connection(struct kobject *kobj)
 
 static int veth_open(struct net_device *dev)
 {
-	struct veth_port *port = (struct veth_port *) dev->priv;
-
-	memset(&port->stats, 0, sizeof (port->stats));
 	netif_start_queue(dev);
 	return 0;
 }
@@ -949,13 +945,6 @@ static int veth_close(struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *veth_get_stats(struct net_device *dev)
-{
-	struct veth_port *port = (struct veth_port *) dev->priv;
-
-	return &port->stats;
-}
-
 static int veth_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if ((new_mtu < 68) || (new_mtu > VETH_MAX_MTU))
@@ -1084,7 +1073,6 @@ static struct net_device * __init veth_probe_one(int vlan,
 	dev->open = veth_open;
 	dev->hard_start_xmit = veth_start_xmit;
 	dev->stop = veth_close;
-	dev->get_stats = veth_get_stats;
 	dev->change_mtu = veth_change_mtu;
 	dev->set_mac_address = NULL;
 	dev->set_multicast_list = veth_set_multicast_list;
@@ -1199,11 +1187,11 @@ static void veth_transmit_to_many(struct sk_buff *skb,
 	}
 
 	if (error)
-		port->stats.tx_errors++;
+		dev->stats.tx_errors++;
 
 	if (success) {
-		port->stats.tx_packets++;
-		port->stats.tx_bytes += skb->len;
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes += skb->len;
 	}
 }
 
@@ -1541,8 +1529,8 @@ static void veth_receive(struct veth_lpar_connection *cnx,
 		skb->protocol = eth_type_trans(skb, dev);
 		skb->ip_summed = CHECKSUM_NONE;
 		netif_rx(skb);	/* send it up */
-		port->stats.rx_packets++;
-		port->stats.rx_bytes += length;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += length;
 	} while (startchunk += nchunks, startchunk < VETH_MAX_FRAMES_PER_MSG);
 
 	/* Ack it */
diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index 5884f5b..afa4638 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -322,7 +322,6 @@ struct i596_private {
 	struct i596_cmd *cmd_head;
 	int cmd_backlog;
 	u32    last_cmd;
-	struct net_device_stats stats;
 	int next_tx_cmd;
 	int options;
 	spinlock_t lock;       /* serialize access to chip */
@@ -352,7 +351,6 @@ static int i596_open(struct net_device *dev);
 static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t i596_interrupt(int irq, void *dev_id);
 static int i596_close(struct net_device *dev);
-static struct net_device_stats *i596_get_stats(struct net_device *dev);
 static void i596_add_cmd(struct net_device *dev, struct i596_cmd *cmd);
 static void i596_tx_timeout (struct net_device *dev);
 static void print_eth(unsigned char *buf, char *str);
@@ -725,7 +723,7 @@ memory_squeeze:
 				printk(KERN_ERR
 				       "%s: i596_rx Memory squeeze, dropping packet.\n",
 				       dev->name);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 			} else {
 				if (!rx_in_place) {
 					/* 16 byte align the data fields */
@@ -742,28 +740,28 @@ memory_squeeze:
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
-				lp->stats.rx_packets++;
-				lp->stats.rx_bytes += pkt_len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += pkt_len;
 			}
 		} else {
 			DEB(DEB_ERRORS, printk(KERN_DEBUG
 					       "%s: Error, rfd.stat = 0x%04x\n",
 					       dev->name, rfd->stat));
-			lp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			if (rfd->stat & SWAP16(0x0100))
-				lp->stats.collisions++;
+				dev->stats.collisions++;
 			if (rfd->stat & SWAP16(0x8000))
-				lp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			if (rfd->stat & SWAP16(0x0001))
-				lp->stats.rx_over_errors++;
+				dev->stats.rx_over_errors++;
 			if (rfd->stat & SWAP16(0x0002))
-				lp->stats.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 			if (rfd->stat & SWAP16(0x0004))
-				lp->stats.rx_frame_errors++;
+				dev->stats.rx_frame_errors++;
 			if (rfd->stat & SWAP16(0x0008))
-				lp->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 			if (rfd->stat & SWAP16(0x0010))
-				lp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 		}
 
 		/* Clear the buffer descriptor count and EOF + F flags */
@@ -821,8 +819,8 @@ static inline void i596_cleanup_cmd(struct net_device *dev, struct i596_private
 
 				dev_kfree_skb(skb);
 
-				lp->stats.tx_errors++;
-				lp->stats.tx_aborted_errors++;
+				dev->stats.tx_errors++;
+				dev->stats.tx_aborted_errors++;
 
 				ptr->v_next = NULL;
 				ptr->b_next = I596_NULL;
@@ -951,10 +949,10 @@ static void i596_tx_timeout (struct net_device *dev)
 			       "%s: transmit timed out, status resetting.\n",
 			       dev->name));
 
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 
 	/* Try to restart the adaptor */
-	if (lp->last_restart == lp->stats.tx_packets) {
+	if (lp->last_restart == dev->stats.tx_packets) {
 		DEB(DEB_ERRORS, printk(KERN_DEBUG "Resetting board.\n"));
 		/* Shutdown and restart */
 		i596_reset (dev, lp);
@@ -964,7 +962,7 @@ static void i596_tx_timeout (struct net_device *dev)
 		lp->dma->scb.command = SWAP16(CUC_START | RX_START);
 		DMA_WBACK_INV(dev, &(lp->dma->scb), sizeof(struct i596_scb));
 		ca (dev);
-		lp->last_restart = lp->stats.tx_packets;
+		lp->last_restart = dev->stats.tx_packets;
 	}
 
 	dev->trans_start = jiffies;
@@ -999,7 +997,7 @@ static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		DEB(DEB_ERRORS, printk(KERN_DEBUG
 				       "%s: xmit ring full, dropping packet.\n",
 				       dev->name));
-		lp->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 
 		dev_kfree_skb(skb);
 	} else {
@@ -1025,8 +1023,8 @@ static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		DMA_WBACK_INV(dev, tbd, sizeof(struct i596_tbd));
 		i596_add_cmd(dev, &tx_cmd->cmd);
 
-		lp->stats.tx_packets++;
-		lp->stats.tx_bytes += length;
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes += length;
 	}
 
 	netif_start_queue(dev);
@@ -1076,7 +1074,6 @@ static int __devinit i82596_probe(struct net_device *dev)
 	dev->open = i596_open;
 	dev->stop = i596_close;
 	dev->hard_start_xmit = i596_start_xmit;
-	dev->get_stats = i596_get_stats;
 	dev->set_multicast_list = set_multicast_list;
 	dev->tx_timeout = i596_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
@@ -1197,17 +1194,17 @@ static irqreturn_t i596_interrupt(int irq, void *dev_id)
 					DEB(DEB_TXADDR,
 					    print_eth(skb->data, "tx-done"));
 				} else {
-					lp->stats.tx_errors++;
+					dev->stats.tx_errors++;
 					if (ptr->status & SWAP16(0x0020))
-						lp->stats.collisions++;
+						dev->stats.collisions++;
 					if (!(ptr->status & SWAP16(0x0040)))
-						lp->stats.tx_heartbeat_errors++;
+						dev->stats.tx_heartbeat_errors++;
 					if (ptr->status & SWAP16(0x0400))
-						lp->stats.tx_carrier_errors++;
+						dev->stats.tx_carrier_errors++;
 					if (ptr->status & SWAP16(0x0800))
-						lp->stats.collisions++;
+						dev->stats.collisions++;
 					if (ptr->status & SWAP16(0x1000))
-						lp->stats.tx_aborted_errors++;
+						dev->stats.tx_aborted_errors++;
 				}
 				dma_unmap_single(dev->dev.parent,
 						 tx_cmd->dma_addr,
@@ -1292,8 +1289,8 @@ static irqreturn_t i596_interrupt(int irq, void *dev_id)
 					   "%s: i596 interrupt receive unit inactive, status 0x%x\n",
 					   dev->name, status));
 				ack_cmd |= RX_START;
-				lp->stats.rx_errors++;
-				lp->stats.rx_fifo_errors++;
+				dev->stats.rx_errors++;
+				dev->stats.rx_fifo_errors++;
 				rebuild_rx_bufs(dev);
 			}
 		}
@@ -1346,13 +1343,6 @@ static int i596_close(struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *i596_get_stats(struct net_device *dev)
-{
-	struct i596_private *lp = netdev_priv(dev);
-
-	return &lp->stats;
-}
-
 /*
  *    Set or clear the multicast filter for this adaptor.
  */
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index 5fc18da..e0537fc 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -350,7 +350,6 @@ struct i596_private {		/* aligned to a 16-byte boundary */
 	struct i596_cmd *cmd_head;
 	int cmd_backlog;
 	unsigned long last_cmd;
-	struct net_device_stats stats;
 	spinlock_t cmd_lock;
 };
 
@@ -381,7 +380,6 @@ static int i596_open(struct net_device *dev);
 static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t i596_interrupt(int irq, void *dev_id);
 static int i596_close(struct net_device *dev);
-static struct net_device_stats *i596_get_stats(struct net_device *dev);
 static void i596_add_cmd(struct net_device *dev, struct i596_cmd *cmd);
 static void print_eth(char *);
 static void set_multicast_list(struct net_device *dev);
@@ -672,7 +670,7 @@ i596_rx_one(struct net_device *dev, struct i596_private *lp,
 		if (skb == NULL) {
 			printk ("%s: i596_rx Memory squeeze, "
 				"dropping packet.\n", dev->name);
-			lp->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			return 1;
 		}
 
@@ -681,27 +679,27 @@ i596_rx_one(struct net_device *dev, struct i596_private *lp,
 		skb->protocol = eth_type_trans(skb,dev);
 		netif_rx(skb);
 		dev->last_rx = jiffies;
-		lp->stats.rx_packets++;
+		dev->stats.rx_packets++;
 	} else {
 #if 0
 		printk("Frame reception error status %04x\n",
 		       rfd->stat);
 #endif
-		lp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		if (rfd->stat & RFD_COLLISION)
-			lp->stats.collisions++;
+			dev->stats.collisions++;
 		if (rfd->stat & RFD_SHORT_FRAME_ERR)
-			lp->stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 		if (rfd->stat & RFD_DMA_ERR)
-			lp->stats.rx_over_errors++;
+			dev->stats.rx_over_errors++;
 		if (rfd->stat & RFD_NOBUFS_ERR)
-			lp->stats.rx_fifo_errors++;
+			dev->stats.rx_fifo_errors++;
 		if (rfd->stat & RFD_ALIGN_ERR)
-			lp->stats.rx_frame_errors++;
+			dev->stats.rx_frame_errors++;
 		if (rfd->stat & RFD_CRC_ERR)
-			lp->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 		if (rfd->stat & RFD_LENGTH_ERR)
-			lp->stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 	}
 	rfd->stat = rfd->count = 0;
 	return 0;
@@ -757,8 +755,8 @@ i596_cleanup_cmd(struct net_device *dev) {
 
 				dev_kfree_skb_any(tx_cmd_tbd->skb);
 
-				lp->stats.tx_errors++;
-				lp->stats.tx_aborted_errors++;
+				dev->stats.tx_errors++;
+				dev->stats.tx_aborted_errors++;
 
 				cmd->pa_next = I596_NULL;
 				kfree((unsigned char *)tx_cmd);
@@ -869,7 +867,6 @@ static int i596_open(struct net_device *dev)
 }
 
 static int i596_start_xmit (struct sk_buff *skb, struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
 	struct tx_cmd *tx_cmd;
 	short length;
 
@@ -886,7 +883,7 @@ static int i596_start_xmit (struct sk_buff *skb, struct net_device *dev) {
 	tx_cmd = kmalloc((sizeof (struct tx_cmd) + sizeof (struct i596_tbd)), GFP_ATOMIC);
 	if (tx_cmd == NULL) {
 		printk(KERN_WARNING "%s: i596_xmit Memory squeeze, dropping packet.\n", dev->name);
-		lp->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		dev_kfree_skb (skb);
 	} else {
 		struct i596_tbd *tx_cmd_tbd;
@@ -909,7 +906,7 @@ static int i596_start_xmit (struct sk_buff *skb, struct net_device *dev) {
 
 		i596_add_cmd (dev, (struct i596_cmd *) tx_cmd);
 
-		lp->stats.tx_packets++;
+		dev->stats.tx_packets++;
 	}
 
 	return 0;
@@ -922,10 +919,10 @@ i596_tx_timeout (struct net_device *dev) {
 
 	/* Transmitter timeout, serious problems. */
 	printk(KERN_WARNING "%s: transmit timed out, status resetting.\n", dev->name);
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 
 	/* Try to restart the adaptor */
-	if (lp->last_restart == lp->stats.tx_packets) {
+	if (lp->last_restart == dev->stats.tx_packets) {
 		printk ("Resetting board.\n");
 
 		/* Shutdown and restart */
@@ -935,7 +932,7 @@ i596_tx_timeout (struct net_device *dev) {
 		printk ("Kicking board.\n");
 		lp->scb.command = (CUC_START | RX_START);
 		CA();
-		lp->last_restart = lp->stats.tx_packets;
+		lp->last_restart = dev->stats.tx_packets;
 	}
 	netif_wake_queue(dev);
 }
@@ -1023,7 +1020,6 @@ static int __init lp486e_probe(struct net_device *dev) {
 	dev->open = &i596_open;
 	dev->stop = &i596_close;
 	dev->hard_start_xmit = &i596_start_xmit;
-	dev->get_stats = &i596_get_stats;
 	dev->set_multicast_list = &set_multicast_list;
 	dev->watchdog_timeo = 5*HZ;
 	dev->tx_timeout = i596_tx_timeout;
@@ -1080,20 +1076,20 @@ i596_handle_CU_completion(struct net_device *dev,
 				if (i596_debug)
 					print_eth(pa_to_va(tx_cmd_tbd->pa_data));
 			} else {
-				lp->stats.tx_errors++;
+				dev->stats.tx_errors++;
 				if (i596_debug)
 					printk("transmission failure:%04x\n",
 					       cmd->status);
 				if (cmd->status & 0x0020)
-					lp->stats.collisions++;
+					dev->stats.collisions++;
 				if (!(cmd->status & 0x0040))
-					lp->stats.tx_heartbeat_errors++;
+					dev->stats.tx_heartbeat_errors++;
 				if (cmd->status & 0x0400)
-					lp->stats.tx_carrier_errors++;
+					dev->stats.tx_carrier_errors++;
 				if (cmd->status & 0x0800)
-					lp->stats.collisions++;
+					dev->stats.collisions++;
 				if (cmd->status & 0x1000)
-					lp->stats.tx_aborted_errors++;
+					dev->stats.tx_aborted_errors++;
 			}
 			dev_kfree_skb_irq(tx_cmd_tbd->skb);
 
@@ -1244,12 +1240,6 @@ static int i596_close(struct net_device *dev) {
 	return 0;
 }
 
-static struct net_device_stats * i596_get_stats(struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
-
-	return &lp->stats;
-}
-
 /*
 *	Set or clear the multicast filter for this adaptor.
 */
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index 52b9332..76b7dfb 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -57,7 +57,6 @@ struct mace_data {
     unsigned char tx_fullup;
     unsigned char tx_active;
     unsigned char tx_bad_runt;
-    struct net_device_stats stats;
     struct timer_list tx_timeout;
     int timeout_active;
     int port_aaui;
@@ -78,7 +77,6 @@ struct mace_data {
 static int mace_open(struct net_device *dev);
 static int mace_close(struct net_device *dev);
 static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev);
-static struct net_device_stats *mace_stats(struct net_device *dev);
 static void mace_set_multicast(struct net_device *dev);
 static void mace_reset(struct net_device *dev);
 static int mace_set_address(struct net_device *dev, void *addr);
@@ -189,7 +187,6 @@ static int __devinit mace_probe(struct macio_dev *mdev, const struct of_device_i
 	mp->tx_cmds = (volatile struct dbdma_cmd *) DBDMA_ALIGN(mp + 1);
 	mp->rx_cmds = mp->tx_cmds + NCMDS_TX * N_TX_RING + 1;
 
-	memset(&mp->stats, 0, sizeof(mp->stats));
 	memset((char *) mp->tx_cmds, 0,
 	       (NCMDS_TX*N_TX_RING + N_RX_RING + 2) * sizeof(struct dbdma_cmd));
 	init_timer(&mp->tx_timeout);
@@ -214,7 +211,6 @@ static int __devinit mace_probe(struct macio_dev *mdev, const struct of_device_i
 	dev->open = mace_open;
 	dev->stop = mace_close;
 	dev->hard_start_xmit = mace_xmit_start;
-	dev->get_stats = mace_stats;
 	dev->set_multicast_list = mace_set_multicast;
 	dev->set_mac_address = mace_set_address;
 
@@ -585,13 +581,6 @@ static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
     return 0;
 }
 
-static struct net_device_stats *mace_stats(struct net_device *dev)
-{
-    struct mace_data *p = (struct mace_data *) dev->priv;
-
-    return &p->stats;
-}
-
 static void mace_set_multicast(struct net_device *dev)
 {
     struct mace_data *mp = (struct mace_data *) dev->priv;
@@ -651,13 +640,13 @@ static void mace_handle_misc_intrs(struct mace_data *mp, int intr)
     static int mace_babbles, mace_jabbers;
 
     if (intr & MPCO)
-	mp->stats.rx_missed_errors += 256;
-    mp->stats.rx_missed_errors += in_8(&mb->mpc);   /* reading clears it */
+	dev->stats.rx_missed_errors += 256;
+    dev->stats.rx_missed_errors += in_8(&mb->mpc);   /* reading clears it */
     if (intr & RNTPCO)
-	mp->stats.rx_length_errors += 256;
-    mp->stats.rx_length_errors += in_8(&mb->rntpc); /* reading clears it */
+	dev->stats.rx_length_errors += 256;
+    dev->stats.rx_length_errors += in_8(&mb->rntpc); /* reading clears it */
     if (intr & CERR)
-	++mp->stats.tx_heartbeat_errors;
+	++dev->stats.tx_heartbeat_errors;
     if (intr & BABBLE)
 	if (mace_babbles++ < 4)
 	    printk(KERN_DEBUG "mace: babbling transmitter\n");
@@ -768,14 +757,14 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
 	}
 	/* Update stats */
 	if (fs & (UFLO|LCOL|LCAR|RTRY)) {
-	    ++mp->stats.tx_errors;
+	    ++dev->stats.tx_errors;
 	    if (fs & LCAR)
-		++mp->stats.tx_carrier_errors;
+		++dev->stats.tx_carrier_errors;
 	    if (fs & (UFLO|LCOL|RTRY))
-		++mp->stats.tx_aborted_errors;
+		++dev->stats.tx_aborted_errors;
 	} else {
-	    mp->stats.tx_bytes += mp->tx_bufs[i]->len;
-	    ++mp->stats.tx_packets;
+	    dev->stats.tx_bytes += mp->tx_bufs[i]->len;
+	    ++dev->stats.tx_packets;
 	}
 	dev_kfree_skb_irq(mp->tx_bufs[i]);
 	--mp->tx_active;
@@ -849,7 +838,7 @@ static void mace_tx_timeout(unsigned long data)
     /* fix up the transmit side */
     i = mp->tx_empty;
     mp->tx_active = 0;
-    ++mp->stats.tx_errors;
+    ++dev->stats.tx_errors;
     if (mp->tx_bad_runt) {
 	mp->tx_bad_runt = 0;
     } else if (i != mp->tx_fill) {
@@ -917,18 +906,18 @@ static irqreturn_t mace_rxdma_intr(int irq, void *dev_id)
 	/* got a packet, have a look at it */
 	skb = mp->rx_bufs[i];
 	if (skb == 0) {
-	    ++mp->stats.rx_dropped;
+	    ++dev->stats.rx_dropped;
 	} else if (nb > 8) {
 	    data = skb->data;
 	    frame_status = (data[nb-3] << 8) + data[nb-4];
 	    if (frame_status & (RS_OFLO|RS_CLSN|RS_FRAMERR|RS_FCSERR)) {
-		++mp->stats.rx_errors;
+		++dev->stats.rx_errors;
 		if (frame_status & RS_OFLO)
-		    ++mp->stats.rx_over_errors;
+		    ++dev->stats.rx_over_errors;
 		if (frame_status & RS_FRAMERR)
-		    ++mp->stats.rx_frame_errors;
+		    ++dev->stats.rx_frame_errors;
 		if (frame_status & RS_FCSERR)
-		    ++mp->stats.rx_crc_errors;
+		    ++dev->stats.rx_crc_errors;
 	    } else {
 		/* Mace feature AUTO_STRIP_RCV is on by default, dropping the
 		 * FCS on frames with 802.3 headers. This means that Ethernet
@@ -940,15 +929,15 @@ static irqreturn_t mace_rxdma_intr(int irq, void *dev_id)
 		    nb -= 8;
 		skb_put(skb, nb);
 		skb->protocol = eth_type_trans(skb, dev);
-		mp->stats.rx_bytes += skb->len;
+		dev->stats.rx_bytes += skb->len;
 		netif_rx(skb);
 		dev->last_rx = jiffies;
 		mp->rx_bufs[i] = NULL;
-		++mp->stats.rx_packets;
+		++dev->stats.rx_packets;
 	    }
 	} else {
-	    ++mp->stats.rx_errors;
-	    ++mp->stats.rx_length_errors;
+	    ++dev->stats.rx_errors;
+	    ++dev->stats.rx_length_errors;
 	}
 
 	/* advance to next */
diff --git a/drivers/net/macmace.c b/drivers/net/macmace.c
index 9a343b9..343bb8f 100644
--- a/drivers/net/macmace.c
+++ b/drivers/net/macmace.c
@@ -65,7 +65,6 @@ struct mace_data {
 	unsigned char *rx_ring;
 	dma_addr_t rx_ring_phys;
 	int dma_intr;
-	struct net_device_stats stats;
 	int rx_slot, rx_tail;
 	int tx_slot, tx_sloti, tx_count;
 	int chipid;
@@ -92,7 +91,6 @@ struct mace_frame {
 static int mace_open(struct net_device *dev);
 static int mace_close(struct net_device *dev);
 static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev);
-static struct net_device_stats *mace_stats(struct net_device *dev);
 static void mace_set_multicast(struct net_device *dev);
 static int mace_set_address(struct net_device *dev, void *addr);
 static void mace_reset(struct net_device *dev);
@@ -243,14 +241,11 @@ static int __devinit mace_probe(struct platform_device *pdev)
 		return -ENODEV;
 	}
 
-	memset(&mp->stats, 0, sizeof(mp->stats));
-
 	dev->open		= mace_open;
 	dev->stop		= mace_close;
 	dev->hard_start_xmit	= mace_xmit_start;
 	dev->tx_timeout		= mace_tx_timeout;
 	dev->watchdog_timeo	= TX_TIMEOUT;
-	dev->get_stats		= mace_stats;
 	dev->set_multicast_list	= mace_set_multicast;
 	dev->set_mac_address	= mace_set_address;
 
@@ -473,8 +468,8 @@ static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
 	mp->tx_count--;
 	local_irq_restore(flags);
 
-	mp->stats.tx_packets++;
-	mp->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	/* We need to copy into our xmit buffer to take care of alignment and caching issues */
 	skb_copy_from_linear_data(skb, mp->tx_ring, skb->len);
@@ -493,12 +488,6 @@ static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static struct net_device_stats *mace_stats(struct net_device *dev)
-{
-	struct mace_data *mp = netdev_priv(dev);
-	return &mp->stats;
-}
-
 static void mace_set_multicast(struct net_device *dev)
 {
 	struct mace_data *mp = netdev_priv(dev);
@@ -556,13 +545,13 @@ static void mace_handle_misc_intrs(struct mace_data *mp, int intr)
 	static int mace_babbles, mace_jabbers;
 
 	if (intr & MPCO)
-		mp->stats.rx_missed_errors += 256;
-	mp->stats.rx_missed_errors += mb->mpc;   /* reading clears it */
+		dev->stats.rx_missed_errors += 256;
+	dev->stats.rx_missed_errors += mb->mpc;   /* reading clears it */
 	if (intr & RNTPCO)
-		mp->stats.rx_length_errors += 256;
-	mp->stats.rx_length_errors += mb->rntpc; /* reading clears it */
+		dev->stats.rx_length_errors += 256;
+	dev->stats.rx_length_errors += mb->rntpc; /* reading clears it */
 	if (intr & CERR)
-		++mp->stats.tx_heartbeat_errors;
+		++dev->stats.tx_heartbeat_errors;
 	if (intr & BABBLE)
 		if (mace_babbles++ < 4)
 			printk(KERN_DEBUG "macmace: babbling transmitter\n");
@@ -601,14 +590,14 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
 		}
 		/* Update stats */
 		if (fs & (UFLO|LCOL|LCAR|RTRY)) {
-			++mp->stats.tx_errors;
+			++dev->stats.tx_errors;
 			if (fs & LCAR)
-				++mp->stats.tx_carrier_errors;
+				++dev->stats.tx_carrier_errors;
 			else if (fs & (UFLO|LCOL|RTRY)) {
-				++mp->stats.tx_aborted_errors;
+				++dev->stats.tx_aborted_errors;
 				if (mb->xmtfs & UFLO) {
 					printk(KERN_ERR "%s: DMA underrun.\n", dev->name);
-					mp->stats.tx_fifo_errors++;
+					dev->stats.tx_fifo_errors++;
 					mace_txdma_reset(dev);
 				}
 			}
@@ -662,23 +651,23 @@ static void mace_dma_rx_frame(struct net_device *dev, struct mace_frame *mf)
 	unsigned int frame_status = mf->rcvsts;
 
 	if (frame_status & (RS_OFLO | RS_CLSN | RS_FRAMERR | RS_FCSERR)) {
-		mp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		if (frame_status & RS_OFLO) {
 			printk(KERN_DEBUG "%s: fifo overflow.\n", dev->name);
-			mp->stats.rx_fifo_errors++;
+			dev->stats.rx_fifo_errors++;
 		}
 		if (frame_status & RS_CLSN)
-			mp->stats.collisions++;
+			dev->stats.collisions++;
 		if (frame_status & RS_FRAMERR)
-			mp->stats.rx_frame_errors++;
+			dev->stats.rx_frame_errors++;
 		if (frame_status & RS_FCSERR)
-			mp->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 	} else {
 		unsigned int frame_length = mf->rcvcnt + ((frame_status & 0x0F) << 8 );
 
 		skb = dev_alloc_skb(frame_length + 2);
 		if (!skb) {
-			mp->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			return;
 		}
 		skb_reserve(skb, 2);
@@ -687,8 +676,8 @@ static void mace_dma_rx_frame(struct net_device *dev, struct mace_frame *mf)
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
 		dev->last_rx = jiffies;
-		mp->stats.rx_packets++;
-		mp->stats.rx_bytes += frame_length;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += frame_length;
 	}
 }
 
diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index 32bed6b..fe5b6c3 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -66,7 +66,6 @@ module_param(timeout, int, 0);
  * packets in and out, so there is place for a packet
  */
 struct meth_private {
-	struct net_device_stats stats;
 	/* in-memory copy of MAC Control register */
 	unsigned long mac_ctrl;
 	/* in-memory copy of DMA Control register */
@@ -401,15 +400,15 @@ static void meth_rx(struct net_device* dev, unsigned long int_status)
 				printk(KERN_DEBUG "%s: bogus packet size: %ld, status=%#2lx.\n",
 				       dev->name, priv->rx_write,
 				       priv->rx_ring[priv->rx_write]->status.raw);
-				priv->stats.rx_errors++;
-				priv->stats.rx_length_errors++;
+				dev->stats.rx_errors++;
+				dev->stats.rx_length_errors++;
 				skb = priv->rx_skbs[priv->rx_write];
 			} else {
 				skb = alloc_skb(METH_RX_BUFF_SIZE, GFP_ATOMIC);
 				if (!skb) {
 					/* Ouch! No memory! Drop packet on the floor */
 					DPRINTK("No mem: dropping packet\n");
-					priv->stats.rx_dropped++;
+					dev->stats.rx_dropped++;
 					skb = priv->rx_skbs[priv->rx_write];
 				} else {
 					struct sk_buff *skb_c = priv->rx_skbs[priv->rx_write];
@@ -421,13 +420,13 @@ static void meth_rx(struct net_device* dev, unsigned long int_status)
 					priv->rx_skbs[priv->rx_write] = skb;
 					skb_c->protocol = eth_type_trans(skb_c, dev);
 					dev->last_rx = jiffies;
-					priv->stats.rx_packets++;
-					priv->stats.rx_bytes += len;
+					dev->stats.rx_packets++;
+					dev->stats.rx_bytes += len;
 					netif_rx(skb_c);
 				}
 			}
 		} else {
-			priv->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			skb=priv->rx_skbs[priv->rx_write];
 #if MFE_DEBUG>0
 			printk(KERN_WARNING "meth: RX error: status=0x%016lx\n",status);
@@ -490,10 +489,10 @@ static void meth_tx_cleanup(struct net_device* dev, unsigned long int_status)
 #endif
 		if (status & METH_TX_ST_DONE) {
 			if (status & METH_TX_ST_SUCCESS){
-				priv->stats.tx_packets++;
-				priv->stats.tx_bytes += skb->len;
+				dev->stats.tx_packets++;
+				dev->stats.tx_bytes += skb->len;
 			} else {
-				priv->stats.tx_errors++;
+				dev->stats.tx_errors++;
 #if MFE_DEBUG>=1
 				DPRINTK("TX error: status=%016lx <",status);
 				if(status & METH_TX_ST_SUCCESS)
@@ -734,7 +733,7 @@ static void meth_tx_timeout(struct net_device *dev)
 	/* Try to reset the interface. */
 	meth_reset(dev);
 
-	priv->stats.tx_errors++;
+	dev->stats.tx_errors++;
 
 	/* Clear all rings */
 	meth_free_tx_ring(priv);
@@ -773,12 +772,6 @@ static int meth_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 /*
  * Return statistics to the caller
  */
-static struct net_device_stats *meth_stats(struct net_device *dev)
-{
-	struct meth_private *priv = netdev_priv(dev);
-	return &priv->stats;
-}
-
 /*
  * The init function.
  */
@@ -796,7 +789,6 @@ static int __init meth_probe(struct platform_device *pdev)
 	dev->stop            = meth_release;
 	dev->hard_start_xmit = meth_tx;
 	dev->do_ioctl        = meth_ioctl;
-	dev->get_stats       = meth_stats;
 #ifdef HAVE_TX_TIMEOUT
 	dev->tx_timeout      = meth_tx_timeout;
 	dev->watchdog_timeo  = timeout;
diff --git a/drivers/net/mipsnet.c b/drivers/net/mipsnet.c
index c0f5ad3..d593175 100644
--- a/drivers/net/mipsnet.c
+++ b/drivers/net/mipsnet.c
@@ -21,10 +21,6 @@
 
 #define mipsnet_reg_address(dev, field) (dev->base_addr + field_offset(field))
 
-struct mipsnet_priv {
-	struct net_device_stats stats;
-};
-
 static char mipsnet_string[] = "mipsnet";
 
 /*
@@ -49,7 +45,6 @@ static inline ssize_t mipsnet_put_todevice(struct net_device *dev,
 {
 	int count_to_go = skb->len;
 	char *buf_ptr = skb->data;
-	struct mipsnet_priv *mp = netdev_priv(dev);
 
 	pr_debug("%s: %s(): telling MIPSNET txDataCount(%d)\n",
 	         dev->name, __FUNCTION__, skb->len);
@@ -63,8 +58,8 @@ static inline ssize_t mipsnet_put_todevice(struct net_device *dev,
 		outb(*buf_ptr, mipsnet_reg_address(dev, txDataBuffer));
 	}
 
-	mp->stats.tx_packets++;
-	mp->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	return skb->len;
 }
@@ -87,10 +82,9 @@ static inline ssize_t mipsnet_get_fromdev(struct net_device *dev, size_t count)
 {
 	struct sk_buff *skb;
 	size_t len = count;
-	struct mipsnet_priv *mp = netdev_priv(dev);
 
 	if (!(skb = alloc_skb(len + 2, GFP_KERNEL))) {
-		mp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return -ENOMEM;
 	}
 
@@ -105,8 +99,8 @@ static inline ssize_t mipsnet_get_fromdev(struct net_device *dev, size_t count)
 	         dev->name, __FUNCTION__);
 	netif_rx(skb);
 
-	mp->stats.rx_packets++;
-	mp->stats.rx_bytes += len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += len;
 
 	return count;
 }
@@ -203,13 +197,6 @@ static int mipsnet_close(struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *mipsnet_get_stats(struct net_device *dev)
-{
-	struct mipsnet_priv *mp = netdev_priv(dev);
-
-	return &mp->stats;
-}
-
 static void mipsnet_set_mclist(struct net_device *dev)
 {
 	// we don't do anything
@@ -221,7 +208,7 @@ static int __init mipsnet_probe(struct device *dev)
 	struct net_device *netdev;
 	int err;
 
-	netdev = alloc_etherdev(sizeof(struct mipsnet_priv));
+	netdev = alloc_etherdev(0);
 	if (!netdev) {
 		err = -ENOMEM;
 		goto out;
@@ -232,7 +219,6 @@ static int __init mipsnet_probe(struct device *dev)
 	netdev->open			= mipsnet_open;
 	netdev->stop			= mipsnet_close;
 	netdev->hard_start_xmit		= mipsnet_xmit;
-	netdev->get_stats		= mipsnet_get_stats;
 	netdev->set_multicast_list	= mipsnet_set_mclist;
 
 	/*
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1799eee..6d8b360 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -63,7 +63,6 @@ static unsigned int mv643xx_eth_port_disable_rx(unsigned int port_num);
 static int mv643xx_eth_open(struct net_device *);
 static int mv643xx_eth_stop(struct net_device *);
 static int mv643xx_eth_change_mtu(struct net_device *, int);
-static struct net_device_stats *mv643xx_eth_get_stats(struct net_device *);
 static void eth_port_init_mac_tables(unsigned int eth_port_num);
 #ifdef MV643XX_NAPI
 static int mv643xx_poll(struct net_device *dev, int *budget);
@@ -341,7 +340,7 @@ int mv643xx_eth_free_tx_descs(struct net_device *dev, int force)
 
 		if (cmd_sts & ETH_ERROR_SUMMARY) {
 			printk("%s: Error in TX\n", dev->name);
-			mp->stats.tx_errors++;
+			dev->stats.tx_errors++;
 		}
 
 		spin_unlock_irqrestore(&mp->lock, flags);
@@ -388,7 +387,7 @@ static void mv643xx_eth_free_all_tx_descs(struct net_device *dev)
 static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
-	struct net_device_stats *stats = &mp->stats;
+	struct net_device_stats *stats = &dev->stats;
 	unsigned int received_packets = 0;
 	struct sk_buff *skb;
 	struct pkt_info pkt_info;
@@ -1198,7 +1197,7 @@ static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
 static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
-	struct net_device_stats *stats = &mp->stats;
+	struct net_device_stats *stats = &dev->stats;
 	unsigned long flags;
 
 	BUG_ON(netif_queue_stopped(dev));
@@ -1234,23 +1233,6 @@ static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;		/* success */
 }
 
-/*
- * mv643xx_eth_get_stats
- *
- * Returns a pointer to the interface statistics.
- *
- * Input :	dev - a pointer to the required interface
- *
- * Output :	a pointer to the interface's statistics
- */
-
-static struct net_device_stats *mv643xx_eth_get_stats(struct net_device *dev)
-{
-	struct mv643xx_private *mp = netdev_priv(dev);
-
-	return &mp->stats;
-}
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void mv643xx_netpoll(struct net_device *netdev)
 {
@@ -1341,7 +1323,6 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	dev->open = mv643xx_eth_open;
 	dev->stop = mv643xx_eth_stop;
 	dev->hard_start_xmit = mv643xx_eth_start_xmit;
-	dev->get_stats = mv643xx_eth_get_stats;
 	dev->set_mac_address = mv643xx_eth_set_mac_address;
 	dev->set_multicast_list = mv643xx_eth_set_rx_mode;
 
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 13444da..bb018ca 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -353,7 +353,7 @@ static void myri_tx(struct myri_eth *mp, struct net_device *dev)
 		sbus_unmap_single(mp->myri_sdev, dma_addr, skb->len, SBUS_DMA_TODEVICE);
 		dev_kfree_skb(skb);
 		mp->tx_skbs[entry] = NULL;
-		mp->enet_stats.tx_packets++;
+		dev->stats.tx_packets++;
 		entry = NEXT_TX(entry);
 	}
 	mp->tx_old = entry;
@@ -434,20 +434,20 @@ static void myri_rx(struct myri_eth *mp, struct net_device *dev)
 					     RX_ALLOC_SIZE, SBUS_DMA_FROMDEVICE);
 		if (len < (ETH_HLEN + MYRI_PAD_LEN) || (skb->data[0] != MYRI_PAD_LEN)) {
 			DRX(("ERROR["));
-			mp->enet_stats.rx_errors++;
+			dev->stats.rx_errors++;
 			if (len < (ETH_HLEN + MYRI_PAD_LEN)) {
 				DRX(("BAD_LENGTH] "));
-				mp->enet_stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			} else {
 				DRX(("NO_PADDING] "));
-				mp->enet_stats.rx_frame_errors++;
+				dev->stats.rx_frame_errors++;
 			}
 
 			/* Return it to the LANAI. */
 	drop_it:
 			drops++;
 			DRX(("DROP "));
-			mp->enet_stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			sbus_dma_sync_single_for_device(mp->myri_sdev,
 							sbus_readl(&rxd->myri_scatters[0].addr),
 							RX_ALLOC_SIZE,
@@ -527,8 +527,8 @@ static void myri_rx(struct myri_eth *mp, struct net_device *dev)
 		netif_rx(skb);
 
 		dev->last_rx = jiffies;
-		mp->enet_stats.rx_packets++;
-		mp->enet_stats.rx_bytes += len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += len;
 	next:
 		DRX(("NEXT\n"));
 		entry = NEXT_RX(entry);
@@ -596,7 +596,7 @@ static void myri_tx_timeout(struct net_device *dev)
 
 	printk(KERN_ERR "%s: transmit timed out, resetting\n", dev->name);
 
-	mp->enet_stats.tx_errors++;
+	dev->stats.tx_errors++;
 	myri_init(mp, 0);
 	netif_wake_queue(dev);
 }
@@ -806,9 +806,6 @@ static int myri_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-static struct net_device_stats *myri_get_stats(struct net_device *dev)
-{ return &(((struct myri_eth *)dev->priv)->enet_stats); }
-
 static void myri_set_multicast(struct net_device *dev)
 {
 	/* Do nothing, all MyriCOM nodes transmit multicast frames
@@ -1061,7 +1058,6 @@ static int __devinit myri_ether_init(struct sbus_dev *sdev)
 	dev->hard_start_xmit = &myri_start_xmit;
 	dev->tx_timeout = &myri_tx_timeout;
 	dev->watchdog_timeo = 5*HZ;
-	dev->get_stats = &myri_get_stats;
 	dev->set_multicast_list = &myri_set_multicast;
 	dev->irq = sdev->irqs[0];
 
diff --git a/drivers/net/myri_sbus.h b/drivers/net/myri_sbus.h
index 2f69ef7..5d93fcc 100644
--- a/drivers/net/myri_sbus.h
+++ b/drivers/net/myri_sbus.h
@@ -280,7 +280,6 @@ struct myri_eth {
 	void __iomem			*lregs;		/* Quick ptr to LANAI regs.   */
 	struct sk_buff	       *rx_skbs[RX_RING_SIZE+1];/* RX skb's                   */
 	struct sk_buff	       *tx_skbs[TX_RING_SIZE];  /* TX skb's                   */
-	struct net_device_stats		enet_stats;	/* Interface stats.           */
 
 	/* These are less frequently accessed. */
 	void __iomem			*regs;          /* MyriCOM register space.    */
diff --git a/drivers/net/netx-eth.c b/drivers/net/netx-eth.c
index 2b8da0a..f621342 100644
--- a/drivers/net/netx-eth.c
+++ b/drivers/net/netx-eth.c
@@ -97,7 +97,6 @@
 struct netx_eth_priv {
 	void                    __iomem *sram_base, *xpec_base, *xmac_base;
 	int                     id;
-	struct net_device_stats stats;
 	struct mii_if_info      mii;
 	u32                     msg_enable;
 	struct xc               *xc;
@@ -129,8 +128,8 @@ netx_eth_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	           FIFO_PTR_FRAMELEN(len));
 
 	ndev->trans_start = jiffies;
-	priv->stats.tx_packets++;
-	priv->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	netif_stop_queue(ndev);
 	spin_unlock_irq(&priv->lock);
@@ -156,7 +155,7 @@ static void netx_eth_receive(struct net_device *ndev)
 	if (unlikely(skb == NULL)) {
 		printk(KERN_NOTICE "%s: Low memory, packet dropped.\n",
 			ndev->name);
-		priv->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 
@@ -170,8 +169,8 @@ static void netx_eth_receive(struct net_device *ndev)
 	ndev->last_rx = jiffies;
 	skb->protocol = eth_type_trans(skb, ndev);
 	netif_rx(skb);
-	priv->stats.rx_packets++;
-	priv->stats.rx_bytes += len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += len;
 }
 
 static irqreturn_t
@@ -210,12 +209,6 @@ netx_eth_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static struct net_device_stats *netx_eth_query_statistics(struct net_device *ndev)
-{
-	struct netx_eth_priv *priv = netdev_priv(ndev);
-	return &priv->stats;
-}
-
 static int netx_eth_open(struct net_device *ndev)
 {
 	struct netx_eth_priv *priv = netdev_priv(ndev);
@@ -323,7 +316,6 @@ static int netx_eth_enable(struct net_device *ndev)
 	ndev->hard_start_xmit = netx_eth_hard_start_xmit;
 	ndev->tx_timeout = netx_eth_timeout;
 	ndev->watchdog_timeo = msecs_to_jiffies(5000);
-	ndev->get_stats = netx_eth_query_statistics;
 	ndev->set_multicast_list = netx_eth_set_multicast_list;
 
 	priv->msg_enable       = NETIF_MSG_LINK;
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index 22a3b3d..4dda7ae 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -89,7 +89,6 @@ static unsigned int ports[] __initdata =
 
 /* Information that needs to be kept for each board. */
 struct ni5010_local {
-	struct net_device_stats stats;
 	int o_pkt_size;
 	spinlock_t lock;
 };
@@ -103,7 +102,6 @@ static irqreturn_t ni5010_interrupt(int irq, void *dev_id);
 static void	ni5010_rx(struct net_device *dev);
 static void	ni5010_timeout(struct net_device *dev);
 static int	ni5010_close(struct net_device *dev);
-static struct net_device_stats *ni5010_get_stats(struct net_device *dev);
 static void 	ni5010_set_multicast_list(struct net_device *dev);
 static void	reset_receiver(struct net_device *dev);
 
@@ -336,7 +334,6 @@ static int __init ni5010_probe1(struct net_device *dev, int ioaddr)
 	dev->open		= ni5010_open;
 	dev->stop		= ni5010_close;
 	dev->hard_start_xmit	= ni5010_send_packet;
-	dev->get_stats		= ni5010_get_stats;
 	dev->set_multicast_list = ni5010_set_multicast_list;
 	dev->tx_timeout		= ni5010_timeout;
 	dev->watchdog_timeo	= HZ/20;
@@ -534,11 +531,11 @@ static void ni5010_rx(struct net_device *dev)
 
 	if ( (rcv_stat & RS_VALID_BITS) != RS_PKT_OK) {
 		PRINTK((KERN_INFO "%s: receive error.\n", dev->name));
-		lp->stats.rx_errors++;
-		if (rcv_stat & RS_RUNT) lp->stats.rx_length_errors++;
-		if (rcv_stat & RS_ALIGN) lp->stats.rx_frame_errors++;
-		if (rcv_stat & RS_CRC_ERR) lp->stats.rx_crc_errors++;
-		if (rcv_stat & RS_OFLW) lp->stats.rx_fifo_errors++;
+		dev->stats.rx_errors++;
+		if (rcv_stat & RS_RUNT) dev->stats.rx_length_errors++;
+		if (rcv_stat & RS_ALIGN) dev->stats.rx_frame_errors++;
+		if (rcv_stat & RS_CRC_ERR) dev->stats.rx_crc_errors++;
+		if (rcv_stat & RS_OFLW) dev->stats.rx_fifo_errors++;
         	outb(0xff, EDLC_RCLR); /* Clear the interrupt */
 		return;
 	}
@@ -549,8 +546,8 @@ static void ni5010_rx(struct net_device *dev)
 	if (i_pkt_size > ETH_FRAME_LEN || i_pkt_size < 10 ) {
 		PRINTK((KERN_DEBUG "%s: Packet size error, packet size = %#4.4x\n",
 			dev->name, i_pkt_size));
-		lp->stats.rx_errors++;
-		lp->stats.rx_length_errors++;
+		dev->stats.rx_errors++;
+		dev->stats.rx_length_errors++;
 		return;
 	}
 
@@ -558,7 +555,7 @@ static void ni5010_rx(struct net_device *dev)
 	skb = dev_alloc_skb(i_pkt_size + 3);
 	if (skb == NULL) {
 		printk(KERN_WARNING "%s: Memory squeeze, dropping packet.\n", dev->name);
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 
@@ -575,8 +572,8 @@ static void ni5010_rx(struct net_device *dev)
 	skb->protocol = eth_type_trans(skb,dev);
 	netif_rx(skb);
 	dev->last_rx = jiffies;
-	lp->stats.rx_packets++;
-	lp->stats.rx_bytes += i_pkt_size;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += i_pkt_size;
 
 	PRINTK2((KERN_DEBUG "%s: Received packet, size=%#4.4x\n",
 		dev->name, i_pkt_size));
@@ -604,14 +601,14 @@ static int process_xmt_interrupt(struct net_device *dev)
 		/* outb(0, IE_MMODE); */ /* xmt buf on sysbus FIXME: needed ? */
 		outb(MM_EN_XMT | MM_MUX, IE_MMODE);
 		outb(XM_ALL, EDLC_XMASK); /* Enable xmt IRQ's */
-		lp->stats.collisions++;
+		dev->stats.collisions++;
 		return 1;
 	}
 
 	/* FIXME: handle other xmt error conditions */
 
-	lp->stats.tx_packets++;
-	lp->stats.tx_bytes += lp->o_pkt_size;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += lp->o_pkt_size;
 	netif_wake_queue(dev);
 
 	PRINTK2((KERN_DEBUG "%s: sent packet, size=%#4.4x\n",
@@ -640,24 +637,6 @@ static int ni5010_close(struct net_device *dev)
 
 }
 
-/* Get the current statistics.	This may be called with the card open or
-   closed. */
-static struct net_device_stats *ni5010_get_stats(struct net_device *dev)
-{
-	struct ni5010_local *lp = netdev_priv(dev);
-
-	PRINTK2((KERN_DEBUG "%s: entering ni5010_get_stats\n", dev->name));
-
-	if (NI5010_DEBUG) ni5010_show_registers(dev);
-
-	/* cli(); */
-	/* Update the statistics from the device registers. */
-	/* We do this in the interrupt handler */
-	/* sti(); */
-
-	return &lp->stats;
-}
-
 /* Set or clear the multicast filter for this adaptor.
    num_addrs == -1      Promiscuous mode, receive all packets
    num_addrs == 0       Normal mode, clear multicast list
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index ee394c1..f2d9166 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -530,8 +530,8 @@ static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 		} else
 			skb->ip_summed = CHECKSUM_NONE;
 
-		mac->stats.rx_bytes += len;
-		mac->stats.rx_packets++;
+		dev->stats.rx_bytes += len;
+		dev->stats.rx_packets++;
 
 		skb->protocol = eth_type_trans(skb, mac->netdev);
 		netif_receive_skb(skb);
@@ -1031,8 +1031,8 @@ static int pasemi_mac_start_tx(struct sk_buff *skb, struct net_device *dev)
 	info->skb = skb;
 
 	txring->next_to_fill++;
-	mac->stats.tx_packets++;
-	mac->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	spin_unlock_irqrestore(&txring->lock, flags);
 
@@ -1046,14 +1046,6 @@ out_err:
 	return NETDEV_TX_BUSY;
 }
 
-static struct net_device_stats *pasemi_mac_get_stats(struct net_device *dev)
-{
-	struct pasemi_mac *mac = netdev_priv(dev);
-
-	return &mac->stats;
-}
-
-
 static void pasemi_mac_set_rx_mode(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
@@ -1225,7 +1217,6 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->open = pasemi_mac_open;
 	dev->stop = pasemi_mac_close;
 	dev->hard_start_xmit = pasemi_mac_start_tx;
-	dev->get_stats = pasemi_mac_get_stats;
 	dev->set_multicast_list = pasemi_mac_set_rx_mode;
 	dev->weight = 64;
 	dev->poll = pasemi_mac_poll;
diff --git a/drivers/net/pasemi_mac.h b/drivers/net/pasemi_mac.h
index bfebdaa..2503a1c 100644
--- a/drivers/net/pasemi_mac.h
+++ b/drivers/net/pasemi_mac.h
@@ -59,7 +59,6 @@ struct pasemi_mac {
 	struct pci_dev *dma_pdev;
 	struct pci_dev *iob_pdev;
 	struct phy_device *phydev;
-	struct net_device_stats stats;
 
 	/* Pointer to the cacheable per-channel status registers */
 	u64	*rx_status;
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index 3cdbe11..0902627 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -457,7 +457,6 @@ struct netdrv_private {
 	void *mmio_addr;
 	int drv_flags;
 	struct pci_dev *pci_dev;
-	struct net_device_stats stats;
 	struct timer_list timer;	/* Media selection timer. */
 	unsigned char *rx_ring;
 	unsigned int cur_rx;	/* Index into the Rx buffer of next Rx pkt. */
@@ -505,7 +504,6 @@ static int netdrv_start_xmit (struct sk_buff *skb,
 static irqreturn_t netdrv_interrupt (int irq, void *dev_instance);
 static int netdrv_close (struct net_device *dev);
 static int netdrv_ioctl (struct net_device *dev, struct ifreq *rq, int cmd);
-static struct net_device_stats *netdrv_get_stats (struct net_device *dev);
 static void netdrv_set_rx_mode (struct net_device *dev);
 static void netdrv_hw_start (struct net_device *dev);
 
@@ -776,7 +774,6 @@ static int __devinit netdrv_init_one (struct pci_dev *pdev,
 	dev->open = netdrv_open;
 	dev->hard_start_xmit = netdrv_start_xmit;
 	dev->stop = netdrv_close;
-	dev->get_stats = netdrv_get_stats;
 	dev->set_multicast_list = netdrv_set_rx_mode;
 	dev->do_ioctl = netdrv_ioctl;
 	dev->tx_timeout = netdrv_tx_timeout;
@@ -1277,7 +1274,7 @@ static void netdrv_tx_clear (struct netdrv_private *tp)
 		if (rp->skb) {
 			dev_kfree_skb (rp->skb);
 			rp->skb = NULL;
-			tp->stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 		}
 	}
 }
@@ -1390,25 +1387,25 @@ static void netdrv_tx_interrupt (struct net_device *dev,
 			/* There was an major error, log it. */
 			DPRINTK ("%s: Transmit error, Tx status %8.8x.\n",
 				 dev->name, txstatus);
-			tp->stats.tx_errors++;
+			dev->stats.tx_errors++;
 			if (txstatus & TxAborted) {
-				tp->stats.tx_aborted_errors++;
+				dev->stats.tx_aborted_errors++;
 				NETDRV_W32 (TxConfig, TxClearAbt | (TX_DMA_BURST << TxDMAShift));
 			}
 			if (txstatus & TxCarrierLost)
-				tp->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 			if (txstatus & TxOutOfWindow)
-				tp->stats.tx_window_errors++;
+				dev->stats.tx_window_errors++;
 		} else {
 			if (txstatus & TxUnderrun) {
 				/* Add 64 to the Tx FIFO threshold. */
 				if (tp->tx_flag < 0x00300000)
 					tp->tx_flag += 0x00020000;
-				tp->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 			}
-			tp->stats.collisions += (txstatus >> 24) & 15;
-			tp->stats.tx_bytes += txstatus & 0x7ff;
-			tp->stats.tx_packets++;
+			dev->stats.collisions += (txstatus >> 24) & 15;
+			dev->stats.tx_bytes += txstatus & 0x7ff;
+			dev->stats.tx_packets++;
 		}
 
 		/* Free the original skb. */
@@ -1461,13 +1458,13 @@ static void netdrv_rx_err (u32 rx_status, struct net_device *dev,
 			 dev->name, rx_status);
 		/* A.C.: The chip hangs here. */
 	}
-	tp->stats.rx_errors++;
+	dev->stats.rx_errors++;
 	if (rx_status & (RxBadSymbol | RxBadAlign))
-		tp->stats.rx_frame_errors++;
+		dev->stats.rx_frame_errors++;
 	if (rx_status & (RxRunt | RxTooLong))
-		tp->stats.rx_length_errors++;
+		dev->stats.rx_length_errors++;
 	if (rx_status & RxCRCErr)
-		tp->stats.rx_crc_errors++;
+		dev->stats.rx_crc_errors++;
 	/* Reset the receiver, based on RealTek recommendation. (Bug?) */
 	tp->cur_rx = 0;
 
@@ -1573,13 +1570,13 @@ static void netdrv_rx_interrupt (struct net_device *dev,
 			skb->protocol = eth_type_trans (skb, dev);
 			netif_rx (skb);
 			dev->last_rx = jiffies;
-			tp->stats.rx_bytes += pkt_size;
-			tp->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_size;
+			dev->stats.rx_packets++;
 		} else {
 			printk (KERN_WARNING
 				"%s: Memory squeeze, dropping packet.\n",
 				dev->name);
-			tp->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 		}
 
 		cur_rx = (cur_rx + rx_size + 4 + 3) & ~3;
@@ -1608,7 +1605,7 @@ static void netdrv_weird_interrupt (struct net_device *dev,
 	assert (ioaddr != NULL);
 
 	/* Update the error count. */
-	tp->stats.rx_missed_errors += NETDRV_R32 (RxMissed);
+	dev->stats.rx_missed_errors += NETDRV_R32 (RxMissed);
 	NETDRV_W32 (RxMissed, 0);
 
 	if ((status & RxUnderrun) && link_changed &&
@@ -1629,14 +1626,14 @@ static void netdrv_weird_interrupt (struct net_device *dev,
 	/* XXX along with netdrv_rx_err, are we double-counting errors? */
 	if (status &
 	    (RxUnderrun | RxOverflow | RxErr | RxFIFOOver))
-		tp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 
 	if (status & (PCSTimeout))
-		tp->stats.rx_length_errors++;
+		dev->stats.rx_length_errors++;
 	if (status & (RxUnderrun | RxFIFOOver))
-		tp->stats.rx_fifo_errors++;
+		dev->stats.rx_fifo_errors++;
 	if (status & RxOverflow) {
-		tp->stats.rx_over_errors++;
+		dev->stats.rx_over_errors++;
 		tp->cur_rx = NETDRV_R16 (RxBufAddr) % RX_BUF_LEN;
 		NETDRV_W16_F (RxBufPtr, tp->cur_rx - 16);
 	}
@@ -1740,7 +1737,7 @@ static int netdrv_close (struct net_device *dev)
 	NETDRV_W16 (IntrMask, 0x0000);
 
 	/* Update the error counts. */
-	tp->stats.rx_missed_errors += NETDRV_R32 (RxMissed);
+	dev->stats.rx_missed_errors += NETDRV_R32 (RxMissed);
 	NETDRV_W32 (RxMissed, 0);
 
 	spin_unlock_irqrestore (&tp->lock, flags);
@@ -1807,31 +1804,6 @@ static int netdrv_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 	return rc;
 }
 
-
-static struct net_device_stats *netdrv_get_stats (struct net_device *dev)
-{
-	struct netdrv_private *tp = dev->priv;
-	void *ioaddr = tp->mmio_addr;
-
-	DPRINTK ("ENTER\n");
-
-	assert (tp != NULL);
-
-	if (netif_running(dev)) {
-		unsigned long flags;
-
-		spin_lock_irqsave (&tp->lock, flags);
-
-		tp->stats.rx_missed_errors += NETDRV_R32 (RxMissed);
-		NETDRV_W32 (RxMissed, 0);
-
-		spin_unlock_irqrestore (&tp->lock, flags);
-	}
-
-	DPRINTK ("EXIT\n");
-	return &tp->stats;
-}
-
 /* Set or clear the multicast filter for this adaptor.
    This routine is not state sensitive and need not be SMP locked. */
 
@@ -1909,7 +1881,7 @@ static int netdrv_suspend (struct pci_dev *pdev, pm_message_t state)
 	NETDRV_W8 (ChipCmd, (NETDRV_R8 (ChipCmd) & ChipCmdClear));
 
 	/* Update the error counts. */
-	tp->stats.rx_missed_errors += NETDRV_R32 (RxMissed);
+	dev->stats.rx_missed_errors += NETDRV_R32 (RxMissed);
 	NETDRV_W32 (RxMissed, 0);
 
 	spin_unlock_irqrestore (&tp->lock, flags);
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index 8754cf3..d7efb3e 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -154,7 +154,6 @@ static int plip_hard_header_cache(struct neighbour *neigh,
                                   struct hh_cache *hh);
 static int plip_open(struct net_device *dev);
 static int plip_close(struct net_device *dev);
-static struct net_device_stats *plip_get_stats(struct net_device *dev);
 static int plip_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 static int plip_preempt(void *handle);
 static void plip_wakeup(void *handle);
@@ -206,7 +205,6 @@ struct plip_local {
 };
 
 struct net_local {
-	struct net_device_stats enet_stats;
 	struct net_device *dev;
 	struct work_struct immediate;
 	struct delayed_work deferred;
@@ -285,7 +283,6 @@ plip_init_netdev(struct net_device *dev)
 	dev->hard_start_xmit	 = plip_tx_packet;
 	dev->open		 = plip_open;
 	dev->stop		 = plip_close;
-	dev->get_stats 		 = plip_get_stats;
 	dev->do_ioctl		 = plip_ioctl;
 	dev->header_cache_update = NULL;
 	dev->tx_queue_len 	 = 10;
@@ -430,8 +427,8 @@ plip_bh_timeout_error(struct net_device *dev, struct net_local *nl,
 			       dev->name, snd->state, c0);
 		} else
 			error = HS_TIMEOUT;
-		nl->enet_stats.tx_errors++;
-		nl->enet_stats.tx_aborted_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
 	} else if (nl->connection == PLIP_CN_RECEIVE) {
 		if (rcv->state == PLIP_PK_TRIGGER) {
 			/* Transmission was interrupted. */
@@ -448,7 +445,7 @@ plip_bh_timeout_error(struct net_device *dev, struct net_local *nl,
 			printk(KERN_WARNING "%s: receive timeout(%d,%02x)\n",
 			       dev->name, rcv->state, c0);
 		}
-		nl->enet_stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 	}
 	rcv->state = PLIP_PK_DONE;
 	if (rcv->skb) {
@@ -661,7 +658,7 @@ plip_receive_packet(struct net_device *dev, struct net_local *nl,
 				 &rcv->nibble, &rcv->data))
 			return TIMEOUT;
 		if (rcv->data != rcv->checksum) {
-			nl->enet_stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 			if (net_debug)
 				printk(KERN_DEBUG "%s: checksum error\n", dev->name);
 			return ERROR;
@@ -673,8 +670,8 @@ plip_receive_packet(struct net_device *dev, struct net_local *nl,
 		rcv->skb->protocol=plip_type_trans(rcv->skb, dev);
 		netif_rx(rcv->skb);
 		dev->last_rx = jiffies;
-		nl->enet_stats.rx_bytes += rcv->length.h;
-		nl->enet_stats.rx_packets++;
+		dev->stats.rx_bytes += rcv->length.h;
+		dev->stats.rx_packets++;
 		rcv->skb = NULL;
 		if (net_debug > 2)
 			printk(KERN_DEBUG "%s: receive end\n", dev->name);
@@ -776,7 +773,7 @@ plip_send_packet(struct net_device *dev, struct net_local *nl,
 			if (nl->connection == PLIP_CN_RECEIVE) {
 				spin_unlock_irq(&nl->lock);
 				/* Interrupted. */
-				nl->enet_stats.collisions++;
+				dev->stats.collisions++;
 				return OK;
 			}
 			c0 = read_status(dev);
@@ -792,7 +789,7 @@ plip_send_packet(struct net_device *dev, struct net_local *nl,
 					   {enable,disable}_irq *counts*
 					   them.  -- AV  */
 					ENABLE(dev->irq);
-					nl->enet_stats.collisions++;
+					dev->stats.collisions++;
 					return OK;
 				}
 				disable_parport_interrupts (dev);
@@ -840,9 +837,9 @@ plip_send_packet(struct net_device *dev, struct net_local *nl,
 			      &snd->nibble, snd->checksum))
 			return TIMEOUT;
 
-		nl->enet_stats.tx_bytes += snd->skb->len;
+		dev->stats.tx_bytes += snd->skb->len;
 		dev_kfree_skb(snd->skb);
-		nl->enet_stats.tx_packets++;
+		dev->stats.tx_packets++;
 		snd->state = PLIP_PK_DONE;
 
 	case PLIP_PK_DONE:
@@ -1199,15 +1196,6 @@ plip_wakeup(void *handle)
 	return;
 }
 
-static struct net_device_stats *
-plip_get_stats(struct net_device *dev)
-{
-	struct net_local *nl = netdev_priv(dev);
-	struct net_device_stats *r = &nl->enet_stats;
-
-	return r;
-}
-
 static int
 plip_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index b1aed18..8e13b15 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2053,7 +2053,7 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 	if(mac_rsp->flags & OB_MAC_IOCB_RSP_S) {
 		printk(KERN_ERR "Frame too short to be legal, frame not sent.\n");
 
-		qdev->stats.tx_errors++;
+		qdev->ndev->stats.tx_errors++;
 		retval = -EIO;
 		goto frame_not_sent;
 	}
@@ -2061,7 +2061,7 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 	if(tx_cb->seg_count == 0) {
 		printk(KERN_ERR "tx_cb->seg_count == 0: %d\n", mac_rsp->transaction_id);
 
-		qdev->stats.tx_errors++;
+		qdev->ndev->stats.tx_errors++;
 		retval = -EIO;
 		goto invalid_seg_count;
 	}
@@ -2080,8 +2080,8 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 				       PCI_DMA_TODEVICE);
 		}
 	}
-	qdev->stats.tx_packets++;
-	qdev->stats.tx_bytes += tx_cb->skb->len;
+	qdev->ndev->stats.tx_packets++;
+	qdev->ndev->stats.tx_bytes += tx_cb->skb->len;
 
 frame_not_sent:
 	dev_kfree_skb_irq(tx_cb->skb);
@@ -2140,8 +2140,8 @@ static void ql_process_mac_rx_intr(struct ql3_adapter *qdev,
 	lrg_buf_cb2 = ql_get_lbuf(qdev);
 	skb = lrg_buf_cb2->skb;
 
-	qdev->stats.rx_packets++;
-	qdev->stats.rx_bytes += length;
+	qdev->ndev->stats.rx_packets++;
+	qdev->ndev->stats.rx_bytes += length;
 
 	skb_put(skb, length);
 	pci_unmap_single(qdev->pdev,
@@ -2225,8 +2225,8 @@ static void ql_process_macip_rx_intr(struct ql3_adapter *qdev,
 	skb2->protocol = eth_type_trans(skb2, qdev->ndev);
 
 	netif_receive_skb(skb2);
-	qdev->stats.rx_packets++;
-	qdev->stats.rx_bytes += length;
+	ndev->stats.rx_packets++;
+	ndev->stats.rx_bytes += length;
 	ndev->last_rx = jiffies;
 	lrg_buf_cb2->skb = NULL;
 
@@ -3750,12 +3750,6 @@ static int ql3xxx_open(struct net_device *ndev)
 	return (ql_adapter_up(qdev));
 }
 
-static struct net_device_stats *ql3xxx_get_stats(struct net_device *dev)
-{
-	struct ql3_adapter *qdev = (struct ql3_adapter *)dev->priv;
-	return &qdev->stats;
-}
-
 static void ql3xxx_set_multicast_list(struct net_device *ndev)
 {
 	/*
@@ -4046,7 +4040,6 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	ndev->open = ql3xxx_open;
 	ndev->hard_start_xmit = ql3xxx_send;
 	ndev->stop = ql3xxx_close;
-	ndev->get_stats = ql3xxx_get_stats;
 	ndev->set_multicast_list = ql3xxx_set_multicast_list;
 	SET_ETHTOOL_OPS(ndev, &ql3xxx_ethtool_ops);
 	ndev->set_mac_address = ql3xxx_set_mac_address;
diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
index 4a832c4..abee25e 100755
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -1281,7 +1281,6 @@ struct ql3_adapter {
 	u32 update_ob_opcode;	/* Opcode to use for updating NCB */
 	u32 mb_bit_mask;	/* MA Bits mask to use on transmission */
 	u32 numPorts;
-	struct net_device_stats stats;
 	struct workqueue_struct *workqueue;
 	struct delayed_work reset_work;
 	struct delayed_work tx_timeout_work;
diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index df6b738..1d9d0c7 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -53,7 +53,6 @@ struct rionet_private {
 	struct rio_mport *mport;
 	struct sk_buff *rx_skb[RIONET_RX_RING_SIZE];
 	struct sk_buff *tx_skb[RIONET_TX_RING_SIZE];
-	struct net_device_stats stats;
 	int rx_slot;
 	int tx_slot;
 	int tx_cnt;
@@ -91,12 +90,6 @@ static struct rio_dev *rionet_active[RIO_MAX_ROUTE_ENTRIES];
 #define RIONET_MAC_MATCH(x)	(*(u32 *)x == 0x00010001)
 #define RIONET_GET_DESTID(x)	(*(u16 *)(x + 4))
 
-static struct net_device_stats *rionet_stats(struct net_device *ndev)
-{
-	struct rionet_private *rnet = ndev->priv;
-	return &rnet->stats;
-}
-
 static int rionet_rx_clean(struct net_device *ndev)
 {
 	int i;
@@ -120,15 +113,15 @@ static int rionet_rx_clean(struct net_device *ndev)
 		error = netif_rx(rnet->rx_skb[i]);
 
 		if (error == NET_RX_DROP) {
-			rnet->stats.rx_dropped++;
+			ndev->stats.rx_dropped++;
 		} else if (error == NET_RX_BAD) {
 			if (netif_msg_rx_err(rnet))
 				printk(KERN_WARNING "%s: bad rx packet\n",
 				       DRV_NAME);
-			rnet->stats.rx_errors++;
+			ndev->stats.rx_errors++;
 		} else {
-			rnet->stats.rx_packets++;
-			rnet->stats.rx_bytes += RIO_MAX_MSG_SIZE;
+			ndev->stats.rx_packets++;
+			ndev->stats.rx_bytes += RIO_MAX_MSG_SIZE;
 		}
 
 	} while ((i = (i + 1) % RIONET_RX_RING_SIZE) != rnet->rx_slot);
@@ -163,8 +156,8 @@ static int rionet_queue_tx_msg(struct sk_buff *skb, struct net_device *ndev,
 	rio_add_outb_message(rnet->mport, rdev, 0, skb->data, skb->len);
 	rnet->tx_skb[rnet->tx_slot] = skb;
 
-	rnet->stats.tx_packets++;
-	rnet->stats.tx_bytes += skb->len;
+	ndev->stats.tx_packets++;
+	ndev->stats.tx_bytes += skb->len;
 
 	if (++rnet->tx_cnt == RIONET_TX_RING_SIZE)
 		netif_stop_queue(ndev);
@@ -466,7 +459,6 @@ static int rionet_setup_netdev(struct rio_mport *mport)
 	ndev->open = &rionet_open;
 	ndev->hard_start_xmit = &rionet_start_xmit;
 	ndev->stop = &rionet_close;
-	ndev->get_stats = &rionet_stats;
 	ndev->mtu = RIO_MAX_MSG_SIZE - 14;
 	ndev->features = NETIF_F_LLTX;
 	SET_ETHTOOL_OPS(ndev, &rionet_ethtool_ops);
diff --git a/drivers/net/rrunner.c b/drivers/net/rrunner.c
index 5c2e41f..a066b74 100644
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -127,7 +127,6 @@ static int __devinit rr_init_one(struct pci_dev *pdev,
 	dev->open = &rr_open;
 	dev->hard_start_xmit = &rr_start_xmit;
 	dev->stop = &rr_close;
-	dev->get_stats = &rr_get_stats;
 	dev->do_ioctl = &rr_ioctl;
 
 	dev->base_addr = pci_resource_start(pdev, 0);
@@ -809,7 +808,7 @@ static u32 rr_handle_event(struct net_device *dev, u32 prodidx, u32 eidx)
 		case E_CON_REJ:
 			printk(KERN_WARNING "%s: Connection rejected\n",
 			       dev->name);
-			rrpriv->stats.tx_aborted_errors++;
+			dev->stats.tx_aborted_errors++;
 			break;
 		case E_CON_TMOUT:
 			printk(KERN_WARNING "%s: Connection timeout\n",
@@ -818,7 +817,7 @@ static u32 rr_handle_event(struct net_device *dev, u32 prodidx, u32 eidx)
 		case E_DISC_ERR:
 			printk(KERN_WARNING "%s: HIPPI disconnect error\n",
 			       dev->name);
-			rrpriv->stats.tx_aborted_errors++;
+			dev->stats.tx_aborted_errors++;
 			break;
 		case E_INT_PRTY:
 			printk(KERN_ERR "%s: HIPPI Internal Parity error\n",
@@ -834,7 +833,7 @@ static u32 rr_handle_event(struct net_device *dev, u32 prodidx, u32 eidx)
 		case E_TX_LINK_DROP:
 			printk(KERN_WARNING "%s: Link lost during transmit\n",
 			       dev->name);
-			rrpriv->stats.tx_aborted_errors++;
+			dev->stats.tx_aborted_errors++;
 			writel(readl(&regs->HostCtrl)|HALT_NIC|RR_CLEAR_INT,
 			       &regs->HostCtrl);
 			wmb();
@@ -974,7 +973,7 @@ static void rx_int(struct net_device *dev, u32 rxlimit, u32 index)
 		printk("len %x, mode %x\n", pkt_len, desc->mode);
 #endif
 		if ( (rrpriv->rx_ring[index].mode & PACKET_BAD) == PACKET_BAD){
-			rrpriv->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			goto defer;
 		}
 
@@ -987,7 +986,7 @@ static void rx_int(struct net_device *dev, u32 rxlimit, u32 index)
 				skb = alloc_skb(pkt_len, GFP_ATOMIC);
 				if (skb == NULL){
 					printk(KERN_WARNING "%s: Unable to allocate skb (%i bytes), deferring packet\n", dev->name, pkt_len);
-					rrpriv->stats.rx_dropped++;
+					dev->stats.rx_dropped++;
 					goto defer;
 				} else {
 					pci_dma_sync_single_for_cpu(rrpriv->pci_dev,
@@ -1025,7 +1024,7 @@ static void rx_int(struct net_device *dev, u32 rxlimit, u32 index)
 				} else {
 					printk("%s: Out of memory, deferring "
 					       "packet\n", dev->name);
-					rrpriv->stats.rx_dropped++;
+					dev->stats.rx_dropped++;
 					goto defer;
 				}
 			}
@@ -1034,8 +1033,8 @@ static void rx_int(struct net_device *dev, u32 rxlimit, u32 index)
 			netif_rx(skb);		/* send it up */
 
 			dev->last_rx = jiffies;
-			rrpriv->stats.rx_packets++;
-			rrpriv->stats.rx_bytes += pkt_len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_len;
 		}
 	defer:
 		desc->mode = 0;
@@ -1103,8 +1102,8 @@ static irqreturn_t rr_interrupt(int irq, void *dev_id)
 				desc = &(rrpriv->tx_ring[txcon]);
 				skb = rrpriv->tx_skbuff[txcon];
 
-				rrpriv->stats.tx_packets++;
-				rrpriv->stats.tx_bytes += skb->len;
+				dev->stats.tx_packets++;
+				dev->stats.tx_bytes += skb->len;
 
 				pci_unmap_single(rrpriv->pci_dev,
 						 desc->addr.addrlo, skb->len,
@@ -1492,16 +1491,6 @@ static int rr_start_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 
-static struct net_device_stats *rr_get_stats(struct net_device *dev)
-{
-	struct rr_private *rrpriv;
-
-	rrpriv = netdev_priv(dev);
-
-	return(&rrpriv->stats);
-}
-
-
 /*
  * Read the firmware out of the EEPROM and put it into the SRAM
  * (or from user space - later)
diff --git a/drivers/net/rrunner.h b/drivers/net/rrunner.h
index 9f3e050..6a79825 100644
--- a/drivers/net/rrunner.h
+++ b/drivers/net/rrunner.h
@@ -819,7 +819,6 @@ struct rr_private
 	u32			tx_full;
 	u32			fw_rev;
 	volatile short		fw_running;
-	struct net_device_stats stats;
 	struct pci_dev		*pci_dev;
 };
 
@@ -834,7 +833,6 @@ static irqreturn_t rr_interrupt(int irq, void *dev_id);
 static int rr_open(struct net_device *dev);
 static int rr_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int rr_close(struct net_device *dev);
-static struct net_device_stats *rr_get_stats(struct net_device *dev);
 static int rr_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static unsigned int rr_read_eeprom(struct rr_private *rrpriv,
 				   unsigned long offset,
diff --git a/drivers/net/saa9730.c b/drivers/net/saa9730.c
index 7dae4d4..14361e8 100644
--- a/drivers/net/saa9730.c
+++ b/drivers/net/saa9730.c
@@ -151,30 +151,30 @@ static void __attribute_used__ show_saa9730_regs(struct lan_saa9730_private *lp)
 		printk("lp->lan_saa9730_regs->CamData = %x\n",
 		       readl(&lp->lan_saa9730_regs->CamData));
 	}
-	printk("lp->stats.tx_packets = %lx\n", lp->stats.tx_packets);
-	printk("lp->stats.tx_errors = %lx\n", lp->stats.tx_errors);
-	printk("lp->stats.tx_aborted_errors = %lx\n",
-	       lp->stats.tx_aborted_errors);
-	printk("lp->stats.tx_window_errors = %lx\n",
-	       lp->stats.tx_window_errors);
-	printk("lp->stats.tx_carrier_errors = %lx\n",
-	       lp->stats.tx_carrier_errors);
-	printk("lp->stats.tx_fifo_errors = %lx\n",
-	       lp->stats.tx_fifo_errors);
-	printk("lp->stats.tx_heartbeat_errors = %lx\n",
-	       lp->stats.tx_heartbeat_errors);
-	printk("lp->stats.collisions = %lx\n", lp->stats.collisions);
-
-	printk("lp->stats.rx_packets = %lx\n", lp->stats.rx_packets);
-	printk("lp->stats.rx_errors = %lx\n", lp->stats.rx_errors);
-	printk("lp->stats.rx_dropped = %lx\n", lp->stats.rx_dropped);
-	printk("lp->stats.rx_crc_errors = %lx\n", lp->stats.rx_crc_errors);
-	printk("lp->stats.rx_frame_errors = %lx\n",
-	       lp->stats.rx_frame_errors);
-	printk("lp->stats.rx_fifo_errors = %lx\n",
-	       lp->stats.rx_fifo_errors);
-	printk("lp->stats.rx_length_errors = %lx\n",
-	       lp->stats.rx_length_errors);
+	printk("dev->stats.tx_packets = %lx\n", dev->stats.tx_packets);
+	printk("dev->stats.tx_errors = %lx\n", dev->stats.tx_errors);
+	printk("dev->stats.tx_aborted_errors = %lx\n",
+	       dev->stats.tx_aborted_errors);
+	printk("dev->stats.tx_window_errors = %lx\n",
+	       dev->stats.tx_window_errors);
+	printk("dev->stats.tx_carrier_errors = %lx\n",
+	       dev->stats.tx_carrier_errors);
+	printk("dev->stats.tx_fifo_errors = %lx\n",
+	       dev->stats.tx_fifo_errors);
+	printk("dev->stats.tx_heartbeat_errors = %lx\n",
+	       dev->stats.tx_heartbeat_errors);
+	printk("dev->stats.collisions = %lx\n", dev->stats.collisions);
+
+	printk("dev->stats.rx_packets = %lx\n", dev->stats.rx_packets);
+	printk("dev->stats.rx_errors = %lx\n", dev->stats.rx_errors);
+	printk("dev->stats.rx_dropped = %lx\n", dev->stats.rx_dropped);
+	printk("dev->stats.rx_crc_errors = %lx\n", dev->stats.rx_crc_errors);
+	printk("dev->stats.rx_frame_errors = %lx\n",
+	       dev->stats.rx_frame_errors);
+	printk("dev->stats.rx_fifo_errors = %lx\n",
+	       dev->stats.rx_fifo_errors);
+	printk("dev->stats.rx_length_errors = %lx\n",
+	       dev->stats.rx_length_errors);
 
 	printk("lp->lan_saa9730_regs->DebugPCIMasterAddr = %x\n",
 	       readl(&lp->lan_saa9730_regs->DebugPCIMasterAddr));
@@ -605,24 +605,24 @@ static int lan_saa9730_tx(struct net_device *dev)
 				printk("lan_saa9730_tx: tx error = %x\n",
 				       tx_status);
 
-			lp->stats.tx_errors++;
+			dev->stats.tx_errors++;
 			if (tx_status &
 			    (TX_STATUS_EX_COLL << TX_STAT_CTL_STATUS_SHF))
-				lp->stats.tx_aborted_errors++;
+				dev->stats.tx_aborted_errors++;
 			if (tx_status &
 			    (TX_STATUS_LATE_COLL << TX_STAT_CTL_STATUS_SHF))
-				lp->stats.tx_window_errors++;
+				dev->stats.tx_window_errors++;
 			if (tx_status &
 			    (TX_STATUS_L_CARR << TX_STAT_CTL_STATUS_SHF))
-				lp->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 			if (tx_status &
 			    (TX_STATUS_UNDER << TX_STAT_CTL_STATUS_SHF))
-				lp->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 			if (tx_status &
 			    (TX_STATUS_SQ_ERR << TX_STAT_CTL_STATUS_SHF))
-				lp->stats.tx_heartbeat_errors++;
+				dev->stats.tx_heartbeat_errors++;
 
-			lp->stats.collisions +=
+			dev->stats.collisions +=
 				tx_status & TX_STATUS_TX_COLL_MSK;
 		}
 
@@ -684,10 +684,10 @@ static int lan_saa9730_rx(struct net_device *dev)
 				printk
 				    ("%s: Memory squeeze, deferring packet.\n",
 				     dev->name);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 			} else {
-				lp->stats.rx_bytes += len;
-				lp->stats.rx_packets++;
+				dev->stats.rx_bytes += len;
+				dev->stats.rx_packets++;
 				skb_reserve(skb, 2);	/* 16 byte align */
 				skb_put(skb, len);	/* make room */
 				skb_copy_to_linear_data(skb,
@@ -704,19 +704,19 @@ static int lan_saa9730_rx(struct net_device *dev)
 				    ("lan_saa9730_rx: We got an error packet = %x\n",
 				     rx_status);
 
-			lp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			if (rx_status &
 			    (RX_STATUS_CRC_ERR << RX_STAT_CTL_STATUS_SHF))
-				lp->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 			if (rx_status &
 			    (RX_STATUS_ALIGN_ERR << RX_STAT_CTL_STATUS_SHF))
-				lp->stats.rx_frame_errors++;
+				dev->stats.rx_frame_errors++;
 			if (rx_status &
 			    (RX_STATUS_OVERFLOW << RX_STAT_CTL_STATUS_SHF))
-				lp->stats.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 			if (rx_status &
 			    (RX_STATUS_LONG_ERR << RX_STAT_CTL_STATUS_SHF))
-				lp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 		}
 
 		/* Indicate we have processed the buffer. */
@@ -853,7 +853,7 @@ static void lan_saa9730_tx_timeout(struct net_device *dev)
 	struct lan_saa9730_private *lp = netdev_priv(dev);
 
 	/* Transmitter timeout, serious problems */
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	printk("%s: transmit timed out, reset\n", dev->name);
 	/*show_saa9730_regs(lp); */
 	lan_saa9730_restart(lp);
@@ -886,8 +886,8 @@ static int lan_saa9730_start_xmit(struct sk_buff *skb,
 		return -1;
 	}
 
-	lp->stats.tx_bytes += len;
-	lp->stats.tx_packets++;
+	dev->stats.tx_bytes += len;
+	dev->stats.tx_packets++;
 
 	dev->trans_start = jiffies;
 	netif_wake_queue(dev);
@@ -919,14 +919,6 @@ static int lan_saa9730_close(struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *lan_saa9730_get_stats(struct net_device
-						      *dev)
-{
-	struct lan_saa9730_private *lp = netdev_priv(dev);
-
-	return &lp->stats;
-}
-
 static void lan_saa9730_set_multicast(struct net_device *dev)
 {
 	struct lan_saa9730_private *lp = netdev_priv(dev);
@@ -1040,7 +1032,6 @@ static int lan_saa9730_init(struct net_device *dev, struct pci_dev *pdev,
 	dev->open = lan_saa9730_open;
 	dev->hard_start_xmit = lan_saa9730_start_xmit;
 	dev->stop = lan_saa9730_close;
-	dev->get_stats = lan_saa9730_get_stats;
 	dev->set_multicast_list = lan_saa9730_set_multicast;
 	dev->tx_timeout = lan_saa9730_tx_timeout;
 	dev->watchdog_timeo = (HZ >> 1);
diff --git a/drivers/net/saa9730.h b/drivers/net/saa9730.h
index f656f2f..010a120 100644
--- a/drivers/net/saa9730.h
+++ b/drivers/net/saa9730.h
@@ -378,7 +378,6 @@ struct lan_saa9730_private {
 
 	unsigned char PhysicalAddress[LAN_SAA9730_CAM_ENTRIES][6];
 
-	struct net_device_stats stats;
 	spinlock_t lock;
 };
 
diff --git a/drivers/net/sb1000.c b/drivers/net/sb1000.c
index 1de3eec..a46c8b2 100644
--- a/drivers/net/sb1000.c
+++ b/drivers/net/sb1000.c
@@ -76,7 +76,6 @@ struct sb1000_private {
 	unsigned char rx_session_id[NPIDS];
 	unsigned char rx_frame_id[NPIDS];
 	unsigned char rx_pkt_type[NPIDS];
-	struct net_device_stats stats;
 };
 
 /* prototypes for Linux interface */
@@ -85,7 +84,6 @@ static int sb1000_open(struct net_device *dev);
 static int sb1000_dev_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd);
 static int sb1000_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t sb1000_interrupt(int irq, void *dev_id);
-static struct net_device_stats *sb1000_stats(struct net_device *dev);
 static int sb1000_close(struct net_device *dev);
 
 
@@ -200,7 +198,6 @@ sb1000_probe_one(struct pnp_dev *pdev, const struct pnp_device_id *id)
 	dev->do_ioctl		= sb1000_dev_ioctl;
 	dev->hard_start_xmit	= sb1000_start_xmit;
 	dev->stop		= sb1000_close;
-	dev->get_stats		= sb1000_stats;
 
 	/* hardware address is 0:0:serial_number */
 	dev->dev_addr[2]	= serial_number >> 24 & 0xff;
@@ -740,7 +737,7 @@ sb1000_rx(struct net_device *dev)
 	unsigned int skbsize;
 	struct sk_buff *skb;
 	struct sb1000_private *lp = netdev_priv(dev);
-	struct net_device_stats *stats = &lp->stats;
+	struct net_device_stats *stats = &dev->stats;
 
 	/* SB1000 frame constants */
 	const int FrameSize = FRAMESIZE;
@@ -1003,11 +1000,11 @@ static int sb1000_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	switch (cmd) {
 	case SIOCGCMSTATS:		/* get statistics */
-		stats[0] = lp->stats.rx_bytes;
+		stats[0] = dev->stats.rx_bytes;
 		stats[1] = lp->rx_frames;
-		stats[2] = lp->stats.rx_packets;
-		stats[3] = lp->stats.rx_errors;
-		stats[4] = lp->stats.rx_dropped;
+		stats[2] = dev->stats.rx_packets;
+		stats[3] = dev->stats.rx_errors;
+		stats[4] = dev->stats.rx_dropped;
 		if(copy_to_user(ifr->ifr_data, stats, sizeof(stats)))
 			return -EFAULT;
 		status = 0;
@@ -1133,12 +1130,6 @@ static irqreturn_t sb1000_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static struct net_device_stats *sb1000_stats(struct net_device *dev)
-{
-	struct sb1000_private *lp = netdev_priv(dev);
-	return &lp->stats;
-}
-
 static int sb1000_close(struct net_device *dev)
 {
 	int i;
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 2bfb44a..fb7ed67 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -240,7 +240,6 @@ struct sbmac_softc {
 	struct net_device *sbm_dev;		/* pointer to linux device */
 	spinlock_t sbm_lock;		/* spin lock */
 	struct timer_list sbm_timer;     	/* for monitoring MII */
-	struct net_device_stats sbm_stats;
 	int sbm_devflags;			/* current device flags */
 
 	int	     sbm_phy_oldbmsr;
@@ -316,7 +315,6 @@ static int sbmac_set_duplex(struct sbmac_softc *s,sbmac_duplex_t duplex,sbmac_fc
 static int sbmac_open(struct net_device *dev);
 static void sbmac_timer(unsigned long data);
 static void sbmac_tx_timeout (struct net_device *dev);
-static struct net_device_stats *sbmac_get_stats(struct net_device *dev);
 static void sbmac_set_rx_mode(struct net_device *dev);
 static int sbmac_mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static int sbmac_close(struct net_device *dev);
@@ -1201,7 +1199,7 @@ static int sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d,
 
 again:
 	/* Check if the HW dropped any frames */
-	sc->sbm_stats.rx_fifo_errors
+	dev->stats.rx_fifo_errors
 	    += __raw_readq(sc->sbm_rxdma.sbdma_oodpktlost) & 0xffff;
 	__raw_writeq(0, sc->sbm_rxdma.sbdma_oodpktlost);
 
@@ -1260,7 +1258,7 @@ again:
 
 			if (unlikely (sbdma_add_rcvbuffer(d,NULL) ==
 				      -ENOBUFS)) {
- 				sc->sbm_stats.rx_dropped++;
+ 				dev->stats.rx_dropped++;
 				sbdma_add_rcvbuffer(d,sb); /* re-add old buffer */
 				/* No point in continuing at the moment */
 				printk(KERN_ERR "dropped packet (1)\n");
@@ -1296,13 +1294,13 @@ again:
 					dropped = netif_rx(sb);
 
 				if (dropped == NET_RX_DROP) {
-					sc->sbm_stats.rx_dropped++;
+					dev->stats.rx_dropped++;
 					d->sbdma_remptr = SBDMA_NEXTBUF(d,sbdma_remptr);
 					goto done;
 				}
 				else {
-					sc->sbm_stats.rx_bytes += len;
-					sc->sbm_stats.rx_packets++;
+					dev->stats.rx_bytes += len;
+					dev->stats.rx_packets++;
 				}
 			}
 		} else {
@@ -1310,7 +1308,7 @@ again:
 			 * Packet was mangled somehow.  Just drop it and
 			 * put it back on the receive ring.
 			 */
-			sc->sbm_stats.rx_errors++;
+			dev->stats.rx_errors++;
 			sbdma_add_rcvbuffer(d,sb);
 		}
 
@@ -1400,8 +1398,8 @@ static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d, int poll)
 		 * Stats
 		 */
 
-		sc->sbm_stats.tx_bytes += sb->len;
-		sc->sbm_stats.tx_packets++;
+		dev->stats.tx_bytes += sb->len;
+		dev->stats.tx_packets++;
 
 		/*
 		 * for transmits, we just free buffers.
@@ -2463,7 +2461,6 @@ static int sbmac_init(struct net_device *dev, int idx)
 	dev->open               = sbmac_open;
 	dev->hard_start_xmit    = sbmac_start_tx;
 	dev->stop               = sbmac_close;
-	dev->get_stats          = sbmac_get_stats;
 	dev->set_multicast_list = sbmac_set_rx_mode;
 	dev->do_ioctl           = sbmac_mii_ioctl;
 	dev->tx_timeout         = sbmac_tx_timeout;
@@ -2752,7 +2749,7 @@ static void sbmac_tx_timeout (struct net_device *dev)
 
 
 	dev->trans_start = jiffies;
-	sc->sbm_stats.tx_errors++;
+	dev->stats.tx_errors++;
 
 	spin_unlock_irq (&sc->sbm_lock);
 
@@ -2762,22 +2759,6 @@ static void sbmac_tx_timeout (struct net_device *dev)
 
 
 
-static struct net_device_stats *sbmac_get_stats(struct net_device *dev)
-{
-	struct sbmac_softc *sc = netdev_priv(dev);
-	unsigned long flags;
-
-	spin_lock_irqsave(&sc->sbm_lock, flags);
-
-	/* XXX update other stats here */
-
-	spin_unlock_irqrestore(&sc->sbm_lock, flags);
-
-	return &sc->sbm_stats;
-}
-
-
-
 static void sbmac_set_rx_mode(struct net_device *dev)
 {
 	unsigned long flags;
diff --git a/drivers/net/seeq8005.c b/drivers/net/seeq8005.c
index 4bce7c4..8ef9402 100644
--- a/drivers/net/seeq8005.c
+++ b/drivers/net/seeq8005.c
@@ -67,7 +67,6 @@ static unsigned int net_debug = NET_DEBUG;
 
 /* Information that need to be kept for each board. */
 struct net_local {
-	struct net_device_stats stats;
 	unsigned short receive_ptr;		/* What address in packet memory do we expect a recv_pkt_header? */
 	long open_time;				/* Useless example local info. */
 };
@@ -86,7 +85,6 @@ static int seeq8005_send_packet(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t seeq8005_interrupt(int irq, void *dev_id);
 static void seeq8005_rx(struct net_device *dev);
 static int seeq8005_close(struct net_device *dev);
-static struct net_device_stats *seeq8005_get_stats(struct net_device *dev);
 static void set_multicast_list(struct net_device *dev);
 
 /* Example routines you must write ;->. */
@@ -338,7 +336,6 @@ static int __init seeq8005_probe1(struct net_device *dev, int ioaddr)
 	dev->hard_start_xmit 	= seeq8005_send_packet;
 	dev->tx_timeout		= seeq8005_timeout;
 	dev->watchdog_timeo	= HZ/20;
-	dev->get_stats		= seeq8005_get_stats;
 	dev->set_multicast_list = set_multicast_list;
 	dev->flags &= ~IFF_MULTICAST;
 
@@ -391,7 +388,6 @@ static void seeq8005_timeout(struct net_device *dev)
 
 static int seeq8005_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *lp = netdev_priv(dev);
 	short length = skb->len;
 	unsigned char *buf;
 
@@ -407,7 +403,7 @@ static int seeq8005_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	hardware_send_packet(dev, buf, length);
 	dev->trans_start = jiffies;
-	lp->stats.tx_bytes += length;
+	dev->stats.tx_bytes += length;
 	dev_kfree_skb (skb);
 	/* You might need to clean up and record Tx statistics here. */
 
@@ -463,7 +459,7 @@ static irqreturn_t seeq8005_interrupt(int irq, void *dev_id)
 		if (status & SEEQSTAT_TX_INT) {
 			handled = 1;
 			outw( SEEQCMD_TX_INT_ACK | (status & SEEQCMD_INT_MASK), SEEQ_CMD);
-			lp->stats.tx_packets++;
+			dev->stats.tx_packets++;
 			netif_wake_queue(dev);	/* Inform upper layers. */
 		}
 		if (status & SEEQSTAT_RX_INT) {
@@ -531,11 +527,11 @@ static void seeq8005_rx(struct net_device *dev)
 		}
 
 		if (pkt_hdr & SEEQPKTS_ANY_ERROR) {				/* There was an error. */
-			lp->stats.rx_errors++;
-			if (pkt_hdr & SEEQPKTS_SHORT) lp->stats.rx_frame_errors++;
-			if (pkt_hdr & SEEQPKTS_DRIB) lp->stats.rx_frame_errors++;
-			if (pkt_hdr & SEEQPKTS_OVERSIZE) lp->stats.rx_over_errors++;
-			if (pkt_hdr & SEEQPKTS_CRC_ERR) lp->stats.rx_crc_errors++;
+			dev->stats.rx_errors++;
+			if (pkt_hdr & SEEQPKTS_SHORT) dev->stats.rx_frame_errors++;
+			if (pkt_hdr & SEEQPKTS_DRIB) dev->stats.rx_frame_errors++;
+			if (pkt_hdr & SEEQPKTS_OVERSIZE) dev->stats.rx_over_errors++;
+			if (pkt_hdr & SEEQPKTS_CRC_ERR) dev->stats.rx_crc_errors++;
 			/* skip over this packet */
 			outw( SEEQCMD_FIFO_WRITE | SEEQCMD_DMA_INT_ACK | (status & SEEQCMD_INT_MASK), SEEQ_CMD);
 			outw( (lp->receive_ptr & 0xff00)>>8, SEEQ_REA);
@@ -547,7 +543,7 @@ static void seeq8005_rx(struct net_device *dev)
 			skb = dev_alloc_skb(pkt_len);
 			if (skb == NULL) {
 				printk("%s: Memory squeeze, dropping packet.\n", dev->name);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				break;
 			}
 			skb_reserve(skb, 2);	/* align data on 16 byte */
@@ -567,8 +563,8 @@ static void seeq8005_rx(struct net_device *dev)
 			skb->protocol=eth_type_trans(skb,dev);
 			netif_rx(skb);
 			dev->last_rx = jiffies;
-			lp->stats.rx_packets++;
-			lp->stats.rx_bytes += pkt_len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_len;
 		}
 	} while ((--boguscount) && (pkt_hdr & SEEQPKTH_CHAIN));
 
@@ -599,15 +595,6 @@ static int seeq8005_close(struct net_device *dev)
 
 }
 
-/* Get the current statistics.	This may be called with the card open or
-   closed. */
-static struct net_device_stats *seeq8005_get_stats(struct net_device *dev)
-{
-	struct net_local *lp = netdev_priv(dev);
-
-	return &lp->stats;
-}
-
 /* Set or clear the multicast filter for this adaptor.
    num_addrs == -1	Promiscuous mode, receive all packets
    num_addrs == 0	Normal mode, clear multicast list
diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 0fb74cb..f97b04b 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -92,8 +92,6 @@ struct sgiseeq_private {
 	unsigned char control;
 	unsigned char mode;
 
-	struct net_device_stats stats;
-
 	spinlock_t tx_lock;
 };
 
@@ -271,13 +269,13 @@ static inline void record_rx_errors(struct sgiseeq_private *sp,
 {
 	if (status & SEEQ_RSTAT_OVERF ||
 	    status & SEEQ_RSTAT_SFRAME)
-		sp->stats.rx_over_errors++;
+		dev->stats.rx_over_errors++;
 	if (status & SEEQ_RSTAT_CERROR)
-		sp->stats.rx_crc_errors++;
+		dev->stats.rx_crc_errors++;
 	if (status & SEEQ_RSTAT_DERROR)
-		sp->stats.rx_frame_errors++;
+		dev->stats.rx_frame_errors++;
 	if (status & SEEQ_RSTAT_REOF)
-		sp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 }
 
 static inline void rx_maybe_restart(struct sgiseeq_private *sp,
@@ -327,8 +325,8 @@ static inline void sgiseeq_rx(struct net_device *dev, struct sgiseeq_private *sp
 				if (memcmp(eth_hdr(skb)->h_source, dev->dev_addr, ETH_ALEN)) {
 					netif_rx(skb);
 					dev->last_rx = jiffies;
-					sp->stats.rx_packets++;
-					sp->stats.rx_bytes += len;
+					dev->stats.rx_packets++;
+					dev->stats.rx_bytes += len;
 				} else {
 					/* Silently drop my own packets */
 					dev_kfree_skb_irq(skb);
@@ -336,7 +334,7 @@ static inline void sgiseeq_rx(struct net_device *dev, struct sgiseeq_private *sp
 			} else {
 				printk (KERN_NOTICE "%s: Memory squeeze, deferring packet.\n",
 					dev->name);
-				sp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 			}
 		} else {
 			record_rx_errors(sp, pkt_status);
@@ -391,11 +389,11 @@ static inline void sgiseeq_tx(struct net_device *dev, struct sgiseeq_private *sp
 	if (!(status & (HPC3_ETXCTRL_ACTIVE | SEEQ_TSTAT_PTRANS))) {
 		/* Oops, HPC detected some sort of error. */
 		if (status & SEEQ_TSTAT_R16)
-			sp->stats.tx_aborted_errors++;
+			dev->stats.tx_aborted_errors++;
 		if (status & SEEQ_TSTAT_UFLOW)
-			sp->stats.tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 		if (status & SEEQ_TSTAT_LCLS)
-			sp->stats.collisions++;
+			dev->stats.collisions++;
 	}
 
 	/* Ack 'em... */
@@ -411,7 +409,7 @@ static inline void sgiseeq_tx(struct net_device *dev, struct sgiseeq_private *sp
 			}
 			break;
 		}
-		sp->stats.tx_packets++;
+		dev->stats.tx_packets++;
 		sp->tx_old = NEXT_TX(sp->tx_old);
 		td->tdma.cntinfo &= ~(HPCDMA_XIU | HPCDMA_XIE);
 		td->tdma.cntinfo |= HPCDMA_EOX;
@@ -515,7 +513,7 @@ static int sgiseeq_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Setup... */
 	skblen = skb->len;
 	len = (skblen <= ETH_ZLEN) ? ETH_ZLEN : skblen;
-	sp->stats.tx_bytes += len;
+	dev->stats.tx_bytes += len;
 	entry = sp->tx_new;
 	td = &sp->tx_desc[entry];
 
@@ -568,13 +566,6 @@ static void timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static struct net_device_stats *sgiseeq_get_stats(struct net_device *dev)
-{
-	struct sgiseeq_private *sp = netdev_priv(dev);
-
-	return &sp->stats;
-}
-
 static void sgiseeq_set_multicast(struct net_device *dev)
 {
 	struct sgiseeq_private *sp = (struct sgiseeq_private *) dev->priv;
@@ -699,7 +690,6 @@ static int __init sgiseeq_probe(struct platform_device *pdev)
 	dev->hard_start_xmit	= sgiseeq_start_xmit;
 	dev->tx_timeout		= timeout;
 	dev->watchdog_timeo	= (200 * HZ) / 1000;
-	dev->get_stats		= sgiseeq_get_stats;
 	dev->set_multicast_list	= sgiseeq_set_multicast;
 	dev->set_mac_address	= sgiseeq_set_mac_address;
 	dev->irq		= irq;
diff --git a/drivers/net/shaper.c b/drivers/net/shaper.c
index 4c3d98f..61db686 100644
--- a/drivers/net/shaper.c
+++ b/drivers/net/shaper.c
@@ -170,7 +170,7 @@ static int shaper_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		 */
 		if(time_after(SHAPERCB(skb)->shapeclock,jiffies + SHAPER_LATENCY)) {
 			dev_kfree_skb(skb);
-			shaper->stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 		} else
 			skb_queue_tail(&shaper->sendq, skb);
 	}
@@ -181,7 +181,7 @@ static int shaper_start_xmit(struct sk_buff *skb, struct net_device *dev)
  	{
  		ptr=skb_dequeue(&shaper->sendq);
                 dev_kfree_skb(ptr);
-                shaper->stats.collisions++;
+                dev->stats.collisions++;
  	}
 	shaper_kick(shaper);
 	spin_unlock(&shaper->lock);
@@ -206,8 +206,8 @@ static void shaper_queue_xmit(struct shaper *shaper, struct sk_buff *skb)
 				shaper->dev->name,newskb->priority);
 		dev_queue_xmit(newskb);
 
-                shaper->stats.tx_bytes += skb->len;
-		shaper->stats.tx_packets++;
+                shaper->dev->stats.tx_bytes += skb->len;
+		shaper->dev->stats.tx_packets++;
 
                 if(sh_debug)
 			printk("Kicked new frame out.\n");
@@ -329,12 +329,6 @@ static int shaper_close(struct net_device *dev)
  *	ARP and other resolutions and not before.
  */
 
-static struct net_device_stats *shaper_get_stats(struct net_device *dev)
-{
-     	struct shaper *sh=dev->priv;
-	return &sh->stats;
-}
-
 static int shaper_header(struct sk_buff *skb, struct net_device *dev,
 	unsigned short type, void *daddr, void *saddr, unsigned len)
 {
@@ -539,7 +533,6 @@ static void __init shaper_setup(struct net_device *dev)
 	dev->open		= shaper_open;
 	dev->stop		= shaper_close;
 	dev->hard_start_xmit 	= shaper_start_xmit;
-	dev->get_stats 		= shaper_get_stats;
 	dev->set_multicast_list = NULL;
 
 	/*
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index d470b19..126bfbf 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -281,7 +281,6 @@ struct sis190_private {
 	void __iomem *mmio_addr;
 	struct pci_dev *pci_dev;
 	struct net_device *dev;
-	struct net_device_stats stats;
 	spinlock_t lock;
 	u32 rx_buf_sz;
 	u32 cur_rx;
@@ -580,7 +579,7 @@ static inline int sis190_rx_pkt_err(u32 status, struct net_device_stats *stats)
 static int sis190_rx_interrupt(struct net_device *dev,
 			       struct sis190_private *tp, void __iomem *ioaddr)
 {
-	struct net_device_stats *stats = &tp->stats;
+	struct net_device_stats *stats = &dev->stats;
 	u32 rx_left, cur_rx = tp->cur_rx;
 	u32 delta, count;
 
@@ -694,8 +693,8 @@ static void sis190_tx_interrupt(struct net_device *dev,
 
 		skb = tp->Tx_skbuff[entry];
 
-		tp->stats.tx_packets++;
-		tp->stats.tx_bytes += skb->len;
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes += skb->len;
 
 		sis190_unmap_tx_skb(tp->pci_dev, skb, txd);
 		tp->Tx_skbuff[entry] = NULL;
@@ -1091,7 +1090,7 @@ static void sis190_tx_clear(struct sis190_private *tp)
 		tp->Tx_skbuff[i] = NULL;
 		dev_kfree_skb(skb);
 
-		tp->stats.tx_dropped++;
+		tp->dev->stats.tx_dropped++;
 	}
 	tp->cur_tx = tp->dirty_tx = 0;
 }
@@ -1158,7 +1157,7 @@ static int sis190_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (unlikely(skb->len < ETH_ZLEN)) {
 		if (skb_padto(skb, ETH_ZLEN)) {
-			tp->stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 			goto out;
 		}
 		len = ETH_ZLEN;
@@ -1211,13 +1210,6 @@ out:
 	return NETDEV_TX_OK;
 }
 
-static struct net_device_stats *sis190_get_stats(struct net_device *dev)
-{
-	struct sis190_private *tp = netdev_priv(dev);
-
-	return &tp->stats;
-}
-
 static void sis190_free_phy(struct list_head *first_phy)
 {
 	struct sis190_phy *cur, *next;
@@ -1811,7 +1803,6 @@ static int __devinit sis190_init_one(struct pci_dev *pdev,
 	dev->open = sis190_open;
 	dev->stop = sis190_close;
 	dev->do_ioctl = sis190_ioctl;
-	dev->get_stats = sis190_get_stats;
 	dev->tx_timeout = sis190_tx_timeout;
 	dev->watchdog_timeo = SIS190_TX_TIMEOUT;
 	dev->hard_start_xmit = sis190_start_xmit;
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index 7c6e480..17cf847 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -158,7 +158,6 @@ typedef struct _BufferDesc {
 } BufferDesc;
 
 struct sis900_private {
-	struct net_device_stats stats;
 	struct pci_dev * pci_dev;
 
 	spinlock_t lock;
@@ -221,7 +220,6 @@ static void sis900_finish_xmit (struct net_device *net_dev);
 static irqreturn_t sis900_interrupt(int irq, void *dev_instance);
 static int sis900_close(struct net_device *net_dev);
 static int mii_ioctl(struct net_device *net_dev, struct ifreq *rq, int cmd);
-static struct net_device_stats *sis900_get_stats(struct net_device *net_dev);
 static u16 sis900_mcast_bitnr(u8 *addr, u8 revision);
 static void set_rx_mode(struct net_device *net_dev);
 static void sis900_reset(struct net_device *net_dev);
@@ -467,7 +465,6 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 	net_dev->open = &sis900_open;
 	net_dev->hard_start_xmit = &sis900_start_xmit;
 	net_dev->stop = &sis900_close;
-	net_dev->get_stats = &sis900_get_stats;
 	net_dev->set_config = &sis900_set_config;
 	net_dev->set_multicast_list = &set_rx_mode;
 	net_dev->do_ioctl = &mii_ioctl;
@@ -1543,7 +1540,7 @@ static void sis900_tx_timeout(struct net_device *net_dev)
 			sis_priv->tx_skbuff[i] = NULL;
 			sis_priv->tx_ring[i].cmdsts = 0;
 			sis_priv->tx_ring[i].bufptr = 0;
-			sis_priv->stats.tx_dropped++;
+			net_dev->stats.tx_dropped++;
 		}
 	}
 	sis_priv->tx_full = 0;
@@ -1740,15 +1737,15 @@ static int sis900_rx(struct net_device *net_dev)
 				printk(KERN_DEBUG "%s: Corrupted packet "
 				       "received, buffer status = 0x%8.8x/%d.\n",
 				       net_dev->name, rx_status, data_size);
-			sis_priv->stats.rx_errors++;
+			net_dev->stats.rx_errors++;
 			if (rx_status & OVERRUN)
-				sis_priv->stats.rx_over_errors++;
+				net_dev->stats.rx_over_errors++;
 			if (rx_status & (TOOLONG|RUNT))
-				sis_priv->stats.rx_length_errors++;
+				net_dev->stats.rx_length_errors++;
 			if (rx_status & (RXISERR | FAERR))
-				sis_priv->stats.rx_frame_errors++;
+				net_dev->stats.rx_frame_errors++;
 			if (rx_status & CRCERR)
-				sis_priv->stats.rx_crc_errors++;
+				net_dev->stats.rx_crc_errors++;
 			/* reset buffer descriptor state */
 			sis_priv->rx_ring[entry].cmdsts = RX_BUF_SIZE;
 		} else {
@@ -1769,7 +1766,7 @@ static int sis900_rx(struct net_device *net_dev)
 				 * in the rx ring
 				 */
 				skb = sis_priv->rx_skbuff[entry];
-				sis_priv->stats.rx_dropped++;
+				net_dev->stats.rx_dropped++;
 				goto refill_rx_ring;
 			}	
 
@@ -1794,10 +1791,10 @@ static int sis900_rx(struct net_device *net_dev)
 
 			/* some network statistics */
 			if ((rx_status & BCAST) == MCAST)
-				sis_priv->stats.multicast++;
+				net_dev->stats.multicast++;
 			net_dev->last_rx = jiffies;
-			sis_priv->stats.rx_bytes += rx_size;
-			sis_priv->stats.rx_packets++;
+			net_dev->stats.rx_bytes += rx_size;
+			net_dev->stats.rx_packets++;
 			sis_priv->dirty_rx++;
 refill_rx_ring:
 			sis_priv->rx_skbuff[entry] = skb;
@@ -1828,7 +1825,7 @@ refill_rx_ring:
 					printk(KERN_INFO "%s: Memory squeeze,"
 						"deferring packet.\n",
 						net_dev->name);
-				sis_priv->stats.rx_dropped++;
+				net_dev->stats.rx_dropped++;
 				break;
 			}
 			sis_priv->rx_skbuff[entry] = skb;
@@ -1879,20 +1876,20 @@ static void sis900_finish_xmit (struct net_device *net_dev)
 				printk(KERN_DEBUG "%s: Transmit "
 				       "error, Tx status %8.8x.\n",
 				       net_dev->name, tx_status);
-			sis_priv->stats.tx_errors++;
+			net_dev->stats.tx_errors++;
 			if (tx_status & UNDERRUN)
-				sis_priv->stats.tx_fifo_errors++;
+				net_dev->stats.tx_fifo_errors++;
 			if (tx_status & ABORT)
-				sis_priv->stats.tx_aborted_errors++;
+				net_dev->stats.tx_aborted_errors++;
 			if (tx_status & NOCARRIER)
-				sis_priv->stats.tx_carrier_errors++;
+				net_dev->stats.tx_carrier_errors++;
 			if (tx_status & OWCOLL)
-				sis_priv->stats.tx_window_errors++;
+				net_dev->stats.tx_window_errors++;
 		} else {
 			/* packet successfully transmitted */
-			sis_priv->stats.collisions += (tx_status & COLCNT) >> 16;
-			sis_priv->stats.tx_bytes += tx_status & DSIZE;
-			sis_priv->stats.tx_packets++;
+			net_dev->stats.collisions += (tx_status & COLCNT) >> 16;
+			net_dev->stats.tx_bytes += tx_status & DSIZE;
+			net_dev->stats.tx_packets++;
 		}
 		/* Free the original skb. */
 		skb = sis_priv->tx_skbuff[entry];
@@ -2139,21 +2136,6 @@ static int mii_ioctl(struct net_device *net_dev, struct ifreq *rq, int cmd)
 }
 
 /**
- *	sis900_get_stats - Get sis900 read/write statistics
- *	@net_dev: the net device to get statistics for
- *
- *	get tx/rx statistics for sis900
- */
-
-static struct net_device_stats *
-sis900_get_stats(struct net_device *net_dev)
-{
-	struct sis900_private *sis_priv = net_dev->priv;
-
-	return &sis_priv->stats;
-}
-
-/**
  *	sis900_set_config - Set media type by net_device.set_config
  *	@dev: the net device for media type change
  *	@map: ifmap passed by ifconfig
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index db43e42..b83807f 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -115,13 +115,6 @@ struct smc911x_local {
 	 */
 	struct sk_buff *pending_tx_skb;
 
-	/*
-	 * these are things that the kernel wants me to keep, so users
-	 * can find out semi-useless statistics of how well the card is
-	 * performing
-	 */
-	struct net_device_stats stats;
-
 	/* version/revision of the SMC911x chip */
 	u16 version;
 	u16 revision;
@@ -315,8 +308,8 @@ static void smc911x_reset(struct net_device *dev)
 	if (lp->pending_tx_skb != NULL) {
 		dev_kfree_skb (lp->pending_tx_skb);
 		lp->pending_tx_skb = NULL;
-		lp->stats.tx_errors++;
-		lp->stats.tx_aborted_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
 	}
 }
 
@@ -449,14 +442,14 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 	pkt_len = (status & RX_STS_PKT_LEN_) >> 16;
 	if (status & RX_STS_ES_) {
 		/* Deal with a bad packet */
-		lp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		if (status & RX_STS_CRC_ERR_)
-			lp->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 		else {
 			if (status & RX_STS_LEN_ERR_)
-				lp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			if (status & RX_STS_MCAST_)
-				lp->stats.multicast++;
+				dev->stats.multicast++;
 		}
 		/* Remove the bad packet data from the RX FIFO */
 		smc911x_drop_pkt(dev);
@@ -467,7 +460,7 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 		if (unlikely(skb == NULL)) {
 			PRINTK( "%s: Low memory, rcvd packet dropped.\n",
 				dev->name);
-			lp->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			smc911x_drop_pkt(dev);
 			return;
 		}
@@ -503,8 +496,8 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 		dev->last_rx = jiffies;
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
-		lp->stats.rx_packets++;
-		lp->stats.rx_bytes += pkt_len-4;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += pkt_len-4;
 #endif
 	}
 }
@@ -616,8 +609,8 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		printk("%s: No Tx free space %d < %d\n",
 			dev->name, free, skb->len);
 		lp->pending_tx_skb = NULL;
-		lp->stats.tx_errors++;
-		lp->stats.tx_dropped++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_dropped++;
 		dev_kfree_skb(skb);
 		return 0;
 	}
@@ -667,8 +660,8 @@ static void smc911x_tx(struct net_device *dev)
 			dev->name,
 			(SMC_GET_TX_FIFO_INF() & TX_FIFO_INF_TSUSED_) >> 16);
 		tx_status = SMC_GET_TX_STS_FIFO();
-		lp->stats.tx_packets++;
-		lp->stats.tx_bytes+=tx_status>>16;
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes+=tx_status>>16;
 		DBG(SMC_DEBUG_TX, "%s: Tx FIFO tag 0x%04x status 0x%04x\n",
 			dev->name, (tx_status & 0xffff0000) >> 16,
 			tx_status & 0x0000ffff);
@@ -676,22 +669,22 @@ static void smc911x_tx(struct net_device *dev)
 		 * full-duplex mode */
 		if ((tx_status & TX_STS_ES_) && !(lp->ctl_rfduplx &&
 		    !(tx_status & 0x00000306))) {
-			lp->stats.tx_errors++;
+			dev->stats.tx_errors++;
 		}
 		if (tx_status & TX_STS_MANY_COLL_) {
-			lp->stats.collisions+=16;
-			lp->stats.tx_aborted_errors++;
+			dev->stats.collisions+=16;
+			dev->stats.tx_aborted_errors++;
 		} else {
-			lp->stats.collisions+=(tx_status & TX_STS_COLL_CNT_) >> 3;
+			dev->stats.collisions+=(tx_status & TX_STS_COLL_CNT_) >> 3;
 		}
 		/* carrier error only has meaning for half-duplex communication */
 		if ((tx_status & (TX_STS_LOC_ | TX_STS_NO_CARR_)) &&
 		    !lp->ctl_rfduplx) {
-			lp->stats.tx_carrier_errors++;
+			dev->stats.tx_carrier_errors++;
 		}
 		if (tx_status & TX_STS_LATE_COLL_) {
-			lp->stats.collisions++;
-			lp->stats.tx_aborted_errors++;
+			dev->stats.collisions++;
+			dev->stats.tx_aborted_errors++;
 		}
 	}
 }
@@ -1121,11 +1114,11 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 		/* Handle various error conditions */
 		if (status & INT_STS_RXE_) {
 			SMC_ACK_INT(INT_STS_RXE_);
-			lp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 		}
 		if (status & INT_STS_RXDFH_INT_) {
 			SMC_ACK_INT(INT_STS_RXDFH_INT_);
-			lp->stats.rx_dropped+=SMC_GET_RX_DROP();
+			dev->stats.rx_dropped+=SMC_GET_RX_DROP();
 		 }
 		/* Undocumented interrupt-what is the right thing to do here? */
 		if (status & INT_STS_RXDF_INT_) {
@@ -1140,8 +1133,8 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 				cr &= ~MAC_CR_RXEN_;
 				SMC_SET_MAC_CR(cr);
 				DBG(SMC_DEBUG_RX, "%s: RX overrun\n", dev->name);
-				lp->stats.rx_errors++;
-				lp->stats.rx_fifo_errors++;
+				dev->stats.rx_errors++;
+				dev->stats.rx_fifo_errors++;
 			}
 			SMC_ACK_INT(INT_STS_RDFL_);
 		}
@@ -1152,8 +1145,8 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 				SMC_SET_MAC_CR(cr);
 				rx_overrun=1;
 				DBG(SMC_DEBUG_RX, "%s: RX overrun\n", dev->name);
-				lp->stats.rx_errors++;
-				lp->stats.rx_fifo_errors++;
+				dev->stats.rx_errors++;
+				dev->stats.rx_fifo_errors++;
 			}
 			SMC_ACK_INT(INT_STS_RDFO_);
 		}
@@ -1307,8 +1300,8 @@ smc911x_rx_dma_irq(int dma, void *data)
 	dev->last_rx = jiffies;
 	skb->protocol = eth_type_trans(skb, dev);
 	netif_rx(skb);
-	lp->stats.rx_packets++;
-	lp->stats.rx_bytes += skb->len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
 
 	spin_lock_irqsave(&lp->lock, flags);
 	pkts = (SMC_GET_RX_FIFO_INF() & RX_FIFO_INF_RXSUSED_) >> 16;
@@ -1568,19 +1561,6 @@ static int smc911x_close(struct net_device *dev)
 }
 
 /*
- * Get the current statistics.
- * This may be called with the card open or closed.
- */
-static struct net_device_stats *smc911x_query_statistics(struct net_device *dev)
-{
-	struct smc911x_local *lp = netdev_priv(dev);
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
-
-
-	return &lp->stats;
-}
-
-/*
  * Ethtool support
  */
 static int
@@ -2056,7 +2036,6 @@ static int __init smc911x_probe(struct net_device *dev, unsigned long ioaddr)
 	dev->hard_start_xmit = smc911x_hard_start_xmit;
 	dev->tx_timeout = smc911x_timeout;
 	dev->watchdog_timeo = msecs_to_jiffies(watchdog);
-	dev->get_stats = smc911x_query_statistics;
 	dev->set_multicast_list = smc911x_set_multicast_list;
 	dev->ethtool_ops = &smc911x_ethtool_ops;
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index 36c1eba..c153d92 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -191,13 +191,6 @@ static struct devlist smc_devlist[] __initdata = {
 /* store this information for the driver.. */
 struct smc_local {
 	/*
- 	   these are things that the kernel wants me to keep, so users
-	   can find out semi-useless statistics of how well the card is
-	   performing
- 	*/
-	struct net_device_stats stats;
-
-	/*
 	   If I have to wait until memory is available to send
 	   a packet, I will store the skbuff here, until I get the
 	   desired memory.  Then, I'll send it out and free it.
@@ -249,12 +242,6 @@ static void smc_timeout(struct net_device *dev);
 static int smc_close(struct net_device *dev);
 
 /*
- . This routine allows the proc file system to query the driver's
- . statistics.
-*/
-static struct net_device_stats * smc_query_statistics( struct net_device *dev);
-
-/*
  . Finally, a call to set promiscuous mode ( for TCPDUMP and related
  . programs ) and multicast modes.
 */
@@ -514,7 +501,7 @@ static int smc_wait_to_send_packet( struct sk_buff * skb, struct net_device * de
 
 	if ( lp->saved_skb) {
 		/* THIS SHOULD NEVER HAPPEN. */
-		lp->stats.tx_aborted_errors++;
+		dev->stats.tx_aborted_errors++;
 		printk(CARDNAME": Bad Craziness - sent packet while busy.\n" );
 		return 1;
 	}
@@ -1067,7 +1054,6 @@ static int __init smc_probe(struct net_device *dev, int ioaddr)
 	dev->hard_start_xmit    	= smc_wait_to_send_packet;
 	dev->tx_timeout		    	= smc_timeout;
 	dev->watchdog_timeo		= HZ/20;
-	dev->get_stats			= smc_query_statistics;
 	dev->set_multicast_list 	= smc_set_multicast_list;
 
 	return 0;
@@ -1201,7 +1187,6 @@ static void smc_timeout(struct net_device *dev)
 */
 static void smc_rcv(struct net_device *dev)
 {
-	struct smc_local *lp = netdev_priv(dev);
 	int 	ioaddr = dev->base_addr;
 	int 	packet_number;
 	word	status;
@@ -1245,13 +1230,13 @@ static void smc_rcv(struct net_device *dev)
 
 		/* set multicast stats */
 		if ( status & RS_MULTICAST )
-			lp->stats.multicast++;
+			dev->stats.multicast++;
 
 		skb = dev_alloc_skb( packet_length + 5);
 
 		if ( skb == NULL ) {
 			printk(KERN_NOTICE CARDNAME ": Low memory, packet dropped.\n");
-			lp->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			goto done;
 		}
 
@@ -1291,16 +1276,16 @@ static void smc_rcv(struct net_device *dev)
 		skb->protocol = eth_type_trans(skb, dev );
 		netif_rx(skb);
 		dev->last_rx = jiffies;
-		lp->stats.rx_packets++;
-		lp->stats.rx_bytes += packet_length;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += packet_length;
 	} else {
 		/* error ... */
-		lp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 
-		if ( status & RS_ALGNERR )  lp->stats.rx_frame_errors++;
+		if ( status & RS_ALGNERR )  dev->stats.rx_frame_errors++;
 		if ( status & (RS_TOOSHORT | RS_TOOLONG ) )
-			lp->stats.rx_length_errors++;
-		if ( status & RS_BADCRC)	lp->stats.rx_crc_errors++;
+			dev->stats.rx_length_errors++;
+		if ( status & RS_BADCRC)	dev->stats.rx_crc_errors++;
 	}
 
 done:
@@ -1348,12 +1333,12 @@ static void smc_tx( struct net_device * dev )
 	tx_status = inw( ioaddr + DATA_1 );
 	PRINTK3((CARDNAME": TX DONE STATUS: %4x \n", tx_status ));
 
-	lp->stats.tx_errors++;
-	if ( tx_status & TS_LOSTCAR ) lp->stats.tx_carrier_errors++;
+	dev->stats.tx_errors++;
+	if ( tx_status & TS_LOSTCAR ) dev->stats.tx_carrier_errors++;
 	if ( tx_status & TS_LATCOL  ) {
 		printk(KERN_DEBUG CARDNAME
 			": Late collision occurred on last xmit.\n");
-		lp->stats.tx_window_errors++;
+		dev->stats.tx_window_errors++;
 	}
 #if 0
 		if ( tx_status & TS_16COL ) { ... }
@@ -1448,10 +1433,10 @@ static irqreturn_t smc_interrupt(int irq, void * dev_id)
 			SMC_SELECT_BANK( 0 );
 			card_stats = inw( ioaddr + COUNTER );
 			/* single collisions */
-			lp->stats.collisions += card_stats & 0xF;
+			dev->stats.collisions += card_stats & 0xF;
 			card_stats >>= 4;
 			/* multiple collisions */
-			lp->stats.collisions += card_stats & 0xF;
+			dev->stats.collisions += card_stats & 0xF;
 
 			/* these are for when linux supports these statistics */
 
@@ -1460,7 +1445,7 @@ static irqreturn_t smc_interrupt(int irq, void * dev_id)
 				": TX_BUFFER_EMPTY handled\n"));
 			outb( IM_TX_EMPTY_INT, ioaddr + INTERRUPT );
 			mask &= ~IM_TX_EMPTY_INT;
-			lp->stats.tx_packets += lp->packets_waiting;
+			dev->stats.tx_packets += lp->packets_waiting;
 			lp->packets_waiting = 0;
 
 		} else if (status & IM_ALLOC_INT ) {
@@ -1479,8 +1464,8 @@ static irqreturn_t smc_interrupt(int irq, void * dev_id)
 
 			PRINTK2((CARDNAME": Handoff done successfully.\n"));
 		} else if (status & IM_RX_OVRN_INT ) {
-			lp->stats.rx_errors++;
-			lp->stats.rx_fifo_errors++;
+			dev->stats.rx_errors++;
+			dev->stats.rx_fifo_errors++;
 			outb( IM_RX_OVRN_INT, ioaddr + INTERRUPT );
 		} else if (status & IM_EPH_INT ) {
 			PRINTK((CARDNAME ": UNSUPPORTED: EPH INTERRUPT \n"));
@@ -1523,16 +1508,6 @@ static int smc_close(struct net_device *dev)
 	return 0;
 }
 
-/*------------------------------------------------------------
- . Get the current statistics.
- . This may be called with the card open or closed.
- .-------------------------------------------------------------*/
-static struct net_device_stats* smc_query_statistics(struct net_device *dev) {
-	struct smc_local *lp = netdev_priv(dev);
-
-	return &lp->stats;
-}
-
 /*-----------------------------------------------------------
  . smc_set_multicast_list
  .
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 01cc3c7..0c315d1 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -183,13 +183,6 @@ struct smc_local {
 	struct sk_buff *pending_tx_skb;
 	struct tasklet_struct tx_task;
 
- 	/*
-	 * these are things that the kernel wants me to keep, so users
-	 * can find out semi-useless statistics of how well the card is
-	 * performing
-	 */
-	struct net_device_stats stats;
-
 	/* version/revision of the SMC91x chip */
 	int	version;
 
@@ -332,8 +325,8 @@ static void smc_reset(struct net_device *dev)
 	/* free any pending tx skb */
 	if (pending_skb) {
 		dev_kfree_skb(pending_skb);
-		lp->stats.tx_errors++;
-		lp->stats.tx_aborted_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
 	}
 
 	/*
@@ -512,13 +505,13 @@ static inline void  smc_rcv(struct net_device *dev)
 		}
 		SMC_WAIT_MMU_BUSY();
 		SMC_SET_MMU_CMD(MC_RELEASE);
-		lp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 		if (status & RS_ALGNERR)
-			lp->stats.rx_frame_errors++;
+			dev->stats.rx_frame_errors++;
 		if (status & (RS_TOOSHORT | RS_TOOLONG))
-			lp->stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 		if (status & RS_BADCRC)
-			lp->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 	} else {
 		struct sk_buff *skb;
 		unsigned char *data;
@@ -526,7 +519,7 @@ static inline void  smc_rcv(struct net_device *dev)
 
 		/* set multicast stats */
 		if (status & RS_MULTICAST)
-			lp->stats.multicast++;
+			dev->stats.multicast++;
 
 		/*
 		 * Actual payload is packet_len - 6 (or 5 if odd byte).
@@ -542,7 +535,7 @@ static inline void  smc_rcv(struct net_device *dev)
 				dev->name);
 			SMC_WAIT_MMU_BUSY();
 			SMC_SET_MMU_CMD(MC_RELEASE);
-			lp->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			return;
 		}
 
@@ -570,8 +563,8 @@ static inline void  smc_rcv(struct net_device *dev)
 		dev->last_rx = jiffies;
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
-		lp->stats.rx_packets++;
-		lp->stats.rx_bytes += data_len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += data_len;
 	}
 }
 
@@ -644,8 +637,8 @@ static void smc_hardware_send_pkt(unsigned long data)
 	packet_no = SMC_GET_AR();
 	if (unlikely(packet_no & AR_FAILED)) {
 		printk("%s: Memory allocation failed.\n", dev->name);
-		lp->stats.tx_errors++;
-		lp->stats.tx_fifo_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_fifo_errors++;
 		smc_special_unlock(&lp->lock);
 		goto done;
 	}
@@ -688,8 +681,8 @@ static void smc_hardware_send_pkt(unsigned long data)
 	smc_special_unlock(&lp->lock);
 
 	dev->trans_start = jiffies;
-	lp->stats.tx_packets++;
-	lp->stats.tx_bytes += len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += len;
 
 	SMC_ENABLE_INT(IM_TX_INT | IM_TX_EMPTY_INT);
 
@@ -729,8 +722,8 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	numPages = ((skb->len & ~1) + (6 - 1)) >> 8;
 	if (unlikely(numPages > 7)) {
 		printk("%s: Far too big packet error.\n", dev->name);
-		lp->stats.tx_errors++;
-		lp->stats.tx_dropped++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_dropped++;
 		dev_kfree_skb(skb);
 		return 0;
 	}
@@ -803,17 +796,17 @@ static void smc_tx(struct net_device *dev)
 		dev->name, tx_status, packet_no);
 
 	if (!(tx_status & ES_TX_SUC))
-		lp->stats.tx_errors++;
+		dev->stats.tx_errors++;
 
 	if (tx_status & ES_LOSTCARR)
-		lp->stats.tx_carrier_errors++;
+		dev->stats.tx_carrier_errors++;
 
 	if (tx_status & (ES_LATCOL | ES_16COL)) {
 		PRINTK("%s: %s occurred on last xmit\n", dev->name,
 		       (tx_status & ES_LATCOL) ?
 			"late collision" : "too many collisions");
-		lp->stats.tx_window_errors++;
-		if (!(lp->stats.tx_window_errors & 63) && net_ratelimit()) {
+		dev->stats.tx_window_errors++;
+		if (!(dev->stats.tx_window_errors & 63) && net_ratelimit()) {
 			printk(KERN_INFO "%s: unexpectedly large number of "
 			       "bad collisions. Please check duplex "
 			       "setting.\n", dev->name);
@@ -1347,19 +1340,19 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 			SMC_SELECT_BANK(2);
 
 			/* single collisions */
-			lp->stats.collisions += card_stats & 0xF;
+			dev->stats.collisions += card_stats & 0xF;
 			card_stats >>= 4;
 
 			/* multiple collisions */
-			lp->stats.collisions += card_stats & 0xF;
+			dev->stats.collisions += card_stats & 0xF;
 		} else if (status & IM_RX_OVRN_INT) {
 			DBG(1, "%s: RX overrun (EPH_ST 0x%04x)\n", dev->name,
 			       ({ int eph_st; SMC_SELECT_BANK(0);
 				  eph_st = SMC_GET_EPH_STATUS();
 				  SMC_SELECT_BANK(2); eph_st; }) );
 			SMC_ACK_INT(IM_RX_OVRN_INT);
-			lp->stats.rx_errors++;
-			lp->stats.rx_fifo_errors++;
+			dev->stats.rx_errors++;
+			dev->stats.rx_fifo_errors++;
 		} else if (status & IM_EPH_INT) {
 			smc_eph_interrupt(dev);
 		} else if (status & IM_MDINT) {
@@ -1628,19 +1621,6 @@ static int smc_close(struct net_device *dev)
 }
 
 /*
- * Get the current statistics.
- * This may be called with the card open or closed.
- */
-static struct net_device_stats *smc_query_statistics(struct net_device *dev)
-{
-	struct smc_local *lp = netdev_priv(dev);
-
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
-
-	return &lp->stats;
-}
-
-/*
  * Ethtool support
  */
 static int
@@ -1965,7 +1945,6 @@ static int __init smc_probe(struct net_device *dev, void __iomem *ioaddr)
 	dev->hard_start_xmit = smc_hard_start_xmit;
 	dev->tx_timeout = smc_timeout;
 	dev->watchdog_timeo = msecs_to_jiffies(watchdog);
-	dev->get_stats = smc_query_statistics;
 	dev->set_multicast_list = smc_set_multicast_list;
 	dev->ethtool_ops = &smc_ethtool_ops;
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 590b12c..5ba940a 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -815,8 +815,8 @@ spider_net_release_tx_chain(struct spider_net_card *card, int brutal)
 		status = spider_net_get_descr_status(hwdescr);
 		switch (status) {
 		case SPIDER_NET_DESCR_COMPLETE:
-			card->netdev_stats.tx_packets++;
-			card->netdev_stats.tx_bytes += descr->skb->len;
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes += descr->skb->len;
 			break;
 
 		case SPIDER_NET_DESCR_CARDOWNED:
@@ -835,11 +835,11 @@ spider_net_release_tx_chain(struct spider_net_card *card, int brutal)
 			if (netif_msg_tx_err(card))
 				dev_err(&card->netdev->dev, "forcing end of tx descriptor "
 				       "with status x%02x\n", status);
-			card->netdev_stats.tx_errors++;
+			dev->stats.tx_errors++;
 			break;
 
 		default:
-			card->netdev_stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 			if (!brutal) {
 				spin_unlock_irqrestore(&chain->lock, flags);
 				return 1;
@@ -919,7 +919,7 @@ spider_net_xmit(struct sk_buff *skb, struct net_device *netdev)
 	spider_net_release_tx_chain(card, 0);
 
 	if (spider_net_prepare_tx_descr(card, skb) != 0) {
-		card->netdev_stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		netif_stop_queue(netdev);
 		return NETDEV_TX_BUSY;
 	}
@@ -1015,8 +1015,8 @@ spider_net_pass_skb_up(struct spider_net_descr *descr,
 	}
 
 	/* update netdevice statistics */
-	card->netdev_stats.rx_packets++;
-	card->netdev_stats.rx_bytes += skb->len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
 
 	/* pass skb up to stack */
 	netif_receive_skb(skb);
@@ -1212,7 +1212,7 @@ spider_net_decode_one_descr(struct spider_net_card *card)
 		if (netif_msg_rx_err(card))
 			dev_err(&card->netdev->dev,
 			       "dropping RX descriptor with state %d\n", status);
-		card->netdev_stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		goto bad_desc;
 	}
 
@@ -1324,20 +1324,6 @@ spider_net_poll(struct net_device *netdev, int *budget)
 }
 
 /**
- * spider_net_get_stats - get interface statistics
- * @netdev: interface device structure
- *
- * returns the interface statistics residing in the spider_net_card struct
- */
-static struct net_device_stats *
-spider_net_get_stats(struct net_device *netdev)
-{
-	struct spider_net_card *card = netdev_priv(netdev);
-	struct net_device_stats *stats = &card->netdev_stats;
-	return stats;
-}
-
-/**
  * spider_net_change_mtu - changes the MTU of an interface
  * @netdev: interface device structure
  * @new_mtu: new MTU value
@@ -2300,7 +2286,6 @@ spider_net_setup_netdev_ops(struct net_device *netdev)
 	netdev->open = &spider_net_open;
 	netdev->stop = &spider_net_stop;
 	netdev->hard_start_xmit = &spider_net_xmit;
-	netdev->get_stats = &spider_net_get_stats;
 	netdev->set_multicast_list = &spider_net_set_multi;
 	netdev->set_mac_address = &spider_net_set_mac;
 	netdev->change_mtu = &spider_net_change_mtu;
diff --git a/drivers/net/spider_net.h b/drivers/net/spider_net.h
index dbbdb8c..86b1207 100644
--- a/drivers/net/spider_net.h
+++ b/drivers/net/spider_net.h
@@ -485,7 +485,6 @@ struct spider_net_card {
 
 	/* for ethtool */
 	int msg_enable;
-	struct net_device_stats netdev_stats;
 	struct spider_net_extra_stats spider_stats;
 	struct spider_net_options options;
 
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index f1548c0..dd46234 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -152,7 +152,6 @@ struct lance_private {
 	struct lance_memory	*mem;
      	int new_rx, new_tx;	/* The next free ring entry */
 	int old_tx, old_rx;     /* ring entry to be processed */
-	struct net_device_stats stats;
 /* These two must be longs for set_bit() */
 	long	    tx_full;
 	long	    lock;
@@ -241,7 +240,6 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev );
 static irqreturn_t lance_interrupt( int irq, void *dev_id);
 static int lance_rx( struct net_device *dev );
 static int lance_close( struct net_device *dev );
-static struct net_device_stats *lance_get_stats( struct net_device *dev );
 static void set_multicast_list( struct net_device *dev );
 
 /************************* End of Prototypes **************************/
@@ -402,15 +400,12 @@ static int __init lance_probe( struct net_device *dev)
 	dev->open = &lance_open;
 	dev->hard_start_xmit = &lance_start_xmit;
 	dev->stop = &lance_close;
-	dev->get_stats = &lance_get_stats;
 	dev->set_multicast_list = &set_multicast_list;
 	dev->set_mac_address = NULL;
 //	KLUDGE -- REMOVE ME
 	set_bit(__LINK_STATE_PRESENT, &dev->state);
 
 
-	memset( &lp->stats, 0, sizeof(lp->stats) );
-
 	return 1;
 }
 
@@ -535,7 +530,7 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 		 * little endian mode.
 		 */
 		REGA(CSR3) = CSR3_BSWP;
-		lp->stats.tx_errors++;
+		dev->stats.tx_errors++;
 
 		if(lance_debug >= 2) {
 			int i;
@@ -635,7 +630,7 @@ static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 
 	head->flag = TMD1_OWN_CHIP | TMD1_ENP | TMD1_STP;
 	lp->new_tx = (lp->new_tx + 1) & TX_RING_MOD_MASK;
-	lp->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 
 	/* Trigger an immediate send poll. */
 	REGA(CSR0) = CSR0_INEA | CSR0_TDMD | CSR0_STRT;
@@ -713,12 +708,12 @@ static irqreturn_t lance_interrupt( int irq, void *dev_id)
 
 			if (head->flag & TMD1_ERR) {
 				int status = head->misc;
-				lp->stats.tx_errors++;
-				if (status & TMD3_RTRY) lp->stats.tx_aborted_errors++;
-				if (status & TMD3_LCAR) lp->stats.tx_carrier_errors++;
-				if (status & TMD3_LCOL) lp->stats.tx_window_errors++;
+				dev->stats.tx_errors++;
+				if (status & TMD3_RTRY) dev->stats.tx_aborted_errors++;
+				if (status & TMD3_LCAR) dev->stats.tx_carrier_errors++;
+				if (status & TMD3_LCOL) dev->stats.tx_window_errors++;
 				if (status & (TMD3_UFLO | TMD3_BUFF)) {
-					lp->stats.tx_fifo_errors++;
+					dev->stats.tx_fifo_errors++;
 					printk("%s: Tx FIFO error\n",
 					       dev->name);
 					REGA(CSR0) = CSR0_STOP;
@@ -731,9 +726,9 @@ static irqreturn_t lance_interrupt( int irq, void *dev_id)
 
 				head->flag &= ~(TMD1_ENP | TMD1_STP);
 				if(head->flag & (TMD1_ONE | TMD1_MORE))
-					lp->stats.collisions++;
+					dev->stats.collisions++;
 
-				lp->stats.tx_packets++;
+				dev->stats.tx_packets++;
 				DPRINTK(3, ("cleared tx ring %d\n", old_tx));
 			}
 			old_tx = (old_tx +1) & TX_RING_MOD_MASK;
@@ -753,8 +748,8 @@ static irqreturn_t lance_interrupt( int irq, void *dev_id)
 		lance_rx( dev );
 
 	/* Log misc errors. */
-	if (csr0 & CSR0_BABL) lp->stats.tx_errors++; /* Tx babble. */
-	if (csr0 & CSR0_MISS) lp->stats.rx_errors++; /* Missed a Rx frame. */
+	if (csr0 & CSR0_BABL) dev->stats.tx_errors++; /* Tx babble. */
+	if (csr0 & CSR0_MISS) dev->stats.rx_errors++; /* Missed a Rx frame. */
 	if (csr0 & CSR0_MERR) {
 		DPRINTK( 1, ( "%s: Bus master arbitration failure (?!?), "
 			      "status %04x.\n", dev->name, csr0 ));
@@ -800,11 +795,11 @@ static int lance_rx( struct net_device *dev )
 			   full-sized buffers it's possible for a jabber packet to use two
 			   buffers, with only the last correctly noting the error. */
 			if (status & RMD1_ENP)	/* Only count a general error at the */
-				lp->stats.rx_errors++; /* end of a packet.*/
-			if (status & RMD1_FRAM) lp->stats.rx_frame_errors++;
-			if (status & RMD1_OFLO) lp->stats.rx_over_errors++;
-			if (status & RMD1_CRC) lp->stats.rx_crc_errors++;
-			if (status & RMD1_BUFF) lp->stats.rx_fifo_errors++;
+				dev->stats.rx_errors++; /* end of a packet.*/
+			if (status & RMD1_FRAM) dev->stats.rx_frame_errors++;
+			if (status & RMD1_OFLO) dev->stats.rx_over_errors++;
+			if (status & RMD1_CRC) dev->stats.rx_crc_errors++;
+			if (status & RMD1_BUFF) dev->stats.rx_fifo_errors++;
 			head->flag &= (RMD1_ENP|RMD1_STP);
 		} else {
 			/* Malloc up new buffer, compatible with net-3. */
@@ -814,7 +809,7 @@ static int lance_rx( struct net_device *dev )
 
 			if (pkt_len < 60) {
 				printk( "%s: Runt packet!\n", dev->name );
-				lp->stats.rx_errors++;
+				dev->stats.rx_errors++;
 			}
 			else {
 				skb = dev_alloc_skb( pkt_len+2 );
@@ -822,7 +817,7 @@ static int lance_rx( struct net_device *dev )
 					DPRINTK( 1, ( "%s: Memory squeeze, deferring packet.\n",
 						      dev->name ));
 
-					lp->stats.rx_dropped++;
+					dev->stats.rx_dropped++;
 					head->msg_length = 0;
 					head->flag |= RMD1_OWN_CHIP;
 					lp->new_rx = (lp->new_rx+1) &
@@ -860,8 +855,8 @@ static int lance_rx( struct net_device *dev )
 				skb->protocol = eth_type_trans( skb, dev );
 				netif_rx( skb );
 				dev->last_rx = jiffies;
-				lp->stats.rx_packets++;
-				lp->stats.rx_bytes += pkt_len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += pkt_len;
 			}
 		}
 
@@ -898,14 +893,6 @@ static int lance_close( struct net_device *dev )
 }
 
 
-static struct net_device_stats *lance_get_stats( struct net_device *dev )
-{
-	struct lance_private *lp = netdev_priv(dev);
-
-	return &lp->stats;
-}
-
-
 /* Set or clear the multicast filter for this adaptor.
    num_addrs == -1		Promiscuous mode, receive all packets
    num_addrs == 0		Normal mode, clear multicast list
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index e94b752..717d337 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -248,7 +248,6 @@ struct lance_private {
 	int		rx_new, tx_new;
 	int		rx_old, tx_old;
 
-	struct net_device_stats	stats;
 	struct sbus_dma *ledma;	/* If set this points to ledma	*/
 	char		tpe;		/* cable-selection is TPE	*/
 	char		auto_select;	/* cable-selection by carrier	*/
@@ -519,17 +518,17 @@ static void lance_rx_dvma(struct net_device *dev)
 
 		/* We got an incomplete frame? */
 		if ((bits & LE_R1_POK) != LE_R1_POK) {
-			lp->stats.rx_over_errors++;
-			lp->stats.rx_errors++;
+			dev->stats.rx_over_errors++;
+			dev->stats.rx_errors++;
 		} else if (bits & LE_R1_ERR) {
 			/* Count only the end frame as a rx error,
 			 * not the beginning
 			 */
-			if (bits & LE_R1_BUF) lp->stats.rx_fifo_errors++;
-			if (bits & LE_R1_CRC) lp->stats.rx_crc_errors++;
-			if (bits & LE_R1_OFL) lp->stats.rx_over_errors++;
-			if (bits & LE_R1_FRA) lp->stats.rx_frame_errors++;
-			if (bits & LE_R1_EOP) lp->stats.rx_errors++;
+			if (bits & LE_R1_BUF) dev->stats.rx_fifo_errors++;
+			if (bits & LE_R1_CRC) dev->stats.rx_crc_errors++;
+			if (bits & LE_R1_OFL) dev->stats.rx_over_errors++;
+			if (bits & LE_R1_FRA) dev->stats.rx_frame_errors++;
+			if (bits & LE_R1_EOP) dev->stats.rx_errors++;
 		} else {
 			len = (rd->mblength & 0xfff) - 4;
 			skb = dev_alloc_skb(len + 2);
@@ -537,14 +536,14 @@ static void lance_rx_dvma(struct net_device *dev)
 			if (skb == NULL) {
 				printk(KERN_INFO "%s: Memory squeeze, deferring packet.\n",
 				       dev->name);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				rd->mblength = 0;
 				rd->rmd1_bits = LE_R1_OWN;
 				lp->rx_new = RX_NEXT(entry);
 				return;
 			}
 
-			lp->stats.rx_bytes += len;
+			dev->stats.rx_bytes += len;
 
 			skb_reserve(skb, 2);		/* 16 byte align */
 			skb_put(skb, len);		/* make room */
@@ -554,7 +553,7 @@ static void lance_rx_dvma(struct net_device *dev)
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
 			dev->last_rx = jiffies;
-			lp->stats.rx_packets++;
+			dev->stats.rx_packets++;
 		}
 
 		/* Return the packet to the pool */
@@ -586,12 +585,12 @@ static void lance_tx_dvma(struct net_device *dev)
 		if (bits & LE_T1_ERR) {
 			u16 status = td->misc;
 
-			lp->stats.tx_errors++;
-			if (status & LE_T3_RTY)  lp->stats.tx_aborted_errors++;
-			if (status & LE_T3_LCOL) lp->stats.tx_window_errors++;
+			dev->stats.tx_errors++;
+			if (status & LE_T3_RTY)  dev->stats.tx_aborted_errors++;
+			if (status & LE_T3_LCOL) dev->stats.tx_window_errors++;
 
 			if (status & LE_T3_CLOS) {
-				lp->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 				if (lp->auto_select) {
 					lp->tpe = 1 - lp->tpe;
 					printk(KERN_NOTICE "%s: Carrier Lost, trying %s\n",
@@ -608,7 +607,7 @@ static void lance_tx_dvma(struct net_device *dev)
 			 * transmitter, restart the adapter.
 			 */
 			if (status & (LE_T3_BUF|LE_T3_UFL)) {
-				lp->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 
 				printk(KERN_ERR "%s: Tx: ERR_BUF|ERR_UFL, restarting\n",
 				       dev->name);
@@ -626,13 +625,13 @@ static void lance_tx_dvma(struct net_device *dev)
 
 			/* One collision before packet was sent. */
 			if (bits & LE_T1_EONE)
-				lp->stats.collisions++;
+				dev->stats.collisions++;
 
 			/* More than one collision, be optimistic. */
 			if (bits & LE_T1_EMORE)
-				lp->stats.collisions += 2;
+				dev->stats.collisions += 2;
 
-			lp->stats.tx_packets++;
+			dev->stats.tx_packets++;
 		}
 
 		j = TX_NEXT(j);
@@ -692,17 +691,17 @@ static void lance_rx_pio(struct net_device *dev)
 
 		/* We got an incomplete frame? */
 		if ((bits & LE_R1_POK) != LE_R1_POK) {
-			lp->stats.rx_over_errors++;
-			lp->stats.rx_errors++;
+			dev->stats.rx_over_errors++;
+			dev->stats.rx_errors++;
 		} else if (bits & LE_R1_ERR) {
 			/* Count only the end frame as a rx error,
 			 * not the beginning
 			 */
-			if (bits & LE_R1_BUF) lp->stats.rx_fifo_errors++;
-			if (bits & LE_R1_CRC) lp->stats.rx_crc_errors++;
-			if (bits & LE_R1_OFL) lp->stats.rx_over_errors++;
-			if (bits & LE_R1_FRA) lp->stats.rx_frame_errors++;
-			if (bits & LE_R1_EOP) lp->stats.rx_errors++;
+			if (bits & LE_R1_BUF) dev->stats.rx_fifo_errors++;
+			if (bits & LE_R1_CRC) dev->stats.rx_crc_errors++;
+			if (bits & LE_R1_OFL) dev->stats.rx_over_errors++;
+			if (bits & LE_R1_FRA) dev->stats.rx_frame_errors++;
+			if (bits & LE_R1_EOP) dev->stats.rx_errors++;
 		} else {
 			len = (sbus_readw(&rd->mblength) & 0xfff) - 4;
 			skb = dev_alloc_skb(len + 2);
@@ -710,14 +709,14 @@ static void lance_rx_pio(struct net_device *dev)
 			if (skb == NULL) {
 				printk(KERN_INFO "%s: Memory squeeze, deferring packet.\n",
 				       dev->name);
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				sbus_writew(0, &rd->mblength);
 				sbus_writeb(LE_R1_OWN, &rd->rmd1_bits);
 				lp->rx_new = RX_NEXT(entry);
 				return;
 			}
 
-			lp->stats.rx_bytes += len;
+			dev->stats.rx_bytes += len;
 
 			skb_reserve (skb, 2);		/* 16 byte align */
 			skb_put(skb, len);		/* make room */
@@ -725,7 +724,7 @@ static void lance_rx_pio(struct net_device *dev)
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
 			dev->last_rx = jiffies;
-			lp->stats.rx_packets++;
+			dev->stats.rx_packets++;
 		}
 
 		/* Return the packet to the pool */
@@ -757,12 +756,12 @@ static void lance_tx_pio(struct net_device *dev)
 		if (bits & LE_T1_ERR) {
 			u16 status = sbus_readw(&td->misc);
 
-			lp->stats.tx_errors++;
-			if (status & LE_T3_RTY)  lp->stats.tx_aborted_errors++;
-			if (status & LE_T3_LCOL) lp->stats.tx_window_errors++;
+			dev->stats.tx_errors++;
+			if (status & LE_T3_RTY)  dev->stats.tx_aborted_errors++;
+			if (status & LE_T3_LCOL) dev->stats.tx_window_errors++;
 
 			if (status & LE_T3_CLOS) {
-				lp->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 				if (lp->auto_select) {
 					lp->tpe = 1 - lp->tpe;
 					printk(KERN_NOTICE "%s: Carrier Lost, trying %s\n",
@@ -779,7 +778,7 @@ static void lance_tx_pio(struct net_device *dev)
 			 * transmitter, restart the adapter.
 			 */
 			if (status & (LE_T3_BUF|LE_T3_UFL)) {
-				lp->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 
 				printk(KERN_ERR "%s: Tx: ERR_BUF|ERR_UFL, restarting\n",
 				       dev->name);
@@ -797,13 +796,13 @@ static void lance_tx_pio(struct net_device *dev)
 
 			/* One collision before packet was sent. */
 			if (bits & LE_T1_EONE)
-				lp->stats.collisions++;
+				dev->stats.collisions++;
 
 			/* More than one collision, be optimistic. */
 			if (bits & LE_T1_EMORE)
-				lp->stats.collisions += 2;
+				dev->stats.collisions += 2;
 
-			lp->stats.tx_packets++;
+			dev->stats.tx_packets++;
 		}
 
 		j = TX_NEXT(j);
@@ -844,10 +843,10 @@ static irqreturn_t lance_interrupt(int irq, void *dev_id)
 		lp->tx(dev);
 
 	if (csr0 & LE_C0_BABL)
-		lp->stats.tx_errors++;
+		dev->stats.tx_errors++;
 
 	if (csr0 & LE_C0_MISS)
-		lp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 
 	if (csr0 & LE_C0_MERR) {
 		if (lp->dregs) {
@@ -1127,7 +1126,7 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irq(&lp->lock);
 
-	lp->stats.tx_bytes += len;
+	dev->stats.tx_bytes += len;
 
 	entry = lp->tx_new & TX_RING_MOD_MASK;
 	if (lp->pio_buffer) {
@@ -1170,13 +1169,6 @@ static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *lance_get_stats(struct net_device *dev)
-{
-	struct lance_private *lp = netdev_priv(dev);
-
-	return &lp->stats;
-}
-
 /* taken from the depca driver */
 static void lance_load_multicast(struct net_device *dev)
 {
@@ -1464,7 +1456,6 @@ no_link_test:
 	dev->hard_start_xmit = &lance_start_xmit;
 	dev->tx_timeout = &lance_tx_timeout;
 	dev->watchdog_timeo = 5*HZ;
-	dev->get_stats = &lance_get_stats;
 	dev->set_multicast_list = &lance_set_multicast;
 	dev->ethtool_ops = &sparc_lance_ethtool_ops;
 
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index 1b65ae8..815bddb 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -260,31 +260,31 @@ static int qe_is_bolixed(struct sunqe *qep, u32 qe_status)
 
 	if (qe_status & CREG_STAT_EDEFER) {
 		printk(KERN_ERR "%s: Excessive transmit defers.\n", dev->name);
-		qep->net_stats.tx_errors++;
+		dev->stats.tx_errors++;
 	}
 
 	if (qe_status & CREG_STAT_CLOSS) {
 		printk(KERN_ERR "%s: Carrier lost, link down?\n", dev->name);
-		qep->net_stats.tx_errors++;
-		qep->net_stats.tx_carrier_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_carrier_errors++;
 	}
 
 	if (qe_status & CREG_STAT_ERETRIES) {
 		printk(KERN_ERR "%s: Excessive transmit retries (more than 16).\n", dev->name);
-		qep->net_stats.tx_errors++;
+		dev->stats.tx_errors++;
 		mace_hwbug_workaround = 1;
 	}
 
 	if (qe_status & CREG_STAT_LCOLL) {
 		printk(KERN_ERR "%s: Late transmit collision.\n", dev->name);
-		qep->net_stats.tx_errors++;
-		qep->net_stats.collisions++;
+		dev->stats.tx_errors++;
+		dev->stats.collisions++;
 		mace_hwbug_workaround = 1;
 	}
 
 	if (qe_status & CREG_STAT_FUFLOW) {
 		printk(KERN_ERR "%s: Transmit fifo underflow, driver bug.\n", dev->name);
-		qep->net_stats.tx_errors++;
+		dev->stats.tx_errors++;
 		mace_hwbug_workaround = 1;
 	}
 
@@ -297,104 +297,104 @@ static int qe_is_bolixed(struct sunqe *qep, u32 qe_status)
 	}
 
 	if (qe_status & CREG_STAT_CCOFLOW) {
-		qep->net_stats.tx_errors += 256;
-		qep->net_stats.collisions += 256;
+		dev->stats.tx_errors += 256;
+		dev->stats.collisions += 256;
 	}
 
 	if (qe_status & CREG_STAT_TXDERROR) {
 		printk(KERN_ERR "%s: Transmit descriptor is bogus, driver bug.\n", dev->name);
-		qep->net_stats.tx_errors++;
-		qep->net_stats.tx_aborted_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
 		mace_hwbug_workaround = 1;
 	}
 
 	if (qe_status & CREG_STAT_TXLERR) {
 		printk(KERN_ERR "%s: Transmit late error.\n", dev->name);
-		qep->net_stats.tx_errors++;
+		dev->stats.tx_errors++;
 		mace_hwbug_workaround = 1;
 	}
 
 	if (qe_status & CREG_STAT_TXPERR) {
 		printk(KERN_ERR "%s: Transmit DMA parity error.\n", dev->name);
-		qep->net_stats.tx_errors++;
-		qep->net_stats.tx_aborted_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
 		mace_hwbug_workaround = 1;
 	}
 
 	if (qe_status & CREG_STAT_TXSERR) {
 		printk(KERN_ERR "%s: Transmit DMA sbus error ack.\n", dev->name);
-		qep->net_stats.tx_errors++;
-		qep->net_stats.tx_aborted_errors++;
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
 		mace_hwbug_workaround = 1;
 	}
 
 	if (qe_status & CREG_STAT_RCCOFLOW) {
-		qep->net_stats.rx_errors += 256;
-		qep->net_stats.collisions += 256;
+		dev->stats.rx_errors += 256;
+		dev->stats.collisions += 256;
 	}
 
 	if (qe_status & CREG_STAT_RUOFLOW) {
-		qep->net_stats.rx_errors += 256;
-		qep->net_stats.rx_over_errors += 256;
+		dev->stats.rx_errors += 256;
+		dev->stats.rx_over_errors += 256;
 	}
 
 	if (qe_status & CREG_STAT_MCOFLOW) {
-		qep->net_stats.rx_errors += 256;
-		qep->net_stats.rx_missed_errors += 256;
+		dev->stats.rx_errors += 256;
+		dev->stats.rx_missed_errors += 256;
 	}
 
 	if (qe_status & CREG_STAT_RXFOFLOW) {
 		printk(KERN_ERR "%s: Receive fifo overflow.\n", dev->name);
-		qep->net_stats.rx_errors++;
-		qep->net_stats.rx_over_errors++;
+		dev->stats.rx_errors++;
+		dev->stats.rx_over_errors++;
 	}
 
 	if (qe_status & CREG_STAT_RLCOLL) {
 		printk(KERN_ERR "%s: Late receive collision.\n", dev->name);
-		qep->net_stats.rx_errors++;
-		qep->net_stats.collisions++;
+		dev->stats.rx_errors++;
+		dev->stats.collisions++;
 	}
 
 	if (qe_status & CREG_STAT_FCOFLOW) {
-		qep->net_stats.rx_errors += 256;
-		qep->net_stats.rx_frame_errors += 256;
+		dev->stats.rx_errors += 256;
+		dev->stats.rx_frame_errors += 256;
 	}
 
 	if (qe_status & CREG_STAT_CECOFLOW) {
-		qep->net_stats.rx_errors += 256;
-		qep->net_stats.rx_crc_errors += 256;
+		dev->stats.rx_errors += 256;
+		dev->stats.rx_crc_errors += 256;
 	}
 
 	if (qe_status & CREG_STAT_RXDROP) {
 		printk(KERN_ERR "%s: Receive packet dropped.\n", dev->name);
-		qep->net_stats.rx_errors++;
-		qep->net_stats.rx_dropped++;
-		qep->net_stats.rx_missed_errors++;
+		dev->stats.rx_errors++;
+		dev->stats.rx_dropped++;
+		dev->stats.rx_missed_errors++;
 	}
 
 	if (qe_status & CREG_STAT_RXSMALL) {
 		printk(KERN_ERR "%s: Receive buffer too small, driver bug.\n", dev->name);
-		qep->net_stats.rx_errors++;
-		qep->net_stats.rx_length_errors++;
+		dev->stats.rx_errors++;
+		dev->stats.rx_length_errors++;
 	}
 
 	if (qe_status & CREG_STAT_RXLERR) {
 		printk(KERN_ERR "%s: Receive late error.\n", dev->name);
-		qep->net_stats.rx_errors++;
+		dev->stats.rx_errors++;
 		mace_hwbug_workaround = 1;
 	}
 
 	if (qe_status & CREG_STAT_RXPERR) {
 		printk(KERN_ERR "%s: Receive DMA parity error.\n", dev->name);
-		qep->net_stats.rx_errors++;
-		qep->net_stats.rx_missed_errors++;
+		dev->stats.rx_errors++;
+		dev->stats.rx_missed_errors++;
 		mace_hwbug_workaround = 1;
 	}
 
 	if (qe_status & CREG_STAT_RXSERR) {
 		printk(KERN_ERR "%s: Receive DMA sbus error ack.\n", dev->name);
-		qep->net_stats.rx_errors++;
-		qep->net_stats.rx_missed_errors++;
+		dev->stats.rx_errors++;
+		dev->stats.rx_missed_errors++;
 		mace_hwbug_workaround = 1;
 	}
 
@@ -428,14 +428,14 @@ static void qe_rx(struct sunqe *qep)
 
 		/* Check for errors. */
 		if (len < ETH_ZLEN) {
-			qep->net_stats.rx_errors++;
-			qep->net_stats.rx_length_errors++;
-			qep->net_stats.rx_dropped++;
+			dev->stats.rx_errors++;
+			dev->stats.rx_length_errors++;
+			dev->stats.rx_dropped++;
 		} else {
 			skb = dev_alloc_skb(len + 2);
 			if (skb == NULL) {
 				drops++;
-				qep->net_stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 			} else {
 				skb_reserve(skb, 2);
 				skb_put(skb, len);
@@ -444,8 +444,8 @@ static void qe_rx(struct sunqe *qep)
 				skb->protocol = eth_type_trans(skb, qep->dev);
 				netif_rx(skb);
 				qep->dev->last_rx = jiffies;
-				qep->net_stats.rx_packets++;
-				qep->net_stats.rx_bytes += len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += len;
 			}
 		}
 		end_rxd->rx_addr = this_qbuf_dvma;
@@ -603,8 +603,8 @@ static int qe_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->trans_start = jiffies;
 	sbus_writel(CREG_CTRL_TWAKEUP, qep->qcregs + CREG_CTRL);
 
-	qep->net_stats.tx_packets++;
-	qep->net_stats.tx_bytes += len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += len;
 
 	if (TX_BUFFS_AVAIL(qep) <= 0) {
 		/* Halt the net queue and enable tx interrupts.
@@ -622,13 +622,6 @@ static int qe_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *qe_get_stats(struct net_device *dev)
-{
-	struct sunqe *qep = (struct sunqe *) dev->priv;
-
-	return &qep->net_stats;
-}
-
 static void qe_set_multicast(struct net_device *dev)
 {
 	struct sunqe *qep = (struct sunqe *) dev->priv;
@@ -904,7 +897,6 @@ static int __init qec_ether_init(struct sbus_dev *sdev)
 	dev->open = qe_open;
 	dev->stop = qe_close;
 	dev->hard_start_xmit = qe_start_xmit;
-	dev->get_stats = qe_get_stats;
 	dev->set_multicast_list = qe_set_multicast;
 	dev->tx_timeout = qe_tx_timeout;
 	dev->watchdog_timeo = 5*HZ;
diff --git a/drivers/net/sunqe.h b/drivers/net/sunqe.h
index af34f36..347c8dd 100644
--- a/drivers/net/sunqe.h
+++ b/drivers/net/sunqe.h
@@ -342,7 +342,6 @@ struct sunqe {
 	__u32				buffers_dvma;	/* DVMA visible address.       */
 	struct sunqec			*parent;
 	u8				mconfig;	/* Base MACE mconfig value     */
-	struct net_device_stats		net_stats;	/* Statistical counters        */
 	struct sbus_dev			*qe_sdev;	/* QE's SBUS device struct     */
 	struct net_device		*dev;		/* QE's netdevice struct       */
 	int				channel;	/* Who am I?                   */
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 62b2b30..5c14a26 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -109,7 +109,7 @@ static int tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 
 			/* We won't see all dropped packets individually, so overrun
 			 * error is more appropriate. */
-			tun->stats.tx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 		} else {
 			/* Single queue mode.
 			 * Driver handles dropping of all packets itself. */
@@ -128,7 +128,7 @@ static int tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 
 drop:
-	tun->stats.tx_dropped++;
+	dev->stats.tx_dropped++;
 	kfree_skb(skb);
 	return 0;
 }
@@ -171,12 +171,6 @@ tun_net_mclist(struct net_device *dev)
 	}
 }
 
-static struct net_device_stats *tun_net_stats(struct net_device *dev)
-{
-	struct tun_struct *tun = netdev_priv(dev);
-	return &tun->stats;
-}
-
 /* Initialize net device. */
 static void tun_net_init(struct net_device *dev)
 {
@@ -249,14 +243,14 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun, struct iovec *iv,
 		align = NET_IP_ALIGN;
 
 	if (!(skb = alloc_skb(len + align, GFP_KERNEL))) {
-		tun->stats.rx_dropped++;
+		tun->dev->stats.rx_dropped++;
 		return -ENOMEM;
 	}
 
 	if (align)
 		skb_reserve(skb, align);
 	if (memcpy_fromiovec(skb_put(skb, len), iv, len)) {
-		tun->stats.rx_dropped++;
+		tun->dev->stats.rx_dropped++;
 		kfree_skb(skb);
 		return -EFAULT;
 	}
@@ -278,8 +272,8 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun, struct iovec *iv,
 	netif_rx_ni(skb);
 	tun->dev->last_rx = jiffies;
 
-	tun->stats.rx_packets++;
-	tun->stats.rx_bytes += len;
+	tun->dev->stats.rx_packets++;
+	tun->dev->stats.rx_bytes += len;
 
 	return count;
 }
@@ -335,8 +329,8 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 	skb_copy_datagram_iovec(skb, 0, iv, len);
 	total += len;
 
-	tun->stats.tx_packets++;
-	tun->stats.tx_bytes += len;
+	tun->dev->stats.tx_packets++;
+	tun->dev->stats.tx_bytes += len;
 
 	return total;
 }
@@ -438,7 +432,6 @@ static void tun_setup(struct net_device *dev)
 	dev->open = tun_net_open;
 	dev->hard_start_xmit = tun_net_xmit;
 	dev->stop = tun_net_close;
-	dev->get_stats = tun_net_stats;
 	dev->ethtool_ops = &tun_ethtool_ops;
 	dev->destructor = free_netdev;
 }
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 12e01b2..ddfcb53 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3350,14 +3350,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	return 0;
 }
 
-/* returns a net_device_stats structure pointer */
-static struct net_device_stats *ucc_geth_get_stats(struct net_device *dev)
-{
-	struct ucc_geth_private *ugeth = netdev_priv(dev);
-
-	return &(ugeth->stats);
-}
-
 /* ucc_geth_timeout gets called when a packet has not been
  * transmitted after a set amount of time.
  * For now, assume that clearing out all the structures, and
@@ -3368,7 +3360,7 @@ static void ucc_geth_timeout(struct net_device *dev)
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
 
-	ugeth->stats.tx_errors++;
+	dev->stats.tx_errors++;
 
 	ugeth_dump_regs(ugeth);
 
@@ -3396,7 +3388,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irq(&ugeth->lock);
 
-	ugeth->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 
 	/* Start from the next BD that should be filled */
 	bd = ugeth->txBd[txQ];
@@ -3488,9 +3480,9 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 				dev_kfree_skb_any(skb);
 
 			ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]] = NULL;
-			ugeth->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 		} else {
-			ugeth->stats.rx_packets++;
+			dev->stats.rx_packets++;
 			howmany++;
 
 			/* Prep the skb for the packet */
@@ -3499,7 +3491,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 			/* Tell the skb what kind of packet this is */
 			skb->protocol = eth_type_trans(skb, ugeth->dev);
 
-			ugeth->stats.rx_bytes += length;
+			dev->stats.rx_bytes += length;
 			/* Send the packet up the stack */
 #ifdef CONFIG_UGETH_NAPI
 			netif_receive_skb(skb);
@@ -3514,7 +3506,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 		if (!skb) {
 			if (netif_msg_rx_err(ugeth))
 				ugeth_warn("%s: No Rx Data Buffer", __FUNCTION__);
-			ugeth->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 			break;
 		}
 
@@ -3556,7 +3548,7 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 		if ((bd == ugeth->txBd[txQ]) && (netif_queue_stopped(dev) == 0))
 			break;
 
-		ugeth->stats.tx_packets++;
+		dev->stats.tx_packets++;
 
 		/* Free the sk buffer associated with this TxBD */
 		dev_kfree_skb_irq(ugeth->
@@ -3683,10 +3675,10 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 	/* Errors and other events */
 	if (ucce & UCCE_OTHER) {
 		if (ucce & UCCE_BSY) {
-			ugeth->stats.rx_errors++;
+			dev->stats.rx_errors++;
 		}
 		if (ucce & UCCE_TXE) {
-			ugeth->stats.tx_errors++;
+			dev->stats.tx_errors++;
 		}
 	}
 
@@ -3968,7 +3960,6 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	dev->weight = UCC_GETH_DEV_WEIGHT;
 #endif				/* CONFIG_UGETH_NAPI */
 	dev->stop = ucc_geth_close;
-	dev->get_stats = ucc_geth_get_stats;
 //    dev->change_mtu = ucc_geth_change_mtu;
 	dev->mtu = 1500;
 	dev->set_multicast_list = ucc_geth_set_multi;
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index bb4dac8..4fff6af 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -1184,7 +1184,6 @@ struct ucc_geth_private {
 	struct ucc_geth_info *ug_info;
 	struct ucc_fast_private *uccf;
 	struct net_device *dev;
-	struct net_device_stats stats;	/* linux network statistics */
 	struct ucc_geth *ug_regs;
 	struct ucc_geth_init_pram *p_init_enet_param_shadow;
 	struct ucc_geth_exf_global_pram *p_exf_glbl_param;
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 33e2bc8..90c4d93 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -72,8 +72,6 @@ struct netfront_info {
 	struct list_head list;
 	struct net_device *netdev;
 
-	struct net_device_stats stats;
-
 	struct xen_netif_tx_front_ring tx;
 	struct xen_netif_rx_front_ring rx;
 
@@ -307,8 +305,6 @@ static int xennet_open(struct net_device *dev)
 {
 	struct netfront_info *np = netdev_priv(dev);
 
-	memset(&np->stats, 0, sizeof(np->stats));
-
 	spin_lock_bh(&np->rx_lock);
 	if (netif_carrier_ok(dev)) {
 		xennet_alloc_rx_buffers(dev);
@@ -533,8 +529,8 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (notify)
 		notify_remote_via_irq(np->netdev->irq);
 
-	np->stats.tx_bytes += skb->len;
-	np->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
 
 	/* Note: It is not safe to access skb after xennet_tx_buf_gc()! */
 	xennet_tx_buf_gc(dev);
@@ -547,7 +543,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 
  drop:
-	np->stats.tx_dropped++;
+	dev->stats.tx_dropped++;
 	dev_kfree_skb(skb);
 	return 0;
 }
@@ -559,12 +555,6 @@ static int xennet_close(struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *xennet_get_stats(struct net_device *dev)
-{
-	struct netfront_info *np = netdev_priv(dev);
-	return &np->stats;
-}
-
 static void xennet_move_rx_slot(struct netfront_info *np, struct sk_buff *skb,
 				grant_ref_t ref)
 {
@@ -801,7 +791,6 @@ out:
 static int handle_incoming_queue(struct net_device *dev,
 				  struct sk_buff_head *rxq)
 {
-	struct netfront_info *np = netdev_priv(dev);
 	int packets_dropped = 0;
 	struct sk_buff *skb;
 
@@ -823,13 +812,13 @@ static int handle_incoming_queue(struct net_device *dev,
 			if (skb_checksum_setup(skb)) {
 				kfree_skb(skb);
 				packets_dropped++;
-				np->stats.rx_errors++;
+				dev->stats.rx_errors++;
 				continue;
 			}
 		}
 
-		np->stats.rx_packets++;
-		np->stats.rx_bytes += skb->len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += skb->len;
 
 		/* Pass it up. */
 		netif_receive_skb(skb);
@@ -884,7 +873,7 @@ static int xennet_poll(struct net_device *dev, int *pbudget)
 err:
 			while ((skb = __skb_dequeue(&tmpq)))
 				__skb_queue_tail(&errq, skb);
-			np->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			i = np->rx.rsp_cons;
 			continue;
 		}
@@ -1167,7 +1156,6 @@ static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev
 	netdev->open            = xennet_open;
 	netdev->hard_start_xmit = xennet_start_xmit;
 	netdev->stop            = xennet_close;
-	netdev->get_stats       = xennet_get_stats;
 	netdev->poll            = xennet_poll;
 	netdev->uninit          = xennet_uninit;
 	netdev->change_mtu	= xennet_change_mtu;
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 870c539..d616fb4 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -318,7 +318,6 @@ struct yellowfin_private {
 	dma_addr_t tx_status_dma;
 
 	struct timer_list timer;	/* Media selection timer. */
-	struct net_device_stats stats;
 	/* Frequently used and paired value: keep adjacent for cache effect. */
 	int chip_id, drv_flags;
 	struct pci_dev *pci_dev;
@@ -353,7 +352,6 @@ static irqreturn_t yellowfin_interrupt(int irq, void *dev_instance);
 static int yellowfin_rx(struct net_device *dev);
 static void yellowfin_error(struct net_device *dev, int intr_status);
 static int yellowfin_close(struct net_device *dev);
-static struct net_device_stats *yellowfin_get_stats(struct net_device *dev);
 static void set_rx_mode(struct net_device *dev);
 static const struct ethtool_ops ethtool_ops;
 
@@ -470,7 +468,6 @@ static int __devinit yellowfin_init_one(struct pci_dev *pdev,
 	dev->open = &yellowfin_open;
 	dev->hard_start_xmit = &yellowfin_start_xmit;
 	dev->stop = &yellowfin_close;
-	dev->get_stats = &yellowfin_get_stats;
 	dev->set_multicast_list = &set_rx_mode;
 	dev->do_ioctl = &netdev_ioctl;
 	SET_ETHTOOL_OPS(dev, &ethtool_ops);
@@ -718,7 +715,7 @@ static void yellowfin_tx_timeout(struct net_device *dev)
 		netif_wake_queue (dev);		/* Typical path */
 
 	dev->trans_start = jiffies;
-	yp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 }
 
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
@@ -924,8 +921,8 @@ static irqreturn_t yellowfin_interrupt(int irq, void *dev_instance)
 			if (yp->tx_ring[entry].result_status == 0)
 				break;
 			skb = yp->tx_skbuff[entry];
-			yp->stats.tx_packets++;
-			yp->stats.tx_bytes += skb->len;
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes += skb->len;
 			/* Free the original skb. */
 			pci_unmap_single(yp->pci_dev, yp->tx_ring[entry].addr,
 				skb->len, PCI_DMA_TODEVICE);
@@ -969,20 +966,20 @@ static irqreturn_t yellowfin_interrupt(int irq, void *dev_instance)
 						printk(KERN_DEBUG "%s: Transmit error, Tx status %4.4x.\n",
 							   dev->name, tx_errs);
 #endif
-					yp->stats.tx_errors++;
-					if (tx_errs & 0xF800) yp->stats.tx_aborted_errors++;
-					if (tx_errs & 0x0800) yp->stats.tx_carrier_errors++;
-					if (tx_errs & 0x2000) yp->stats.tx_window_errors++;
-					if (tx_errs & 0x8000) yp->stats.tx_fifo_errors++;
+					dev->stats.tx_errors++;
+					if (tx_errs & 0xF800) dev->stats.tx_aborted_errors++;
+					if (tx_errs & 0x0800) dev->stats.tx_carrier_errors++;
+					if (tx_errs & 0x2000) dev->stats.tx_window_errors++;
+					if (tx_errs & 0x8000) dev->stats.tx_fifo_errors++;
 				} else {
 #ifndef final_version
 					if (yellowfin_debug > 4)
 						printk(KERN_DEBUG "%s: Normal transmit, Tx status %4.4x.\n",
 							   dev->name, tx_errs);
 #endif
-					yp->stats.tx_bytes += skb->len;
-					yp->stats.collisions += tx_errs & 15;
-					yp->stats.tx_packets++;
+					dev->stats.tx_bytes += skb->len;
+					dev->stats.collisions += tx_errs & 15;
+					dev->stats.tx_packets++;
 				}
 				/* Free the original skb. */
 				pci_unmap_single(yp->pci_dev,
@@ -1077,26 +1074,26 @@ static int yellowfin_rx(struct net_device *dev)
 			if (data_size != 0)
 				printk(KERN_WARNING "%s: Oversized Ethernet frame spanned multiple buffers,"
 					   " status %4.4x, data_size %d!\n", dev->name, desc_status, data_size);
-			yp->stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 		} else if ((yp->drv_flags & IsGigabit)  &&  (frame_status & 0x0038)) {
 			/* There was a error. */
 			if (yellowfin_debug > 3)
 				printk(KERN_DEBUG "  yellowfin_rx() Rx error was %4.4x.\n",
 					   frame_status);
-			yp->stats.rx_errors++;
-			if (frame_status & 0x0060) yp->stats.rx_length_errors++;
-			if (frame_status & 0x0008) yp->stats.rx_frame_errors++;
-			if (frame_status & 0x0010) yp->stats.rx_crc_errors++;
-			if (frame_status < 0) yp->stats.rx_dropped++;
+			dev->stats.rx_errors++;
+			if (frame_status & 0x0060) dev->stats.rx_length_errors++;
+			if (frame_status & 0x0008) dev->stats.rx_frame_errors++;
+			if (frame_status & 0x0010) dev->stats.rx_crc_errors++;
+			if (frame_status < 0) dev->stats.rx_dropped++;
 		} else if ( !(yp->drv_flags & IsGigabit)  &&
 				   ((buf_addr[data_size-1] & 0x85) || buf_addr[data_size-2] & 0xC0)) {
 			u8 status1 = buf_addr[data_size-2];
 			u8 status2 = buf_addr[data_size-1];
-			yp->stats.rx_errors++;
-			if (status1 & 0xC0) yp->stats.rx_length_errors++;
-			if (status2 & 0x03) yp->stats.rx_frame_errors++;
-			if (status2 & 0x04) yp->stats.rx_crc_errors++;
-			if (status2 & 0x80) yp->stats.rx_dropped++;
+			dev->stats.rx_errors++;
+			if (status1 & 0xC0) dev->stats.rx_length_errors++;
+			if (status2 & 0x03) dev->stats.rx_frame_errors++;
+			if (status2 & 0x04) dev->stats.rx_crc_errors++;
+			if (status2 & 0x80) dev->stats.rx_dropped++;
 #ifdef YF_PROTOTYPE		/* Support for prototype hardware errata. */
 		} else if ((yp->flags & HasMACAddrBug)  &&
 			memcmp(le32_to_cpu(yp->rx_ring_dma +
@@ -1146,8 +1143,8 @@ static int yellowfin_rx(struct net_device *dev)
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
 			dev->last_rx = jiffies;
-			yp->stats.rx_packets++;
-			yp->stats.rx_bytes += pkt_len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_len;
 		}
 		entry = (++yp->cur_rx) % RX_RING_SIZE;
 	}
@@ -1181,15 +1178,13 @@ static int yellowfin_rx(struct net_device *dev)
 
 static void yellowfin_error(struct net_device *dev, int intr_status)
 {
-	struct yellowfin_private *yp = netdev_priv(dev);
-
 	printk(KERN_ERR "%s: Something Wicked happened! %4.4x.\n",
 		   dev->name, intr_status);
 	/* Hmmmmm, it's not clear what to do here. */
 	if (intr_status & (IntrTxPCIErr | IntrTxPCIFault))
-		yp->stats.tx_errors++;
+		dev->stats.tx_errors++;
 	if (intr_status & (IntrRxPCIErr | IntrRxPCIFault))
-		yp->stats.rx_errors++;
+		dev->stats.rx_errors++;
 }
 
 static int yellowfin_close(struct net_device *dev)
@@ -1281,12 +1276,6 @@ static int yellowfin_close(struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *yellowfin_get_stats(struct net_device *dev)
-{
-	struct yellowfin_private *yp = netdev_priv(dev);
-	return &yp->stats;
-}
-
 /* Set or clear the multicast filter for this adaptor. */
 
 static void set_rx_mode(struct net_device *dev)
diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index 4032e9f..da489be 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -128,7 +128,6 @@ MODULE_LICENSE("GPL");
 
 struct znet_private {
 	int rx_dma, tx_dma;
-	struct net_device_stats stats;
 	spinlock_t lock;
 	short sia_base, sia_size, io_size;
 	struct i82593_conf_block i593_init;
@@ -161,7 +160,6 @@ static int	znet_send_packet(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t znet_interrupt(int irq, void *dev_id);
 static void	znet_rx(struct net_device *dev);
 static int	znet_close(struct net_device *dev);
-static struct net_device_stats *net_get_stats(struct net_device *dev);
 static void hardware_init(struct net_device *dev);
 static void update_stop_hit(short ioaddr, unsigned short rx_stop_offset);
 static void znet_tx_timeout (struct net_device *dev);
@@ -447,7 +445,6 @@ static int __init znet_probe (void)
 	dev->open = &znet_open;
 	dev->hard_start_xmit = &znet_send_packet;
 	dev->stop = &znet_close;
-	dev->get_stats	= net_get_stats;
 	dev->set_multicast_list = &znet_set_multicast_list;
 	dev->tx_timeout = znet_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
@@ -566,7 +563,7 @@ static int znet_send_packet(struct sk_buff *skb, struct net_device *dev)
 		ushort *tx_link = znet->tx_cur - 1;
 		ushort rnd_len = (length + 1)>>1;
 
-		znet->stats.tx_bytes+=length;
+		dev->stats.tx_bytes+=length;
 
 		if (znet->tx_cur >= znet->tx_end)
 		  znet->tx_cur = znet->tx_start;
@@ -641,20 +638,20 @@ static irqreturn_t znet_interrupt(int irq, void *dev_id)
 			tx_status = inw(ioaddr);
 			/* It's undocumented, but tx_status seems to match the i82586. */
 			if (tx_status & TX_OK) {
-				znet->stats.tx_packets++;
-				znet->stats.collisions += tx_status & TX_NCOL_MASK;
+				dev->stats.tx_packets++;
+				dev->stats.collisions += tx_status & TX_NCOL_MASK;
 			} else {
 				if (tx_status & (TX_LOST_CTS | TX_LOST_CRS))
-					znet->stats.tx_carrier_errors++;
+					dev->stats.tx_carrier_errors++;
 				if (tx_status & TX_UND_RUN)
-					znet->stats.tx_fifo_errors++;
+					dev->stats.tx_fifo_errors++;
 				if (!(tx_status & TX_HRT_BEAT))
-					znet->stats.tx_heartbeat_errors++;
+					dev->stats.tx_heartbeat_errors++;
 				if (tx_status & TX_MAX_COL)
-					znet->stats.tx_aborted_errors++;
+					dev->stats.tx_aborted_errors++;
 				/* ...and the catch-all. */
 				if ((tx_status | (TX_LOST_CRS | TX_LOST_CTS | TX_UND_RUN | TX_HRT_BEAT | TX_MAX_COL)) != (TX_LOST_CRS | TX_LOST_CTS | TX_UND_RUN | TX_HRT_BEAT | TX_MAX_COL))
-					znet->stats.tx_errors++;
+					dev->stats.tx_errors++;
 
 				/* Transceiver may be stuck if cable
 				 * was removed while emiting a
@@ -750,19 +747,19 @@ static void znet_rx(struct net_device *dev)
 				 this_rfp_ptr[-3]<<1);
 		/* Once again we must assume that the i82586 docs apply. */
 		if ( ! (status & RX_RCV_OK)) { /* There was an error. */
-			znet->stats.rx_errors++;
-			if (status & RX_CRC_ERR) znet->stats.rx_crc_errors++;
-			if (status & RX_ALG_ERR) znet->stats.rx_frame_errors++;
+			dev->stats.rx_errors++;
+			if (status & RX_CRC_ERR) dev->stats.rx_crc_errors++;
+			if (status & RX_ALG_ERR) dev->stats.rx_frame_errors++;
 #if 0
-			if (status & 0x0200) znet->stats.rx_over_errors++; /* Wrong. */
-			if (status & 0x0100) znet->stats.rx_fifo_errors++;
+			if (status & 0x0200) dev->stats.rx_over_errors++; /* Wrong. */
+			if (status & 0x0100) dev->stats.rx_fifo_errors++;
 #else
 			/* maz : Wild guess... */
-			if (status & RX_OVRRUN) znet->stats.rx_over_errors++;
+			if (status & RX_OVRRUN) dev->stats.rx_over_errors++;
 #endif
-			if (status & RX_SRT_FRM) znet->stats.rx_length_errors++;
+			if (status & RX_SRT_FRM) dev->stats.rx_length_errors++;
 		} else if (pkt_len > 1536) {
-			znet->stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 		} else {
 			/* Malloc up new buffer. */
 			struct sk_buff *skb;
@@ -771,7 +768,7 @@ static void znet_rx(struct net_device *dev)
 			if (skb == NULL) {
 				if (znet_debug)
 				  printk(KERN_WARNING "%s: Memory squeeze, dropping packet.\n", dev->name);
-				znet->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				break;
 			}
 
@@ -791,8 +788,8 @@ static void znet_rx(struct net_device *dev)
 		  skb->protocol=eth_type_trans(skb,dev);
 		  netif_rx(skb);
 		  dev->last_rx = jiffies;
-		  znet->stats.rx_packets++;
-		  znet->stats.rx_bytes += pkt_len;
+		  dev->stats.rx_packets++;
+		  dev->stats.rx_bytes += pkt_len;
 		}
 		znet->rx_cur = this_rfp_ptr;
 		if (znet->rx_cur >= znet->rx_end)
@@ -829,15 +826,6 @@ static int znet_close(struct net_device *dev)
 	return 0;
 }
 
-/* Get the current statistics.	This may be called with the card open or
-   closed. */
-static struct net_device_stats *net_get_stats(struct net_device *dev)
-{
-	struct znet_private *znet = dev->priv;
-
-	return &znet->stats;
-}
-
 static void show_dma(struct net_device *dev)
 {
 	short ioaddr = dev->base_addr;
diff --git a/include/linux/if_eql.h b/include/linux/if_eql.h
index b68752f..79c4f26 100644
--- a/include/linux/if_eql.h
+++ b/include/linux/if_eql.h
@@ -58,7 +58,6 @@ typedef struct equalizer {
 	slave_queue_t		queue;
 	int			min_slaves;
 	int			max_slaves;
-	struct net_device_stats	stats;
 	struct timer_list	timer;
 } equalizer_t;  
 
diff --git a/include/linux/if_shaper.h b/include/linux/if_shaper.h
index 68c896a..5157474 100644
--- a/include/linux/if_shaper.h
+++ b/include/linux/if_shaper.h
@@ -24,7 +24,6 @@ struct shaper
 	unsigned long recovery;	/* Time we can next clock a packet out on
 				   an empty queue */
 	spinlock_t lock;
-        struct net_device_stats stats;
 	struct net_device *dev;
 	int  (*hard_start_xmit) (struct sk_buff *skb,
 		struct net_device *dev);
diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index 42eb694..33e489d 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -42,7 +42,6 @@ struct tun_struct {
 	struct sk_buff_head	readq;
 
 	struct net_device	*dev;
-	struct net_device_stats	stats;
 
 	struct fasync_struct    *fasync;
 
