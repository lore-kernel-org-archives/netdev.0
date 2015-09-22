From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 07/33] arcnet: Use network block comment style
Date: Tue, 22 Sep 2015 11:01:48 +0200
Message-ID: <1442912534-10821-8-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54468 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932328AbbIVJCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:39 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Conformity can be useful.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rawmode.c  | 15 ++++----
 drivers/net/arcnet/arc-rimi.c     | 17 ++++-----
 drivers/net/arcnet/arcnet.c       | 76 ++++++++++++++++-----------------------
 drivers/net/arcnet/capmode.c      | 25 +++++++------
 drivers/net/arcnet/com20020-isa.c |  3 +-
 drivers/net/arcnet/com20020.c     |  3 +-
 drivers/net/arcnet/com20020_cs.c  |  3 +-
 drivers/net/arcnet/com90io.c      |  9 ++---
 drivers/net/arcnet/com90xx.c      |  3 +-
 drivers/net/arcnet/rfc1051.c      | 19 ++++------
 drivers/net/arcnet/rfc1201.c      | 54 ++++++++++++++--------------
 11 files changed, 95 insertions(+), 132 deletions(-)

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index 500b5bb..efdd8e9 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -123,8 +123,7 @@ static void rx(struct net_device *dev, int bufnum,
 	netif_rx(skb);
 }
 
-/*
- * Create the ARCnet hard/soft headers for raw mode.
+/* Create the ARCnet hard/soft headers for raw mode.
  * There aren't any soft headers in raw mode - not even the protocol id.
  */
 static int build_header(struct sk_buff *skb, struct net_device *dev,
@@ -133,21 +132,19 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 	int hdr_size = ARC_HDR_SIZE;
 	struct archdr *pkt = (struct archdr *)skb_push(skb, hdr_size);
 
-	/*
-	 * Set the source hardware address.
+	/* Set the source hardware address.
 	 *
 	 * This is pretty pointless for most purposes, but it can help in
-	 * debugging.  ARCnet does not allow us to change the source address in
-	 * the actual packet sent)
+	 * debugging.  ARCnet does not allow us to change the source address
+	 * in the actual packet sent.
 	 */
 	pkt->hard.source = *dev->dev_addr;
 
 	/* see linux/net/ethernet/eth.c to see where I got the following */
 
 	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP)) {
-		/*
-		 * FIXME: fill in the last byte of the dest ipaddr here to better
-		 * comply with RFC1051 in "noarp" mode.
+		/* FIXME: fill in the last byte of the dest ipaddr here
+		 * to better comply with RFC1051 in "noarp" mode.
 		 */
 		pkt->hard.dest = 0;
 		return hdr_size;
diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index 88e6157..c7ab23e 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -76,8 +76,7 @@ static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offse
 #define AINTMASK(msk)	writeb((msk), _INTMASK)
 #define SETCONF()	writeb(lp->config, _CONFIG)
 
-/*
- * We cannot probe for a RIM I card; one reason is I don't know how to reset
+/* We cannot probe for a RIM I card; one reason is I don't know how to reset
  * them.  In fact, we can't even get their node ID automatically.  So, we
  * need to be passed a specific shmem address, IRQ, and node ID.
  */
@@ -97,8 +96,7 @@ static int __init arcrimi_probe(struct net_device *dev)
 		BUGLVL(D_NORMAL) printk("You need to specify your card's station ID!\n");
 		return -ENODEV;
 	}
-	/*
-	 * Grab the memory region at mem_start for MIRROR_SIZE bytes.
+	/* Grab the memory region at mem_start for MIRROR_SIZE bytes.
 	 * Later in arcrimi_found() the real size will be determined
 	 * and this reserve will be released and the correct size
 	 * will be taken.
@@ -131,9 +129,8 @@ static int check_mirror(unsigned long addr, size_t size)
 	return res;
 }
 
-/*
- * Set up the struct net_device associated with this card.  Called after
- * probing succeeds.
+/* Set up the struct net_device associated with this card.
+ * Called after probing succeeds.
  */
 static int __init arcrimi_found(struct net_device *dev)
 {
@@ -199,8 +196,7 @@ static int __init arcrimi_found(struct net_device *dev)
 	lp->hw.copy_to_card = arcrimi_copy_to_card;
 	lp->hw.copy_from_card = arcrimi_copy_from_card;
 
-	/*
-	 * re-reserve the memory region - arcrimi_probe() alloced this reqion
+	/* re-reserve the memory region - arcrimi_probe() alloced this reqion
 	 * but didn't know the real size.  Free that region and then re-get
 	 * with the correct size.  There is a VERY slim chance this could
 	 * fail.
@@ -243,8 +239,7 @@ err_free_irq:
 	return -EIO;
 }
 
-/*
- * Do a hardware reset on the card, and set up necessary registers.
+/* Do a hardware reset on the card, and set up necessary registers.
  *
  * This should be called as little as possible, because it disrupts the
  * token on the network (causes a RECON) and requires a significant delay.
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index d70efda..605b4a7 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -63,8 +63,7 @@ static int null_prepare_tx(struct net_device *dev, struct archdr *pkt,
 
 static void arcnet_rx(struct net_device *dev, int bufnum);
 
-/*
- * one ArcProto per possible proto ID.  None of the elements of
+/* one ArcProto per possible proto ID.  None of the elements of
  * arc_proto_map are allowed to be NULL; they will get set to
  * arc_proto_default instead.  It also must not be NULL; if you would like
  * to set it to NULL, set it to &arc_proto_null instead.
@@ -149,9 +148,7 @@ static void __exit arcnet_exit(void)
 module_init(arcnet_init);
 module_exit(arcnet_exit);
 
-/*
- * Dump the contents of an sk_buff
- */
+/* Dump the contents of an sk_buff */
 #if ARCNET_DEBUG_MAX & D_SKB
 void arcnet_dump_skb(struct net_device *dev,
 		     struct sk_buff *skb, char *desc)
@@ -167,9 +164,7 @@ void arcnet_dump_skb(struct net_device *dev,
 EXPORT_SYMBOL(arcnet_dump_skb);
 #endif
 
-/*
- * Dump the contents of an ARCnet buffer
- */
+/* Dump the contents of an ARCnet buffer */
 #if (ARCNET_DEBUG_MAX & (D_RX | D_TX))
 static void arcnet_dump_packet(struct net_device *dev, int bufnum,
 			       char *desc, int take_arcnet_lock)
@@ -181,7 +176,8 @@ static void arcnet_dump_packet(struct net_device *dev, int bufnum,
 	char hdr[32];
 
 	/* hw.copy_from_card expects IRQ context so take the IRQ lock
-	   to keep it single threaded */
+	 * to keep it single threaded
+	 */
 	if (take_arcnet_lock)
 		spin_lock_irqsave(&lp->lock, flags);
 
@@ -204,8 +200,7 @@ static void arcnet_dump_packet(struct net_device *dev, int bufnum,
 
 #endif
 
-/*
- * Unregister a protocol driver from the arc_proto_map.  Protocol drivers
+/* Unregister a protocol driver from the arc_proto_map.  Protocol drivers
  * are responsible for registering themselves, but the unregister routine
  * is pretty generic so we'll do it here.
  */
@@ -226,8 +221,7 @@ void arcnet_unregister_proto(struct ArcProto *proto)
 	}
 }
 
-/*
- * Add a buffer to the queue.  Only the interrupt handler is allowed to do
+/* Add a buffer to the queue.  Only the interrupt handler is allowed to do
  * this, unless interrupts are disabled.
  *
  * Note: we don't check for a full queue, since there aren't enough buffers
@@ -250,9 +244,8 @@ static void release_arcbuf(struct net_device *dev, int bufnum)
 	}
 }
 
-/*
- * Get a buffer from the queue.  If this returns -1, there are no buffers
- * available.
+/* Get a buffer from the queue.
+ * If this returns -1, there are no buffers available.
  */
 static int get_arcbuf(struct net_device *dev)
 {
@@ -346,8 +339,7 @@ struct net_device *alloc_arcdev(const char *name)
 	return dev;
 }
 
-/*
- * Open/initialize the board.  This is called sometime after booting when
+/* Open/initialize the board.  This is called sometime after booting when
  * the 'ifconfig' program is run.
  *
  * This routine should set everything up anew at each open, even registers
@@ -490,15 +482,13 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 		BUGMSG(D_DEBUG, "arc_raw_proto used. proto='%c'\n", proto->suffix);
 		_daddr = daddr ? *(uint8_t *)daddr : 0;
 	} else if (!daddr) {
-		/*
-		 * if the dest addr isn't provided, we can't choose an encapsulation!
-		 * Store the packet type (eg. ETH_P_IP) for now, and we'll push on a
-		 * real header when we do rebuild_header.
+		/* if the dest addr isn't provided, we can't choose an
+		 * encapsulation!  Store the packet type (eg. ETH_P_IP)
+		 * for now, and we'll push on a real header when we do
+		 * rebuild_header.
 		 */
 		*(uint16_t *)skb_push(skb, 2) = type;
-		/*
-		 * XXX: Why not use skb->mac_len?
-		 */
+		/* XXX: Why not use skb->mac_len? */
 		if (skb->network_header - skb->mac_header != 2)
 			BUGMSG(D_NORMAL, "arcnet_header: Yikes!  diff (%d) is not 2!\n",
 			       (int)(skb->network_header - skb->mac_header));
@@ -564,7 +554,8 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 		if (proto->prepare_tx(dev, pkt, skb->len, txbuf) &&
 		    !proto->ack_tx) {
 			/* done right away and we don't want to acknowledge
-			   the package later - forget about it now */
+			 *  the package later - forget about it now
+			 */
 			dev->stats.tx_bytes += skb->len;
 			freeskb = 1;
 		} else {
@@ -605,8 +596,7 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 	return retval;		/* no need to try again */
 }
 
-/*
- * Actually start transmitting a packet that was loaded into a buffer
+/* Actually start transmitting a packet that was loaded into a buffer
  * by prepare_tx.  This should _only_ be called by the interrupt handler.
  */
 static int go_tx(struct net_device *dev)
@@ -672,8 +662,7 @@ void arcnet_timeout(struct net_device *dev)
 		netif_wake_queue(dev);
 }
 
-/*
- * The typical workload of the driver: Handle the network interface
+/* The typical workload of the driver: Handle the network interface
  * interrupts. Establish which device needs attention, and call the correct
  * chipset interrupt handler.
  */
@@ -693,9 +682,8 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 
 	spin_lock(&lp->lock);
 
-	/*
-	 * RESET flag was enabled - if device is not running, we must clear it right
-	 * away (but nothing else).
+	/* RESET flag was enabled - if device is not running, we must
+	 * clear it right away (but nothing else).
 	 */
 	if (!netif_running(dev)) {
 		if (ASTATUS() & RESETflag)
@@ -717,11 +705,11 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 		       __FILE__, __LINE__, __func__, status);
 		didsomething = 0;
 
-		/*
-		 * RESET flag was enabled - card is resetting and if RX is
+		/* RESET flag was enabled - card is resetting and if RX is
 		 * disabled, it's NOT because we just got a packet.
 		 *
-		 * The card is in an undefined state.  Clear it out and start over.
+		 * The card is in an undefined state.
+		 * Clear it out and start over.
 		 */
 		if (status & RESETflag) {
 			BUGMSG(D_NORMAL, "spurious reset (status=%Xh)\n", status);
@@ -731,14 +719,13 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			/* get out of the interrupt handler! */
 			break;
 		}
-		/*
-		 * RX is inhibited - we must have received something. Prepare to
-		 * receive into the next buffer.
+		/* RX is inhibited - we must have received something.
+		 * Prepare to receive into the next buffer.
 		 *
-		 * We don't actually copy the received packet from the card until
-		 * after the transmit handler runs (and possibly launches the next
-		 * tx); this should improve latency slightly if we get both types
-		 * of interrupts at once.
+		 * We don't actually copy the received packet from the card
+		 * until after the transmit handler runs (and possibly
+		 * launches the next tx); this should improve latency slightly
+		 * if we get both types of interrupts at once.
 		 */
 		recbuf = -1;
 		if (status & lp->intmask & NORXflag) {
@@ -914,8 +901,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 	return retval;
 }
 
-/*
- * This is a generic packet receiver that calls arcnet??_rx depending on the
+/* This is a generic packet receiver that calls arcnet??_rx depending on the
  * protocol ID found.
  */
 static void arcnet_rx(struct net_device *dev, int bufnum)
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 36648d3..8391324 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -66,11 +66,11 @@ static void rx(struct net_device *dev, int bufnum,
 	pkt = (struct archdr *)skb_mac_header(skb);
 	skb_pull(skb, ARC_HDR_SIZE);
 
-	/* up to sizeof(pkt->soft) has already been copied from the card */
-	/* squeeze in an int for the cap encapsulation */
-
-	/* use these variables to be sure we count in bytes, not in
-	   sizeof(struct archdr) */
+	/* up to sizeof(pkt->soft) has already been copied from the card
+	 * squeeze in an int for the cap encapsulation
+	 * use these variables to be sure we count in bytes, not in
+	 * sizeof(struct archdr)
+	 */
 	pktbuf = (char *)pkt;
 	pkthdrbuf = (char *)pkthdr;
 	memcpy(pktbuf, pkthdrbuf, ARC_HDR_SIZE + sizeof(pkt->soft.cap.proto));
@@ -90,8 +90,7 @@ static void rx(struct net_device *dev, int bufnum,
 	netif_rx(skb);
 }
 
-/*
- * Create the ARCnet hard/soft headers for cap mode.
+/* Create the ARCnet hard/soft headers for cap mode.
  * There aren't any soft headers in cap mode - not even the protocol id.
  */
 static int build_header(struct sk_buff *skb,
@@ -104,8 +103,8 @@ static int build_header(struct sk_buff *skb,
 
 	BUGMSG(D_PROTO, "Preparing header for cap packet %x.\n",
 	       *((int *)&pkt->soft.cap.cookie[0]));
-	/*
-	 * Set the source hardware address.
+
+	/* Set the source hardware address.
 	 *
 	 * This is pretty pointless for most purposes, but it can help in
 	 * debugging.  ARCnet does not allow us to change the source address in
@@ -116,9 +115,8 @@ static int build_header(struct sk_buff *skb,
 	/* see linux/net/ethernet/eth.c to see where I got the following */
 
 	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP)) {
-		/*
-		 * FIXME: fill in the last byte of the dest ipaddr here to better
-		 * comply with RFC1051 in "noarp" mode.
+		/* FIXME: fill in the last byte of the dest ipaddr here to
+		 * better comply with RFC1051 in "noarp" mode.
 		 */
 		pkt->hard.dest = 0;
 		return hdr_size;
@@ -172,7 +170,8 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 			    sizeof(pkt->soft.cap.proto));
 
 	/* Skip the extra integer we have written into it as a cookie
-	   but write the rest of the message: */
+	 * but write the rest of the message:
+	 */
 	lp->hw.copy_to_card(dev, bufnum, ofs + 1,
 			    ((unsigned char *)&pkt->soft.cap.mes), length - 1);
 
diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index d829e60..6e38a19 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -43,8 +43,7 @@
 
 #define VERSION "arcnet: COM20020 ISA support (by David Woodhouse et al.)\n"
 
-/*
- * We cannot (yet) probe for an IO mapped card, although we can check that
+/* We cannot (yet) probe for an IO mapped card, although we can check that
  * it's where we were told it was, and even do autoirq.
  */
 static int __init com20020isa_probe(struct net_device *dev)
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index bdf883f..6369727 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -239,8 +239,7 @@ int com20020_found(struct net_device *dev, int shared)
 	return 0;
 }
 
-/*
- * Do a hardware reset on the card, and set up necessary registers.
+/* Do a hardware reset on the card, and set up necessary registers.
  *
  * This should be called as little as possible, because it disrupts the
  * token on the network (causes a RECON) and requires a significant delay.
diff --git a/drivers/net/arcnet/com20020_cs.c b/drivers/net/arcnet/com20020_cs.c
index 437b456..13fe538 100644
--- a/drivers/net/arcnet/com20020_cs.c
+++ b/drivers/net/arcnet/com20020_cs.c
@@ -162,8 +162,7 @@ static void com20020_detach(struct pcmcia_device *link)
 
 	unregister_netdev(dev);
 
-	/*
-	 * this is necessary because we register our IRQ separately
+	/* this is necessary because we register our IRQ separately
 	 * from card services.
 	 */
 	if (dev->irq)
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 3233346..6ec36f9 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -137,8 +137,7 @@ static void put_whole_buffer(struct net_device *dev, unsigned offset, unsigned l
 #endif
 }
 
-/*
- * We cannot probe for an IO mapped card either, although we can check that
+/* We cannot probe for an IO mapped card either, although we can check that
  * it's where we were told it was, and even autoirq
  */
 static int __init com90io_probe(struct net_device *dev)
@@ -196,8 +195,7 @@ static int __init com90io_probe(struct net_device *dev)
 		goto err_out;
 	}
 	if (!dev->irq) {
-		/*
-		 * if we do this, we're sure to get an IRQ since the
+		/* if we do this, we're sure to get an IRQ since the
 		 * card has just reset and the NORXflag is on until
 		 * we tell it to start receiving.
 		 */
@@ -272,8 +270,7 @@ static int __init com90io_found(struct net_device *dev)
 	return 0;
 }
 
-/*
- * Do a hardware reset on the card, and set up necessary registers.
+/* Do a hardware reset on the card, and set up necessary registers.
  *
  * This should be called as little as possible, because it disrupts the
  * token on the network (causes a RECON) and requires a significant delay.
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index 0b7bc86..4781cd6 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -568,8 +568,7 @@ static void com90xx_setmask(struct net_device *dev, int mask)
 	AINTMASK(mask);
 }
 
-/*
- * Do a hardware reset on the card, and set up necessary registers.
+/* Do a hardware reset on the card, and set up necessary registers.
  *
  * This should be called as little as possible, because it disrupts the
  * token on the network (causes a RECON) and requires a significant delay.
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index ed7b645..e78b765 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -78,8 +78,7 @@ module_exit(arcnet_rfc1051_exit);
 
 MODULE_LICENSE("GPL");
 
-/*
- * Determine a packet's protocol ID.
+/* Determine a packet's protocol ID.
  *
  * With ARCnet we have to convert everything to Ethernet-style stuff.
  */
@@ -156,9 +155,7 @@ static void rx(struct net_device *dev, int bufnum,
 	netif_rx(skb);
 }
 
-/*
- * Create the ARCnet hard/soft headers for RFC1051.
- */
+/* Create the ARCnet hard/soft headers for RFC1051 */
 static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
@@ -182,21 +179,19 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 		return 0;
 	}
 
-	/*
-	 * Set the source hardware address.
+	/* Set the source hardware address.
 	 *
 	 * This is pretty pointless for most purposes, but it can help in
-	 * debugging.  ARCnet does not allow us to change the source address in
-	 * the actual packet sent)
+	 * debugging.  ARCnet does not allow us to change the source address
+	 * in the actual packet sent.
 	 */
 	pkt->hard.source = *dev->dev_addr;
 
 	/* see linux/net/ethernet/eth.c to see where I got the following */
 
 	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP)) {
-		/*
-		 * FIXME: fill in the last byte of the dest ipaddr here to better
-		 * comply with RFC1051 in "noarp" mode.
+		/* FIXME: fill in the last byte of the dest ipaddr here to
+		 * better comply with RFC1051 in "noarp" mode.
 		 */
 		pkt->hard.dest = 0;
 		return hdr_size;
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index 4775017..4ebfbcb 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -81,8 +81,7 @@ static void __exit arcnet_rfc1201_exit(void)
 module_init(arcnet_rfc1201_init);
 module_exit(arcnet_rfc1201_exit);
 
-/*
- * Determine a packet's protocol ID.
+/* Determine a packet's protocol ID.
  *
  * With ARCnet we have to convert everything to Ethernet-style stuff.
  */
@@ -193,10 +192,10 @@ static void rx(struct net_device *dev, int bufnum,
 				       pkt->soft.raw + sizeof(pkt->soft),
 					      length - sizeof(pkt->soft));
 
-		/*
-		 * ARP packets have problems when sent from some DOS systems: the
-		 * source address is always 0!  So we take the hardware source addr
-		 * (which is impossible to fumble) and insert it ourselves.
+		/* ARP packets have problems when sent from some DOS systems:
+		 * the source address is always 0!
+		 * So we take the hardware source addr (which is impossible
+		 * to fumble) and insert it ourselves.
 		 */
 		if (soft->proto == ARC_P_ARP) {
 			struct arphdr *arp = (struct arphdr *)soft->payload;
@@ -227,21 +226,22 @@ static void rx(struct net_device *dev, int bufnum,
 		skb->protocol = type_trans(skb, dev);
 		netif_rx(skb);
 	} else {		/* split packet */
-		/*
-		 * NOTE: MSDOS ARP packet correction should only need to apply to
-		 * unsplit packets, since ARP packets are so short.
+		/* NOTE: MSDOS ARP packet correction should only need to
+		 * apply to unsplit packets, since ARP packets are so short.
 		 *
-		 * My interpretation of the RFC1201 document is that if a packet is
-		 * received out of order, the entire assembly process should be
-		 * aborted.
+		 * My interpretation of the RFC1201 document is that if a
+		 * packet is received out of order, the entire assembly
+		 * process should be aborted.
 		 *
-		 * The RFC also mentions "it is possible for successfully received
-		 * packets to be retransmitted." As of 0.40 all previously received
-		 * packets are allowed, not just the most recent one.
+		 * The RFC also mentions "it is possible for successfully
+		 * received packets to be retransmitted." As of 0.40 all
+		 * previously received packets are allowed, not just the
+		 * most recent one.
 		 *
-		 * We allow multiple assembly processes, one for each ARCnet card
-		 * possible on the network.  Seems rather like a waste of memory,
-		 * but there's no other way to be reliable.
+		 * We allow multiple assembly processes, one for each
+		 * ARCnet card possible on the network.
+		 * Seems rather like a waste of memory, but there's no
+		 * other way to be reliable.
 		 */
 
 		BUGMSG(D_RX, "packet is split (splitflag=%d, seq=%d)\n",
@@ -299,8 +299,7 @@ static void rx(struct net_device *dev, int bufnum,
 		} else {	/* not first packet */
 			int packetnum = ((unsigned)soft->split_flag >> 1) + 1;
 
-			/*
-			 * if we're not assembling, there's no point trying to
+			/* if we're not assembling, there's no point trying to
 			 * continue.
 			 */
 			if (!in->skb) {
@@ -401,12 +400,11 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 		return 0;
 	}
 
-	/*
-	 * Set the source hardware address.
+	/* Set the source hardware address.
 	 *
 	 * This is pretty pointless for most purposes, but it can help in
-	 * debugging.  ARCnet does not allow us to change the source address in
-	 * the actual packet sent)
+	 * debugging.  ARCnet does not allow us to change the source address
+	 * in the actual packet sent.
 	 */
 	pkt->hard.source = *dev->dev_addr;
 
@@ -416,10 +414,10 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 	/* see linux/net/ethernet/eth.c to see where I got the following */
 
 	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP)) {
-		/*
-		 * FIXME: fill in the last byte of the dest ipaddr here to better
-		 * comply with RFC1051 in "noarp" mode.  For now, always broadcasting
-		 * will probably at least get packets sent out :)
+		/* FIXME: fill in the last byte of the dest ipaddr here
+		 * to better comply with RFC1051 in "noarp" mode.
+		 * For now, always broadcasting will probably at least get
+		 * packets sent out :)
 		 */
 		pkt->hard.dest = 0;
 		return hdr_size;
-- 
2.5.1
