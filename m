From: Domen Puncer <domen@coderock.org>
Subject: [patch] arcnet: remove casts
Date: Wed, 29 Dec 2004 23:16:15 +0100
Message-ID: <20041229221615.GF26245@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove casts of (void *) pointers.

 drivers/net/arcnet/arc-rawmode.c |    4 ++--
 drivers/net/arcnet/arc-rimi.c    |   14 +++++++-------
 drivers/net/arcnet/arcnet.c      |   30 +++++++++++++++---------------
 drivers/net/arcnet/com20020.c    |    6 +++---
 drivers/net/arcnet/com90io.c     |    4 ++--
 drivers/net/arcnet/com90xx.c     |    8 ++++----
 drivers/net/arcnet/rfc1051.c     |    8 ++++----
 drivers/net/arcnet/rfc1201.c     |   12 ++++++------
 8 files changed, 43 insertions(+), 43 deletions(-)

Signed-off-by: Domen Puncer <domen@coderock.org>

diff -pruNX dontdiff c/drivers/net/arcnet/arc-rawmode.c a/drivers/net/arcnet/arc-rawmode.c
--- c/drivers/net/arcnet/arc-rawmode.c	2004-12-29 22:46:51.000000000 +0100
+++ a/drivers/net/arcnet/arc-rawmode.c	2004-12-29 23:09:19.000000000 +0100
@@ -87,7 +87,7 @@ MODULE_LICENSE("GPL");
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	int ofs;
@@ -168,7 +168,7 @@ static int build_header(struct sk_buff *
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct arc_hardware *hard = &pkt->hard;
 	int ofs;
 
diff -pruNX dontdiff c/drivers/net/arcnet/arc-rimi.c a/drivers/net/arcnet/arc-rimi.c
--- c/drivers/net/arcnet/arc-rimi.c	2004-10-19 13:52:57.000000000 +0200
+++ a/drivers/net/arcnet/arc-rimi.c	2004-12-29 23:09:19.000000000 +0100
@@ -230,7 +230,7 @@ err_free_irq:
  */
 static int arcrimi_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, ASTATUS());
@@ -251,7 +251,7 @@ static int arcrimi_reset(struct net_devi
 
 static void arcrimi_setmask(struct net_device *dev, int mask)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	AINTMASK(mask);
@@ -259,7 +259,7 @@ static void arcrimi_setmask(struct net_d
 
 static int arcrimi_status(struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	return ASTATUS();
@@ -267,7 +267,7 @@ static int arcrimi_status(struct net_dev
 
 static void arcrimi_command(struct net_device *dev, int cmd)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	ACOMMAND(cmd);
@@ -276,7 +276,7 @@ static void arcrimi_command(struct net_d
 static void arcrimi_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *memaddr = lp->mem_start + 0x800 + bufnum * 512 + offset;
 	TIME("memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
@@ -285,7 +285,7 @@ static void arcrimi_copy_to_card(struct 
 static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offset,
 				   void *buf, int count)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *memaddr = lp->mem_start + 0x800 + bufnum * 512 + offset;
 	TIME("memcpy_fromio", count, memcpy_fromio(buf, memaddr, count));
 }
@@ -331,7 +331,7 @@ static int __init arc_rimi_init(void)
 static void __exit arc_rimi_exit(void)
 {
 	struct net_device *dev = my_dev;
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 
 	unregister_netdev(dev);
 	iounmap(lp->mem_start);
diff -pruNX dontdiff c/drivers/net/arcnet/arcnet.c a/drivers/net/arcnet/arcnet.c
--- c/drivers/net/arcnet/arcnet.c	2004-12-29 22:46:51.000000000 +0100
+++ a/drivers/net/arcnet/arcnet.c	2004-12-29 23:09:19.000000000 +0100
@@ -182,7 +182,7 @@ EXPORT_SYMBOL(arcnet_dump_skb);
 void arcnet_dump_packet(struct net_device *dev, int bufnum, char *desc,
 			int take_arcnet_lock)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int i, length;
 	unsigned long flags = 0;
 	static uint8_t buf[512];
@@ -245,7 +245,7 @@ void arcnet_unregister_proto(struct ArcP
  */
 static void release_arcbuf(struct net_device *dev, int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int i;
 
 	lp->buf_queue[lp->first_free_buf++] = bufnum;
@@ -267,7 +267,7 @@ static void release_arcbuf(struct net_de
  */
 static int get_arcbuf(struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int buf = -1, i;
 
 	if (!atomic_dec_and_test(&lp->buf_lock)) {
@@ -368,7 +368,7 @@ struct net_device *alloc_arcdev(char *na
  */
 static int arcnet_open(struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int count, newmtu, error;
 
 	BUGMSG(D_INIT,"opened.");
@@ -468,7 +468,7 @@ static int arcnet_open(struct net_device
 /* The inverse routine to arcnet_open - shuts down the card. */
 static int arcnet_close(struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 
 	netif_stop_queue(dev);
 
@@ -489,7 +489,7 @@ static int arcnet_header(struct sk_buff 
 			 unsigned short type, void *daddr, void *saddr,
 			 unsigned len)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	uint8_t _daddr, proto_num;
 	struct ArcProto *proto;
 
@@ -547,7 +547,7 @@ static int arcnet_header(struct sk_buff 
 static int arcnet_rebuild_header(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int status = 0;		/* default is failure */
 	unsigned short type;
 	uint8_t daddr=0;
@@ -592,7 +592,7 @@ static int arcnet_rebuild_header(struct 
 /* Called by the kernel in order to transmit a packet. */
 static int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct archdr *pkt;
 	struct arc_rfc1201 *soft;
 	struct ArcProto *proto;
@@ -675,7 +675,7 @@ static int arcnet_send_packet(struct sk_
  */
 static int go_tx(struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 
 	BUGMSG(D_DURING, "go_tx: status=%Xh, intmask=%Xh, next_tx=%d, cur_tx=%d\n",
 	       ASTATUS(), lp->intmask, lp->next_tx, lp->cur_tx);
@@ -706,7 +706,7 @@ static int go_tx(struct net_device *dev)
 static void arcnet_timeout(struct net_device *dev)
 {
 	unsigned long flags;
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int status = ASTATUS();
 	char *msg;
 
@@ -755,7 +755,7 @@ irqreturn_t arcnet_interrupt(int irq, vo
 
 	BUGMSG(D_DURING, "in arcnet_interrupt\n");
 	
-	lp = (struct arcnet_local *) dev->priv;
+	lp = dev->priv;
 	if (!lp)
 		BUG();
 		
@@ -990,7 +990,7 @@ irqreturn_t arcnet_interrupt(int irq, vo
  */
 void arcnet_rx(struct net_device *dev, int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct archdr pkt;
 	struct arc_rfc1201 *soft;
 	int length, ofs;
@@ -1054,7 +1054,7 @@ void arcnet_rx(struct net_device *dev, i
  */
 static struct net_device_stats *arcnet_get_stats(struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	return &lp->stats;
 }
 
@@ -1071,7 +1071,7 @@ static void null_rx(struct net_device *d
 static int null_build_header(struct sk_buff *skb, struct net_device *dev,
 			     unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 
 	BUGMSG(D_PROTO,
 	       "tx: can't build header for encap %02Xh; load a protocol driver.\n",
@@ -1086,7 +1086,7 @@ static int null_build_header(struct sk_b
 static int null_prepare_tx(struct net_device *dev, struct archdr *pkt,
 			   int length, int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct arc_hardware newpkt;
 
 	BUGMSG(D_PROTO, "tx: no encap for this host; load a protocol driver.\n");
diff -pruNX dontdiff c/drivers/net/arcnet/com20020.c a/drivers/net/arcnet/com20020.c
--- c/drivers/net/arcnet/com20020.c	2004-12-29 22:46:51.000000000 +0100
+++ a/drivers/net/arcnet/com20020.c	2004-12-29 23:11:53.000000000 +0100
@@ -159,7 +159,7 @@ int com20020_found(struct net_device *de
 
 	/* Initialize the rest of the device structure. */
 
-	lp = (struct arcnet_local *) dev->priv;
+	lp = dev->priv;
 
 	lp->hw.owner = THIS_MODULE;
 	lp->hw.command = com20020_command;
@@ -233,7 +233,7 @@ int com20020_found(struct net_device *de
  */
 static int com20020_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	u_int ioaddr = dev->base_addr;
 	u_char inbyte;
 
@@ -300,7 +300,7 @@ static int com20020_status(struct net_de
 
 static void com20020_close(struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	/* disable transmitter */
diff -pruNX dontdiff c/drivers/net/arcnet/com90io.c a/drivers/net/arcnet/com90io.c
--- c/drivers/net/arcnet/com90io.c	2004-02-18 13:27:39.000000000 +0100
+++ a/drivers/net/arcnet/com90io.c	2004-12-29 23:09:19.000000000 +0100
@@ -248,7 +248,7 @@ static int __init com90io_found(struct n
 		return -EBUSY;
 	}
 
-	lp = (struct arcnet_local *) (dev->priv);
+	lp = dev->priv;
 	lp->card_name = "COM90xx I/O";
 	lp->hw.command = com90io_command;
 	lp->hw.status = com90io_status;
@@ -290,7 +290,7 @@ static int __init com90io_found(struct n
  */
 static int com90io_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	short ioaddr = dev->base_addr;
 
 	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, ASTATUS());
diff -pruNX dontdiff c/drivers/net/arcnet/com90xx.c a/drivers/net/arcnet/com90xx.c
--- c/drivers/net/arcnet/com90xx.c	2004-10-19 13:52:58.000000000 +0200
+++ a/drivers/net/arcnet/com90xx.c	2004-12-29 23:09:19.000000000 +0100
@@ -529,7 +529,7 @@ static void com90xx_setmask(struct net_d
  */
 int com90xx_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	short ioaddr = dev->base_addr;
 
 	BUGMSG(D_INIT, "Resetting (status=%02Xh)\n", ASTATUS());
@@ -565,7 +565,7 @@ int com90xx_reset(struct net_device *dev
 static void com90xx_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *memaddr = lp->mem_start + bufnum * 512 + offset;
 	TIME("memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
@@ -574,7 +574,7 @@ static void com90xx_copy_to_card(struct 
 static void com90xx_copy_from_card(struct net_device *dev, int bufnum, int offset,
 				   void *buf, int count)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	void __iomem *memaddr = lp->mem_start + bufnum * 512 + offset;
 	TIME("memcpy_fromio", count, memcpy_fromio(buf, memaddr, count));
 }
@@ -600,7 +600,7 @@ static void __exit com90xx_exit(void)
 
 	for (count = 0; count < numcards; count++) {
 		dev = cards[count];
-		lp = (struct arcnet_local *) dev->priv;
+		lp = dev->priv;
 
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
diff -pruNX dontdiff c/drivers/net/arcnet/rfc1051.c a/drivers/net/arcnet/rfc1051.c
--- c/drivers/net/arcnet/rfc1051.c	2004-12-29 22:46:51.000000000 +0100
+++ a/drivers/net/arcnet/rfc1051.c	2004-12-29 23:09:19.000000000 +0100
@@ -88,7 +88,7 @@ MODULE_LICENSE("GPL");
  */
 static unsigned short type_trans(struct sk_buff *skb, struct net_device *dev)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct archdr *pkt = (struct archdr *) skb->data;
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
@@ -125,7 +125,7 @@ static unsigned short type_trans(struct 
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	int ofs;
@@ -169,7 +169,7 @@ static void rx(struct net_device *dev, i
 static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
 	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
@@ -220,7 +220,7 @@ static int build_header(struct sk_buff *
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct arc_hardware *hard = &pkt->hard;
 	int ofs;
 
diff -pruNX dontdiff c/drivers/net/arcnet/rfc1201.c a/drivers/net/arcnet/rfc1201.c
--- c/drivers/net/arcnet/rfc1201.c	2004-12-29 22:46:51.000000000 +0100
+++ a/drivers/net/arcnet/rfc1201.c	2004-12-29 23:09:19.000000000 +0100
@@ -92,7 +92,7 @@ static unsigned short type_trans(struct 
 {
 	struct archdr *pkt = (struct archdr *) skb->data;
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
 
 	/* Pull off the arcnet header. */
@@ -134,7 +134,7 @@ static unsigned short type_trans(struct 
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	struct arc_rfc1201 *soft = &pkthdr->soft.rfc1201;
@@ -376,7 +376,7 @@ static void rx(struct net_device *dev, i
 static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
 	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
@@ -443,7 +443,7 @@ static int build_header(struct sk_buff *
 static void load_pkt(struct net_device *dev, struct arc_hardware *hard,
 		     struct arc_rfc1201 *soft, int softlen, int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	int ofs;
 
 	/* assume length <= XMTU: someone should have handled that by now. */
@@ -476,7 +476,7 @@ static void load_pkt(struct net_device *
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	const int maxsegsize = XMTU - RFC1201_HDR_SIZE;
 	struct Outgoing *out;
 
@@ -511,7 +511,7 @@ static int prepare_tx(struct net_device 
 
 static int continue_tx(struct net_device *dev, int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = dev->priv;
 	struct Outgoing *out = &lp->outgoing;
 	struct arc_hardware *hard = &out->pkt->hard;
 	struct arc_rfc1201 *soft = &out->pkt->soft.rfc1201, *newsoft;
