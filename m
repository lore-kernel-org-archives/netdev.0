From: linux@kbdbabel.org
Subject: [PATCH] net/pcmcia/3c589_cs: using netdev_info and friends where appropriate
Date: Wed, 31 Mar 2010 16:42:10 +0400
Message-ID: <1270039330-5775-1-git-send-email-linux@kbdbabel.org>
References: <1269969733.4558.171.camel@Joe-Laptop.home>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ken Kawasaki <ken_kawasaki@spring.nifty.jp>,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Magnus Damm <damm@opensource.se>,
	Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux@kbdbabel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269969733.4558.171.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Kurz <linux@kbdbabel.org>

Signed-off-by: Alexander Kurz <linux@kbdbabel.org>
---
 drivers/net/pcmcia/3c589_cs.c |  286 +++++++++++++++++++++--------------------
 1 files changed, 147 insertions(+), 139 deletions(-)

diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 091e0b0..580977f 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -1,20 +1,20 @@
 /*======================================================================
 
     A PCMCIA ethernet driver for the 3com 3c589 card.
-    
+
     Copyright (C) 1999 David A. Hinds -- dahinds@users.sourceforge.net
 
     3c589_cs.c 1.162 2001/10/13 00:08:50
 
     The network driver code is based on Donald Becker's 3c589 code:
-    
+
     Written 1994 by Donald Becker.
     Copyright 1993 United States Government as represented by the
     Director, National Security Agency.  This software may be used and
     distributed according to the terms of the GNU General Public License,
     incorporated herein by reference.
     Donald Becker may be reached at becker@scyld.com
-    
+
     Updated for 2.5.x by Alan Cox <alan@lxorguk.ukuu.org.uk>
 
 ======================================================================*/
@@ -69,31 +69,54 @@
 /* The top five bits written to EL3_CMD are a command, the lower
    11 bits are the parameter, if applicable. */
 enum c509cmd {
-    TotalReset = 0<<11, SelectWindow = 1<<11, StartCoax = 2<<11,
-    RxDisable = 3<<11, RxEnable = 4<<11, RxReset = 5<<11, RxDiscard = 8<<11,
-    TxEnable = 9<<11, TxDisable = 10<<11, TxReset = 11<<11,
-    FakeIntr = 12<<11, AckIntr = 13<<11, SetIntrEnb = 14<<11,
-    SetStatusEnb = 15<<11, SetRxFilter = 16<<11, SetRxThreshold = 17<<11,
-    SetTxThreshold = 18<<11, SetTxStart = 19<<11, StatsEnable = 21<<11,
-    StatsDisable = 22<<11, StopCoax = 23<<11,
+	TotalReset	= 0<<11,
+	SelectWindow	= 1<<11,
+	StartCoax	= 2<<11,
+	RxDisable	= 3<<11,
+	RxEnable	= 4<<11,
+	RxReset		= 5<<11,
+	RxDiscard	= 8<<11,
+	TxEnable	= 9<<11,
+	TxDisable	= 10<<11,
+	TxReset		= 11<<11,
+	FakeIntr	= 12<<11,
+	AckIntr		= 13<<11,
+	SetIntrEnb	= 14<<11,
+	SetStatusEnb	= 15<<11,
+	SetRxFilter	= 16<<11,
+	SetRxThreshold	= 17<<11,
+	SetTxThreshold	= 18<<11,
+	SetTxStart	= 19<<11,
+	StatsEnable	= 21<<11,
+	StatsDisable	= 22<<11,
+	StopCoax	= 23<<11
 };
 
 enum c509status {
-    IntLatch = 0x0001, AdapterFailure = 0x0002, TxComplete = 0x0004,
-    TxAvailable = 0x0008, RxComplete = 0x0010, RxEarly = 0x0020,
-    IntReq = 0x0040, StatsFull = 0x0080, CmdBusy = 0x1000
+	IntLatch	= 0x0001,
+	AdapterFailure	= 0x0002,
+	TxComplete	= 0x0004,
+	TxAvailable	= 0x0008,
+	RxComplete	= 0x0010,
+	RxEarly		= 0x0020,
+	IntReq		= 0x0040,
+	StatsFull	= 0x0080,
+	CmdBusy		= 0x1000
 };
 
 /* The SetRxFilter command accepts the following classes: */
 enum RxFilter {
-    RxStation = 1, RxMulticast = 2, RxBroadcast = 4, RxProm = 8
+	RxStation	= 1,
+	RxMulticast	= 2,
+	RxBroadcast	= 4,
+	RxProm		= 8
 };
 
 /* Register window 1 offsets, the window used in normal operation. */
 #define TX_FIFO		0x00
 #define RX_FIFO		0x00
-#define RX_STATUS 	0x08
-#define TX_STATUS 	0x0B
+#define RX_STATUS	0x08
+#define TX_STATUS	0x0B
 #define TX_FREE		0x0C	/* Remaining free bytes in Tx buffer. */
 
 #define WN0_IRQ		0x08	/* Window 0: Set IRQ line in bits 12-15. */
@@ -106,13 +129,13 @@ enum RxFilter {
 
 struct el3_private {
 	struct pcmcia_device	*p_dev;
-    dev_node_t 		node;
-    /* For transceiver monitoring */
-    struct timer_list	media;
-    u16			media_status;
-    u16			fast_poll;
-    unsigned long	last_irq;
-    spinlock_t		lock;
+	dev_node_t		node;
+	/* For transceiver monitoring */
+	struct timer_list	media;
+	u16			media_status;
+	u16			fast_poll;
+	unsigned long		last_irq;
+	spinlock_t		lock;
 };
 
 static const char *if_names[] = { "auto", "10baseT", "10base2", "AUI" };
@@ -164,15 +187,15 @@ static void tc589_detach(struct pcmcia_device *p_dev);
 ======================================================================*/
 
 static const struct net_device_ops el3_netdev_ops = {
-	.ndo_open 		= el3_open,
-	.ndo_stop 		= el3_close,
+	.ndo_open		= el3_open,
+	.ndo_stop		= el3_close,
 	.ndo_start_xmit		= el3_start_xmit,
-	.ndo_tx_timeout 	= el3_tx_timeout,
+	.ndo_tx_timeout		= el3_tx_timeout,
 	.ndo_set_config		= el3_config,
 	.ndo_get_stats		= el3_get_stats,
 	.ndo_set_multicast_list = set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
@@ -236,7 +259,7 @@ static void tc589_detach(struct pcmcia_device *link)
     tc589_config() is scheduled to run after a CARD_INSERTION event
     is received, to configure the PCMCIA socket, and to make the
     ethernet device available to the system.
-    
+
 ======================================================================*/
 
 static int tc589_config(struct pcmcia_device *link)
@@ -249,7 +272,7 @@ static int tc589_config(struct pcmcia_device *link)
     char *ram_split[] = {"5:3", "3:1", "1:1", "3:5"};
     u8 *buf;
     size_t len;
-    
+
     dev_dbg(&link->dev, "3c589_config\n");
 
     phys_addr = (__be16 *)dev->dev_addr;
@@ -278,7 +301,7 @@ static int tc589_config(struct pcmcia_device *link)
     ret = pcmcia_request_configuration(link, &link->conf);
     if (ret)
 	    goto failed;
-	
+
     dev->irq = link->irq.AssignedIRQ;
     dev->base_addr = link->io.BasePort1;
     ioaddr = dev->base_addr;
@@ -312,7 +335,7 @@ static int tc589_config(struct pcmcia_device *link)
 	dev->if_port = if_port;
     else
 	printk(KERN_ERR "3c589_cs: invalid if_port requested\n");
-    
+
     link->dev_node = &lp->node;
     SET_NETDEV_DEV(dev, &link->dev);
 
@@ -324,13 +347,12 @@ static int tc589_config(struct pcmcia_device *link)
 
     strcpy(lp->node.dev_name, dev->name);
 
-    printk(KERN_INFO "%s: 3Com 3c%s, io %#3lx, irq %d, "
-	   "hw_addr %pM\n",
-	   dev->name, (multi ? "562" : "589"), dev->base_addr, dev->irq,
-	   dev->dev_addr);
-    printk(KERN_INFO "  %dK FIFO split %s Rx:Tx, %s xcvr\n",
-	   (fifo & 7) ? 32 : 8, ram_split[(fifo >> 16) & 3],
-	   if_names[dev->if_port]);
+    netdev_info(dev, "3Com 3c%s, io %#3lx, irq %d, hw_addr %pM\n",
+		(multi ? "562" : "589"), dev->base_addr, dev->irq,
+		dev->dev_addr);
+    netdev_info(dev, "  %dK FIFO split %s Rx:Tx, %s xcvr\n",
+		(fifo & 7) ? 32 : 8, ram_split[(fifo >> 16) & 3],
+		if_names[dev->if_port]);
     return 0;
 
 failed:
@@ -343,7 +365,7 @@ failed:
     After a card is removed, tc589_release() will unregister the net
     device, and release the PCMCIA configuration.  If the device is
     still open, this will be postponed until it is closed.
-    
+
 ======================================================================*/
 
 static void tc589_release(struct pcmcia_device *link)
@@ -365,7 +387,7 @@ static int tc589_resume(struct pcmcia_device *link)
 {
 	struct net_device *dev = link->priv;
 
- 	if (link->open) {
+	if (link->open) {
 		tc589_reset(dev);
 		netif_device_attach(dev);
 	}
@@ -385,8 +407,7 @@ static void tc589_wait_for_completion(struct net_device *dev, int cmd)
     while (--i > 0)
 	if (!(inw(dev->base_addr + EL3_STATUS) & 0x1000)) break;
     if (i == 0)
-	printk(KERN_WARNING "%s: command 0x%04x did not complete!\n",
-	       dev->name, cmd);
+	netdev_warn(dev, "command 0x%04x did not complete!\n", cmd);
 }
 
 /*
@@ -412,7 +433,7 @@ static void tc589_set_xcvr(struct net_device *dev, int if_port)
 {
     struct el3_private *lp = netdev_priv(dev);
     unsigned int ioaddr = dev->base_addr;
-    
+
     EL3WINDOW(0);
     switch (if_port) {
     case 0: case 1: outw(0, ioaddr + 6); break;
@@ -435,14 +456,13 @@ static void dump_status(struct net_device *dev)
 {
     unsigned int ioaddr = dev->base_addr;
     EL3WINDOW(1);
-    printk(KERN_INFO "  irq status %04x, rx status %04x, tx status "
-	   "%02x  tx free %04x\n", inw(ioaddr+EL3_STATUS),
-	   inw(ioaddr+RX_STATUS), inb(ioaddr+TX_STATUS),
-	   inw(ioaddr+TX_FREE));
+    netdev_info(dev, "  irq status %04x, rx status %04x, tx status %02x  tx free %04x\n",
+		inw(ioaddr+EL3_STATUS), inw(ioaddr+RX_STATUS),
+		inb(ioaddr+TX_STATUS), inw(ioaddr+TX_FREE));
     EL3WINDOW(4);
-    printk(KERN_INFO "  diagnostics: fifo %04x net %04x ethernet %04x"
-	   " media %04x\n", inw(ioaddr+0x04), inw(ioaddr+0x06),
-	   inw(ioaddr+0x08), inw(ioaddr+0x0a));
+    netdev_info(dev, "  diagnostics: fifo %04x net %04x ethernet %04x media %04x\n",
+		inw(ioaddr+0x04), inw(ioaddr+0x06), inw(ioaddr+0x08),
+		inw(ioaddr+0x0a));
     EL3WINDOW(1);
 }
 
@@ -451,18 +471,18 @@ static void tc589_reset(struct net_device *dev)
 {
     unsigned int ioaddr = dev->base_addr;
     int i;
-    
+
     EL3WINDOW(0);
-    outw(0x0001, ioaddr + 4);			/* Activate board. */ 
+    outw(0x0001, ioaddr + 4);			/* Activate board. */
     outw(0x3f00, ioaddr + 8);			/* Set the IRQ line. */
-    
+
     /* Set the station address in window 2. */
     EL3WINDOW(2);
     for (i = 0; i < 6; i++)
 	outb(dev->dev_addr[i], ioaddr + i);
 
     tc589_set_xcvr(dev, dev->if_port);
-    
+
     /* Switch to the stats window, and clear all stats by reading. */
     outw(StatsDisable, ioaddr + EL3_CMD);
     EL3WINDOW(6);
@@ -470,7 +490,7 @@ static void tc589_reset(struct net_device *dev)
 	inb(ioaddr+i);
     inw(ioaddr + 10);
     inw(ioaddr + 12);
-    
+
     /* Switch to register set 1 for normal use. */
     EL3WINDOW(1);
 
@@ -504,8 +524,7 @@ static int el3_config(struct net_device *dev, struct ifmap *map)
     if ((map->port != (u_char)(-1)) && (map->port != dev->if_port)) {
 	if (map->port <= 3) {
 	    dev->if_port = map->port;
-	    printk(KERN_INFO "%s: switched to %s port\n",
-		   dev->name, if_names[dev->if_port]);
+	    netdev_info(dev, "switched to %s port\n", if_names[dev->if_port]);
 	    tc589_set_xcvr(dev, dev->if_port);
 	} else
 	    return -EINVAL;
@@ -517,13 +536,13 @@ static int el3_open(struct net_device *dev)
 {
     struct el3_private *lp = netdev_priv(dev);
     struct pcmcia_device *link = lp->p_dev;
-    
+
     if (!pcmcia_dev_present(link))
 	return -ENODEV;
 
     link->open++;
     netif_start_queue(dev);
-    
+
     tc589_reset(dev);
     init_timer(&lp->media);
     lp->media.function = &media_check;
@@ -533,15 +552,15 @@ static int el3_open(struct net_device *dev)
 
     dev_dbg(&link->dev, "%s: opened, status %4.4x.\n",
 	  dev->name, inw(dev->base_addr + EL3_STATUS));
-    
+
     return 0;
 }
 
 static void el3_tx_timeout(struct net_device *dev)
 {
     unsigned int ioaddr = dev->base_addr;
-    
-    printk(KERN_WARNING "%s: Transmit timed out!\n", dev->name);
+
+    netdev_warn(dev, "Transmit timed out!\n");
     dump_status(dev);
     dev->stats.tx_errors++;
     dev->trans_start = jiffies;
@@ -555,19 +574,18 @@ static void pop_tx_status(struct net_device *dev)
 {
     unsigned int ioaddr = dev->base_addr;
     int i;
-    
+
     /* Clear the Tx status stack. */
     for (i = 32; i > 0; i--) {
 	u_char tx_status = inb(ioaddr + TX_STATUS);
 	if (!(tx_status & 0x84)) break;
 	/* reset transmitter on jabber error or underrun */
 	if (tx_status & 0x30)
-	    tc589_wait_for_completion(dev, TxReset);
+		tc589_wait_for_completion(dev, TxReset);
 	if (tx_status & 0x38) {
-	    pr_debug("%s: transmit error: status 0x%02x\n",
-		  dev->name, tx_status);
-	    outw(TxEnable, ioaddr + EL3_CMD);
-	    dev->stats.tx_aborted_errors++;
+		netdev_dbg(dev, "transmit error: status 0x%02x\n", tx_status);
+		outw(TxEnable, ioaddr + EL3_CMD);
+		dev->stats.tx_aborted_errors++;
 	}
 	outb(0x00, ioaddr + TX_STATUS); /* Pop the status stack. */
     }
@@ -580,11 +598,10 @@ static netdev_tx_t el3_start_xmit(struct sk_buff *skb,
     struct el3_private *priv = netdev_priv(dev);
     unsigned long flags;
 
-    pr_debug("%s: el3_start_xmit(length = %ld) called, "
-	  "status %4.4x.\n", dev->name, (long)skb->len,
-	  inw(ioaddr + EL3_STATUS));
+    netdev_dbg(dev, "el3_start_xmit(length = %ld) called, status %4.4x.\n",
+	       (long)skb->len, inw(ioaddr + EL3_STATUS));
 
-    spin_lock_irqsave(&priv->lock, flags);    
+    spin_lock_irqsave(&priv->lock, flags);
 
     dev->stats.tx_bytes += skb->len;
 
@@ -602,9 +619,9 @@ static netdev_tx_t el3_start_xmit(struct sk_buff *skb,
     }
 
     pop_tx_status(dev);
-    spin_unlock_irqrestore(&priv->lock, flags);    
+    spin_unlock_irqrestore(&priv->lock, flags);
     dev_kfree_skb(skb);
-    
+
     return NETDEV_TX_OK;
 }
 
@@ -616,37 +633,32 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
     unsigned int ioaddr;
     __u16 status;
     int i = 0, handled = 1;
-    
+
     if (!netif_device_present(dev))
 	return IRQ_NONE;
 
     ioaddr = dev->base_addr;
 
-    pr_debug("%s: interrupt, status %4.4x.\n",
-	  dev->name, inw(ioaddr + EL3_STATUS));
+    netdev_dbg(dev, "interrupt, status %4.4x.\n", inw(ioaddr + EL3_STATUS));
 
-    spin_lock(&lp->lock);    
+    spin_lock(&lp->lock);
     while ((status = inw(ioaddr + EL3_STATUS)) &
 	(IntLatch | RxComplete | StatsFull)) {
 	if ((status & 0xe000) != 0x2000) {
-	    pr_debug("%s: interrupt from dead card\n", dev->name);
-	    handled = 0;
-	    break;
+		netdev_dbg(dev, "interrupt from dead card\n");
+		handled = 0;
+		break;
 	}
-	
 	if (status & RxComplete)
-	    el3_rx(dev);
-	
+		el3_rx(dev);
 	if (status & TxAvailable) {
-	    pr_debug("    TX room bit was handled.\n");
-	    /* There's room in the FIFO for a full-sized packet. */
-	    outw(AckIntr | TxAvailable, ioaddr + EL3_CMD);
-	    netif_wake_queue(dev);
+		netdev_dbg(dev, "    TX room bit was handled.\n");
+		/* There's room in the FIFO for a full-sized packet. */
+		outw(AckIntr | TxAvailable, ioaddr + EL3_CMD);
+		netif_wake_queue(dev);
 	}
-	
 	if (status & TxComplete)
-	    pop_tx_status(dev);
-
+		pop_tx_status(dev);
 	if (status & (AdapterFailure | RxEarly | StatsFull)) {
 	    /* Handle all uncommon interrupts. */
 	    if (status & StatsFull)		/* Empty statistics. */
@@ -660,8 +672,8 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 		EL3WINDOW(4);
 		fifo_diag = inw(ioaddr + 4);
 		EL3WINDOW(1);
-		printk(KERN_WARNING "%s: adapter failure, FIFO diagnostic"
-		       " register %04x.\n", dev->name, fifo_diag);
+		netdev_warn(dev, "adapter failure, FIFO diagnostic register %04x.\n",
+			    fifo_diag);
 		if (fifo_diag & 0x0400) {
 		    /* Tx overrun */
 		    tc589_wait_for_completion(dev, TxReset);
@@ -676,22 +688,20 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 		outw(AckIntr | AdapterFailure, ioaddr + EL3_CMD);
 	    }
 	}
-	
 	if (++i > 10) {
-	    printk(KERN_ERR "%s: infinite loop in interrupt, "
-		   "status %4.4x.\n", dev->name, status);
-	    /* Clear all interrupts */
-	    outw(AckIntr | 0xFF, ioaddr + EL3_CMD);
-	    break;
+		netdev_err(dev, "infinite loop in interrupt, status %4.4x.\n",
+			   status);
+		/* Clear all interrupts */
+		outw(AckIntr | 0xFF, ioaddr + EL3_CMD);
+		break;
 	}
 	/* Acknowledge the IRQ. */
 	outw(AckIntr | IntReq | IntLatch, ioaddr + EL3_CMD);
     }
-
     lp->last_irq = jiffies;
-    spin_unlock(&lp->lock);    
-    pr_debug("%s: exiting interrupt, status %4.4x.\n",
-	  dev->name, inw(ioaddr + EL3_STATUS));
+    spin_unlock(&lp->lock);
+    netdev_dbg(dev, "exiting interrupt, status %4.4x.\n",
+	       inw(ioaddr + EL3_STATUS));
     return IRQ_RETVAL(handled);
 }
 
@@ -710,7 +720,7 @@ static void media_check(unsigned long arg)
     if ((inw(ioaddr + EL3_STATUS) & IntLatch) &&
 	(inb(ioaddr + EL3_TIMER) == 0xff)) {
 	if (!lp->fast_poll)
-	    printk(KERN_WARNING "%s: interrupt(s) dropped!\n", dev->name);
+		netdev_warn(dev, "interrupt(s) dropped!\n");
 
 	local_irq_save(flags);
 	el3_interrupt(dev->irq, dev);
@@ -727,7 +737,7 @@ static void media_check(unsigned long arg)
 
     /* lp->lock guards the EL3 window. Window should always be 1 except
        when the lock is held */
-    spin_lock_irqsave(&lp->lock, flags);    
+    spin_lock_irqsave(&lp->lock, flags);
     EL3WINDOW(4);
     media = inw(ioaddr+WN4_MEDIA) & 0xc810;
 
@@ -747,32 +757,30 @@ static void media_check(unsigned long arg)
     if (media != lp->media_status) {
 	if ((media & lp->media_status & 0x8000) &&
 	    ((lp->media_status ^ media) & 0x0800))
-	    printk(KERN_INFO "%s: %s link beat\n", dev->name,
-		   (lp->media_status & 0x0800 ? "lost" : "found"));
+		netdev_info(dev, "%s link beat\n",
+			    (lp->media_status & 0x0800 ? "lost" : "found"));
 	else if ((media & lp->media_status & 0x4000) &&
 		 ((lp->media_status ^ media) & 0x0010))
-	    printk(KERN_INFO "%s: coax cable %s\n", dev->name,
-		   (lp->media_status & 0x0010 ? "ok" : "problem"));
+		netdev_info(dev, "coax cable %s\n",
+			    (lp->media_status & 0x0010 ? "ok" : "problem"));
 	if (dev->if_port == 0) {
 	    if (media & 0x8000) {
 		if (media & 0x0800)
-		    printk(KERN_INFO "%s: flipped to 10baseT\n",
-			   dev->name);
+			netdev_info(dev, "flipped to 10baseT\n");
 		else
-		    tc589_set_xcvr(dev, 2);
+			tc589_set_xcvr(dev, 2);
 	    } else if (media & 0x4000) {
 		if (media & 0x0010)
 		    tc589_set_xcvr(dev, 1);
 		else
-		    printk(KERN_INFO "%s: flipped to 10base2\n",
-			   dev->name);
+		    netdev_info(dev, "flipped to 10base2\n");
 	    }
 	}
 	lp->media_status = media;
     }
-    
+
     EL3WINDOW(1);
-    spin_unlock_irqrestore(&lp->lock, flags);    
+    spin_unlock_irqrestore(&lp->lock, flags);
 
 reschedule:
     lp->media.expires = jiffies + HZ;
@@ -786,7 +794,7 @@ static struct net_device_stats *el3_get_stats(struct net_device *dev)
     struct pcmcia_device *link = lp->p_dev;
 
     if (pcmcia_dev_present(link)) {
-    	spin_lock_irqsave(&lp->lock, flags);
+	spin_lock_irqsave(&lp->lock, flags);
 	update_stats(dev);
 	spin_unlock_irqrestore(&lp->lock, flags);
     }
@@ -798,21 +806,21 @@ static struct net_device_stats *el3_get_stats(struct net_device *dev)
   single-threaded if the device is active. This is expected to be a rare
   operation, and it's simpler for the rest of the driver to assume that
   window 1 is always valid rather than use a special window-state variable.
-  
+
   Caller must hold the lock for this
 */
 static void update_stats(struct net_device *dev)
 {
     unsigned int ioaddr = dev->base_addr;
 
-    pr_debug("%s: updating the statistics.\n", dev->name);
+    netdev_dbg(dev, "updating the statistics.\n");
     /* Turn off statistics updates while reading. */
     outw(StatsDisable, ioaddr + EL3_CMD);
     /* Switch to the stats window, and read everything. */
     EL3WINDOW(6);
-    dev->stats.tx_carrier_errors 	+= inb(ioaddr + 0);
+    dev->stats.tx_carrier_errors	+= inb(ioaddr + 0);
     dev->stats.tx_heartbeat_errors	+= inb(ioaddr + 1);
-    /* Multiple collisions. */	   	inb(ioaddr + 2);
+    /* Multiple collisions. */		inb(ioaddr + 2);
     dev->stats.collisions		+= inb(ioaddr + 3);
     dev->stats.tx_window_errors		+= inb(ioaddr + 4);
     dev->stats.rx_fifo_errors		+= inb(ioaddr + 5);
@@ -821,7 +829,7 @@ static void update_stats(struct net_device *dev)
     /* Tx deferrals */			inb(ioaddr + 8);
     /* Rx octets */			inw(ioaddr + 10);
     /* Tx octets */			inw(ioaddr + 12);
-    
+
     /* Back to window 1, and turn statistics back on. */
     EL3WINDOW(1);
     outw(StatsEnable, ioaddr + EL3_CMD);
@@ -832,9 +840,9 @@ static int el3_rx(struct net_device *dev)
     unsigned int ioaddr = dev->base_addr;
     int worklimit = 32;
     short rx_status;
-    
-    pr_debug("%s: in rx_packet(), status %4.4x, rx_status %4.4x.\n",
-	  dev->name, inw(ioaddr+EL3_STATUS), inw(ioaddr+RX_STATUS));
+
+    netdev_dbg(dev, "in rx_packet(), status %4.4x, rx_status %4.4x.\n",
+	       inw(ioaddr+EL3_STATUS), inw(ioaddr+RX_STATUS));
     while (!((rx_status = inw(ioaddr + RX_STATUS)) & 0x8000) &&
 		    worklimit > 0) {
 	worklimit--;
@@ -852,11 +860,11 @@ static int el3_rx(struct net_device *dev)
 	} else {
 	    short pkt_len = rx_status & 0x7ff;
 	    struct sk_buff *skb;
-	    
+
 	    skb = dev_alloc_skb(pkt_len+5);
-	    
-	    pr_debug("    Receiving packet size %d status %4.4x.\n",
-		  pkt_len, rx_status);
+
+	    netdev_dbg(dev, "    Receiving packet size %d status %4.4x.\n",
+		       pkt_len, rx_status);
 	    if (skb != NULL) {
 		skb_reserve(skb, 2);
 		insl(ioaddr+RX_FIFO, skb_put(skb, pkt_len),
@@ -866,8 +874,8 @@ static int el3_rx(struct net_device *dev)
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += pkt_len;
 	    } else {
-		pr_debug("%s: couldn't allocate a sk_buff of"
-		      " size %d.\n", dev->name, pkt_len);
+		netdev_dbg(dev, "couldn't allocate a sk_buff of size %d.\n",
+			   pkt_len);
 		dev->stats.rx_dropped++;
 	    }
 	}
@@ -875,7 +883,7 @@ static int el3_rx(struct net_device *dev)
 	tc589_wait_for_completion(dev, RxDiscard);
     }
     if (worklimit == 0)
-	printk(KERN_WARNING "%s: too much work in el3_rx!\n", dev->name);
+	netdev_warn(dev, "too much work in el3_rx!\n");
     return 0;
 }
 
@@ -906,17 +914,17 @@ static int el3_close(struct net_device *dev)
     struct el3_private *lp = netdev_priv(dev);
     struct pcmcia_device *link = lp->p_dev;
     unsigned int ioaddr = dev->base_addr;
-    
+
     dev_dbg(&link->dev, "%s: shutting down ethercard.\n", dev->name);
 
     if (pcmcia_dev_present(link)) {
 	/* Turn off statistics ASAP.  We update dev->stats below. */
 	outw(StatsDisable, ioaddr + EL3_CMD);
-	
+
 	/* Disable the receiver and transmitter. */
 	outw(RxDisable, ioaddr + EL3_CMD);
 	outw(TxDisable, ioaddr + EL3_CMD);
-	
+
 	if (dev->if_port == 2)
 	    /* Turn off thinnet power.  Green! */
 	    outw(StopCoax, ioaddr + EL3_CMD);
@@ -925,12 +933,12 @@ static int el3_close(struct net_device *dev)
 	    EL3WINDOW(4);
 	    outw(0, ioaddr + WN4_MEDIA);
 	}
-	
+
 	/* Switching back to window 0 disables the IRQ. */
 	EL3WINDOW(0);
 	/* But we explicitly zero the IRQ line select anyway. */
 	outw(0x0f00, ioaddr + WN0_IRQ);
-        
+
 	/* Check if the card still exists */
 	if ((inw(ioaddr+EL3_STATUS) & 0xe000) == 0x2000)
 	    update_stats(dev);
@@ -939,7 +947,7 @@ static int el3_close(struct net_device *dev)
     link->open--;
     netif_stop_queue(dev);
     del_timer_sync(&lp->media);
-    
+
     return 0;
 }
 
@@ -961,7 +969,7 @@ static struct pcmcia_driver tc589_driver = {
 	},
 	.probe		= tc589_probe,
 	.remove		= tc589_detach,
-        .id_table       = tc589_ids,
+	.id_table	= tc589_ids,
 	.suspend	= tc589_suspend,
 	.resume		= tc589_resume,
 };
-- 
1.7.0
