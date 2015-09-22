From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 04/33] arcnet: Use normal kernel brace style
Date: Tue, 22 Sep 2015 11:01:45 +0200
Message-ID: <1442912534-10821-5-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59315 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932398AbbIVJCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:39 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Move braces normal kernel locations.
Add missing braces.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rawmode.c |  6 +++---
 drivers/net/arcnet/arcnet.c      | 38 +++++++++++++++-----------------------
 drivers/net/arcnet/capmode.c     |  6 +++---
 drivers/net/arcnet/com20020.c    | 15 +++++++--------
 drivers/net/arcnet/com20020_cs.c | 31 +++++++++++--------------------
 drivers/net/arcnet/com90xx.c     |  3 +--
 drivers/net/arcnet/rfc1051.c     | 10 +++++-----
 drivers/net/arcnet/rfc1201.c     | 14 +++++++-------
 8 files changed, 52 insertions(+), 71 deletions(-)

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index 251a98b..500b5bb 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -42,8 +42,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum);
 
-static struct ArcProto rawmode_proto =
-{
+static struct ArcProto rawmode_proto = {
 	.suffix		= 'r',
 	.mtu		= XMTU,
 	.rx		= rx,
@@ -183,8 +182,9 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 	} else if (length > MTU) {
 		hard->offset[0] = 0;
 		hard->offset[1] = ofs = 512 - length - 3;
-	} else
+	} else {
 		hard->offset[0] = ofs = 256 - length;
+	}
 
 	BUGMSG(D_DURING, "prepare_tx: length=%d ofs=%d\n",
 	       length, ofs);
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index bb49753..24c0a64 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -72,8 +72,7 @@ static void arcnet_rx(struct net_device *dev, int bufnum);
 struct ArcProto *arc_proto_map[256], *arc_proto_default,
 	*arc_bcast_proto, *arc_raw_proto;
 
-static struct ArcProto arc_proto_null =
-{
+static struct ArcProto arc_proto_null = {
 	.suffix		= '?',
 	.mtu		= XMTU,
 	.is_ip          = 0,
@@ -264,14 +263,13 @@ static int get_arcbuf(struct net_device *dev)
 		/* already in this function */
 		BUGMSG(D_NORMAL, "get_arcbuf: overlap (%d)!\n",
 		       lp->buf_lock.counter);
-	}
-	else {			/* we can continue */
+	} else {			/* we can continue */
 		if (lp->next_buf >= 5)
 			lp->next_buf -= 5;
 
-		if (lp->next_buf == lp->first_free_buf)
+		if (lp->next_buf == lp->first_free_buf) {
 			BUGMSG(D_NORMAL, "get_arcbuf: BUG: no buffers are available??\n");
-		else {
+		} else {
 			buf = lp->buf_queue[lp->next_buf++];
 			lp->next_buf %= 5;
 		}
@@ -330,7 +328,6 @@ static void arcdev_setup(struct net_device *dev)
 
 	/* New-style flags. */
 	dev->flags = IFF_BROADCAST;
-
 }
 
 struct net_device *alloc_arcdev(const char *name)
@@ -494,8 +491,7 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 		proto = arc_raw_proto;
 		BUGMSG(D_DEBUG, "arc_raw_proto used. proto='%c'\n", proto->suffix);
 		_daddr = daddr ? *(uint8_t *)daddr : 0;
-	}
-	else if (!daddr) {
+	} else if (!daddr) {
 		/*
 		 * if the dest addr isn't provided, we can't choose an encapsulation!
 		 * Store the packet type (eg. ETH_P_IP) for now, and we'll push on a
@@ -509,8 +505,7 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 			BUGMSG(D_NORMAL, "arcnet_header: Yikes!  diff (%d) is not 2!\n",
 			       (int)(skb->network_header - skb->mac_header));
 		return -2;	/* return error -- can't transmit yet! */
-	}
-	else {
+	} else {
 		/* otherwise, we can just add the header as usual. */
 		_daddr = *(uint8_t *)daddr;
 		proto_num = lp->default_proto[_daddr];
@@ -564,9 +559,9 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 	AINTMASK(0);
 	if (lp->next_tx == -1)
 		txbuf = get_arcbuf(dev);
-	else {
+	else
 		txbuf = -1;
-	}
+
 	if (txbuf != -1) {
 		if (proto->prepare_tx(dev, pkt, skb->len, txbuf) &&
 		    !proto->ack_tx) {
@@ -606,9 +601,9 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n", __FILE__, __LINE__, __func__, ASTATUS());
 
 	spin_unlock_irqrestore(&lp->lock, flags);
-	if (freeskb) {
+	if (freeskb)
 		dev_kfree_skb(skb);
-	}
+
 	return retval;		/* no need to try again */
 }
 
@@ -830,8 +825,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 					if (lp->outgoing.proto->continue_tx(dev, txbuf)) {
 						/* that was the last segment */
 						dev->stats.tx_bytes += lp->outgoing.skb->len;
-						if (!lp->outgoing.proto->ack_tx)
-						{
+						if (!lp->outgoing.proto->ack_tx) {
 							dev_kfree_skb_irq(lp->outgoing.skb);
 							lp->outgoing.proto = NULL;
 						}
@@ -908,11 +902,9 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			BUGMSG(D_DURING, "not recon: clearing counters anyway.\n");
 		}
 
-		if (didsomething) {
+		if (didsomething)
 			retval |= IRQ_HANDLED;
-		}
-	}
-	while (--boguscount && didsomething);
+	} while (--boguscount && didsomething);
 
 	BUGMSG(D_DURING, "arcnet_interrupt complete (status=%Xh, count=%d)\n",
 	       ASTATUS(), boguscount);
@@ -949,9 +941,9 @@ static void arcnet_rx(struct net_device *dev, int bufnum)
 	}
 
 	/* get the full header, if possible */
-	if (sizeof(pkt.soft) <= length)
+	if (sizeof(pkt.soft) <= length) {
 		lp->hw.copy_from_card(dev, bufnum, ofs, soft, sizeof(pkt.soft));
-	else {
+	} else {
 		memset(&pkt.soft, 0, sizeof(pkt.soft));
 		lp->hw.copy_from_card(dev, bufnum, ofs, soft, length);
 	}
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 02815ff..36648d3 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -159,8 +159,9 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 	} else if (length > MTU) {
 		hard->offset[0] = 0;
 		hard->offset[1] = ofs = 512 - length - 3;
-	} else
+	} else {
 		hard->offset[0] = ofs = 256 - length;
+	}
 
 	BUGMSG(D_DURING, "prepare_tx: length=%d ofs=%d\n",
 	       length, ofs);
@@ -226,8 +227,7 @@ free_outskb:
 	return 0;
 }
 
-static struct ArcProto capmode_proto =
-{
+static struct ArcProto capmode_proto = {
 	'r',
 	XMTU,
 	0,
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index c749af6..48a45d3 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -41,10 +41,11 @@
 
 #define VERSION "arcnet: COM20020 chipset support (by David Woodhouse et al.)\n"
 
-static char *clockrates[] =
-{"10 Mb/s", "Reserved", "5 Mb/s",
- "2.5 Mb/s", "1.25Mb/s", "625 Kb/s", "312.5 Kb/s",
- "156.25 Kb/s", "Reserved", "Reserved", "Reserved"};
+static char *clockrates[] = {
+	"XXXXXXX", "XXXXXXXX", "XXXXXX",
+	"2.5 Mb/s", "1.25Mb/s", "625 Kb/s", "312.5 Kb/s",
+	"156.25 Kb/s", "Reserved", "Reserved", "Reserved"
+};
 
 static void com20020_command(struct net_device *dev, int command);
 static int com20020_status(struct net_device *dev);
@@ -102,8 +103,7 @@ int com20020_check(struct net_device *dev)
 	SET_SUBADR(SUB_SETUP1);
 	outb(lp->setup, _XREG);
 
-	if (lp->clockm != 0)
-	{
+	if (lp->clockm != 0) {
 		SET_SUBADR(SUB_SETUP2);
 		outb(lp->setup2, _XREG);
 
@@ -196,8 +196,7 @@ int com20020_found(struct net_device *dev, int shared)
 	SET_SUBADR(SUB_SETUP1);
 	outb(lp->setup, _XREG);
 
-	if (lp->card_flags & ARC_CAN_10MBIT)
-	{
+	if (lp->card_flags & ARC_CAN_10MBIT) {
 		SET_SUBADR(SUB_SETUP2);
 		outb(lp->setup2, _XREG);
 
diff --git a/drivers/net/arcnet/com20020_cs.c b/drivers/net/arcnet/com20020_cs.c
index 2eafb29..532410b 100644
--- a/drivers/net/arcnet/com20020_cs.c
+++ b/drivers/net/arcnet/com20020_cs.c
@@ -56,8 +56,7 @@ static void regdump(struct net_device *dev)
 	int count;
 
 	netdev_dbg(dev, "register dump:\n");
-	for (count = ioaddr; count < ioaddr + 16; count++)
-	{
+	for (count = ioaddr; count < ioaddr + 16; count++) {
 		if (!(count % 16))
 			pr_cont("%04X:", count);
 		pr_cont(" %02X", inb(count));
@@ -70,8 +69,7 @@ static void regdump(struct net_device *dev)
 	outb((count >> 8) | RDDATAflag | AUTOINCflag, _ADDR_HI);
 	outb(count & 0xff, _ADDR_LO);
 
-	for (count = 0; count < 256 + 32; count++)
-	{
+	for (count = 0; count < 256 + 32; count++) {
 		if (!(count % 16))
 			pr_cont("%04X:", count);
 
@@ -175,11 +173,9 @@ static void com20020_detach(struct pcmcia_device *link)
 
 	/* Unlink device structure, free bits */
 	dev_dbg(&link->dev, "unlinking...\n");
-	if (link->priv)
-	{
+	if (link->priv) {
 		dev = info->dev;
-		if (dev)
-		{
+		if (dev) {
 			dev_dbg(&link->dev, "kfree...\n");
 			free_netdev(dev);
 		}
@@ -210,21 +206,18 @@ static int com20020_config(struct pcmcia_device *link)
 	i = -ENODEV;
 	link->io_lines = 16;
 
-	if (!link->resource[0]->start)
-	{
-		for (ioaddr = 0x100; ioaddr < 0x400; ioaddr += 0x10)
-		{
+	if (!link->resource[0]->start) {
+		for (ioaddr = 0x100; ioaddr < 0x400; ioaddr += 0x10) {
 			link->resource[0]->start = ioaddr;
 			i = pcmcia_request_io(link);
 			if (i == 0)
 				break;
 		}
-	}
-	else
+	} else {
 		i = pcmcia_request_io(link);
+	}
 
-	if (i != 0)
-	{
+	if (i != 0) {
 		dev_dbg(&link->dev, "requestIO failed totally!\n");
 		goto failed;
 	}
@@ -234,8 +227,7 @@ static int com20020_config(struct pcmcia_device *link)
 
 	dev_dbg(&link->dev, "request IRQ %d\n",
 		link->irq);
-	if (!link->irq)
-	{
+	if (!link->irq) {
 		dev_dbg(&link->dev, "requestIRQ failed totally!\n");
 		goto failed;
 	}
@@ -246,8 +238,7 @@ static int com20020_config(struct pcmcia_device *link)
 	if (ret)
 		goto failed;
 
-	if (com20020_check(dev))
-	{
+	if (com20020_check(dev)) {
 		regdump(dev);
 		goto failed;
 	}
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index f0f06a2..c16bfde 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -112,8 +112,7 @@ static void __init com90xx_probe(void)
 {
 	int count, status, ioaddr, numprint, airq, openparen = 0;
 	unsigned long airqmask;
-	int ports[(0x3f0 - 0x200) / 16 + 1] =
-	{0};
+	int ports[(0x3f0 - 0x200) / 16 + 1] = {	0 };
 	unsigned long *shmems;
 	void __iomem **iomem;
 	int numports, numshmems, *port;
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index 49d35c9..ed7b645 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -42,8 +42,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum);
 
-static struct ArcProto rfc1051_proto =
-{
+static struct ArcProto rfc1051_proto = {
 	.suffix		= 's',
 	.mtu		= XMTU - RFC1051_HDR_SIZE,
 	.is_ip          = 1,
@@ -94,9 +93,9 @@ static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 	skb_reset_mac_header(skb);
 	skb_pull(skb, hdr_size);
 
-	if (pkt->hard.dest == 0)
+	if (pkt->hard.dest == 0) {
 		skb->pkt_type = PACKET_BROADCAST;
-	else if (dev->flags & IFF_PROMISC) {
+	} else if (dev->flags & IFF_PROMISC) {
 		/* if we're not sending to ourselves :) */
 		if (pkt->hard.dest != dev->dev_addr[0])
 			skb->pkt_type = PACKET_OTHERHOST;
@@ -232,8 +231,9 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 	} else if (length > MTU) {
 		hard->offset[0] = 0;
 		hard->offset[1] = ofs = 512 - length - 3;
-	} else
+	} else {
 		hard->offset[0] = ofs = 256 - length;
+	}
 
 	lp->hw.copy_to_card(dev, bufnum, 0, hard, ARC_HDR_SIZE);
 	lp->hw.copy_to_card(dev, bufnum, ofs, &pkt->soft, length);
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index 15f103a..4abb20e 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -43,8 +43,7 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum);
 static int continue_tx(struct net_device *dev, int bufnum);
 
-static struct ArcProto rfc1201_proto =
-{
+static struct ArcProto rfc1201_proto = {
 	.suffix		= 'a',
 	.mtu		= 1500,	/* could be more, but some receivers can't handle it... */
 	.is_ip          = 1,    /* This is for sending IP and ARP packages */
@@ -97,9 +96,9 @@ static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 	skb_reset_mac_header(skb);
 	skb_pull(skb, hdr_size);
 
-	if (pkt->hard.dest == 0)
+	if (pkt->hard.dest == 0) {
 		skb->pkt_type = PACKET_BROADCAST;
-	else if (dev->flags & IFF_PROMISC) {
+	} else if (dev->flags & IFF_PROMISC) {
 		/* if we're not sending to ourselves :) */
 		if (pkt->hard.dest != dev->dev_addr[0])
 			skb->pkt_type = PACKET_OTHERHOST;
@@ -146,9 +145,9 @@ static void rx(struct net_device *dev, int bufnum,
 		ofs = 256 - length;
 
 	if (soft->split_flag == 0xFF) {		/* Exception Packet */
-		if (length >= 4 + RFC1201_HDR_SIZE)
+		if (length >= 4 + RFC1201_HDR_SIZE) {
 			BUGMSG(D_DURING, "compensating for exception packet\n");
-		else {
+		} else {
 			BUGMSG(D_EXTRA, "short RFC1201 exception packet from %02Xh",
 			       saddr);
 			return;
@@ -456,8 +455,9 @@ static void load_pkt(struct net_device *dev, struct arc_hardware *hard,
 		hard->offset[1] = ofs - RFC1201_HDR_SIZE;
 		lp->hw.copy_to_card(dev, bufnum, ofs - RFC1201_HDR_SIZE,
 				    &excsoft, RFC1201_HDR_SIZE);
-	} else
+	} else {
 		hard->offset[0] = ofs = 256 - softlen;
+	}
 
 	lp->hw.copy_to_card(dev, bufnum, 0, hard, ARC_HDR_SIZE);
 	lp->hw.copy_to_card(dev, bufnum, ofs, soft, softlen);
-- 
2.5.1
