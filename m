From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 03/33] arcnet: Add and remove blank lines
Date: Tue, 22 Sep 2015 11:01:44 +0200
Message-ID: <1442912534-10821-4-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57104 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932340AbbIVJCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:39 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Use a more current kernel line style.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rawmode.c  |  5 -----
 drivers/net/arcnet/arc-rimi.c     |  8 +++-----
 drivers/net/arcnet/arcnet.c       | 23 +++--------------------
 drivers/net/arcnet/capmode.c      |  3 ---
 drivers/net/arcnet/com20020-isa.c |  1 -
 drivers/net/arcnet/com20020-pci.c |  2 --
 drivers/net/arcnet/com20020.c     |  8 ++------
 drivers/net/arcnet/com20020_cs.c  |  4 +---
 drivers/net/arcnet/com90io.c      | 12 +-----------
 drivers/net/arcnet/com90xx.c      | 13 +++----------
 drivers/net/arcnet/rfc1051.c      |  7 -------
 drivers/net/arcnet/rfc1201.c      |  8 --------
 include/linux/arcdevice.h         | 12 ------------
 13 files changed, 13 insertions(+), 93 deletions(-)

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index 49f5819..251a98b 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -35,7 +35,6 @@
 
 #define VERSION "arcnet: raw mode (`r') encapsulation support loaded.\n"
 
-
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length);
 static int build_header(struct sk_buff *skb, struct net_device *dev,
@@ -54,7 +53,6 @@ static struct ArcProto rawmode_proto =
 	.ack_tx         = NULL
 };
 
-
 static int __init arcnet_raw_init(void)
 {
 	int count;
@@ -83,7 +81,6 @@ module_exit(arcnet_raw_exit);
 
 MODULE_LICENSE("GPL");
 
-
 /* packet receiver */
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
@@ -127,7 +124,6 @@ static void rx(struct net_device *dev, int bufnum,
 	netif_rx(skb);
 }
 
-
 /*
  * Create the ARCnet hard/soft headers for raw mode.
  * There aren't any soft headers in raw mode - not even the protocol id.
@@ -163,7 +159,6 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 	return hdr_size;	/* success */
 }
 
-
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index 4644d46..e8c1501 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -36,10 +36,8 @@
 #include <asm/io.h>
 #include <linux/arcdevice.h>
 
-
 #define VERSION "arcnet: RIM I (entirely mem-mapped) support\n"
 
-
 /* Internal function declarations */
 
 static int arcrimi_probe(struct net_device *dev);
@@ -78,7 +76,6 @@ static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offse
 #define AINTMASK(msk)	writeb((msk), _INTMASK)
 #define SETCONF()	writeb(lp->config, _CONFIG)
 
-
 /*
  * We cannot probe for a RIM I card; one reason is I don't know how to reset
  * them.  In fact, we can't even get their node ID automatically.  So, we
@@ -249,7 +246,6 @@ err_free_irq:
 	return -EIO;
 }
 
-
 /*
  * Do a hardware reset on the card, and set up necessary registers.
  *
@@ -308,15 +304,16 @@ static void arcrimi_copy_to_card(struct net_device *dev, int bufnum, int offset,
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + 0x800 + bufnum * 512 + offset;
+
 	TIME("memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
 
-
 static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offset,
 				   void *buf, int count)
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + 0x800 + bufnum * 512 + offset;
+
 	TIME("memcpy_fromio", count, memcpy_fromio(buf, memaddr, count));
 }
 
@@ -374,6 +371,7 @@ static void __exit arc_rimi_exit(void)
 static int __init arcrimi_setup(char *s)
 {
 	int ints[8];
+
 	s = get_options(s, 8, ints);
 	if (!ints[0])
 		return 1;
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 2a594d1..bb49753 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -168,7 +168,6 @@ void arcnet_dump_skb(struct net_device *dev,
 EXPORT_SYMBOL(arcnet_dump_skb);
 #endif
 
-
 /*
  * Dump the contents of an ARCnet buffer
  */
@@ -206,7 +205,6 @@ static void arcnet_dump_packet(struct net_device *dev, int bufnum,
 
 #endif
 
-
 /*
  * Unregister a protocol driver from the arc_proto_map.  Protocol drivers
  * are responsible for registering themselves, but the unregister routine
@@ -229,7 +227,6 @@ void arcnet_unregister_proto(struct ArcProto *proto)
 	}
 }
 
-
 /*
  * Add a buffer to the queue.  Only the interrupt handler is allowed to do
  * this, unless interrupts are disabled.
@@ -254,7 +251,6 @@ static void release_arcbuf(struct net_device *dev, int bufnum)
 	}
 }
 
-
 /*
  * Get a buffer from the queue.  If this returns -1, there are no buffers
  * available.
@@ -281,7 +277,6 @@ static int get_arcbuf(struct net_device *dev)
 		}
 	}
 
-
 	BUGLVL(D_DURING) {
 		BUGMSG(D_DURING, "get_arcbuf: got #%d; buffer queue is now: ", buf);
 		for (i = lp->next_buf; i != lp->first_free_buf; i = (i + 1) % 5)
@@ -293,7 +288,6 @@ static int get_arcbuf(struct net_device *dev)
 	return buf;
 }
 
-
 static int choose_mtu(void)
 {
 	int count, mtu = 65535;
@@ -348,6 +342,7 @@ struct net_device *alloc_arcdev(const char *name)
 			   arcdev_setup);
 	if (dev) {
 		struct arcnet_local *lp = netdev_priv(dev);
+
 		spin_lock_init(&lp->lock);
 	}
 
@@ -380,7 +375,6 @@ int arcnet_open(struct net_device *dev)
 		BUGMSG2(D_PROTO, "\n");
 	}
 
-
 	BUGMSG(D_INIT, "arcnet_open: resetting card.\n");
 
 	/* try to put the card in a defined state - if it fails the first
@@ -437,7 +431,6 @@ int arcnet_open(struct net_device *dev)
 		ACOMMAND(CFLAGScmd | RESETclear);
 	}
 
-
 	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	/* make sure we're ready to receive IRQ's. */
 	AINTMASK(0);
@@ -459,7 +452,6 @@ int arcnet_open(struct net_device *dev)
 	return error;
 }
 
-
 /* The inverse routine to arcnet_open - shuts down the card. */
 int arcnet_close(struct net_device *dev)
 {
@@ -479,7 +471,6 @@ int arcnet_close(struct net_device *dev)
 	return 0;
 }
 
-
 static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 			 unsigned short type, const void *daddr,
 			 const void *saddr, unsigned len)
@@ -498,7 +489,6 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 		BUGMSG(D_NORMAL, "arcnet_header: Yikes!  skb->len(%d) != len(%d)!\n",
 		       skb->len, len);
 
-
 	/* Type is host order - ? */
 	if (type == ETH_P_ARCNET) {
 		proto = arc_raw_proto;
@@ -622,7 +612,6 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 	return retval;		/* no need to try again */
 }
 
-
 /*
  * Actually start transmitting a packet that was loaded into a buffer
  * by prepare_tx.  This should _only_ be called by the interrupt handler.
@@ -654,7 +643,6 @@ static int go_tx(struct net_device *dev)
 	return 1;
 }
 
-
 /* Called by the kernel when transmit times out */
 void arcnet_timeout(struct net_device *dev)
 {
@@ -691,7 +679,6 @@ void arcnet_timeout(struct net_device *dev)
 		netif_wake_queue(dev);
 }
 
-
 /*
  * The typical workload of the driver: Handle the network interface
  * interrupts. Establish which device needs attention, and call the correct
@@ -787,7 +774,6 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			didsomething++;
 		}
 
-
 		/* a transmit finished, and we're interested in it. */
 		if ((status & lp->intmask & TXFREEflag) || lp->timed_out) {
 			lp->intmask &= ~(TXFREEflag | EXCNAKflag);
@@ -814,6 +800,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 				if (lp->outgoing.proto &&
 				    lp->outgoing.proto->ack_tx) {
 					int ackstatus;
+
 					if (status & TXACKflag)
 						ackstatus = 2;
 					else if (lp->excnak_pending)
@@ -838,6 +825,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			/* continue a split packet, if any */
 			if (lp->outgoing.proto && lp->outgoing.proto->continue_tx) {
 				int txbuf = get_arcbuf(dev);
+
 				if (txbuf != -1) {
 					if (lp->outgoing.proto->continue_tx(dev, txbuf)) {
 						/* that was the last segment */
@@ -930,7 +918,6 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 	       ASTATUS(), boguscount);
 	BUGMSG(D_DURING, "\n");
 
-
 	AINTMASK(0);
 	udelay(1);
 	AINTMASK(lp->intmask);
@@ -939,7 +926,6 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 	return retval;
 }
 
-
 /*
  * This is a generic packet receiver that calls arcnet??_rx depending on the
  * protocol ID found.
@@ -1002,7 +988,6 @@ static void arcnet_rx(struct net_device *dev, int bufnum)
 	arc_proto_map[soft->proto]->rx(dev, bufnum, &pkt, length);
 }
 
-
 static void null_rx(struct net_device *dev, int bufnum,
 		    struct archdr *pkthdr, int length)
 {
@@ -1011,7 +996,6 @@ static void null_rx(struct net_device *dev, int bufnum,
 	       pkthdr->soft.rfc1201.proto, pkthdr->hard.source);
 }
 
-
 static int null_build_header(struct sk_buff *skb, struct net_device *dev,
 			     unsigned short type, uint8_t daddr)
 {
@@ -1025,7 +1009,6 @@ static int null_build_header(struct sk_buff *skb, struct net_device *dev,
 	return 0;
 }
 
-
 /* the "do nothing" prepare_tx function warns that there's nothing to do. */
 static int null_prepare_tx(struct net_device *dev, struct archdr *pkt,
 			   int length, int bufnum)
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 95a6cf0..02815ff 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -90,7 +90,6 @@ static void rx(struct net_device *dev, int bufnum,
 	netif_rx(skb);
 }
 
-
 /*
  * Create the ARCnet hard/soft headers for cap mode.
  * There aren't any soft headers in cap mode - not even the protocol id.
@@ -130,7 +129,6 @@ static int build_header(struct sk_buff *skb,
 	return hdr_size;	/* success */
 }
 
-
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
@@ -138,7 +136,6 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 	struct arc_hardware *hard = &pkt->hard;
 	int ofs;
 
-
 	/* hard header is not included in packet length */
 	length -= ARC_HDR_SIZE;
 	/* And neither is the cookie field */
diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index d8746ca..c7d3377 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -43,7 +43,6 @@
 
 #define VERSION "arcnet: COM20020 ISA support (by David Woodhouse et al.)\n"
 
-
 /*
  * We cannot (yet) probe for an IO mapped card, although we can check that
  * it's where we were told it was, and even do autoirq.
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index e0f489a..06621e9 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -42,7 +42,6 @@
 
 #include <asm/io.h>
 
-
 #define VERSION "arcnet: COM20020 PCI support\n"
 
 /* Module parameters */
@@ -86,7 +85,6 @@ static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *i
 
 	INIT_LIST_HEAD(&priv->list_dev);
 
-
 	for (i = 0; i < ci->devcount; i++) {
 		struct com20020_pci_channel_map *cm = &ci->chan_map_tbl[i];
 		struct com20020_dev *card;
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index cd2a5ca..c749af6 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -70,7 +70,6 @@ static void com20020_copy_from_card(struct net_device *dev, int bufnum,
 	TIME("insb", count, insb(_MEMDATA, buf, count));
 }
 
-
 static void com20020_copy_to_card(struct net_device *dev, int bufnum,
 				  int offset, void *buf, int count)
 {
@@ -84,7 +83,6 @@ static void com20020_copy_to_card(struct net_device *dev, int bufnum,
 	TIME("outsb", count, outsb(_MEMDATA, buf, count));
 }
 
-
 /* Reset the card and check some basic stuff during the detection stage. */
 int com20020_check(struct net_device *dev)
 {
@@ -242,7 +240,6 @@ int com20020_found(struct net_device *dev, int shared)
 	return 0;
 }
 
-
 /*
  * Do a hardware reset on the card, and set up necessary registers.
  *
@@ -295,22 +292,21 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 	return 0;
 }
 
-
 static void com20020_setmask(struct net_device *dev, int mask)
 {
 	u_int ioaddr = dev->base_addr;
+
 	BUGMSG(D_DURING, "Setting mask to %x at %x\n", mask, ioaddr);
 	AINTMASK(mask);
 }
 
-
 static void com20020_command(struct net_device *dev, int cmd)
 {
 	u_int ioaddr = dev->base_addr;
+
 	ACOMMAND(cmd);
 }
 
-
 static int com20020_status(struct net_device *dev)
 {
 	u_int ioaddr = dev->base_addr;
diff --git a/drivers/net/arcnet/com20020_cs.c b/drivers/net/arcnet/com20020_cs.c
index f687521..2eafb29 100644
--- a/drivers/net/arcnet/com20020_cs.c
+++ b/drivers/net/arcnet/com20020_cs.c
@@ -49,7 +49,6 @@
 
 #define VERSION "arcnet: COM20020 PCMCIA support loaded.\n"
 
-
 static void regdump(struct net_device *dev)
 {
 #ifdef DEBUG
@@ -83,8 +82,6 @@ static void regdump(struct net_device *dev)
 #endif
 }
 
-
-
 /*====================================================================*/
 
 /* Parameters that can be set with 'insmod' */
@@ -304,6 +301,7 @@ static int com20020_resume(struct pcmcia_device *link)
 	if (link->open) {
 		int ioaddr = dev->base_addr;
 		struct arcnet_local *lp = netdev_priv(dev);
+
 		ARCRESET;
 	}
 
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 23ac9ed..11d2d0b 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -37,10 +37,8 @@
 #include <asm/io.h>
 #include <linux/arcdevice.h>
 
-
 #define VERSION "arcnet: COM90xx IO-mapped mode support (by David Woodhouse et el.)\n"
 
-
 /* Internal function declarations */
 
 static int com90io_found(struct net_device *dev);
@@ -53,7 +51,6 @@ static void com90io_copy_to_card(struct net_device *dev, int bufnum, int offset,
 static void com90io_copy_from_card(struct net_device *dev, int bufnum, int offset,
 				   void *buf, int count);
 
-
 /* Handy defines for ARCnet specific stuff */
 
 /* The number of low I/O ports used by the card. */
@@ -78,7 +75,6 @@ static void com90io_copy_from_card(struct net_device *dev, int bufnum, int offse
 #define AINTMASK(msk)	outb((msk), _INTMASK)
 #define SETCONF()	outb((lp->config), _CONFIG)
 
-
 /****************************************************************************
  *                                                                          *
  * IO-mapped operation routines                                             *
@@ -111,7 +107,6 @@ static void put_buffer_byte(struct net_device *dev, unsigned offset, u_char datu
 
 #endif
 
-
 static void get_whole_buffer(struct net_device *dev, unsigned offset, unsigned length, char *dest)
 {
 	int ioaddr = dev->base_addr;
@@ -227,7 +222,6 @@ err_out:
 	return -ENODEV;
 }
 
-
 /* Set up the struct net_device associated with this card.  Called after
  * probing succeeds.
  */
@@ -279,7 +273,6 @@ static int __init com90io_found(struct net_device *dev)
 	return 0;
 }
 
-
 /*
  * Do a hardware reset on the card, and set up necessary registers.
  *
@@ -319,7 +312,6 @@ static int com90io_reset(struct net_device *dev, int really_reset)
 	return 0;
 }
 
-
 static void com90io_command(struct net_device *dev, int cmd)
 {
 	short ioaddr = dev->base_addr;
@@ -327,7 +319,6 @@ static void com90io_command(struct net_device *dev, int cmd)
 	ACOMMAND(cmd);
 }
 
-
 static int com90io_status(struct net_device *dev)
 {
 	short ioaddr = dev->base_addr;
@@ -335,7 +326,6 @@ static int com90io_status(struct net_device *dev)
 	return ASTATUS();
 }
 
-
 static void com90io_setmask(struct net_device *dev, int mask)
 {
 	short ioaddr = dev->base_addr;
@@ -349,7 +339,6 @@ static void com90io_copy_to_card(struct net_device *dev, int bufnum, int offset,
 	TIME("put_whole_buffer", count, put_whole_buffer(dev, bufnum * 512 + offset, count, buf));
 }
 
-
 static void com90io_copy_from_card(struct net_device *dev, int bufnum, int offset,
 				   void *buf, int count)
 {
@@ -369,6 +358,7 @@ MODULE_LICENSE("GPL");
 static int __init com90io_setup(char *s)
 {
 	int ints[4];
+
 	s = get_options(s, 4, ints);
 	if (!ints[0])
 		return 0;
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index a4c5d59..f0f06a2 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -35,10 +35,8 @@
 #include <asm/io.h>
 #include <linux/arcdevice.h>
 
-
 #define VERSION "arcnet: COM90xx chipset support\n"
 
-
 /* Define this to speed up the autoprobe by assuming if only one io port and
  * shmem are left in the list at Stage 5, they must correspond to each
  * other.
@@ -53,7 +51,6 @@
  */
 #undef FAST_PROBE
 
-
 /* Internal function declarations */
 static int com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem *);
 static void com90xx_command(struct net_device *dev, int command);
@@ -97,7 +94,6 @@ static int numcards;
 #define ACOMMAND(cmd)	outb((cmd), _COMMAND)
 #define AINTMASK(msk)	outb((msk), _INTMASK)
 
-
 static int com90xx_skip_probe __initdata = 0;
 
 /* Module parameters */
@@ -308,6 +304,7 @@ static void __init com90xx_probe(void)
 	numprint = -1;
 	for (port = &ports[0]; port < ports + numports; port++) {
 		int found = 0;
+
 		numprint++;
 		numprint %= 8;
 		if (!numprint) {
@@ -552,7 +549,6 @@ err_free_dev:
 	return -EIO;
 }
 
-
 static void com90xx_command(struct net_device *dev, int cmd)
 {
 	short ioaddr = dev->base_addr;
@@ -560,7 +556,6 @@ static void com90xx_command(struct net_device *dev, int cmd)
 	ACOMMAND(cmd);
 }
 
-
 static int com90xx_status(struct net_device *dev)
 {
 	short ioaddr = dev->base_addr;
@@ -568,7 +563,6 @@ static int com90xx_status(struct net_device *dev)
 	return ASTATUS();
 }
 
-
 static void com90xx_setmask(struct net_device *dev, int mask)
 {
 	short ioaddr = dev->base_addr;
@@ -576,7 +570,6 @@ static void com90xx_setmask(struct net_device *dev, int mask)
 	AINTMASK(mask);
 }
 
-
 /*
  * Do a hardware reset on the card, and set up necessary registers.
  *
@@ -625,19 +618,19 @@ static void com90xx_copy_to_card(struct net_device *dev, int bufnum, int offset,
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + bufnum * 512 + offset;
+
 	TIME("memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
 
-
 static void com90xx_copy_from_card(struct net_device *dev, int bufnum, int offset,
 				   void *buf, int count)
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + bufnum * 512 + offset;
+
 	TIME("memcpy_fromio", count, memcpy_fromio(buf, memaddr, count));
 }
 
-
 MODULE_LICENSE("GPL");
 
 static int __init com90xx_init(void)
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index ae1ded2..49d35c9 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -34,7 +34,6 @@
 
 #define VERSION "arcnet: RFC1051 \"simple standard\" (`s') encapsulation support loaded.\n"
 
-
 static __be16 type_trans(struct sk_buff *skb, struct net_device *dev);
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length);
@@ -43,7 +42,6 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum);
 
-
 static struct ArcProto rfc1051_proto =
 {
 	.suffix		= 's',
@@ -56,7 +54,6 @@ static struct ArcProto rfc1051_proto =
 	.ack_tx         = NULL
 };
 
-
 static int __init arcnet_rfc1051_init(void)
 {
 	printk(VERSION);
@@ -120,7 +117,6 @@ static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 	return htons(ETH_P_IP);
 }
 
-
 /* packet receiver */
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
@@ -161,7 +157,6 @@ static void rx(struct net_device *dev, int bufnum,
 	netif_rx(skb);
 }
 
-
 /*
  * Create the ARCnet hard/soft headers for RFC1051.
  */
@@ -188,7 +183,6 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 		return 0;
 	}
 
-
 	/*
 	 * Set the source hardware address.
 	 *
@@ -214,7 +208,6 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 	return hdr_size;	/* success */
 }
 
-
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index bf2a8cb..15f103a 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -34,7 +34,6 @@
 MODULE_LICENSE("GPL");
 #define VERSION "arcnet: RFC1201 \"standard\" (`a') encapsulation support loaded.\n"
 
-
 static __be16 type_trans(struct sk_buff *skb, struct net_device *dev);
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length);
@@ -56,7 +55,6 @@ static struct ArcProto rfc1201_proto =
 	.ack_tx         = NULL
 };
 
-
 static int __init arcnet_rfc1201_init(void)
 {
 	printk(VERSION);
@@ -129,7 +127,6 @@ static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 	return htons(ETH_P_IP);
 }
 
-
 /* packet receiver */
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
@@ -369,7 +366,6 @@ static void rx(struct net_device *dev, int bufnum,
 	}
 }
 
-
 /* Create the ARCnet hard/soft headers for RFC1201. */
 static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
@@ -437,7 +433,6 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 	return hdr_size;
 }
 
-
 static void load_pkt(struct net_device *dev, struct arc_hardware *hard,
 		     struct arc_rfc1201 *soft, int softlen, int bufnum)
 {
@@ -470,7 +465,6 @@ static void load_pkt(struct net_device *dev, struct arc_hardware *hard,
 	lp->lastload_dest = hard->dest;
 }
 
-
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
@@ -478,7 +472,6 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 	const int maxsegsize = XMTU - RFC1201_HDR_SIZE;
 	struct Outgoing *out;
 
-
 	BUGMSG(D_DURING, "prepare_tx: txbufs=%d/%d/%d\n",
 	       lp->next_tx, lp->cur_tx, bufnum);
 
@@ -506,7 +499,6 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 	return 1;		/* done */
 }
 
-
 static int continue_tx(struct net_device *dev, int bufnum)
 {
 	struct arcnet_local *lp = netdev_priv(dev);
diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index ccfd1d2..7868788 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -34,7 +34,6 @@
  */
 #define RECON_THRESHOLD 30
 
-
 /*
  * Define this to the minimum "timeout" value.  If a transmit takes longer
  * than TX_TIMEOUT jiffies, Linux will abort the TX and retry.  On a large
@@ -44,11 +43,9 @@
  */
 #define TX_TIMEOUT (HZ * 200 / 1000)
 
-
 /* Display warnings about the driver being an ALPHA version. */
 #undef ALPHA_WARNING
 
-
 /*
  * Debugging bitflags: each option can be enabled individually.
  *
@@ -106,7 +103,6 @@ extern int arcnet_debug;
 		call;							\
 	}
 
-
 /*
  * Time needed to reset the card - in ms (milliseconds).  This works on my
  * SMC PC100.  I can't find a reference that tells me just how long I
@@ -182,7 +178,6 @@ extern int arcnet_debug;
 #define ARC_CAN_10MBIT  2   /* card uses COM20022, supporting 10MBit,
 				 but default is 2.5MBit. */
 
-
 /* information needed to define an encapsulation driver */
 struct ArcProto {
 	char suffix;		/* a for RFC1201, e for ether-encap, etc. */
@@ -204,7 +199,6 @@ struct ArcProto {
 extern struct ArcProto *arc_proto_map[256], *arc_proto_default,
 	*arc_bcast_proto, *arc_raw_proto;
 
-
 /*
  * "Incoming" is information needed for each address that could be sending
  * to us.  Mostly for partially-received split packets.
@@ -216,7 +210,6 @@ struct Incoming {
 		numpackets;	/* number of packets in split     */
 };
 
-
 /* only needed for RFC1201 */
 struct Outgoing {
 	struct ArcProto *proto;	/* protocol driver that owns this:
@@ -230,7 +223,6 @@ struct Outgoing {
 		numsegs;	/* number of segments */
 };
 
-
 struct arcnet_local {
 	uint8_t config,		/* current value of CONFIG register */
 		timeout,	/* Extended timeout for COM20020 */
@@ -251,7 +243,6 @@ struct arcnet_local {
 	char *card_name;	/* card ident string */
 	int card_flags;		/* special card features */
 
-
 	/* On preemtive and SMB a lock is needed */
 	spinlock_t lock;
 
@@ -314,14 +305,11 @@ struct arcnet_local {
 	void __iomem *mem_start;	/* pointer to ioremap'ed MMIO */
 };
 
-
 #define ARCRESET(x)  (lp->hw.reset(dev, (x)))
 #define ACOMMAND(x)  (lp->hw.command(dev, (x)))
 #define ASTATUS()    (lp->hw.status(dev))
 #define AINTMASK(x)  (lp->hw.intmask(dev, (x)))
 
-
-
 #if ARCNET_DEBUG_MAX & D_SKB
 void arcnet_dump_skb(struct net_device *dev, struct sk_buff *skb, char *desc);
 #else
-- 
2.5.1
