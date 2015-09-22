From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 02/33] arcnet: Use normal kernel spacing style
Date: Tue, 22 Sep 2015 11:01:43 +0200
Message-ID: <1442912534-10821-3-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35881 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932399AbbIVJCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:39 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Standardized spacing is easier to read.

git diff -w shows no differences.
objdiff shows no differences.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rawmode.c  |  10 +-
 drivers/net/arcnet/arc-rimi.c     |  30 ++--
 drivers/net/arcnet/arcnet.c       | 170 ++++++++++-----------
 drivers/net/arcnet/capmode.c      |  36 ++---
 drivers/net/arcnet/com20020-isa.c |   2 +-
 drivers/net/arcnet/com20020-pci.c |   2 +-
 drivers/net/arcnet/com20020.c     |  38 ++---
 drivers/net/arcnet/com20020_cs.c  | 306 +++++++++++++++++++-------------------
 drivers/net/arcnet/com90io.c      |  24 +--
 drivers/net/arcnet/com90xx.c      |  32 ++--
 drivers/net/arcnet/rfc1051.c      |  12 +-
 drivers/net/arcnet/rfc1201.c      |  36 ++---
 include/linux/arcdevice.h         |  90 +++++------
 13 files changed, 394 insertions(+), 394 deletions(-)

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index 705e6ce..49f5819 100644
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
@@ -109,7 +109,7 @@ static void rx(struct net_device *dev, int bufnum,
 	skb_put(skb, length + ARC_HDR_SIZE);
 	skb->dev = dev;
 
-	pkt = (struct archdr *) skb->data;
+	pkt = (struct archdr *)skb->data;
 
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ARC_HDR_SIZE);
@@ -136,7 +136,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
 	int hdr_size = ARC_HDR_SIZE;
-	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
+	struct archdr *pkt = (struct archdr *)skb_push(skb, hdr_size);
 
 	/*
 	 * Set the source hardware address.
@@ -150,7 +150,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 	/* see linux/net/ethernet/eth.c to see where I got the following */
 
 	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP)) {
-		/* 
+		/*
 		 * FIXME: fill in the last byte of the dest ipaddr here to better
 		 * comply with RFC1051 in "noarp" mode.
 		 */
@@ -192,7 +192,7 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		hard->offset[0] = ofs = 256 - length;
 
 	BUGMSG(D_DURING, "prepare_tx: length=%d ofs=%d\n",
-	       length,ofs);
+	       length, ofs);
 
 	lp->hw.copy_to_card(dev, bufnum, 0, hard, ARC_HDR_SIZE);
 	lp->hw.copy_to_card(dev, bufnum, ofs, &pkt->soft, length);
diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index b8b4c7b..4644d46 100644
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
@@ -56,27 +56,27 @@ static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offse
 /* Handy defines for ARCnet specific stuff */
 
 /* Amount of I/O memory used by the card */
-#define BUFFER_SIZE (512)
-#define MIRROR_SIZE (BUFFER_SIZE*4)
+#define BUFFER_SIZE	(512)
+#define MIRROR_SIZE	(BUFFER_SIZE * 4)
 
 /* COM 9026 controller chip --> ARCnet register addresses */
-#define _INTMASK (ioaddr+0)	/* writable */
-#define _STATUS  (ioaddr+0)	/* readable */
-#define _COMMAND (ioaddr+1)	/* writable, returns random vals on read (?) */
-#define _RESET  (ioaddr+8)	/* software reset (on read) */
-#define _MEMDATA  (ioaddr+12)	/* Data port for IO-mapped memory */
-#define _ADDR_HI  (ioaddr+15)	/* Control registers for said */
-#define _ADDR_LO  (ioaddr+14)
-#define _CONFIG  (ioaddr+2)	/* Configuration register */
+#define _INTMASK	(ioaddr + 0)	/* writable */
+#define _STATUS		(ioaddr + 0)	/* readable */
+#define _COMMAND	(ioaddr + 1)	/* writable, returns random vals on read (?) */
+#define _RESET		(ioaddr + 8)	/* software reset (on read) */
+#define _MEMDATA	(ioaddr + 12)	/* Data port for IO-mapped memory */
+#define _ADDR_HI	(ioaddr + 15)	/* Control registers for said */
+#define _ADDR_LO	(ioaddr + 14)
+#define _CONFIG		(ioaddr + 2)	/* Configuration register */
 
 #undef ASTATUS
 #undef ACOMMAND
 #undef AINTMASK
 
 #define ASTATUS()	readb(_STATUS)
-#define ACOMMAND(cmd)	writeb((cmd),_COMMAND)
-#define AINTMASK(msk)	writeb((msk),_INTMASK)
-#define SETCONF()	writeb(lp->config,_CONFIG)
+#define ACOMMAND(cmd)	writeb((cmd), _COMMAND)
+#define AINTMASK(msk)	writeb((msk), _INTMASK)
+#define SETCONF()	writeb(lp->config, _CONFIG)
 
 
 /*
@@ -90,7 +90,7 @@ static int __init arcrimi_probe(struct net_device *dev)
 	BUGLVL(D_NORMAL) printk("E-mail me if you actually test the RIM I driver, please!\n");
 
 	BUGLVL(D_NORMAL) printk("Given: node %02Xh, shmem %lXh, irq %d\n",
-	       dev->dev_addr[0], dev->mem_start, dev->irq);
+				dev->dev_addr[0], dev->mem_start, dev->irq);
 
 	if (dev->mem_start <= 0 || dev->irq <= 0) {
 		BUGLVL(D_NORMAL) printk("No autoprobe for RIM I; you "
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 10f71c73..2a594d1 100644
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
@@ -69,8 +69,8 @@ static void arcnet_rx(struct net_device *dev, int bufnum);
  * arc_proto_default instead.  It also must not be NULL; if you would like
  * to set it to NULL, set it to &arc_proto_null instead.
  */
- struct ArcProto *arc_proto_map[256], *arc_proto_default,
-   *arc_bcast_proto, *arc_raw_proto;
+struct ArcProto *arc_proto_map[256], *arc_proto_default,
+	*arc_bcast_proto, *arc_raw_proto;
 
 static struct ArcProto arc_proto_null =
 {
@@ -136,8 +136,8 @@ static int __init arcnet_init(void)
 
 	BUGLVL(D_DURING)
 	    printk("arcnet: struct sizes: %Zd %Zd %Zd %Zd %Zd\n",
-		 sizeof(struct arc_hardware), sizeof(struct arc_rfc1201),
-		sizeof(struct arc_rfc1051), sizeof(struct arc_eth_encap),
+		   sizeof(struct arc_hardware), sizeof(struct arc_rfc1201),
+		   sizeof(struct arc_rfc1051), sizeof(struct arc_eth_encap),
 		   sizeof(struct archdr));
 
 	return 0;
@@ -184,11 +184,11 @@ static void arcnet_dump_packet(struct net_device *dev, int bufnum,
 
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
@@ -202,7 +202,7 @@ static void arcnet_dump_packet(struct net_device *dev, int bufnum,
 
 #else
 
-#define arcnet_dump_packet(dev, bufnum, desc,take_arcnet_lock) do { } while (0)
+#define arcnet_dump_packet(dev, bufnum, desc, take_arcnet_lock) do { } while (0)
 
 #endif
 
@@ -233,7 +233,7 @@ void arcnet_unregister_proto(struct ArcProto *proto)
 /*
  * Add a buffer to the queue.  Only the interrupt handler is allowed to do
  * this, unless interrupts are disabled.
- * 
+ *
  * Note: we don't check for a full queue, since there aren't enough buffers
  * to more than fill it.
  */
@@ -248,7 +248,7 @@ static void release_arcbuf(struct net_device *dev, int bufnum)
 	BUGLVL(D_DURING) {
 		BUGMSG(D_DURING, "release_arcbuf: freed #%d; buffer queue is now: ",
 		       bufnum);
-		for (i = lp->next_buf; i != lp->first_free_buf; i = (i+1) % 5)
+		for (i = lp->next_buf; i != lp->first_free_buf; i = (i + 1) % 5)
 			BUGMSG2(D_DURING, "#%d ", lp->buf_queue[i]);
 		BUGMSG2(D_DURING, "\n");
 	}
@@ -284,7 +284,7 @@ static int get_arcbuf(struct net_device *dev)
 
 	BUGLVL(D_DURING) {
 		BUGMSG(D_DURING, "get_arcbuf: got #%d; buffer queue is now: ", buf);
-		for (i = lp->next_buf; i != lp->first_free_buf; i = (i+1) % 5)
+		for (i = lp->next_buf; i != lp->first_free_buf; i = (i + 1) % 5)
 			BUGMSG2(D_DURING, "#%d ", lp->buf_queue[i]);
 		BUGMSG2(D_DURING, "\n");
 	}
@@ -346,7 +346,7 @@ struct net_device *alloc_arcdev(const char *name)
 	dev = alloc_netdev(sizeof(struct arcnet_local),
 			   name && *name ? name : "arc%d", NET_NAME_UNKNOWN,
 			   arcdev_setup);
-	if(dev) {
+	if (dev) {
 		struct arcnet_local *lp = netdev_priv(dev);
 		spin_lock_init(&lp->lock);
 	}
@@ -367,7 +367,7 @@ int arcnet_open(struct net_device *dev)
 	struct arcnet_local *lp = netdev_priv(dev);
 	int count, newmtu, error;
 
-	BUGMSG(D_INIT,"opened.");
+	BUGMSG(D_INIT, "opened.");
 
 	if (!try_module_get(lp->hw.owner))
 		return -ENODEV;
@@ -431,24 +431,24 @@ int arcnet_open(struct net_device *dev)
 		BUGMSG(D_NORMAL, "WARNING!  Station address FF may confuse "
 		       "DOS networking programs!\n");
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	if (ASTATUS() & RESETflag) {
-	  	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
+		BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 		ACOMMAND(CFLAGScmd | RESETclear);
 	}
 
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	/* make sure we're ready to receive IRQ's. */
 	AINTMASK(0);
 	udelay(1);		/* give it time to set the mask before
 				 * we reset it again. (may not even be
 				 * necessary)
 				 */
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	lp->intmask = NORXflag | RECONflag;
 	AINTMASK(lp->intmask);
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 
 	netif_start_queue(dev);
 
@@ -489,29 +489,29 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 	struct ArcProto *proto;
 
 	BUGMSG(D_DURING,
-	    "create header from %d to %d; protocol %d (%Xh); size %u.\n",
-	       saddr ? *(uint8_t *) saddr : -1,
-	       daddr ? *(uint8_t *) daddr : -1,
+	       "create header from %d to %d; protocol %d (%Xh); size %u.\n",
+	       saddr ? *(uint8_t *)saddr : -1,
+	       daddr ? *(uint8_t *)daddr : -1,
 	       type, type, len);
 
-	if (skb->len!=0 && len != skb->len)
+	if (skb->len != 0 && len != skb->len)
 		BUGMSG(D_NORMAL, "arcnet_header: Yikes!  skb->len(%d) != len(%d)!\n",
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
@@ -522,7 +522,7 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 	}
 	else {
 		/* otherwise, we can just add the header as usual. */
-		_daddr = *(uint8_t *) daddr;
+		_daddr = *(uint8_t *)daddr;
 		proto_num = lp->default_proto[_daddr];
 		proto = arc_proto_map[proto_num];
 		BUGMSG(D_DURING, "building header for %02Xh using protocol '%c'\n",
@@ -538,7 +538,7 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 
 /* Called by the kernel in order to transmit a packet. */
 netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
-				     struct net_device *dev)
+			       struct net_device *dev)
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 	struct archdr *pkt;
@@ -550,14 +550,14 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 
 	BUGMSG(D_DURING,
 	       "transmit requested (status=%Xh, txbufs=%d/%d, len=%d, protocol %x)\n",
-	       ASTATUS(), lp->cur_tx, lp->next_tx, skb->len,skb->protocol);
+	       ASTATUS(), lp->cur_tx, lp->next_tx, skb->len, skb->protocol);
 
-	pkt = (struct archdr *) skb->data;
+	pkt = (struct archdr *)skb->data;
 	soft = &pkt->soft.rfc1201;
 	proto = arc_proto_map[soft->proto];
 
 	BUGMSG(D_SKB_SIZE, "skb: transmitting %d bytes to %02X\n",
-		skb->len, pkt->hard.dest);
+	       skb->len, pkt->hard.dest);
 	BUGLVL(D_SKB) arcnet_dump_skb(dev, skb, "tx");
 
 	/* fits in one packet? */
@@ -572,7 +572,7 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 
 	spin_lock_irqsave(&lp->lock, flags);
 	AINTMASK(0);
-	if(lp->next_tx == -1)
+	if (lp->next_tx == -1)
 		txbuf = get_arcbuf(dev);
 	else {
 		txbuf = -1;
@@ -594,9 +594,9 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 
 			if (proto->continue_tx &&
 			    proto->continue_tx(dev, txbuf)) {
-			  BUGMSG(D_NORMAL,
-				 "bug! continue_tx finished the first time! "
-				 "(proto='%c')\n", proto->suffix);
+				BUGMSG(D_NORMAL,
+				       "bug! continue_tx finished the first time! "
+				       "(proto='%c')\n", proto->suffix);
 			}
 		}
 		retval = NETDEV_TX_OK;
@@ -606,14 +606,14 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 		freeskb = 0;
 	}
 
-	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n",__FILE__,__LINE__,__func__,ASTATUS());
+	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n", __FILE__, __LINE__, __func__, ASTATUS());
 	/* make sure we didn't ignore a TX IRQ while we were in here */
 	AINTMASK(0);
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
-	lp->intmask |= TXFREEflag|EXCNAKflag;
+	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
+	lp->intmask |= TXFREEflag | EXCNAKflag;
 	AINTMASK(lp->intmask);
-	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n",__FILE__,__LINE__,__func__,ASTATUS());
+	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n", __FILE__, __LINE__, __func__, ASTATUS());
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 	if (freeskb) {
@@ -649,7 +649,7 @@ static int go_tx(struct net_device *dev)
 	lp->lasttrans_dest = lp->lastload_dest;
 	lp->lastload_dest = 0;
 	lp->excnak_pending = 0;
-	lp->intmask |= TXFREEflag|EXCNAKflag;
+	lp->intmask |= TXFREEflag | EXCNAKflag;
 
 	return 1;
 }
@@ -676,12 +676,12 @@ void arcnet_timeout(struct net_device *dev)
 
 	/* make sure we didn't miss a TX or a EXC NAK IRQ */
 	AINTMASK(0);
-	lp->intmask |= TXFREEflag|EXCNAKflag;
+	lp->intmask |= TXFREEflag | EXCNAKflag;
 	AINTMASK(lp->intmask);
-	
+
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	if (time_after(jiffies, lp->last_timeout + 10*HZ)) {
+	if (time_after(jiffies, lp->last_timeout + 10 * HZ)) {
 		BUGMSG(D_EXTRA, "tx timed out%s (status=%Xh, intmask=%Xh, dest=%02Xh)\n",
 		       msg, status, lp->intmask, lp->lasttrans_dest);
 		lp->last_timeout = jiffies;
@@ -710,7 +710,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 
 	lp = netdev_priv(dev);
 	BUG_ON(!lp);
-		
+
 	spin_lock(&lp->lock);
 
 	/*
@@ -731,16 +731,16 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 	boguscount = 5;
 	do {
 		status = ASTATUS();
-                diagstatus = (status >> 8) & 0xFF;
+		diagstatus = (status >> 8) & 0xFF;
 
 		BUGMSG(D_DEBUG, "%s: %d: %s: status=%x\n",
-			__FILE__,__LINE__,__func__,status);
+		       __FILE__, __LINE__, __func__, status);
 		didsomething = 0;
 
 		/*
 		 * RESET flag was enabled - card is resetting and if RX is
 		 * disabled, it's NOT because we just got a packet.
-		 * 
+		 *
 		 * The card is in an undefined state.  Clear it out and start over.
 		 */
 		if (status & RESETflag) {
@@ -751,14 +751,14 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
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
@@ -775,27 +775,27 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
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
 		if ((status & lp->intmask & TXFREEflag) || lp->timed_out) {
-			lp->intmask &= ~(TXFREEflag|EXCNAKflag);
+			lp->intmask &= ~(TXFREEflag | EXCNAKflag);
 
 			BUGMSG(D_DURING, "TX IRQ (stat=%Xh)\n", status);
 
 			if (lp->cur_tx != -1 && !lp->timed_out) {
-				if(!(status & TXACKflag)) {
+				if (!(status & TXACKflag)) {
 					if (lp->lasttrans_dest != 0) {
 						BUGMSG(D_EXTRA,
 						       "transmit was not acknowledged! "
@@ -813,16 +813,16 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 
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
+					if (status & TXACKflag)
+						ackstatus = 2;
+					else if (lp->excnak_pending)
+						ackstatus = 1;
+					else
+						ackstatus = 0;
+
+					lp->outgoing.proto
+						->ack_tx(dev, ackstatus);
 				}
 			}
 			if (lp->cur_tx != -1)
@@ -842,11 +842,11 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 					if (lp->outgoing.proto->continue_tx(dev, txbuf)) {
 						/* that was the last segment */
 						dev->stats.tx_bytes += lp->outgoing.skb->len;
-						if(!lp->outgoing.proto->ack_tx)
-						  {
-						    dev_kfree_skb_irq(lp->outgoing.skb);
-						    lp->outgoing.proto = NULL;
-						  }
+						if (!lp->outgoing.proto->ack_tx)
+						{
+							dev_kfree_skb_irq(lp->outgoing.skb);
+							lp->outgoing.proto = NULL;
+						}
 					}
 					lp->next_tx = txbuf;
 				}
@@ -871,8 +871,8 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			BUGMSG(D_RECON, "Network reconfiguration detected (status=%Xh)\n",
 			       status);
 			/* MYRECON bit is at bit 7 of diagstatus */
-			if(diagstatus & 0x80)
-				BUGMSG(D_RECON,"Put out that recon myself\n");
+			if (diagstatus & 0x80)
+				BUGMSG(D_RECON, "Put out that recon myself\n");
 
 			/* is the RECON info empty or old? */
 			if (!lp->first_recon || !lp->last_recon ||
@@ -889,7 +889,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 
 				BUGMSG(D_DURING, "recon: counter=%d, time=%lds, net=%d\n",
 				       lp->num_recons,
-				 (lp->last_recon - lp->first_recon) / HZ,
+				       (lp->last_recon - lp->first_recon) / HZ,
 				       lp->network_down);
 
 				/* if network is marked up;
@@ -911,7 +911,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 				}
 			}
 		} else if (lp->network_down &&
-				time_after(jiffies, lp->last_recon + HZ * 10)) {
+			   time_after(jiffies, lp->last_recon + HZ * 10)) {
 			if (lp->network_down)
 				BUGMSG(D_NORMAL, "cabling restored?\n");
 			lp->first_recon = lp->last_recon = 0;
@@ -920,7 +920,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			BUGMSG(D_DURING, "not recon: clearing counters anyway.\n");
 		}
 
-		if(didsomething) {
+		if (didsomething) {
 			retval |= IRQ_HANDLED;
 		}
 	}
@@ -934,7 +934,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 	AINTMASK(0);
 	udelay(1);
 	AINTMASK(lp->intmask);
-	
+
 	spin_unlock(&lp->lock);
 	return retval;
 }
@@ -1007,7 +1007,7 @@ static void null_rx(struct net_device *dev, int bufnum,
 		    struct archdr *pkthdr, int length)
 {
 	BUGMSG(D_PROTO,
-	"rx: don't know how to deal with proto %02Xh from host %02Xh.\n",
+	       "rx: don't know how to deal with proto %02Xh from host %02Xh.\n",
 	       pkthdr->soft.rfc1201.proto, pkthdr->hard.source);
 }
 
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 42fce91..95a6cf0 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -71,12 +71,12 @@ static void rx(struct net_device *dev, int bufnum,
 
 	/* use these variables to be sure we count in bytes, not in
 	   sizeof(struct archdr) */
-	pktbuf=(char*)pkt;
-	pkthdrbuf=(char*)pkthdr;
-	memcpy(pktbuf, pkthdrbuf, ARC_HDR_SIZE+sizeof(pkt->soft.cap.proto));
-	memcpy(pktbuf+ARC_HDR_SIZE+sizeof(pkt->soft.cap.proto)+sizeof(int),
-	       pkthdrbuf+ARC_HDR_SIZE+sizeof(pkt->soft.cap.proto),
-	       sizeof(struct archdr)-ARC_HDR_SIZE-sizeof(pkt->soft.cap.proto));
+	pktbuf = (char *)pkt;
+	pkthdrbuf = (char *)pkthdr;
+	memcpy(pktbuf, pkthdrbuf, ARC_HDR_SIZE + sizeof(pkt->soft.cap.proto));
+	memcpy(pktbuf + ARC_HDR_SIZE + sizeof(pkt->soft.cap.proto) + sizeof(int),
+	       pkthdrbuf + ARC_HDR_SIZE + sizeof(pkt->soft.cap.proto),
+	       sizeof(struct archdr) - ARC_HDR_SIZE - sizeof(pkt->soft.cap.proto));
 
 	if (length > sizeof(pkt->soft))
 		lp->hw.copy_from_card(dev, bufnum, ofs + sizeof(pkt->soft),
@@ -101,10 +101,10 @@ static int build_header(struct sk_buff *skb,
 			uint8_t daddr)
 {
 	int hdr_size = ARC_HDR_SIZE;
-	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
+	struct archdr *pkt = (struct archdr *)skb_push(skb, hdr_size);
 
 	BUGMSG(D_PROTO, "Preparing header for cap packet %x.\n",
-	       *((int*)&pkt->soft.cap.cookie[0]));
+	       *((int *)&pkt->soft.cap.cookie[0]));
 	/*
 	 * Set the source hardware address.
 	 *
@@ -148,7 +148,7 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 	       lp->next_tx, lp->cur_tx, bufnum);
 
 	BUGMSG(D_PROTO, "Sending for cap packet %x.\n",
-	       *((int*)&pkt->soft.cap.cookie[0]));
+	       *((int *)&pkt->soft.cap.cookie[0]));
 
 	if (length > XMTU) {
 		/* should never happen! other people already check for this. */
@@ -166,7 +166,7 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		hard->offset[0] = ofs = 256 - length;
 
 	BUGMSG(D_DURING, "prepare_tx: length=%d ofs=%d\n",
-	       length,ofs);
+	       length, ofs);
 
 	/* Copy the arcnet-header + the protocol byte down: */
 	lp->hw.copy_to_card(dev, bufnum, 0, hard, ARC_HDR_SIZE);
@@ -175,8 +175,8 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 
 	/* Skip the extra integer we have written into it as a cookie
 	   but write the rest of the message: */
-	lp->hw.copy_to_card(dev, bufnum, ofs+1,
-			    ((unsigned char*)&pkt->soft.cap.mes),length-1);
+	lp->hw.copy_to_card(dev, bufnum, ofs + 1,
+			    ((unsigned char *)&pkt->soft.cap.mes), length - 1);
 
 	lp->lastload_dest = hard->dest;
 
@@ -188,21 +188,21 @@ static int ack_tx(struct net_device *dev, int acked)
 	struct arcnet_local *lp = netdev_priv(dev);
 	struct sk_buff *ackskb;
 	struct archdr *ackpkt;
-	int length=sizeof(struct arc_cap);
+	int length = sizeof(struct arc_cap);
 
 	BUGMSG(D_DURING, "capmode: ack_tx: protocol: %x: result: %d\n",
-		lp->outgoing.skb->protocol, acked);
+	       lp->outgoing.skb->protocol, acked);
 
 	BUGLVL(D_SKB) arcnet_dump_skb(dev, lp->outgoing.skb, "ack_tx");
 
 	/* Now alloc a skb to send back up through the layers: */
-	ackskb = alloc_skb(length + ARC_HDR_SIZE , GFP_ATOMIC);
+	ackskb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
 	if (ackskb == NULL) {
 		BUGMSG(D_NORMAL, "Memory squeeze, can't acknowledge.\n");
 		goto free_outskb;
 	}
 
-	skb_put(ackskb, length + ARC_HDR_SIZE );
+	skb_put(ackskb, length + ARC_HDR_SIZE);
 	ackskb->dev = dev;
 
 	skb_reset_mac_header(ackskb);
@@ -212,10 +212,10 @@ static int ack_tx(struct net_device *dev, int acked)
 	skb_copy_from_linear_data(lp->outgoing.skb, ackpkt,
 				  ARC_HDR_SIZE + sizeof(struct arc_cap));
 	ackpkt->soft.cap.proto = 0; /* using protocol 0 for acknowledge */
-	ackpkt->soft.cap.mes.ack=acked;
+	ackpkt->soft.cap.mes.ack = acked;
 
 	BUGMSG(D_PROTO, "Ackknowledge for cap packet %x.\n",
-			*((int*)&ackpkt->soft.cap.cookie[0]));
+	       *((int *)&ackpkt->soft.cap.cookie[0]));
 
 	ackskb->protocol = cpu_to_be16(ETH_P_ARCNET);
 
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
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 96edc13..e0f489a 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -1,7 +1,7 @@
 /*
  * Linux ARCnet driver - COM20020 PCI support
  * Contemporary Controls PCI20 and SOHARD SH-ARC PCI
- * 
+ *
  * Written 1994-1999 by Avery Pennarun,
  *    based on an ISA version by David Woodhouse.
  * Written 1999-2000 by Martin Mares <mj@ucw.cz>.
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 1a84378..cd2a5ca 100644
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
@@ -117,7 +117,7 @@ int com20020_check(struct net_device *dev)
 	lp->config = 0x21 | (lp->timeout << 3) | (lp->backplane << 2);
 	/* set node ID to 0x42 (but transmitter is disabled, so it's okay) */
 	SETCONF;
-	outb(0x42, ioaddr + BUS_ALIGN*7);
+	outb(0x42, ioaddr + BUS_ALIGN * 7);
 
 	status = ASTATUS();
 
@@ -129,7 +129,7 @@ int com20020_check(struct net_device *dev)
 
 	/* Enable TX */
 	outb(0x39, _CONFIG);
-	outb(inb(ioaddr + BUS_ALIGN*8), ioaddr + BUS_ALIGN*7);
+	outb(inb(ioaddr + BUS_ALIGN * 8), ioaddr + BUS_ALIGN * 7);
 
 	ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
 
@@ -193,7 +193,7 @@ int com20020_found(struct net_device *dev, int shared)
 	lp->hw.close = com20020_close;
 
 	if (!dev->dev_addr[0])
-		dev->dev_addr[0] = inb(ioaddr + BUS_ALIGN*8);	/* FIXME: do this some other way! */
+		dev->dev_addr[0] = inb(ioaddr + BUS_ALIGN * 8);	/* FIXME: do this some other way! */
 
 	SET_SUBADR(SUB_SETUP1);
 	outb(lp->setup, _XREG);
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
@@ -243,9 +243,9 @@ int com20020_found(struct net_device *dev, int shared)
 }
 
 
-/* 
+/*
  * Do a hardware reset on the card, and set up necessary registers.
- * 
+ *
  * This should be called as little as possible, because it disrupts the
  * token on the network (causes a RECON) and requires a significant delay.
  *
@@ -258,15 +258,15 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 	u_char inbyte;
 
 	BUGMSG(D_DEBUG, "%s: %d: %s: dev: %p, lp: %p, dev->name: %s\n",
-		__FILE__,__LINE__,__func__,dev,lp,dev->name);
+	       __FILE__, __LINE__, __func__, dev, lp, dev->name);
 	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n",
 	       dev->name, ASTATUS());
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2);
 	/* power-up defaults */
 	SETCONF;
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 
 	if (really_reset) {
 		/* reset the card */
@@ -274,22 +274,22 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 		mdelay(RESETtime * 2);	/* COM20020 seems to be slower sometimes */
 	}
 	/* clear flags & end reset */
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
 
 	/* verify that the ARCnet signature byte is present */
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 
 	com20020_copy_from_card(dev, 0, 0, &inbyte, 1);
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	if (inbyte != TESTvalue) {
-		BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
+		BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 		BUGMSG(D_NORMAL, "reset failed: TESTvalue not present.\n");
 		return 1;
 	}
 	/* enable extended (512-byte) packets */
 	ACOMMAND(CONFIGcmd | EXTconf);
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 
 	/* done!  return success. */
 	return 0;
@@ -299,7 +299,7 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 static void com20020_setmask(struct net_device *dev, int mask)
 {
 	u_int ioaddr = dev->base_addr;
-	BUGMSG(D_DURING, "Setting mask to %x at %x\n",mask,ioaddr);
+	BUGMSG(D_DURING, "Setting mask to %x at %x\n", mask, ioaddr);
 	AINTMASK(mask);
 }
 
@@ -315,7 +315,7 @@ static int com20020_status(struct net_device *dev)
 {
 	u_int ioaddr = dev->base_addr;
 
-	return ASTATUS() + (ADIAGSTATUS()<<8);
+	return ASTATUS() + (ADIAGSTATUS() << 8);
 }
 
 static void com20020_close(struct net_device *dev)
diff --git a/drivers/net/arcnet/com20020_cs.c b/drivers/net/arcnet/com20020_cs.c
index 057d958..f687521 100644
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
@@ -53,33 +53,33 @@
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
+	for (count = ioaddr; count < ioaddr + 16; count++)
+	{
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
+	for (count = 0; count < 256 + 32; count++)
+	{
+		if (!(count % 16))
+			pr_cont("%04X:", count);
+
+		/* copy the data */
+		pr_cont(" %02X", inb(_MEMDATA));
+	}
+	pr_cont("\n");
 #endif
 }
 
@@ -114,169 +114,169 @@ static void com20020_detach(struct pcmcia_device *p_dev);
 
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
+	/*
+	 * this is necessary because we register our IRQ separately
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
+	/* Unlink device structure, free bits */
+	dev_dbg(&link->dev, "unlinking...\n");
+	if (link->priv)
 	{
-	    dev_dbg(&link->dev, "kfree...\n");
-	    free_netdev(dev);
+		dev = info->dev;
+		if (dev)
+		{
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
+	if (!link->resource[0]->start)
+	{
+		for (ioaddr = 0x100; ioaddr < 0x400; ioaddr += 0x10)
+		{
+			link->resource[0]->start = ioaddr;
+			i = pcmcia_request_io(link);
+			if (i == 0)
+				break;
+		}
+	}
+	else
+		i = pcmcia_request_io(link);
+
+	if (i != 0)
+	{
+		dev_dbg(&link->dev, "requestIO failed totally!\n");
+		goto failed;
+	}
+
+	ioaddr = dev->base_addr = link->resource[0]->start;
+	dev_dbg(&link->dev, "got ioaddr %Xh\n", ioaddr);
+
+	dev_dbg(&link->dev, "request IRQ %d\n",
+		link->irq);
+	if (!link->irq)
+	{
+		dev_dbg(&link->dev, "requestIRQ failed totally!\n");
+		goto failed;
+	}
 
-    if (!link->resource[0]->start)
-    {
-	for (ioaddr = 0x100; ioaddr < 0x400; ioaddr += 0x10)
+	dev->irq = link->irq;
+
+	ret = pcmcia_enable_device(link);
+	if (ret)
+		goto failed;
+
+	if (com20020_check(dev))
 	{
-	    link->resource[0]->start = ioaddr;
-	    i = pcmcia_request_io(link);
-	    if (i == 0)
-		break;
+		regdump(dev);
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
+		dev_notice(&link->dev,
+			   "com20020_found() failed\n");
+		goto failed;
+	}
+
+	netdev_dbg(dev, "port %#3lx, irq %d\n",
+		   dev->base_addr, dev->irq);
+	return 0;
 
 failed:
-    dev_dbg(&link->dev, "com20020_config failed...\n");
-    com20020_release(link);
-    return -ENODEV;
+	dev_dbg(&link->dev, "com20020_config failed...\n");
+	com20020_release(link);
+	return -ENODEV;
 } /* com20020_config */
 
 static void com20020_release(struct pcmcia_device *link)
@@ -312,9 +312,9 @@ static int com20020_resume(struct pcmcia_device *link)
 
 static const struct pcmcia_device_id com20020_ids[] = {
 	PCMCIA_DEVICE_PROD_ID12("Contemporary Control Systems, Inc.",
-			"PCM20 Arcnet Adapter", 0x59991666, 0x95dfffaf),
+				"PCM20 Arcnet Adapter", 0x59991666, 0x95dfffaf),
 	PCMCIA_DEVICE_PROD_ID12("SoHard AG",
-			"SH ARC PCMCIA", 0xf8991729, 0x69dff0c7),
+				"SH ARC PCMCIA", 0xf8991729, 0x69dff0c7),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, com20020_ids);
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 487d780..23ac9ed 100644
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
@@ -60,23 +60,23 @@ static void com90io_copy_from_card(struct net_device *dev, int bufnum, int offse
 #define ARCNET_TOTAL_SIZE 16
 
 /* COM 9026 controller chip --> ARCnet register addresses */
-#define _INTMASK (ioaddr+0)	/* writable */
-#define _STATUS  (ioaddr+0)	/* readable */
-#define _COMMAND (ioaddr+1)	/* writable, returns random vals on read (?) */
-#define _RESET  (ioaddr+8)	/* software reset (on read) */
-#define _MEMDATA  (ioaddr+12)	/* Data port for IO-mapped memory */
-#define _ADDR_HI  (ioaddr+15)	/* Control registers for said */
-#define _ADDR_LO  (ioaddr+14)
-#define _CONFIG  (ioaddr+2)	/* Configuration register */
+#define _INTMASK	(ioaddr + 0)	/* writable */
+#define _STATUS		(ioaddr + 0)	/* readable */
+#define _COMMAND	(ioaddr + 1)	/* writable, returns random vals on read (?) */
+#define _RESET		(ioaddr + 8)	/* software reset (on read) */
+#define _MEMDATA	(ioaddr + 12)	/* Data port for IO-mapped memory */
+#define _ADDR_HI	(ioaddr + 15)	/* Control registers for said */
+#define _ADDR_LO	(ioaddr + 14)
+#define _CONFIG		(ioaddr + 2)	/* Configuration register */
 
 #undef ASTATUS
 #undef ACOMMAND
 #undef AINTMASK
 
 #define ASTATUS()	inb(_STATUS)
-#define ACOMMAND(cmd) outb((cmd),_COMMAND)
-#define AINTMASK(msk)	outb((msk),_INTMASK)
-#define SETCONF() 	outb((lp->config),_CONFIG)
+#define ACOMMAND(cmd)	outb((cmd), _COMMAND)
+#define AINTMASK(msk)	outb((msk), _INTMASK)
+#define SETCONF()	outb((lp->config), _CONFIG)
 
 
 /****************************************************************************
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index b80fbe4..a4c5d59 100644
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
@@ -77,25 +77,25 @@ static int numcards;
 
 /* Amount of I/O memory used by the card */
 #define BUFFER_SIZE (512)
-#define MIRROR_SIZE (BUFFER_SIZE*4)
+#define MIRROR_SIZE (BUFFER_SIZE * 4)
 
 /* COM 9026 controller chip --> ARCnet register addresses */
-#define _INTMASK (ioaddr+0)	/* writable */
-#define _STATUS  (ioaddr+0)	/* readable */
-#define _COMMAND (ioaddr+1)	/* writable, returns random vals on read (?) */
-#define _CONFIG  (ioaddr+2)	/* Configuration register */
-#define _RESET   (ioaddr+8)	/* software reset (on read) */
-#define _MEMDATA (ioaddr+12)	/* Data port for IO-mapped memory */
-#define _ADDR_HI (ioaddr+15)	/* Control registers for said */
-#define _ADDR_LO (ioaddr+14)
+#define _INTMASK	(ioaddr + 0)	/* writable */
+#define _STATUS		(ioaddr + 0)	/* readable */
+#define _COMMAND	(ioaddr + 1)	/* writable, returns random vals on read (?) */
+#define _CONFIG		(ioaddr + 2)	/* Configuration register */
+#define _RESET		(ioaddr + 8)	/* software reset (on read) */
+#define _MEMDATA	(ioaddr + 12)	/* Data port for IO-mapped memory */
+#define _ADDR_HI	(ioaddr + 15)	/* Control registers for said */
+#define _ADDR_LO	(ioaddr + 14)
 
 #undef ASTATUS
 #undef ACOMMAND
 #undef AINTMASK
 
 #define ASTATUS()	inb(_STATUS)
-#define ACOMMAND(cmd) 	outb((cmd),_COMMAND)
-#define AINTMASK(msk)	outb((msk),_INTMASK)
+#define ACOMMAND(cmd)	outb((cmd), _COMMAND)
+#define AINTMASK(msk)	outb((msk), _INTMASK)
 
 
 static int com90xx_skip_probe __initdata = 0;
@@ -127,12 +127,12 @@ static void __init com90xx_probe(void)
 	if (!io && !irq && !shmem && !*device && com90xx_skip_probe)
 		return;
 
-	shmems = kzalloc(((0x100000-0xa0000) / 0x800) * sizeof(unsigned long),
+	shmems = kzalloc(((0x100000 - 0xa0000) / 0x800) * sizeof(unsigned long),
 			 GFP_KERNEL);
 	if (!shmems)
 		return;
-	iomem = kzalloc(((0x100000-0xa0000) / 0x800) * sizeof(void __iomem *),
-			 GFP_KERNEL);
+	iomem = kzalloc(((0x100000 - 0xa0000) / 0x800) * sizeof(void __iomem *),
+			GFP_KERNEL);
 	if (!iomem) {
 		kfree(shmems);
 		return;
@@ -579,7 +579,7 @@ static void com90xx_setmask(struct net_device *dev, int mask)
 
 /*
  * Do a hardware reset on the card, and set up necessary registers.
- * 
+ *
  * This should be called as little as possible, because it disrupts the
  * token on the network (causes a RECON) and requires a significant delay.
  *
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index f81db40..ae1ded2 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -1,6 +1,6 @@
 /*
  * Linux ARCnet driver - RFC1051 ("simple" standard) packet encapsulation
- * 
+ *
  * Written 1994-1999 by Avery Pennarun.
  * Derived from skeleton.c by Donald Becker.
  *
@@ -84,12 +84,12 @@ MODULE_LICENSE("GPL");
 
 /*
  * Determine a packet's protocol ID.
- * 
+ *
  * With ARCnet we have to convert everything to Ethernet-style stuff.
  */
 static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 {
-	struct archdr *pkt = (struct archdr *) skb->data;
+	struct archdr *pkt = (struct archdr *)skb->data;
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
 
@@ -146,7 +146,7 @@ static void rx(struct net_device *dev, int bufnum,
 	skb_put(skb, length + ARC_HDR_SIZE);
 	skb->dev = dev;
 
-	pkt = (struct archdr *) skb->data;
+	pkt = (struct archdr *)skb->data;
 
 	/* up to sizeof(pkt->soft) has already been copied from the card */
 	memcpy(pkt, pkthdr, sizeof(struct archdr));
@@ -169,7 +169,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
-	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
+	struct archdr *pkt = (struct archdr *)skb_push(skb, hdr_size);
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
 
 	/* set the protocol ID according to RFC1051 */
@@ -201,7 +201,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 	/* see linux/net/ethernet/eth.c to see where I got the following */
 
 	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP)) {
-		/* 
+		/*
 		 * FIXME: fill in the last byte of the dest ipaddr here to better
 		 * comply with RFC1051 in "noarp" mode.
 		 */
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index b71431a..bf2a8cb 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -1,6 +1,6 @@
 /*
  * Linux ARCnet driver - RFC1201 (standard) packet encapsulation
- * 
+ *
  * Written 1994-1999 by Avery Pennarun.
  * Derived from skeleton.c by Donald Becker.
  *
@@ -86,12 +86,12 @@ module_exit(arcnet_rfc1201_exit);
 
 /*
  * Determine a packet's protocol ID.
- * 
+ *
  * With ARCnet we have to convert everything to Ethernet-style stuff.
  */
 static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 {
-	struct archdr *pkt = (struct archdr *) skb->data;
+	struct archdr *pkt = (struct archdr *)skb->data;
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
 
@@ -169,7 +169,7 @@ static void rx(struct net_device *dev, int bufnum,
 
 		if (in->skb) {	/* already assembling one! */
 			BUGMSG(D_EXTRA, "aborting assembly (seq=%d) for unsplit packet (splitflag=%d, seq=%d)\n",
-			 in->sequence, soft->split_flag, soft->sequence);
+			       in->sequence, soft->split_flag, soft->sequence);
 			lp->rfc1201.aborted_seq = soft->sequence;
 			dev_kfree_skb_irq(in->skb);
 			dev->stats.rx_errors++;
@@ -187,7 +187,7 @@ static void rx(struct net_device *dev, int bufnum,
 		skb_put(skb, length + ARC_HDR_SIZE);
 		skb->dev = dev;
 
-		pkt = (struct archdr *) skb->data;
+		pkt = (struct archdr *)skb->data;
 		soft = &pkt->soft.rfc1201;
 
 		/* up to sizeof(pkt->soft) has already been copied from the card */
@@ -203,11 +203,11 @@ static void rx(struct net_device *dev, int bufnum,
 		 * (which is impossible to fumble) and insert it ourselves.
 		 */
 		if (soft->proto == ARC_P_ARP) {
-			struct arphdr *arp = (struct arphdr *) soft->payload;
+			struct arphdr *arp = (struct arphdr *)soft->payload;
 
 			/* make sure addresses are the right length */
 			if (arp->ar_hln == 1 && arp->ar_pln == 4) {
-				uint8_t *cptr = (uint8_t *) arp + sizeof(struct arphdr);
+				uint8_t *cptr = (uint8_t *)arp + sizeof(struct arphdr);
 
 				if (!*cptr) {	/* is saddr = 00? */
 					BUGMSG(D_EXTRA,
@@ -274,7 +274,7 @@ static void rx(struct net_device *dev, int bufnum,
 				dev_kfree_skb_irq(in->skb);
 			}
 			in->sequence = soft->sequence;
-			in->numpackets = ((unsigned) soft->split_flag >> 1) + 2;
+			in->numpackets = ((unsigned)soft->split_flag >> 1) + 2;
 			in->lastpacket = 1;
 
 			if (in->numpackets > 16) {
@@ -294,7 +294,7 @@ static void rx(struct net_device *dev, int bufnum,
 				return;
 			}
 			skb->dev = dev;
-			pkt = (struct archdr *) skb->data;
+			pkt = (struct archdr *)skb->data;
 			soft = &pkt->soft.rfc1201;
 
 			memcpy(pkt, pkthdr, ARC_HDR_SIZE + RFC1201_HDR_SIZE);
@@ -302,7 +302,7 @@ static void rx(struct net_device *dev, int bufnum,
 
 			soft->split_flag = 0;	/* end result won't be split */
 		} else {	/* not first packet */
-			int packetnum = ((unsigned) soft->split_flag >> 1) + 1;
+			int packetnum = ((unsigned)soft->split_flag >> 1) + 1;
 
 			/*
 			 * if we're not assembling, there's no point trying to
@@ -341,7 +341,7 @@ static void rx(struct net_device *dev, int bufnum,
 				in->lastpacket = in->numpackets = 0;
 				return;
 			}
-			pkt = (struct archdr *) in->skb->data;
+			pkt = (struct archdr *)in->skb->data;
 			soft = &pkt->soft.rfc1201;
 		}
 
@@ -357,10 +357,10 @@ static void rx(struct net_device *dev, int bufnum,
 			in->skb = NULL;
 			in->lastpacket = in->numpackets = 0;
 
-	    BUGMSG(D_SKB_SIZE, "skb: received %d bytes from %02X (unsplit)\n",
-    		skb->len, pkt->hard.source);
-	    BUGMSG(D_SKB_SIZE, "skb: received %d bytes from %02X (split)\n",
-    		skb->len, pkt->hard.source);
+			BUGMSG(D_SKB_SIZE, "skb: received %d bytes from %02X (unsplit)\n",
+			       skb->len, pkt->hard.source);
+			BUGMSG(D_SKB_SIZE, "skb: received %d bytes from %02X (split)\n",
+			       skb->len, pkt->hard.source);
 			BUGLVL(D_SKB) arcnet_dump_skb(dev, skb, "rx");
 
 			skb->protocol = type_trans(skb, dev);
@@ -376,7 +376,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
-	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
+	struct archdr *pkt = (struct archdr *)skb_push(skb, hdr_size);
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
 
 	/* set the protocol ID according to RFC1201 */
@@ -424,7 +424,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 	/* see linux/net/ethernet/eth.c to see where I got the following */
 
 	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP)) {
-		/* 
+		/*
 		 * FIXME: fill in the last byte of the dest ipaddr here to better
 		 * comply with RFC1051 in "noarp" mode.  For now, always broadcasting
 		 * will probably at least get packets sent out :)
@@ -517,7 +517,7 @@ static int continue_tx(struct net_device *dev, int bufnum)
 	int seglen;
 
 	BUGMSG(D_DURING,
-	  "rfc1201 continue_tx: loading segment %d(+1) of %d (seq=%d)\n",
+	       "rfc1201 continue_tx: loading segment %d(+1) of %d (seq=%d)\n",
 	       out->segnum, out->numsegs, soft->sequence);
 
 	/* the "new" soft header comes right before the data chunk */
diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index df03562..ccfd1d2 100644
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
@@ -77,33 +77,33 @@
 #endif
 
 #ifndef ARCNET_DEBUG
-#define ARCNET_DEBUG (D_NORMAL|D_EXTRA)
+#define ARCNET_DEBUG (D_NORMAL | D_EXTRA)
 #endif
 extern int arcnet_debug;
 
 /* macros to simplify debug checking */
-#define BUGLVL(x) if ((ARCNET_DEBUG_MAX)&arcnet_debug&(x))
-#define BUGMSG2(x,msg,args...) do { BUGLVL(x) printk(msg, ## args); } while (0)
-#define BUGMSG(x,msg,args...) \
-	BUGMSG2(x, "%s%6s: " msg, \
-            x==D_NORMAL	? KERN_WARNING \
-            		: x < D_DURING ? KERN_INFO : KERN_DEBUG, \
-	    dev->name , ## args)
+#define BUGLVL(x) if ((ARCNET_DEBUG_MAX) & arcnet_debug & (x))
+#define BUGMSG2(x, msg, args...) do { BUGLVL(x) printk(msg, ## args); } while (0)
+#define BUGMSG(x, msg, args...)						\
+	BUGMSG2(x, "%s%6s: " msg,					\
+		x == D_NORMAL	? KERN_WARNING				\
+		: x < D_DURING ? KERN_INFO : KERN_DEBUG,		\
+		dev->name, ## args)
 
 /* see how long a function call takes to run, expressed in CPU cycles */
-#define TIME(name, bytes, call) BUGLVL(D_TIMING) { \
-	    unsigned long _x, _y; \
-	    _x = get_cycles(); \
-	    call; \
-	    _y = get_cycles(); \
-	    BUGMSG(D_TIMING, \
-	       "%s: %d bytes in %lu cycles == " \
-	       "%lu Kbytes/100Mcycle\n",\
-		   name, bytes, _y - _x, \
-		   100000000 / 1024 * bytes / (_y - _x + 1));\
-	} \
-	else { \
-		    call;\
+#define TIME(name, bytes, call) BUGLVL(D_TIMING) {			\
+		unsigned long _x, _y;					\
+		_x = get_cycles();					\
+		call;							\
+		_y = get_cycles();					\
+		BUGMSG(D_TIMING,					\
+		       "%s: %d bytes in %lu cycles == "			\
+		       "%lu Kbytes/100Mcycle\n",			\
+		       name, bytes, _y - _x,				\
+		       100000000 / 1024 * bytes / (_y - _x + 1));	\
+	}								\
+	else {								\
+		call;							\
 	}
 
 
@@ -189,16 +189,16 @@ struct ArcProto {
 	int mtu;		/* largest possible packet */
 	int is_ip;              /* This is a ip plugin - not a raw thing */
 
-	void (*rx) (struct net_device * dev, int bufnum,
-		    struct archdr * pkthdr, int length);
-	int (*build_header) (struct sk_buff * skb, struct net_device *dev,
-			     unsigned short ethproto, uint8_t daddr);
+	void (*rx)(struct net_device *dev, int bufnum,
+		   struct archdr *pkthdr, int length);
+	int (*build_header)(struct sk_buff *skb, struct net_device *dev,
+			    unsigned short ethproto, uint8_t daddr);
 
 	/* these functions return '1' if the skb can now be freed */
-	int (*prepare_tx) (struct net_device * dev, struct archdr * pkt, int length,
-			   int bufnum);
-	int (*continue_tx) (struct net_device * dev, int bufnum);
-	int (*ack_tx) (struct net_device * dev, int acked);
+	int (*prepare_tx)(struct net_device *dev, struct archdr *pkt, int length,
+			  int bufnum);
+	int (*continue_tx)(struct net_device *dev, int bufnum);
+	int (*ack_tx)(struct net_device *dev, int acked);
 };
 
 extern struct ArcProto *arc_proto_map[256], *arc_proto_default,
@@ -263,13 +263,13 @@ struct arcnet_local {
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
@@ -298,17 +298,17 @@ struct arcnet_local {
 	/* hardware-specific functions */
 	struct {
 		struct module *owner;
-		void (*command) (struct net_device * dev, int cmd);
-		int (*status) (struct net_device * dev);
-		void (*intmask) (struct net_device * dev, int mask);
-		int (*reset) (struct net_device * dev, int really_reset);
-		void (*open) (struct net_device * dev);
-		void (*close) (struct net_device * dev);
-
-		void (*copy_to_card) (struct net_device * dev, int bufnum, int offset,
-				      void *buf, int count);
-		void (*copy_from_card) (struct net_device * dev, int bufnum, int offset,
-					void *buf, int count);
+		void (*command)(struct net_device *dev, int cmd);
+		int (*status)(struct net_device *dev);
+		void (*intmask)(struct net_device *dev, int mask);
+		int (*reset)(struct net_device *dev, int really_reset);
+		void (*open)(struct net_device *dev);
+		void (*close)(struct net_device *dev);
+
+		void (*copy_to_card)(struct net_device *dev, int bufnum, int offset,
+				     void *buf, int count);
+		void (*copy_from_card)(struct net_device *dev, int bufnum, int offset,
+				       void *buf, int count);
 	} hw;
 
 	void __iomem *mem_start;	/* pointer to ioremap'ed MMIO */
@@ -325,7 +325,7 @@ struct arcnet_local {
 #if ARCNET_DEBUG_MAX & D_SKB
 void arcnet_dump_skb(struct net_device *dev, struct sk_buff *skb, char *desc);
 #else
-#define arcnet_dump_skb(dev,skb,desc) ;
+#define arcnet_dump_skb(dev, skb, desc) ;
 #endif
 
 void arcnet_unregister_proto(struct ArcProto *proto);
@@ -335,7 +335,7 @@ struct net_device *alloc_arcdev(const char *name);
 int arcnet_open(struct net_device *dev);
 int arcnet_close(struct net_device *dev);
 netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
-				     struct net_device *dev);
+			       struct net_device *dev);
 void arcnet_timeout(struct net_device *dev);
 
 #endif				/* __KERNEL__ */
-- 
2.5.1
