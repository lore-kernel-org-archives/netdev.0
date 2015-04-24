From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 04/21] ARCNET: whitespace, tab and codingstyle fixes
Date: Fri, 24 Apr 2015 19:20:38 +0200
Message-ID: <1429896055-31680-5-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes trailing whitespaces in the whole
the ARCNET layer. It also replaces the use of space
with tabs and changes fixes the codingstyle on those lines.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rawmode.c  |   4 +-
 drivers/net/arcnet/arc-rimi.c     |   2 +-
 drivers/net/arcnet/arcnet.c       | 116 +++++++--------
 drivers/net/arcnet/com20020-isa.c |   2 +-
 drivers/net/arcnet/com20020.c     |  13 +-
 drivers/net/arcnet/com20020_cs.c  | 298 ++++++++++++++++++--------------------
 drivers/net/arcnet/com90io.c      |   2 +-
 drivers/net/arcnet/com90xx.c      |   4 +-
 include/linux/arcdevice.h         |   7 +-
 include/linux/com20020.h          |   4 +-
 include/uapi/linux/if_arcnet.h    |  48 +++---
 11 files changed, 239 insertions(+), 261 deletions(-)

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index 705e6ce..b603470 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -1,6 +1,6 @@
 /*
  * Linux ARCnet driver - "raw mode" packet encapsulation (no soft headers)
- * 
+ *
  * Written 1994-1999 by Avery Pennarun.
  * Derived from skeleton.c by Donald Becker.
  *
@@ -150,7 +150,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 	/* see linux/net/ethernet/eth.c to see where I got the following */
 
 	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP)) {
-		/* 
+		/*
 		 * FIXME: fill in the last byte of the dest ipaddr here to better
 		 * comply with RFC1051 in "noarp" mode.
 		 */
diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index b8b4c7b..4c95d3c 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -1,6 +1,6 @@
 /*
  * Linux ARCnet driver - "RIM I" (entirely mem-mapped) cards
- * 
+ *
  * Written 1994-1999 by Avery Pennarun.
  * Written 1999-2000 by Martin Mares <mj@ucw.cz>.
  * Derived from skeleton.c by Donald Becker.
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 816d0e9..f83034c 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -1,6 +1,6 @@
 /*
  * Linux ARCnet driver - device-independent routines
- * 
+ *
  * Written 1997 by David Woodhouse.
  * Written 1994-1999 by Avery Pennarun.
  * Written 1999-2000 by Martin Mares <mj@ucw.cz>.
@@ -20,12 +20,12 @@
  * modified by SRC, incorporated herein by reference.
  *
  * **********************
- * 
+ *
  * The change log is now in a file called ChangeLog in this directory.
  *
  * Sources:
  *  - Crynwr arcnet.com/arcether.com packet drivers.
- *  - arcnet.c v0.00 dated 1/1/94 and apparently by 
+ *  - arcnet.c v0.00 dated 1/1/94 and apparently by
  *     Donald Becker - it didn't work :)
  *  - skeleton.c v0.05 dated 11/16/93 by Donald Becker
  *     (from Linux Kernel 1.1.45)
@@ -168,7 +168,6 @@ void arcnet_dump_skb(struct net_device *dev,
 EXPORT_SYMBOL(arcnet_dump_skb);
 #endif
 
-
 /*
  * Dump the contents of an ARCnet buffer
  */
@@ -184,11 +183,11 @@ static void arcnet_dump_packet(struct net_device *dev, int bufnum,
 
 	/* hw.copy_from_card expects IRQ context so take the IRQ lock
 	   to keep it single threaded */
-	if(take_arcnet_lock)
+	if (take_arcnet_lock)
 		spin_lock_irqsave(&lp->lock, flags);
 
 	lp->hw.copy_from_card(dev, bufnum, 0, buf, 512);
-	if(take_arcnet_lock)
+	if (take_arcnet_lock)
 		spin_unlock_irqrestore(&lp->lock, flags);
 
 	/* if the offset[0] byte is nonzero, this is a 256-byte packet */
@@ -229,11 +228,10 @@ void arcnet_unregister_proto(struct ArcProto *proto)
 	}
 }
 
-
 /*
  * Add a buffer to the queue.  Only the interrupt handler is allowed to do
  * this, unless interrupts are disabled.
- * 
+ *
  * Note: we don't check for a full queue, since there aren't enough buffers
  * to more than fill it.
  */
@@ -248,13 +246,12 @@ static void release_arcbuf(struct net_device *dev, int bufnum)
 	BUGLVL(D_DURING) {
 		BUGMSG(D_DURING, "release_arcbuf: freed #%d; buffer queue is now: ",
 		       bufnum);
-		for (i = lp->next_buf; i != lp->first_free_buf; i = (i+1) % 5)
+		for (i = lp->next_buf; i != lp->first_free_buf; i = (i + 1) % 5)
 			BUGMSG2(D_DURING, "#%d ", lp->buf_queue[i]);
 		BUGMSG2(D_DURING, "\n");
 	}
 }
 
-
 /*
  * Get a buffer from the queue.  If this returns -1, there are no buffers
  * available.
@@ -284,7 +281,7 @@ static int get_arcbuf(struct net_device *dev)
 
 	BUGLVL(D_DURING) {
 		BUGMSG(D_DURING, "get_arcbuf: got #%d; buffer queue is now: ", buf);
-		for (i = lp->next_buf; i != lp->first_free_buf; i = (i+1) % 5)
+		for (i = lp->next_buf; i != lp->first_free_buf; i = (i + 1) % 5)
 			BUGMSG2(D_DURING, "#%d ", lp->buf_queue[i]);
 		BUGMSG2(D_DURING, "\n");
 	}
@@ -293,7 +290,6 @@ static int get_arcbuf(struct net_device *dev)
 	return buf;
 }
 
-
 static int choose_mtu(void)
 {
 	int count, mtu = 65535;
@@ -346,7 +342,7 @@ struct net_device *alloc_arcdev(const char *name)
 	dev = alloc_netdev(sizeof(struct arcnet_local),
 			   name && *name ? name : "arc%d", NET_NAME_UNKNOWN,
 			   arcdev_setup);
-	if(dev) {
+	if (dev) {
 		struct arcnet_local *lp = netdev_priv(dev);
 		spin_lock_init(&lp->lock);
 	}
@@ -380,7 +376,6 @@ int arcnet_open(struct net_device *dev)
 		BUGMSG2(D_PROTO, "\n");
 	}
 
-
 	BUGMSG(D_INIT, "arcnet_open: resetting card.\n");
 
 	/* try to put the card in a defined state - if it fails the first
@@ -490,8 +485,8 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 
 	BUGMSG(D_DURING,
 	    "create header from %d to %d; protocol %d (%Xh); size %u.\n",
-	       saddr ? *(uint8_t *) saddr : -1,
-	       daddr ? *(uint8_t *) daddr : -1,
+	       saddr ? *(uint8_t *)saddr : -1,
+	       daddr ? *(uint8_t *)daddr : -1,
 	       type, type, len);
 
 	if (skb->len!=0 && len != skb->len)
@@ -499,19 +494,19 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 		       skb->len, len);
 
 
-  	/* Type is host order - ? */
-  	if(type == ETH_P_ARCNET) {
-  		proto = arc_raw_proto;
-  		BUGMSG(D_DEBUG, "arc_raw_proto used. proto='%c'\n",proto->suffix);
-  		_daddr = daddr ? *(uint8_t *) daddr : 0;
-  	}
+	/* Type is host order - ? */
+	if (type == ETH_P_ARCNET) {
+		proto = arc_raw_proto;
+		BUGMSG(D_DEBUG, "arc_raw_proto used. proto='%c'\n", proto->suffix);
+		_daddr = daddr ? *(uint8_t *)daddr : 0;
+	}
 	else if (!daddr) {
 		/*
 		 * if the dest addr isn't provided, we can't choose an encapsulation!
 		 * Store the packet type (eg. ETH_P_IP) for now, and we'll push on a
 		 * real header when we do rebuild_header.
 		 */
-		*(uint16_t *) skb_push(skb, 2) = type;
+		*(uint16_t *)skb_push(skb, 2) = type;
 		/*
 		 * XXX: Why not use skb->mac_len?
 		 */
@@ -522,7 +517,7 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 	}
 	else {
 		/* otherwise, we can just add the header as usual. */
-		_daddr = *(uint8_t *) daddr;
+		_daddr = *(uint8_t *)daddr;
 		proto_num = lp->default_proto[_daddr];
 		proto = arc_proto_map[proto_num];
 		BUGMSG(D_DURING, "building header for %02Xh using protocol '%c'\n",
@@ -572,9 +567,9 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 
 	spin_lock_irqsave(&lp->lock, flags);
 	AINTMASK(0);
-	if(lp->next_tx == -1)
+	if (lp->next_tx == -1) {
 		txbuf = get_arcbuf(dev);
-	else {
+	} else {
 		txbuf = -1;
 	}
 	if (txbuf != -1) {
@@ -678,7 +673,7 @@ void arcnet_timeout(struct net_device *dev)
 	AINTMASK(0);
 	lp->intmask |= TXFREEflag|EXCNAKflag;
 	AINTMASK(lp->intmask);
-	
+
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	if (time_after(jiffies, lp->last_timeout + 10*HZ)) {
@@ -710,7 +705,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 
 	lp = netdev_priv(dev);
 	BUG_ON(!lp);
-		
+
 	spin_lock(&lp->lock);
 
 	/*
@@ -731,7 +726,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 	boguscount = 5;
 	do {
 		status = ASTATUS();
-                diagstatus = (status >> 8) & 0xFF;
+		diagstatus = (status >> 8) & 0xFF;
 
 		BUGMSG(D_DEBUG, "%s: %d: %s: status=%x\n",
 			__FILE__,__LINE__,__func__,status);
@@ -740,7 +735,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 		/*
 		 * RESET flag was enabled - card is resetting and if RX is
 		 * disabled, it's NOT because we just got a packet.
-		 * 
+		 *
 		 * The card is in an undefined state.  Clear it out and start over.
 		 */
 		if (status & RESETflag) {
@@ -751,14 +746,14 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			/* get out of the interrupt handler! */
 			break;
 		}
-		/* 
+		/*
 		 * RX is inhibited - we must have received something. Prepare to
 		 * receive into the next buffer.
-		 * 
+		 *
 		 * We don't actually copy the received packet from the card until
 		 * after the transmit handler runs (and possibly launches the next
 		 * tx); this should improve latency slightly if we get both types
-		 * of interrupts at once. 
+		 * of interrupts at once.
 		 */
 		recbuf = -1;
 		if (status & lp->intmask & NORXflag) {
@@ -775,17 +770,17 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			didsomething++;
 		}
 
-		if((diagstatus & EXCNAKflag)) {
+		if ((diagstatus & EXCNAKflag)) {
 			BUGMSG(D_DURING, "EXCNAK IRQ (diagstat=%Xh)\n",
 			       diagstatus);
 
-                        ACOMMAND(NOTXcmd);      /* disable transmit */
-                        lp->excnak_pending = 1;
+			ACOMMAND(NOTXcmd);      /* disable transmit */
+			lp->excnak_pending = 1;
 
-                        ACOMMAND(EXCNAKclear);
+			ACOMMAND(EXCNAKclear);
 			lp->intmask &= ~(EXCNAKflag);
-                        didsomething++;
-                }
+			didsomething++;
+		}
 
 
 		/* a transmit finished, and we're interested in it. */
@@ -795,7 +790,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			BUGMSG(D_DURING, "TX IRQ (stat=%Xh)\n", status);
 
 			if (lp->cur_tx != -1 && !lp->timed_out) {
-				if(!(status & TXACKflag)) {
+				if (!(status & TXACKflag)) {
 					if (lp->lasttrans_dest != 0) {
 						BUGMSG(D_EXTRA,
 						       "transmit was not acknowledged! "
@@ -813,16 +808,17 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 
 				if (lp->outgoing.proto &&
 				    lp->outgoing.proto->ack_tx) {
-				  int ackstatus;
-				  if(status & TXACKflag)
-                                    ackstatus=2;
-                                  else if(lp->excnak_pending)
-                                    ackstatus=1;
-                                  else
-                                    ackstatus=0;
-
-                                  lp->outgoing.proto
-                                    ->ack_tx(dev, ackstatus);
+					int ackstatus;
+
+					if (status & TXACKflag)
+						ackstatus = 2;
+					else if (lp->excnak_pending)
+						ackstatus = 1;
+					else
+						ackstatus = 0;
+
+					lp->outgoing.proto
+					  ->ack_tx(dev, ackstatus);
 				}
 			}
 			if (lp->cur_tx != -1)
@@ -842,11 +838,10 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 					if (lp->outgoing.proto->continue_tx(dev, txbuf)) {
 						/* that was the last segment */
 						dev->stats.tx_bytes += lp->outgoing.skb->len;
-						if(!lp->outgoing.proto->ack_tx)
-						  {
-						    dev_kfree_skb_irq(lp->outgoing.skb);
-						    lp->outgoing.proto = NULL;
-						  }
+						if (!lp->outgoing.proto->ack_tx) {
+							dev_kfree_skb_irq(lp->outgoing.skb);
+							lp->outgoing.proto = NULL;
+						}
 					}
 					lp->next_tx = txbuf;
 				}
@@ -871,7 +866,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			BUGMSG(D_RECON, "Network reconfiguration detected (status=%Xh)\n",
 			       status);
 			/* MYRECON bit is at bit 7 of diagstatus */
-			if(diagstatus & 0x80)
+			if (diagstatus & 0x80)
 				BUGMSG(D_RECON,"Put out that recon myself\n");
 
 			/* is the RECON info empty or old? */
@@ -920,9 +915,8 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			BUGMSG(D_DURING, "not recon: clearing counters anyway.\n");
 		}
 
-		if(didsomething) {
+		if (didsomething)
 			retval |= IRQ_HANDLED;
-		}
 	}
 	while (--boguscount && didsomething);
 
@@ -930,16 +924,14 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 	       ASTATUS(), boguscount);
 	BUGMSG(D_DURING, "\n");
 
-
 	AINTMASK(0);
 	udelay(1);
 	AINTMASK(lp->intmask);
-	
+
 	spin_unlock(&lp->lock);
 	return retval;
 }
 
-
 /*
  * This is a generic packet receiver that calls arcnet??_rx depending on the
  * protocol ID found.
@@ -1002,7 +994,6 @@ static void arcnet_rx(struct net_device *dev, int bufnum)
 	arc_proto_map[soft->proto]->rx(dev, bufnum, &pkt, length);
 }
 
-
 static void null_rx(struct net_device *dev, int bufnum,
 		    struct archdr *pkthdr, int length)
 {
@@ -1025,7 +1016,6 @@ static int null_build_header(struct sk_buff *skb, struct net_device *dev,
 	return 0;
 }
 
-
 /* the "do nothing" prepare_tx function warns that there's nothing to do. */
 static int null_prepare_tx(struct net_device *dev, struct archdr *pkt,
 			   int length, int bufnum)
diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index 45c61a2..d8746ca 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -1,6 +1,6 @@
 /*
  * Linux ARCnet driver - COM20020 chipset support
- * 
+ *
  * Written 1997 by David Woodhouse.
  * Written 1994-1999 by Avery Pennarun.
  * Written 1999-2000 by Martin Mares <mj@ucw.cz>.
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 1a84378..0d84f6c 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -1,6 +1,6 @@
 /*
  * Linux ARCnet driver - COM20020 chipset support
- * 
+ *
  * Written 1997 by David Woodhouse.
  * Written 1994-1999 by Avery Pennarun.
  * Written 1999 by Martin Mares <mj@ucw.cz>.
@@ -108,7 +108,7 @@ int com20020_check(struct net_device *dev)
 	{
 		SET_SUBADR(SUB_SETUP2);
 		outb(lp->setup2, _XREG);
-	
+
 		/* must now write the magic "restart operation" command */
 		mdelay(1);
 		outb(0x18, _COMMAND);
@@ -202,7 +202,7 @@ int com20020_found(struct net_device *dev, int shared)
 	{
 		SET_SUBADR(SUB_SETUP2);
 		outb(lp->setup2, _XREG);
-	
+
 		/* must now write the magic "restart operation" command */
 		mdelay(1);
 		outb(0x18, _COMMAND);
@@ -232,7 +232,7 @@ int com20020_found(struct net_device *dev, int shared)
 		BUGMSG(D_NORMAL, "Using extended timeout value of %d.\n", lp->timeout);
 
 	BUGMSG(D_NORMAL, "Using CKP %d - data rate %s.\n",
-	       lp->setup >> 1, 
+	       lp->setup >> 1,
 	       clockrates[3 - ((lp->setup2 & 0xF0) >> 4) + ((lp->setup & 0x0F) >> 1)]);
 
 	if (register_netdev(dev)) {
@@ -242,10 +242,9 @@ int com20020_found(struct net_device *dev, int shared)
 	return 0;
 }
 
-
-/* 
+/*
  * Do a hardware reset on the card, and set up necessary registers.
- * 
+ *
  * This should be called as little as possible, because it disrupts the
  * token on the network (causes a RECON) and requires a significant delay.
  *
diff --git a/drivers/net/arcnet/com20020_cs.c b/drivers/net/arcnet/com20020_cs.c
index 057d958..aee4455 100644
--- a/drivers/net/arcnet/com20020_cs.c
+++ b/drivers/net/arcnet/com20020_cs.c
@@ -1,6 +1,6 @@
 /*
  * Linux ARCnet driver - COM20020 PCMCIA support
- * 
+ *
  * Written 1994-1999 by Avery Pennarun,
  *    based on an ISA version by David Woodhouse.
  * Derived from ibmtr_cs.c by Steve Kipisz (pcmcia-cs 3.1.4)
@@ -19,14 +19,14 @@
  * Director, National Security Agency.  This software may only be used
  * and distributed according to the terms of the GNU General Public License as
  * modified by SRC, incorporated herein by reference.
- * 
+ *
  * **********************
  * Changes:
  * Arnaldo Carvalho de Melo <acme@conectiva.com.br> - 08/08/2000
  * - reorganize kmallocs in com20020_attach, checking all for failure
  *   and releasing the previous allocations if one fails
  * **********************
- * 
+ *
  * For more details, see drivers/net/arcnet.c
  *
  * **********************
@@ -53,33 +53,31 @@
 static void regdump(struct net_device *dev)
 {
 #ifdef DEBUG
-    int ioaddr = dev->base_addr;
-    int count;
-    
-    netdev_dbg(dev, "register dump:\n");
-    for (count = ioaddr; count < ioaddr + 16; count++)
-    {
-	if (!(count % 16))
-	    pr_cont("%04X:", count);
-	pr_cont(" %02X", inb(count));
-    }
-    pr_cont("\n");
-    
-    netdev_dbg(dev, "buffer0 dump:\n");
+	int ioaddr = dev->base_addr;
+	int count;
+
+	netdev_dbg(dev, "register dump:\n");
+	for (count = ioaddr; count < ioaddr + 16; count++) {
+		if (!(count % 16))
+			pr_cont("%04X:", count);
+		pr_cont(" %02X", inb(count));
+	}
+	pr_cont("\n");
+
+	netdev_dbg(dev, "buffer0 dump:\n");
 	/* set up the address register */
-        count = 0;
+	count = 0;
 	outb((count >> 8) | RDDATAflag | AUTOINCflag, _ADDR_HI);
 	outb(count & 0xff, _ADDR_LO);
-    
-    for (count = 0; count < 256+32; count++)
-    {
-	if (!(count % 16))
-	    pr_cont("%04X:", count);
-	
-	/* copy the data */
-	pr_cont(" %02X", inb(_MEMDATA));
-    }
-    pr_cont("\n");
+
+	for (count = 0; count < 256 + 32; count++) {
+		if (!(count % 16))
+			pr_cont("%04X:", count);
+
+		/* copy the data */
+		pr_cont(" %02X", inb(_MEMDATA));
+	}
+	pr_cont("\n");
 #endif
 }
 
@@ -114,169 +112,161 @@ static void com20020_detach(struct pcmcia_device *p_dev);
 
 static int com20020_probe(struct pcmcia_device *p_dev)
 {
-    struct com20020_dev *info;
-    struct net_device *dev;
-    struct arcnet_local *lp;
+	struct com20020_dev *info;
+	struct net_device *dev;
+	struct arcnet_local *lp;
 
-    dev_dbg(&p_dev->dev, "com20020_attach()\n");
+	dev_dbg(&p_dev->dev, "com20020_attach()\n");
 
-    /* Create new network device */
-    info = kzalloc(sizeof(*info), GFP_KERNEL);
-    if (!info)
-	goto fail_alloc_info;
+	/* Create new network device */
+	info = kzalloc(sizeof(*info), GFP_KERNEL);
+	if (!info)
+		goto fail_alloc_info;
 
-    dev = alloc_arcdev("");
-    if (!dev)
-	goto fail_alloc_dev;
+	dev = alloc_arcdev("");
+	if (!dev)
+		goto fail_alloc_dev;
 
-    lp = netdev_priv(dev);
-    lp->timeout = timeout;
-    lp->backplane = backplane;
-    lp->clockp = clockp;
-    lp->clockm = clockm & 3;
-    lp->hw.owner = THIS_MODULE;
+	lp = netdev_priv(dev);
+	lp->timeout = timeout;
+	lp->backplane = backplane;
+	lp->clockp = clockp;
+	lp->clockm = clockm & 3;
+	lp->hw.owner = THIS_MODULE;
 
-    /* fill in our module parameters as defaults */
-    dev->dev_addr[0] = node;
+	/* fill in our module parameters as defaults */
+	dev->dev_addr[0] = node;
 
-    p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
-    p_dev->resource[0]->end = 16;
-    p_dev->config_flags |= CONF_ENABLE_IRQ;
+	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_8;
+	p_dev->resource[0]->end = 16;
+	p_dev->config_flags |= CONF_ENABLE_IRQ;
 
-    info->dev = dev;
-    p_dev->priv = info;
+	info->dev = dev;
+	p_dev->priv = info;
 
-    return com20020_config(p_dev);
+	return com20020_config(p_dev);
 
 fail_alloc_dev:
-    kfree(info);
+	kfree(info);
 fail_alloc_info:
-    return -ENOMEM;
+	return -ENOMEM;
 } /* com20020_attach */
 
 static void com20020_detach(struct pcmcia_device *link)
 {
-    struct com20020_dev *info = link->priv;
-    struct net_device *dev = info->dev;
+	struct com20020_dev *info = link->priv;
+	struct net_device *dev = info->dev;
 
-    dev_dbg(&link->dev, "detach...\n");
+	dev_dbg(&link->dev, "detach...\n");
 
-    dev_dbg(&link->dev, "com20020_detach\n");
+	dev_dbg(&link->dev, "com20020_detach\n");
 
-    dev_dbg(&link->dev, "unregister...\n");
+	dev_dbg(&link->dev, "unregister...\n");
 
-    unregister_netdev(dev);
+	unregister_netdev(dev);
 
-    /*
-     * this is necessary because we register our IRQ separately
-     * from card services.
-     */
-    if (dev->irq)
-	    free_irq(dev->irq, dev);
+	/* this is necessary because we register our IRQ separately
+	 * from card services.
+	 */
+	if (dev->irq)
+		free_irq(dev->irq, dev);
 
-    com20020_release(link);
+	com20020_release(link);
 
-    /* Unlink device structure, free bits */
-    dev_dbg(&link->dev, "unlinking...\n");
-    if (link->priv)
-    {
-	dev = info->dev;
-	if (dev)
-	{
-	    dev_dbg(&link->dev, "kfree...\n");
-	    free_netdev(dev);
+	/* Unlink device structure, free bits */
+	dev_dbg(&link->dev, "unlinking...\n");
+	if (link->priv) {
+		dev = info->dev;
+		if (dev) {
+			dev_dbg(&link->dev, "kfree...\n");
+			free_netdev(dev);
+		}
+		dev_dbg(&link->dev, "kfree2...\n");
+		kfree(info);
 	}
-	dev_dbg(&link->dev, "kfree2...\n");
-	kfree(info);
-    }
 
 } /* com20020_detach */
 
 static int com20020_config(struct pcmcia_device *link)
 {
-    struct arcnet_local *lp;
-    struct com20020_dev *info;
-    struct net_device *dev;
-    int i, ret;
-    int ioaddr;
+	struct arcnet_local *lp;
+	struct com20020_dev *info;
+	struct net_device *dev;
+	int i, ret;
+	int ioaddr;
+
+	info = link->priv;
+	dev = info->dev;
 
-    info = link->priv;
-    dev = info->dev;
+	dev_dbg(&link->dev, "config...\n");
 
-    dev_dbg(&link->dev, "config...\n");
+	dev_dbg(&link->dev, "com20020_config\n");
 
-    dev_dbg(&link->dev, "com20020_config\n");
+	dev_dbg(&link->dev, "baseport1 is %Xh\n",
+		(unsigned int)link->resource[0]->start);
 
-    dev_dbg(&link->dev, "baseport1 is %Xh\n",
-	    (unsigned int) link->resource[0]->start);
+	i = -ENODEV;
+	link->io_lines = 16;
 
-    i = -ENODEV;
-    link->io_lines = 16;
+	if (!link->resource[0]->start) {
+		for (ioaddr = 0x100; ioaddr < 0x400; ioaddr += 0x10) {
+			link->resource[0]->start = ioaddr;
+			i = pcmcia_request_io(link);
+			if (i == 0)
+				break;
+		}
+	} else {
+		i = pcmcia_request_io(link);
+	}
 
-    if (!link->resource[0]->start)
-    {
-	for (ioaddr = 0x100; ioaddr < 0x400; ioaddr += 0x10)
+	if (i != 0)
 	{
-	    link->resource[0]->start = ioaddr;
-	    i = pcmcia_request_io(link);
-	    if (i == 0)
-		break;
+		dev_dbg(&link->dev, "requestIO failed totally!\n");
+		goto failed;
 	}
-    }
-    else
-	i = pcmcia_request_io(link);
-    
-    if (i != 0)
-    {
-	dev_dbg(&link->dev, "requestIO failed totally!\n");
-	goto failed;
-    }
-	
-    ioaddr = dev->base_addr = link->resource[0]->start;
-    dev_dbg(&link->dev, "got ioaddr %Xh\n", ioaddr);
-
-    dev_dbg(&link->dev, "request IRQ %d\n",
-	    link->irq);
-    if (!link->irq)
-    {
-	dev_dbg(&link->dev, "requestIRQ failed totally!\n");
-	goto failed;
-    }
-
-    dev->irq = link->irq;
-
-    ret = pcmcia_enable_device(link);
-    if (ret)
-	    goto failed;
-
-    if (com20020_check(dev))
-    {
-	regdump(dev);
-	goto failed;
-    }
-    
-    lp = netdev_priv(dev);
-    lp->card_name = "PCMCIA COM20020";
-    lp->card_flags = ARC_CAN_10MBIT; /* pretend all of them can 10Mbit */
-
-    SET_NETDEV_DEV(dev, &link->dev);
-
-    i = com20020_found(dev, 0);	/* calls register_netdev */
-    
-    if (i != 0) {
-	dev_notice(&link->dev,
-		   "com20020_found() failed\n");
-	goto failed;
-    }
-
-    netdev_dbg(dev, "port %#3lx, irq %d\n",
-	       dev->base_addr, dev->irq);
-    return 0;
-
-failed:
-    dev_dbg(&link->dev, "com20020_config failed...\n");
-    com20020_release(link);
-    return -ENODEV;
+
+	ioaddr = dev->base_addr = link->resource[0]->start;
+	dev_dbg(&link->dev, "got ioaddr %Xh\n", ioaddr);
+
+	dev_dbg(&link->dev, "request IRQ %d\n",
+		link->irq);
+
+	if (!link->irq) {
+		dev_dbg(&link->dev, "requestIRQ failed totally!\n");
+		goto failed;
+	}
+
+	dev->irq = link->irq;
+
+	ret = pcmcia_enable_device(link);
+	if (ret)
+		goto failed;
+
+	if (com20020_check(dev)) {
+		regdump(dev);
+		goto failed;
+	}
+
+	lp = netdev_priv(dev);
+	lp->card_name = "PCMCIA COM20020";
+	lp->card_flags = ARC_CAN_10MBIT; /* pretend all of them can 10Mbit */
+
+	SET_NETDEV_DEV(dev, &link->dev);
+
+	i = com20020_found(dev, 0);	/* calls register_netdev */
+
+	if (i != 0) {
+		dev_notice(&link->dev, "com20020_found() failed\n");
+		goto failed;
+	}
+
+	netdev_dbg(dev, "port %#3lx, irq %d\n", dev->base_addr, dev->irq);
+	return 0;
+
+ failed:
+	dev_dbg(&link->dev, "com20020_config failed...\n");
+	com20020_release(link);
+	return -ENODEV;
 } /* com20020_config */
 
 static void com20020_release(struct pcmcia_device *link)
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 487d780..b1279af 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -1,6 +1,6 @@
 /*
  * Linux ARCnet driver - COM90xx chipset (IO-mapped buffers)
- * 
+ *
  * Written 1997 by David Woodhouse.
  * Written 1994-1999 by Avery Pennarun.
  * Written 1999-2000 by Martin Mares <mj@ucw.cz>.
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index b80fbe4..03bd71c 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -1,6 +1,6 @@
 /*
  * Linux ARCnet driver - COM90xx chipset (memory-mapped buffers)
- * 
+ *
  * Written 1994-1999 by Avery Pennarun.
  * Written 1999 by Martin Mares <mj@ucw.cz>.
  * Derived from skeleton.c by Donald Becker.
@@ -579,7 +579,7 @@ static void com90xx_setmask(struct net_device *dev, int mask)
 
 /*
  * Do a hardware reset on the card, and set up necessary registers.
- * 
+ *
  * This should be called as little as possible, because it disrupts the
  * token on the network (causes a RECON) and requires a significant delay.
  *
diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index df03562..81f336f 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -51,7 +51,7 @@
 
 /*
  * Debugging bitflags: each option can be enabled individually.
- * 
+ *
  * Note: only debug flags included in the ARCNET_DEBUG_MAX define will
  *   actually be available.  GCC will (at least, GCC 2.7.0 will) notice
  *   lines using a BUGLVL not in ARCNET_DEBUG_MAX and automatically optimize
@@ -182,7 +182,6 @@ extern int arcnet_debug;
 #define ARC_CAN_10MBIT  2   /* card uses COM20022, supporting 10MBit,
 				 but default is 2.5MBit. */
 
-
 /* information needed to define an encapsulation driver */
 struct ArcProto {
 	char suffix;		/* a for RFC1201, e for ether-encap, etc. */
@@ -263,13 +262,13 @@ struct arcnet_local {
 	 * situations in which we (for example) want to pre-load a transmit
 	 * buffer, or start receiving while we copy a received packet to
 	 * memory.
-	 * 
+	 *
 	 * The rules: only the interrupt handler is allowed to _add_ buffers to
 	 * the queue; thus, this doesn't require a lock.  Both the interrupt
 	 * handler and the transmit function will want to _remove_ buffers, so
 	 * we need to handle the situation where they try to do it at the same
 	 * time.
-	 * 
+	 *
 	 * If next_buf == first_free_buf, the queue is empty.  Since there are
 	 * only four possible buffers, the queue should never be full.
 	 */
diff --git a/include/linux/com20020.h b/include/linux/com20020.h
index 8589899..5ce5c7d 100644
--- a/include/linux/com20020.h
+++ b/include/linux/com20020.h
@@ -1,6 +1,6 @@
 /*
  * Linux ARCnet driver - COM20020 chipset support - function declarations
- * 
+ *
  * Written 1997 by David Woodhouse.
  * Written 1994-1999 by Avery Pennarun.
  * Derived from skeleton.c by Donald Becker.
@@ -81,7 +81,7 @@ struct com20020_dev {
 #define _SUBADR   (ioaddr+BUS_ALIGN*5)	/* the extended port _XREG refers to */
 #define _CONFIG   (ioaddr+BUS_ALIGN*6)	/* configuration register */
 #define _XREG     (ioaddr+BUS_ALIGN*7)	/* extra registers (indexed by _CONFIG
-  					or _SUBADR) */
+					or _SUBADR) */
 
 /* in the ADDR_HI register */
 #define RDDATAflag	0x80	/* next access is a read (not a write) */
diff --git a/include/uapi/linux/if_arcnet.h b/include/uapi/linux/if_arcnet.h
index 46e34bd..1fa78f4 100644
--- a/include/uapi/linux/if_arcnet.h
+++ b/include/uapi/linux/if_arcnet.h
@@ -57,10 +57,10 @@
  * The RFC1201-specific components of an arcnet packet header.
  */
 struct arc_rfc1201 {
-    __u8  proto;		/* protocol ID field - varies		*/
-    __u8  split_flag;	/* for use with split packets		*/
-    __be16   sequence;		/* sequence number			*/
-    __u8  payload[0];	/* space remaining in packet (504 bytes)*/
+	__u8 proto;		/* protocol ID field - varies */
+	__u8 split_flag;	/* for use with split packets */
+	__be16 sequence;		/* sequence number */
+	__u8 payload[0];	/* space remaining in packet (504 bytes) */
 };
 #define RFC1201_HDR_SIZE 4
 
@@ -69,8 +69,8 @@ struct arc_rfc1201 {
  * The RFC1051-specific components.
  */
 struct arc_rfc1051 {
-    __u8 proto;		/* ARC_P_RFC1051_ARP/RFC1051_IP	*/
-    __u8 payload[0];		/* 507 bytes			*/
+	__u8 proto;		/* ARC_P_RFC1051_ARP/RFC1051_IP */
+	__u8 payload[0];	/* 507 bytes */
 };
 #define RFC1051_HDR_SIZE 1
 
@@ -80,16 +80,16 @@ struct arc_rfc1051 {
  * and some data.
  */
 struct arc_eth_encap {
-    __u8 proto;		/* Always ARC_P_ETHER			*/
-    struct ethhdr eth;		/* standard ethernet header (yuck!)	*/
-    __u8 payload[0];		/* 493 bytes				*/
+	__u8 proto;		/* Always ARC_P_ETHER */
+	struct ethhdr eth;	/* standard ethernet header (yuck!) */
+	__u8 payload[0];	/* 493 bytes */
 };
 #define ETH_ENCAP_HDR_SIZE 14
 
 
 struct arc_cap {
 	__u8 proto;
-	__u8 cookie[sizeof(int)];   /* Actually NOT sent over the network */
+	__u8 cookie[sizeof(int)];	/* Actually NOT sent over the network */
 	union {
 		__u8 ack;
 		__u8 raw[0];		/* 507 bytes */
@@ -105,9 +105,9 @@ struct arc_cap {
  * driver.
  */
 struct arc_hardware {
-    __u8  source,		/* source ARCnet - filled in automagically */
-             dest,		/* destination ARCnet - 0 for broadcast    */
-    	     offset[2];		/* offset bytes (some weird semantics)     */
+	__u8  source,		/* source ARCnet - filled in automagically */
+		dest,		/* destination ARCnet - 0 for broadcast */
+		offset[2];	/* offset bytes (some weird semantics) */
 };
 #define ARC_HDR_SIZE 4
 
@@ -116,17 +116,17 @@ struct arc_hardware {
  * when you do a raw packet capture).
  */
 struct archdr {
-    /* hardware requirements */
-    struct arc_hardware hard;
-     
-    /* arcnet encapsulation-specific bits */
-    union {
-	struct arc_rfc1201   rfc1201;
-	struct arc_rfc1051   rfc1051;
-	struct arc_eth_encap eth_encap;
-	struct arc_cap       cap;
-	__u8 raw[0];		/* 508 bytes				*/
-    } soft;
+	/* hardware requirements */
+	struct arc_hardware hard;
+
+	/* arcnet encapsulation-specific bits */
+	union {
+		struct arc_rfc1201   rfc1201;
+		struct arc_rfc1051   rfc1051;
+		struct arc_eth_encap eth_encap;
+		struct arc_cap       cap;
+		__u8 raw[0];			/* 508 bytes */
+	} soft;
 };
 
 #endif				/* _LINUX_IF_ARCNET_H */
-- 
2.1.4
