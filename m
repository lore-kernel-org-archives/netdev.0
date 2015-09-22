From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 09/33] arcnet: Expand odd BUGLVL macro with if and uses
Date: Tue, 22 Sep 2015 11:01:50 +0200
Message-ID: <1442912534-10821-10-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45284 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932484AbbIVJCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:41 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Don't hide what should be obvious.

Make the macro a simple test instead of using if and test.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rawmode.c  |  3 ++-
 drivers/net/arcnet/arc-rimi.c     | 20 +++++++++-------
 drivers/net/arcnet/arcnet.c       | 29 ++++++++++++-----------
 drivers/net/arcnet/capmode.c      |  9 ++++---
 drivers/net/arcnet/com20020-isa.c |  3 ++-
 drivers/net/arcnet/com20020-pci.c |  3 ++-
 drivers/net/arcnet/com20020.c     |  3 ++-
 drivers/net/arcnet/com90io.c      |  6 +++--
 drivers/net/arcnet/com90xx.c      | 49 +++++++++++++++++++++++++--------------
 drivers/net/arcnet/rfc1051.c      |  3 ++-
 drivers/net/arcnet/rfc1201.c      |  6 +++--
 include/linux/arcdevice.h         | 17 +++++++-------
 12 files changed, 93 insertions(+), 58 deletions(-)

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index efdd8e9..998c835 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -117,7 +117,8 @@ static void rx(struct net_device *dev, int bufnum,
 				      pkt->soft.raw + sizeof(pkt->soft),
 				      length - sizeof(pkt->soft));
 
-	BUGLVL(D_SKB) arcnet_dump_skb(dev, skb, "rx");
+	if (BUGLVL(D_SKB))
+		arcnet_dump_skb(dev, skb, "rx");
 
 	skb->protocol = cpu_to_be16(ETH_P_ARCNET);
 	netif_rx(skb);
diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index c7ab23e..cd47a1b 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -82,18 +82,21 @@ static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offse
  */
 static int __init arcrimi_probe(struct net_device *dev)
 {
-	BUGLVL(D_NORMAL) printk(VERSION);
-	BUGLVL(D_NORMAL) printk("E-mail me if you actually test the RIM I driver, please!\n");
-
-	BUGLVL(D_NORMAL) printk("Given: node %02Xh, shmem %lXh, irq %d\n",
-				dev->dev_addr[0], dev->mem_start, dev->irq);
+	if (BUGLVL(D_NORMAL)) {
+		printk(VERSION);
+		printk("E-mail me if you actually test the RIM I driver, please!\n");
+		printk("Given: node %02Xh, shmem %lXh, irq %d\n",
+		       dev->dev_addr[0], dev->mem_start, dev->irq);
+	}
 
 	if (dev->mem_start <= 0 || dev->irq <= 0) {
-		BUGLVL(D_NORMAL) printk("No autoprobe for RIM I; you must specify the shmem and irq!\n");
+		if (BUGLVL(D_NORMAL))
+			printk("No autoprobe for RIM I; you must specify the shmem and irq!\n");
 		return -ENODEV;
 	}
 	if (dev->dev_addr[0] == 0) {
-		BUGLVL(D_NORMAL) printk("You need to specify your card's station ID!\n");
+		if (BUGLVL(D_NORMAL))
+			printk("You need to specify your card's station ID!\n");
 		return -ENODEV;
 	}
 	/* Grab the memory region at mem_start for MIRROR_SIZE bytes.
@@ -102,7 +105,8 @@ static int __init arcrimi_probe(struct net_device *dev)
 	 * will be taken.
 	 */
 	if (!request_mem_region(dev->mem_start, MIRROR_SIZE, "arcnet (90xx)")) {
-		BUGLVL(D_NORMAL) printk("Card memory already allocated\n");
+		if (BUGLVL(D_NORMAL))
+			printk("Card memory already allocated\n");
 		return -ENODEV;
 	}
 	return arcrimi_found(dev);
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 605b4a7..7a90b8a4 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -117,7 +117,7 @@ static int __init arcnet_init(void)
 	printk("arcnet loaded.\n");
 
 #ifdef ALPHA_WARNING
-	BUGLVL(D_EXTRA) {
+	if (BUGLVL(D_EXTRA)) {
 		printk("arcnet: ***\n"
 		"arcnet: * Read arcnet.txt for important release notes!\n"
 		       "arcnet: *\n"
@@ -132,11 +132,11 @@ static int __init arcnet_init(void)
 	for (count = 0; count < 256; count++)
 		arc_proto_map[count] = arc_proto_default;
 
-	BUGLVL(D_DURING)
-	    printk("arcnet: struct sizes: %Zd %Zd %Zd %Zd %Zd\n",
-		   sizeof(struct arc_hardware), sizeof(struct arc_rfc1201),
-		   sizeof(struct arc_rfc1051), sizeof(struct arc_eth_encap),
-		   sizeof(struct archdr));
+	if (BUGLVL(D_DURING))
+		printk("arcnet: struct sizes: %Zd %Zd %Zd %Zd %Zd\n",
+		       sizeof(struct arc_hardware), sizeof(struct arc_rfc1201),
+		       sizeof(struct arc_rfc1051), sizeof(struct arc_eth_encap),
+		       sizeof(struct archdr));
 
 	return 0;
 }
@@ -235,7 +235,7 @@ static void release_arcbuf(struct net_device *dev, int bufnum)
 	lp->buf_queue[lp->first_free_buf++] = bufnum;
 	lp->first_free_buf %= 5;
 
-	BUGLVL(D_DURING) {
+	if (BUGLVL(D_DURING)) {
 		BUGMSG(D_DURING, "release_arcbuf: freed #%d; buffer queue is now: ",
 		       bufnum);
 		for (i = lp->next_buf; i != lp->first_free_buf; i = (i + 1) % 5)
@@ -268,7 +268,7 @@ static int get_arcbuf(struct net_device *dev)
 		}
 	}
 
-	BUGLVL(D_DURING) {
+	if (BUGLVL(D_DURING)) {
 		BUGMSG(D_DURING, "get_arcbuf: got #%d; buffer queue is now: ", buf);
 		for (i = lp->next_buf; i != lp->first_free_buf; i = (i + 1) % 5)
 			BUGMSG2(D_DURING, "#%d ", lp->buf_queue[i]);
@@ -356,7 +356,7 @@ int arcnet_open(struct net_device *dev)
 	if (!try_module_get(lp->hw.owner))
 		return -ENODEV;
 
-	BUGLVL(D_PROTO) {
+	if (BUGLVL(D_PROTO)) {
 		BUGMSG(D_PROTO, "protocol map (default is '%c'): ",
 		       arc_proto_default->suffix);
 		for (count = 0; count < 256; count++)
@@ -531,7 +531,8 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 
 	BUGMSG(D_SKB_SIZE, "skb: transmitting %d bytes to %02X\n",
 	       skb->len, pkt->hard.dest);
-	BUGLVL(D_SKB) arcnet_dump_skb(dev, skb, "tx");
+	if (BUGLVL(D_SKB))
+		arcnet_dump_skb(dev, skb, "tx");
 
 	/* fits in one packet? */
 	if (skb->len - ARC_HDR_SIZE > XMTU && !proto->continue_tx) {
@@ -609,7 +610,8 @@ static int go_tx(struct net_device *dev)
 	if (lp->cur_tx != -1 || lp->next_tx == -1)
 		return 0;
 
-	BUGLVL(D_TX) arcnet_dump_packet(dev, lp->next_tx, "go_tx", 0);
+	if (BUGLVL(D_TX))
+		arcnet_dump_packet(dev, lp->next_tx, "go_tx", 0);
 
 	lp->cur_tx = lp->next_tx;
 	lp->next_tx = -1;
@@ -822,7 +824,8 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 		}
 		/* now process the received packet, if any */
 		if (recbuf != -1) {
-			BUGLVL(D_RX) arcnet_dump_packet(dev, recbuf, "rx irq", 0);
+			if (BUGLVL(D_RX))
+				arcnet_dump_packet(dev, recbuf, "rx irq", 0);
 
 			arcnet_rx(dev, recbuf);
 			release_arcbuf(dev, recbuf);
@@ -938,7 +941,7 @@ static void arcnet_rx(struct net_device *dev, int bufnum)
 
 	/* call the right receiver for the protocol */
 	if (arc_proto_map[soft->proto]->is_ip) {
-		BUGLVL(D_PROTO) {
+		if (BUGLVL(D_PROTO)) {
 			struct ArcProto
 			*oldp = arc_proto_map[lp->default_proto[pkt.hard.source]],
 			*newp = arc_proto_map[soft->proto];
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 8391324..e7ec907 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -84,7 +84,8 @@ static void rx(struct net_device *dev, int bufnum,
 				      + sizeof(int),
 				      length - sizeof(pkt->soft));
 
-	BUGLVL(D_SKB) arcnet_dump_skb(dev, skb, "rx");
+	if (BUGLVL(D_SKB))
+		arcnet_dump_skb(dev, skb, "rx");
 
 	skb->protocol = cpu_to_be16(ETH_P_ARCNET);
 	netif_rx(skb);
@@ -190,7 +191,8 @@ static int ack_tx(struct net_device *dev, int acked)
 	BUGMSG(D_DURING, "capmode: ack_tx: protocol: %x: result: %d\n",
 	       lp->outgoing.skb->protocol, acked);
 
-	BUGLVL(D_SKB) arcnet_dump_skb(dev, lp->outgoing.skb, "ack_tx");
+	if (BUGLVL(D_SKB))
+		arcnet_dump_skb(dev, lp->outgoing.skb, "ack_tx");
 
 	/* Now alloc a skb to send back up through the layers: */
 	ackskb = alloc_skb(length + ARC_HDR_SIZE, GFP_ATOMIC);
@@ -216,7 +218,8 @@ static int ack_tx(struct net_device *dev, int acked)
 
 	ackskb->protocol = cpu_to_be16(ETH_P_ARCNET);
 
-	BUGLVL(D_SKB) arcnet_dump_skb(dev, ackskb, "ack_tx_recv");
+	if (BUGLVL(D_SKB))
+		arcnet_dump_skb(dev, ackskb, "ack_tx_recv");
 	netif_rx(ackskb);
 
 free_outskb:
diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index 6e38a19..af87c74 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -53,7 +53,8 @@ static int __init com20020isa_probe(struct net_device *dev)
 	struct arcnet_local *lp = netdev_priv(dev);
 	int err;
 
-	BUGLVL(D_NORMAL) printk(VERSION);
+	if (BUGLVL(D_NORMAL))
+		printk(VERSION);
 
 	ioaddr = dev->base_addr;
 	if (!ioaddr) {
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 72334b5..c8184de 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -402,7 +402,8 @@ static struct pci_driver com20020pci_driver = {
 
 static int __init com20020pci_init(void)
 {
-	BUGLVL(D_NORMAL) printk(VERSION);
+	if (BUGLVL(D_NORMAL))
+		printk(VERSION);
 	return pci_register_driver(&com20020pci_driver);
 }
 
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 6369727..3170e8e 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -365,7 +365,8 @@ MODULE_LICENSE("GPL");
 
 static int __init com20020_module_init(void)
 {
-	BUGLVL(D_NORMAL) printk(VERSION);
+	if (BUGLVL(D_NORMAL))
+		printk(VERSION);
 	return 0;
 }
 
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 6ec36f9..33a8531 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -145,8 +145,10 @@ static int __init com90io_probe(struct net_device *dev)
 	int ioaddr = dev->base_addr, status;
 	unsigned long airqmask;
 
-	BUGLVL(D_NORMAL) printk(VERSION);
-	BUGLVL(D_NORMAL) printk("E-mail me if you actually test this driver, please!\n");
+	if (BUGLVL(D_NORMAL)) {
+		printk(VERSION);
+		printk("E-mail me if you actually test this driver, please!\n");
+	}
 
 	if (!ioaddr) {
 		BUGMSG(D_NORMAL, "No autoprobe for IO mapped cards; you must specify the base address!\n");
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index 4781cd6..b5e1c19 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -133,7 +133,8 @@ static void __init com90xx_probe(void)
 		return;
 	}
 
-	BUGLVL(D_NORMAL) printk(VERSION);
+	if (BUGLVL(D_NORMAL))
+		printk(VERSION);
 
 	/* set up the arrays where we'll store the possible probe addresses */
 	numports = numshmems = 0;
@@ -166,14 +167,16 @@ static void __init com90xx_probe(void)
 		if (!request_region(*port, ARCNET_TOTAL_SIZE, "arcnet (90xx)")) {
 			BUGMSG2(D_INIT_REASONS, "(request_region)\n");
 			BUGMSG2(D_INIT_REASONS, "S1: ");
-			BUGLVL(D_INIT_REASONS) numprint = 0;
+			if (BUGLVL(D_INIT_REASONS))
+				numprint = 0;
 			*port-- = ports[--numports];
 			continue;
 		}
 		if (ASTATUS() == 0xFF) {
 			BUGMSG2(D_INIT_REASONS, "(empty)\n");
 			BUGMSG2(D_INIT_REASONS, "S1: ");
-			BUGLVL(D_INIT_REASONS) numprint = 0;
+			if (BUGLVL(D_INIT_REASONS))
+				numprint = 0;
 			release_region(*port, ARCNET_TOTAL_SIZE);
 			*port-- = ports[--numports];
 			continue;
@@ -182,7 +185,8 @@ static void __init com90xx_probe(void)
 
 		BUGMSG2(D_INIT_REASONS, "\n");
 		BUGMSG2(D_INIT_REASONS, "S1: ");
-		BUGLVL(D_INIT_REASONS) numprint = 0;
+		if (BUGLVL(D_INIT_REASONS))
+			numprint = 0;
 	}
 	BUGMSG2(D_INIT, "\n");
 
@@ -227,21 +231,24 @@ static void __init com90xx_probe(void)
 		if (!request_mem_region(*p, MIRROR_SIZE, "arcnet (90xx)")) {
 			BUGMSG2(D_INIT_REASONS, "(request_mem_region)\n");
 			BUGMSG2(D_INIT_REASONS, "Stage 3: ");
-			BUGLVL(D_INIT_REASONS) numprint = 0;
+			if (BUGLVL(D_INIT_REASONS))
+				numprint = 0;
 			goto out;
 		}
 		base = ioremap(*p, MIRROR_SIZE);
 		if (!base) {
 			BUGMSG2(D_INIT_REASONS, "(ioremap)\n");
 			BUGMSG2(D_INIT_REASONS, "Stage 3: ");
-			BUGLVL(D_INIT_REASONS) numprint = 0;
+			if (BUGLVL(D_INIT_REASONS))
+				numprint = 0;
 			goto out1;
 		}
 		if (readb(base) != TESTvalue) {
 			BUGMSG2(D_INIT_REASONS, "(%02Xh != %02Xh)\n",
 				readb(base), TESTvalue);
 			BUGMSG2(D_INIT_REASONS, "S3: ");
-			BUGLVL(D_INIT_REASONS) numprint = 0;
+			if (BUGLVL(D_INIT_REASONS))
+				numprint = 0;
 			goto out2;
 		}
 		/* By writing 0x42 to the TESTvalue location, we also make
@@ -257,7 +264,8 @@ static void __init com90xx_probe(void)
 		}
 		BUGMSG2(D_INIT_REASONS, "\n");
 		BUGMSG2(D_INIT_REASONS, "S3: ");
-		BUGLVL(D_INIT_REASONS) numprint = 0;
+		if (BUGLVL(D_INIT_REASONS))
+			numprint = 0;
 		iomem[index] = base;
 		continue;
 	out2:
@@ -319,7 +327,8 @@ static void __init com90xx_probe(void)
 		    != (NORXflag | RECONflag | TXFREEflag | RESETflag)) {
 			BUGMSG2(D_INIT_REASONS, "(status=%Xh)\n", status);
 			BUGMSG2(D_INIT_REASONS, "S5: ");
-			BUGLVL(D_INIT_REASONS) numprint = 0;
+			if (BUGLVL(D_INIT_REASONS))
+				numprint = 0;
 			release_region(*port, ARCNET_TOTAL_SIZE);
 			*port-- = ports[--numports];
 			continue;
@@ -330,7 +339,8 @@ static void __init com90xx_probe(void)
 			BUGMSG2(D_INIT_REASONS, " (eternal reset, status=%Xh)\n",
 				status);
 			BUGMSG2(D_INIT_REASONS, "S5: ");
-			BUGLVL(D_INIT_REASONS) numprint = 0;
+			if (BUGLVL(D_INIT_REASONS))
+				numprint = 0;
 			release_region(*port, ARCNET_TOTAL_SIZE);
 			*port-- = ports[--numports];
 			continue;
@@ -352,7 +362,8 @@ static void __init com90xx_probe(void)
 			if (airq <= 0) {
 				BUGMSG2(D_INIT_REASONS, "(airq=%d)\n", airq);
 				BUGMSG2(D_INIT_REASONS, "S5: ");
-				BUGLVL(D_INIT_REASONS) numprint = 0;
+				if (BUGLVL(D_INIT_REASONS))
+					numprint = 0;
 				release_region(*port, ARCNET_TOTAL_SIZE);
 				*port-- = ports[--numports];
 				continue;
@@ -406,16 +417,20 @@ static void __init com90xx_probe(void)
 		}
 
 		if (openparen) {
-			BUGLVL(D_INIT) printk("no matching shmem)\n");
-			BUGLVL(D_INIT_REASONS) printk("S5: ");
-			BUGLVL(D_INIT_REASONS) numprint = 0;
+			if (BUGLVL(D_INIT))
+				printk("no matching shmem)\n");
+			if (BUGLVL(D_INIT_REASONS)) {
+				printk("S5: ");
+				numprint = 0;
+			}
 		}
 		if (!found)
 			release_region(*port, ARCNET_TOTAL_SIZE);
 		*port-- = ports[--numports];
 	}
 
-	BUGLVL(D_INIT_REASONS) printk("\n");
+	if (BUGLVL(D_INIT_REASONS))
+		printk("\n");
 
 	/* Now put back TESTvalue on all leftover shmems. */
 	for (index = 0; index < numshmems; index++) {
@@ -603,8 +618,8 @@ static int com90xx_reset(struct net_device *dev, int really_reset)
 	ACOMMAND(CONFIGcmd | EXTconf);
 
 	/* clean out all the memory to make debugging make more sense :) */
-	BUGLVL(D_DURING)
-	    memset_io(lp->mem_start, 0x42, 2048);
+	if (BUGLVL(D_DURING))
+		memset_io(lp->mem_start, 0x42, 2048);
 
 	/* done!  return success. */
 	return 0;
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index e78b765..824d71f 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -149,7 +149,8 @@ static void rx(struct net_device *dev, int bufnum,
 				      pkt->soft.raw + sizeof(pkt->soft),
 				      length - sizeof(pkt->soft));
 
-	BUGLVL(D_SKB) arcnet_dump_skb(dev, skb, "rx");
+	if (BUGLVL(D_SKB))
+		arcnet_dump_skb(dev, skb, "rx");
 
 	skb->protocol = type_trans(skb, dev);
 	netif_rx(skb);
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index 4ebfbcb..d052976 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -221,7 +221,8 @@ static void rx(struct net_device *dev, int bufnum,
 				dev->stats.rx_crc_errors++;
 			}
 		}
-		BUGLVL(D_SKB) arcnet_dump_skb(dev, skb, "rx");
+		if (BUGLVL(D_SKB))
+			arcnet_dump_skb(dev, skb, "rx");
 
 		skb->protocol = type_trans(skb, dev);
 		netif_rx(skb);
@@ -353,7 +354,8 @@ static void rx(struct net_device *dev, int bufnum,
 			       skb->len, pkt->hard.source);
 			BUGMSG(D_SKB_SIZE, "skb: received %d bytes from %02X (split)\n",
 			       skb->len, pkt->hard.source);
-			BUGLVL(D_SKB) arcnet_dump_skb(dev, skb, "rx");
+			if (BUGLVL(D_SKB))
+				arcnet_dump_skb(dev, skb, "rx");
 
 			skb->protocol = type_trans(skb, dev);
 			netif_rx(skb);
diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index ad61020..f07c663 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -78,13 +78,12 @@
 #endif
 extern int arcnet_debug;
 
-#define BUGLVL_TEST(x)	((x) & ARCNET_DEBUG_MAX & arcnet_debug)
-#define BUGLVL(x)	if (BUGLVL_TEST(x))
+#define BUGLVL(x)	((x) & ARCNET_DEBUG_MAX & arcnet_debug)
 
 /* macros to simplify debug checking */
 #define BUGMSG(x, fmt, ...)						\
 do {									\
-	if (BUGLVL_TEST(x))						\
+	if (BUGLVL(x))						\
 		printk("%s%6s: " fmt,					\
 		       (x) == D_NORMAL	? KERN_WARNING :		\
 		       (x) < D_DURING ? KERN_INFO : KERN_DEBUG,		\
@@ -93,12 +92,14 @@ do {									\
 
 #define BUGMSG2(x, fmt, ...)						\
 do {									\
-	if (BUGLVL_TEST(x))						\
+	if (BUGLVL(x))						\
 		printk(fmt, ##__VA_ARGS__);				\
 } while (0)
 
 /* see how long a function call takes to run, expressed in CPU cycles */
-#define TIME(name, bytes, call) BUGLVL(D_TIMING) {			\
+#define TIME(name, bytes, call)						\
+do {									\
+	if (BUGLVL(D_TIMING)) {						\
 		unsigned long _x, _y;					\
 		_x = get_cycles();					\
 		call;							\
@@ -108,10 +109,10 @@ do {									\
 		       "%lu Kbytes/100Mcycle\n",			\
 		       name, bytes, _y - _x,				\
 		       100000000 / 1024 * bytes / (_y - _x + 1));	\
-	}								\
-	else {								\
+	} else {							\
 		call;							\
-	}
+	}								\
+} while (0)
 
 /*
  * Time needed to reset the card - in ms (milliseconds).  This works on my
-- 
2.5.1
