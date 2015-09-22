From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 05/33] arcnet: Coalesce string fragments
Date: Tue, 22 Sep 2015 11:01:46 +0200
Message-ID: <1442912534-10821-6-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37973 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932412AbbIVJCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:39 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Using coalesced strings helps grep for specific messages.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rimi.c     |  9 +++------
 drivers/net/arcnet/arcnet.c       | 23 +++++++++--------------
 drivers/net/arcnet/com20020-isa.c |  3 +--
 drivers/net/arcnet/com90io.c      |  7 +++----
 drivers/net/arcnet/com90xx.c      |  3 +--
 drivers/net/arcnet/rfc1201.c      | 13 +++++--------
 6 files changed, 22 insertions(+), 36 deletions(-)

diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index e8c1501..6eedd6b 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -90,13 +90,11 @@ static int __init arcrimi_probe(struct net_device *dev)
 				dev->dev_addr[0], dev->mem_start, dev->irq);
 
 	if (dev->mem_start <= 0 || dev->irq <= 0) {
-		BUGLVL(D_NORMAL) printk("No autoprobe for RIM I; you "
-		       "must specify the shmem and irq!\n");
+		BUGLVL(D_NORMAL) printk("No autoprobe for RIM I; you must specify the shmem and irq!\n");
 		return -ENODEV;
 	}
 	if (dev->dev_addr[0] == 0) {
-		BUGLVL(D_NORMAL) printk("You need to specify your card's station "
-		       "ID!\n");
+		BUGLVL(D_NORMAL) printk("You need to specify your card's station ID!\n");
 		return -ENODEV;
 	}
 	/*
@@ -225,8 +223,7 @@ static int __init arcrimi_found(struct net_device *dev)
 	/* get and check the station ID from offset 1 in shmem */
 	dev->dev_addr[0] = readb(lp->mem_start + 1);
 
-	BUGMSG(D_NORMAL, "ARCnet RIM I: station %02Xh found at IRQ %d, "
-	       "ShMem %lXh (%ld*%d bytes).\n",
+	BUGMSG(D_NORMAL, "ARCnet RIM I: station %02Xh found at IRQ %d, ShMem %lXh (%ld*%d bytes)\n",
 	       dev->dev_addr[0],
 	       dev->irq, dev->mem_start,
 	 (dev->mem_end - dev->mem_start + 1) / mirror_size, mirror_size);
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 24c0a64..d70efda 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -416,11 +416,9 @@ int arcnet_open(struct net_device *dev)
 		lp->hw.open(dev);
 
 	if (dev->dev_addr[0] == 0)
-		BUGMSG(D_NORMAL, "WARNING!  Station address 00 is reserved "
-		       "for broadcasts!\n");
+		BUGMSG(D_NORMAL, "WARNING!  Station address 00 is reserved for broadcasts!\n");
 	else if (dev->dev_addr[0] == 255)
-		BUGMSG(D_NORMAL, "WARNING!  Station address FF may confuse "
-		       "DOS networking programs!\n");
+		BUGMSG(D_NORMAL, "WARNING!  Station address FF may confuse DOS networking programs!\n");
 
 	BUGMSG(D_DEBUG, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
 	if (ASTATUS() & RESETflag) {
@@ -580,8 +578,8 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 			if (proto->continue_tx &&
 			    proto->continue_tx(dev, txbuf)) {
 				BUGMSG(D_NORMAL,
-				       "bug! continue_tx finished the first time! "
-				       "(proto='%c')\n", proto->suffix);
+				       "bug! continue_tx finished the first time! (proto='%c')\n",
+				       proto->suffix);
 			}
 		}
 		retval = NETDEV_TX_OK;
@@ -779,15 +777,13 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 				if (!(status & TXACKflag)) {
 					if (lp->lasttrans_dest != 0) {
 						BUGMSG(D_EXTRA,
-						       "transmit was not acknowledged! "
-						       "(status=%Xh, dest=%02Xh)\n",
+						       "transmit was not acknowledged! (status=%Xh, dest=%02Xh)\n",
 						       status, lp->lasttrans_dest);
 						dev->stats.tx_errors++;
 						dev->stats.tx_carrier_errors++;
 					} else {
 						BUGMSG(D_DURING,
-						       "broadcast was not acknowledged; that's normal "
-						       "(status=%Xh, dest=%02Xh)\n",
+						       "broadcast was not acknowledged; that's normal (status=%Xh, dest=%02Xh)\n",
 						       status, lp->lasttrans_dest);
 					}
 				}
@@ -948,8 +944,7 @@ static void arcnet_rx(struct net_device *dev, int bufnum)
 		lp->hw.copy_from_card(dev, bufnum, ofs, soft, length);
 	}
 
-	BUGMSG(D_DURING, "Buffer #%d: received packet from %02Xh to %02Xh "
-	       "(%d+4 bytes)\n",
+	BUGMSG(D_DURING, "Buffer #%d: received packet from %02Xh to %02Xh (%d+4 bytes)\n",
 	       bufnum, pkt.hard.source, pkt.hard.dest, length);
 
 	dev->stats.rx_packets++;
@@ -964,8 +959,8 @@ static void arcnet_rx(struct net_device *dev, int bufnum)
 
 			if (oldp != newp) {
 				BUGMSG(D_PROTO,
-				       "got protocol %02Xh; encap for host %02Xh is now '%c'"
-				       " (was '%c')\n", soft->proto, pkt.hard.source,
+				       "got protocol %02Xh; encap for host %02Xh is now '%c' (was '%c')\n",
+				       soft->proto, pkt.hard.source,
 				       newp->suffix, oldp->suffix);
 			}
 		}
diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index c7d3377..b8129360 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -58,8 +58,7 @@ static int __init com20020isa_probe(struct net_device *dev)
 
 	ioaddr = dev->base_addr;
 	if (!ioaddr) {
-		BUGMSG(D_NORMAL, "No autoprobe (yet) for IO mapped cards; you "
-		       "must specify the base address!\n");
+		BUGMSG(D_NORMAL, "No autoprobe (yet) for IO mapped cards; you must specify the base address!\n");
 		return -ENODEV;
 	}
 	if (!request_region(ioaddr, ARCNET_TOTAL_SIZE, "arcnet (COM20020)")) {
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 11d2d0b..1742fa7 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -150,8 +150,7 @@ static int __init com90io_probe(struct net_device *dev)
 	BUGLVL(D_NORMAL) printk("E-mail me if you actually test this driver, please!\n");
 
 	if (!ioaddr) {
-		BUGMSG(D_NORMAL, "No autoprobe for IO mapped cards; you "
-		       "must specify the base address!\n");
+		BUGMSG(D_NORMAL, "No autoprobe for IO mapped cards; you must specify the base address!\n");
 		return -ENODEV;
 	}
 	if (!request_region(ioaddr, ARCNET_TOTAL_SIZE, "com90io probe")) {
@@ -192,8 +191,8 @@ static int __init com90io_probe(struct net_device *dev)
 	outb(0, _ADDR_LO);
 
 	if ((status = inb(_MEMDATA)) != 0xd1) {
-		BUGMSG(D_INIT_REASONS, "Signature byte not found"
-		       " (%Xh instead).\n", status);
+		BUGMSG(D_INIT_REASONS, "Signature byte not found (%Xh instead).\n",
+		       status);
 		goto err_out;
 	}
 	if (!dev->irq) {
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index c16bfde..2e29084 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -525,8 +525,7 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem
 
 	dev->base_addr = ioaddr;
 
-	BUGMSG(D_NORMAL, "COM90xx station %02Xh found at %03lXh, IRQ %d, "
-	       "ShMem %lXh (%ld*%xh).\n",
+	BUGMSG(D_NORMAL, "COM90xx station %02Xh found at %03lXh, IRQ %d, ShMem %lXh (%ld*%xh).\n",
 	       dev->dev_addr[0],
 	       dev->base_addr, dev->irq, dev->mem_start,
 	 (dev->mem_end - dev->mem_start + 1) / mirror_size, mirror_size);
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index 4abb20e..4775017 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -261,8 +261,7 @@ static void rx(struct net_device *dev, int bufnum,
 			BUGMSG(D_RX, "brand new splitpacket (splitflag=%d)\n",
 			       soft->split_flag);
 			if (in->skb) {	/* already assembling one! */
-				BUGMSG(D_EXTRA, "aborting previous (seq=%d) assembly "
-				       "(splitflag=%d, seq=%d)\n",
+				BUGMSG(D_EXTRA, "aborting previous (seq=%d) assembly (splitflag=%d, seq=%d)\n",
 				       in->sequence, soft->split_flag,
 				       soft->sequence);
 				dev->stats.rx_errors++;
@@ -306,8 +305,7 @@ static void rx(struct net_device *dev, int bufnum,
 			 */
 			if (!in->skb) {
 				if (lp->rfc1201.aborted_seq != soft->sequence) {
-					BUGMSG(D_EXTRA, "can't continue split without starting "
-					       "first! (splitflag=%d, seq=%d, aborted=%d)\n",
+					BUGMSG(D_EXTRA, "can't continue split without starting first! (splitflag=%d, seq=%d, aborted=%d)\n",
 					soft->split_flag, soft->sequence,
 					       lp->rfc1201.aborted_seq);
 					dev->stats.rx_errors++;
@@ -326,8 +324,7 @@ static void rx(struct net_device *dev, int bufnum,
 					return;
 				}
 				/* "bad" duplicate, kill reassembly */
-				BUGMSG(D_EXTRA, "out-of-order splitpacket, reassembly "
-				       "(seq=%d) aborted (splitflag=%d, seq=%d)\n",
+				BUGMSG(D_EXTRA, "out-of-order splitpacket, reassembly (seq=%d) aborted (splitflag=%d, seq=%d)\n",
 				       in->sequence, soft->split_flag, soft->sequence);
 				lp->rfc1201.aborted_seq = soft->sequence;
 				dev_kfree_skb_irq(in->skb);
@@ -487,8 +484,8 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		out->numsegs = (out->dataleft + maxsegsize - 1) / maxsegsize;
 		out->segnum = 0;
 
-		BUGMSG(D_DURING, "rfc1201 prep_tx: ready for %d-segment split "
-		       "(%d bytes, seq=%d)\n", out->numsegs, out->length,
+		BUGMSG(D_DURING, "rfc1201 prep_tx: ready for %d-segment split (%d bytes, seq=%d)\n",
+		       out->numsegs, out->length,
 		       pkt->soft.rfc1201.sequence);
 
 		return 0;	/* not done */
-- 
2.5.1
