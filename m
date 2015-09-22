From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 17/33] arcnet: Wrap some long lines
Date: Tue, 22 Sep 2015 11:01:58 +0200
Message-ID: <1442912534-10821-18-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42793 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932559AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Just neatening.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arc-rawmode.c  |  3 ++-
 drivers/net/arcnet/arc-rimi.c     | 11 ++++++-----
 drivers/net/arcnet/arcnet.c       | 10 +++++++---
 drivers/net/arcnet/capmode.c      |  3 ++-
 drivers/net/arcnet/com20020-pci.c |  3 ++-
 drivers/net/arcnet/com20020.c     | 14 ++++++++------
 drivers/net/arcnet/com90io.c      | 31 +++++++++++++++++++------------
 drivers/net/arcnet/com90xx.c      | 28 +++++++++++++++++-----------
 drivers/net/arcnet/rfc1051.c      |  3 ++-
 drivers/net/arcnet/rfc1201.c      | 15 ++++++++++-----
 include/linux/arcdevice.h         | 12 ++++++------
 11 files changed, 81 insertions(+), 52 deletions(-)

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index 40035ee..59b3083 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -165,7 +165,8 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 	arc_printk(D_DURING, dev, "prepare_tx: txbufs=%d/%d/%d\n",
 		   lp->next_tx, lp->cur_tx, bufnum);
 
-	length -= ARC_HDR_SIZE;	/* hard header is not included in packet length */
+	/* hard header is not included in packet length */
+	length -= ARC_HDR_SIZE;
 
 	if (length > XMTU) {
 		/* should never happen! other people already check for this. */
diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index 7360214..8fa5eb4 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -49,8 +49,8 @@ static void arcrimi_setmask(struct net_device *dev, int mask);
 static int arcrimi_reset(struct net_device *dev, int really_reset);
 static void arcrimi_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count);
-static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offset,
-				   void *buf, int count);
+static void arcrimi_copy_from_card(struct net_device *dev, int bufnum,
+				   int offset, void *buf, int count);
 
 /* Handy defines for ARCnet specific stuff */
 
@@ -215,7 +215,8 @@ static int __init arcrimi_found(struct net_device *dev)
 		goto err_free_irq;
 	}
 
-	lp->mem_start = ioremap(dev->mem_start, dev->mem_end - dev->mem_start + 1);
+	lp->mem_start = ioremap(dev->mem_start,
+				dev->mem_end - dev->mem_start + 1);
 	if (!lp->mem_start) {
 		arc_printk(D_NORMAL, dev, "Can't remap device memory!\n");
 		goto err_release_mem;
@@ -307,8 +308,8 @@ static void arcrimi_copy_to_card(struct net_device *dev, int bufnum, int offset,
 	TIME(dev, "memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
 
-static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offset,
-				   void *buf, int count)
+static void arcrimi_copy_from_card(struct net_device *dev, int bufnum,
+				   int offset, void *buf, int count)
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + 0x800 + bufnum * 512 + offset;
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index a9535ec..00074e7 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -759,7 +759,8 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 		if ((status & lp->intmask & TXFREEflag) || lp->timed_out) {
 			lp->intmask &= ~(TXFREEflag | EXCNAKflag);
 
-			arc_printk(D_DURING, dev, "TX IRQ (stat=%Xh)\n", status);
+			arc_printk(D_DURING, dev, "TX IRQ (stat=%Xh)\n",
+				   status);
 
 			if (lp->cur_tx != -1 && !lp->timed_out) {
 				if (!(status & TXACKflag)) {
@@ -804,7 +805,8 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 			go_tx(dev);
 
 			/* continue a split packet, if any */
-			if (lp->outgoing.proto && lp->outgoing.proto->continue_tx) {
+			if (lp->outgoing.proto &&
+			    lp->outgoing.proto->continue_tx) {
 				int txbuf = get_arcbuf(dev);
 
 				if (txbuf != -1) {
@@ -874,7 +876,9 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 					arc_printk(D_NORMAL, dev, "many reconfigurations detected: cabling problem?\n");
 				} else if (!lp->network_down &&
 					   lp->last_recon - lp->first_recon > HZ * 60) {
-					/* reset counters if we've gone for over a minute. */
+					/* reset counters if we've gone for
+					 *  over a minute.
+					 */
 					lp->first_recon = lp->last_recon;
 					lp->num_recons = 1;
 				}
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index a898647..46a76dc 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -222,7 +222,8 @@ static int ack_tx(struct net_device *dev, int acked)
 
 free_outskb:
 	dev_kfree_skb_irq(lp->outgoing.skb);
-	lp->outgoing.proto = NULL; /* We are always finished when in this protocol */
+	lp->outgoing.proto = NULL;
+			/* We are always finished when in this protocol */
 
 	return 0;
 }
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index fc6809b..a28887d 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -64,7 +64,8 @@ MODULE_LICENSE("GPL");
 
 static void com20020pci_remove(struct pci_dev *pdev);
 
-static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
+static int com20020pci_probe(struct pci_dev *pdev,
+			     const struct pci_device_id *id)
 {
 	struct com20020_pci_card_info *ci;
 	struct net_device *dev;
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index bea3862..00f910c 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -192,8 +192,9 @@ int com20020_found(struct net_device *dev, int shared)
 	lp->hw.copy_from_card = com20020_copy_from_card;
 	lp->hw.close = com20020_close;
 
+	/* FIXME: do this some other way! */
 	if (!dev->dev_addr[0])
-		dev->dev_addr[0] = inb(ioaddr + BUS_ALIGN * 8);	/* FIXME: do this some other way! */
+		dev->dev_addr[0] = inb(ioaddr + BUS_ALIGN * 8);
 
 	SET_SUBADR(SUB_SETUP1);
 	outb(lp->setup, _XREG);
@@ -269,7 +270,8 @@ static int com20020_reset(struct net_device *dev, int really_reset)
 	if (really_reset) {
 		/* reset the card */
 		ARCRESET;
-		mdelay(RESETtime * 2);	/* COM20020 seems to be slower sometimes */
+		mdelay(RESETtime * 2);
+				/* COM20020 seems to be slower sometimes */
 	}
 	/* clear flags & end reset */
 	arc_printk(D_DEBUG, dev, "%s: %d: %s\n", __FILE__, __LINE__, __func__);
@@ -338,15 +340,15 @@ static void com20020_set_mc_list(struct net_device *dev)
 	struct arcnet_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
-	if ((dev->flags & IFF_PROMISC) && (dev->flags & IFF_UP)) {	/* Enable promiscuous mode */
+	if ((dev->flags & IFF_PROMISC) && (dev->flags & IFF_UP)) {
+		/* Enable promiscuous mode */
 		if (!(lp->setup & PROMISCset))
 			arc_printk(D_NORMAL, dev, "Setting promiscuous flag...\n");
 		SET_SUBADR(SUB_SETUP1);
 		lp->setup |= PROMISCset;
 		outb(lp->setup, _XREG);
-	} else
+	} else {
 		/* Disable promiscuous mode, use normal mode */
-	{
 		if ((lp->setup & PROMISCset))
 			arc_printk(D_NORMAL, dev, "Resetting promiscuous flag...\n");
 		SET_SUBADR(SUB_SETUP1);
@@ -370,7 +372,7 @@ MODULE_LICENSE("GPL");
 static int __init com20020_module_init(void)
 {
 	if (BUGLVL(D_NORMAL))
-		pr_info("%s\n", "COM20020 chipset support (by David Woodhouse et al.)\n");
+		pr_info("%s\n", "COM20020 chipset support (by David Woodhouse et al.)");
 	return 0;
 }
 
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 11bc589..9e779a53 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -49,8 +49,8 @@ static void com90io_setmask(struct net_device *dev, int mask);
 static int com90io_reset(struct net_device *dev, int really_reset);
 static void com90io_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count);
-static void com90io_copy_from_card(struct net_device *dev, int bufnum, int offset,
-				   void *buf, int count);
+static void com90io_copy_from_card(struct net_device *dev, int bufnum,
+				   int offset, void *buf, int count);
 
 /* Handy defines for ARCnet specific stuff */
 
@@ -96,7 +96,8 @@ static u_char get_buffer_byte(struct net_device *dev, unsigned offset)
 }
 
 #ifdef ONE_AT_A_TIME_TX
-static void put_buffer_byte(struct net_device *dev, unsigned offset, u_char datum)
+static void put_buffer_byte(struct net_device *dev, unsigned offset,
+			    u_char datum)
 {
 	int ioaddr = dev->base_addr;
 
@@ -108,7 +109,8 @@ static void put_buffer_byte(struct net_device *dev, unsigned offset, u_char datu
 
 #endif
 
-static void get_whole_buffer(struct net_device *dev, unsigned offset, unsigned length, char *dest)
+static void get_whole_buffer(struct net_device *dev, unsigned offset,
+			     unsigned length, char *dest)
 {
 	int ioaddr = dev->base_addr;
 
@@ -123,7 +125,8 @@ static void get_whole_buffer(struct net_device *dev, unsigned offset, unsigned l
 #endif
 }
 
-static void put_whole_buffer(struct net_device *dev, unsigned offset, unsigned length, char *dest)
+static void put_whole_buffer(struct net_device *dev, unsigned offset,
+			     unsigned length, char *dest)
 {
 	int ioaddr = dev->base_addr;
 
@@ -237,12 +240,14 @@ static int __init com90io_found(struct net_device *dev)
 	int err;
 
 	/* Reserve the irq */
-	if (request_irq(dev->irq, arcnet_interrupt, 0, "arcnet (COM90xx-IO)", dev)) {
+	if (request_irq(dev->irq, arcnet_interrupt, 0,
+			"arcnet (COM90xx-IO)", dev)) {
 		arc_printk(D_NORMAL, dev, "Can't get IRQ %d!\n", dev->irq);
 		return -ENODEV;
 	}
 	/* Reserve the I/O region */
-	if (!request_region(dev->base_addr, ARCNET_TOTAL_SIZE, "arcnet (COM90xx-IO)")) {
+	if (!request_region(dev->base_addr, ARCNET_TOTAL_SIZE,
+			    "arcnet (COM90xx-IO)")) {
 		free_irq(dev->irq, dev);
 		return -EBUSY;
 	}
@@ -338,15 +343,15 @@ static void com90io_setmask(struct net_device *dev, int mask)
 	AINTMASK(mask);
 }
 
-static void com90io_copy_to_card(struct net_device *dev, int bufnum, int offset,
-				 void *buf, int count)
+static void com90io_copy_to_card(struct net_device *dev, int bufnum,
+				 int offset, void *buf, int count)
 {
 	TIME(dev, "put_whole_buffer", count,
 	     put_whole_buffer(dev, bufnum * 512 + offset, count, buf));
 }
 
-static void com90io_copy_from_card(struct net_device *dev, int bufnum, int offset,
-				   void *buf, int count)
+static void com90io_copy_from_card(struct net_device *dev, int bufnum,
+				   int offset, void *buf, int count)
 {
 	TIME(dev, "get_whole_buffer", count,
 	     get_whole_buffer(dev, bufnum * 512 + offset, count, buf));
@@ -418,7 +423,9 @@ static void __exit com90io_exit(void)
 
 	unregister_netdev(dev);
 
-	/* Set the thing back to MMAP mode, in case the old driver is loaded later */
+	/* In case the old driver is loaded later,
+	 * set the thing back to MMAP mode
+	 */
 	outb((inb(_CONFIG) & ~IOMAPflag), _CONFIG);
 
 	free_irq(dev->irq, dev);
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index 50c346b..62100ac 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -60,8 +60,8 @@ static void com90xx_setmask(struct net_device *dev, int mask);
 static int com90xx_reset(struct net_device *dev, int really_reset);
 static void com90xx_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count);
-static void com90xx_copy_from_card(struct net_device *dev, int bufnum, int offset,
-				   void *buf, int count);
+static void com90xx_copy_from_card(struct net_device *dev, int bufnum,
+				   int offset, void *buf, int count);
 
 /* Known ARCnet cards */
 
@@ -165,7 +165,8 @@ static void __init com90xx_probe(void)
 
 		ioaddr = *port;
 
-		if (!request_region(*port, ARCNET_TOTAL_SIZE, "arcnet (90xx)")) {
+		if (!request_region(*port, ARCNET_TOTAL_SIZE,
+				    "arcnet (90xx)")) {
 			arc_cont(D_INIT_REASONS, "(request_region)\n");
 			arc_cont(D_INIT_REASONS, "S1: ");
 			if (BUGLVL(D_INIT_REASONS))
@@ -467,7 +468,8 @@ static int check_mirror(unsigned long addr, size_t size)
 /* Set up the struct net_device associated with this card.  Called after
  * probing succeeds.
  */
-static int __init com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem *p)
+static int __init com90xx_found(int ioaddr, int airq, u_long shmem,
+				void __iomem *p)
 {
 	struct net_device *dev = NULL;
 	struct arcnet_local *lp;
@@ -511,7 +513,9 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem
 	iounmap(p);
 	release_mem_region(shmem, MIRROR_SIZE);
 
-	if (!request_mem_region(dev->mem_start, dev->mem_end - dev->mem_start + 1, "arcnet (90xx)"))
+	if (!request_mem_region(dev->mem_start,
+				dev->mem_end - dev->mem_start + 1,
+				"arcnet (90xx)"))
 		goto err_free_dev;
 
 	/* reserve the irq */
@@ -530,7 +534,8 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem
 	lp->hw.owner = THIS_MODULE;
 	lp->hw.copy_to_card = com90xx_copy_to_card;
 	lp->hw.copy_from_card = com90xx_copy_from_card;
-	lp->mem_start = ioremap(dev->mem_start, dev->mem_end - dev->mem_start + 1);
+	lp->mem_start = ioremap(dev->mem_start,
+				dev->mem_end - dev->mem_start + 1);
 	if (!lp->mem_start) {
 		arc_printk(D_NORMAL, dev, "Can't remap device memory!\n");
 		goto err_free_irq;
@@ -627,8 +632,8 @@ static int com90xx_reset(struct net_device *dev, int really_reset)
 	return 0;
 }
 
-static void com90xx_copy_to_card(struct net_device *dev, int bufnum, int offset,
-				 void *buf, int count)
+static void com90xx_copy_to_card(struct net_device *dev, int bufnum,
+				 int offset, void *buf, int count)
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + bufnum * 512 + offset;
@@ -636,8 +641,8 @@ static void com90xx_copy_to_card(struct net_device *dev, int bufnum, int offset,
 	TIME(dev, "memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
 
-static void com90xx_copy_from_card(struct net_device *dev, int bufnum, int offset,
-				   void *buf, int count)
+static void com90xx_copy_from_card(struct net_device *dev, int bufnum,
+				   int offset, void *buf, int count)
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + bufnum * 512 + offset;
@@ -671,7 +676,8 @@ static void __exit com90xx_exit(void)
 		free_irq(dev->irq, dev);
 		iounmap(lp->mem_start);
 		release_region(dev->base_addr, ARCNET_TOTAL_SIZE);
-		release_mem_region(dev->mem_start, dev->mem_end - dev->mem_start + 1);
+		release_mem_region(dev->mem_start,
+				   dev->mem_end - dev->mem_start + 1);
 		free_netdev(dev);
 	}
 }
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index b76e458..691bee5 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -213,7 +213,8 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 	arc_printk(D_DURING, dev, "prepare_tx: txbufs=%d/%d/%d\n",
 		   lp->next_tx, lp->cur_tx, bufnum);
 
-	length -= ARC_HDR_SIZE;	/* hard header is not included in packet length */
+	/* hard header is not included in packet length */
+	length -= ARC_HDR_SIZE;
 
 	if (length > XMTU) {
 		/* should never happen! other people already check for this. */
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index 1d777c1..aaa1966 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -188,11 +188,14 @@ static void rx(struct net_device *dev, int bufnum,
 		pkt = (struct archdr *)skb->data;
 		soft = &pkt->soft.rfc1201;
 
-		/* up to sizeof(pkt->soft) has already been copied from the card */
+		/* up to sizeof(pkt->soft) has already
+		 * been copied from the card
+		 */
 		memcpy(pkt, pkthdr, sizeof(struct archdr));
 		if (length > sizeof(pkt->soft))
-			lp->hw.copy_from_card(dev, bufnum, ofs + sizeof(pkt->soft),
-				       pkt->soft.raw + sizeof(pkt->soft),
+			lp->hw.copy_from_card(dev, bufnum,
+					      ofs + sizeof(pkt->soft),
+					      pkt->soft.raw + sizeof(pkt->soft),
 					      length - sizeof(pkt->soft));
 
 		/* ARP packets have problems when sent from some DOS systems:
@@ -318,7 +321,8 @@ static void rx(struct net_device *dev, int bufnum,
 				return;
 			}
 			in->lastpacket++;
-			if (packetnum != in->lastpacket) {	/* not the right flag! */
+			/* if not the right flag */
+			if (packetnum != in->lastpacket) {
 				/* harmless duplicate? ignore. */
 				if (packetnum <= in->lastpacket - 1) {
 					arc_printk(D_EXTRA, dev, "duplicate splitpacket ignored! (splitflag=%d)\n",
@@ -477,7 +481,8 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 	arc_printk(D_DURING, dev, "prepare_tx: txbufs=%d/%d/%d\n",
 		   lp->next_tx, lp->cur_tx, bufnum);
 
-	length -= ARC_HDR_SIZE;	/* hard header is not included in packet length */
+	/* hard header is not included in packet length */
+	length -= ARC_HDR_SIZE;
 	pkt->soft.rfc1201.split_flag = 0;
 
 	/* need to do a split packet? */
diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index 1d8e36e..9ca135d 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -203,8 +203,8 @@ struct ArcProto {
 			    unsigned short ethproto, uint8_t daddr);
 
 	/* these functions return '1' if the skb can now be freed */
-	int (*prepare_tx)(struct net_device *dev, struct archdr *pkt, int length,
-			  int bufnum);
+	int (*prepare_tx)(struct net_device *dev, struct archdr *pkt,
+			  int length, int bufnum);
 	int (*continue_tx)(struct net_device *dev, int bufnum);
 	int (*ack_tx)(struct net_device *dev, int acked);
 };
@@ -309,10 +309,10 @@ struct arcnet_local {
 		void (*open)(struct net_device *dev);
 		void (*close)(struct net_device *dev);
 
-		void (*copy_to_card)(struct net_device *dev, int bufnum, int offset,
-				     void *buf, int count);
-		void (*copy_from_card)(struct net_device *dev, int bufnum, int offset,
-				       void *buf, int count);
+		void (*copy_to_card)(struct net_device *dev, int bufnum,
+				     int offset, void *buf, int count);
+		void (*copy_from_card)(struct net_device *dev, int bufnum,
+				       int offset, void *buf, int count);
 	} hw;
 
 	void __iomem *mem_start;	/* pointer to ioremap'ed MMIO */
-- 
2.5.1
