From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] use netdev_priv() in net/ lance drivers
Date: Thu, 4 Mar 2004 13:18:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304131831.1a33fb96.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


| 
| From: Carlo Perassi <carlo@linux.it>
| and Randy.Dunlap <rddunlap@osdl.org>

--
~Randy



 linux-264-302-priv-rddunlap/drivers/net/7990.c          |   22 +++++-----
 linux-264-302-priv-rddunlap/drivers/net/a2065.c         |   26 ++++++------
 linux-264-302-priv-rddunlap/drivers/net/atari_pamsnet.c |   12 ++---
 linux-264-302-priv-rddunlap/drivers/net/bagetlance.c    |   20 ++++-----
 linux-264-302-priv-rddunlap/drivers/net/declance.c      |   26 ++++++------
 linux-264-302-priv-rddunlap/drivers/net/hplance.c       |   10 ++--
 linux-264-302-priv-rddunlap/drivers/net/sun3lance.c     |   18 ++++----
 linux-264-302-priv-rddunlap/drivers/net/sunlance.c      |   34 ++++++++--------
 8 files changed, 84 insertions(+), 84 deletions(-)

diff -puN drivers/net/7990.c~net_lance_casts drivers/net/7990.c
--- linux-264-302-priv/drivers/net/7990.c~net_lance_casts	2004-03-03 12:20:02.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/7990.c	2004-03-03 12:28:46.000000000 -0800
@@ -99,7 +99,7 @@ static void load_csrs (struct lance_priv
 /* Set up the Lance Rx and Tx rings and the init block */
 static void lance_init_ring (struct net_device *dev)
 {
-        struct lance_private *lp = (struct lance_private *) dev->priv;
+        struct lance_private *lp = netdev_priv(dev);
         volatile struct lance_init_block *ib = lp->init_block;
         volatile struct lance_init_block *aib; /* for LANCE_ADDR computations */
         int leptr;
@@ -216,7 +216,7 @@ static int init_restart_lance (struct la
 
 static int lance_reset (struct net_device *dev)
 {
-        struct lance_private *lp = (struct lance_private *)dev->priv;
+        struct lance_private *lp = netdev_priv(dev);
         int status;
         DECLARE_LL;
     
@@ -236,7 +236,7 @@ static int lance_reset (struct net_devic
 
 static int lance_rx (struct net_device *dev)
 {
-        struct lance_private *lp = (struct lance_private *) dev->priv;
+        struct lance_private *lp = netdev_priv(dev);
         volatile struct lance_init_block *ib = lp->init_block;
         volatile struct lance_rx_desc *rd;
         unsigned char bits;
@@ -316,7 +316,7 @@ static int lance_rx (struct net_device *
 
 static int lance_tx (struct net_device *dev)
 {
-        struct lance_private *lp = (struct lance_private *) dev->priv;
+        struct lance_private *lp = netdev_priv(dev);
         volatile struct lance_init_block *ib = lp->init_block;
         volatile struct lance_tx_desc *td;
         int i, j;
@@ -401,7 +401,7 @@ static irqreturn_t
 lance_interrupt (int irq, void *dev_id, struct pt_regs *regs)
 {
         struct net_device *dev = (struct net_device *)dev_id;
-        struct lance_private *lp = (struct lance_private *)dev->priv;
+        struct lance_private *lp = netdev_priv(dev);
         int csr0;
         DECLARE_LL;
 
@@ -457,7 +457,7 @@ lance_interrupt (int irq, void *dev_id, 
 
 int lance_open (struct net_device *dev)
 {
-        struct lance_private *lp = (struct lance_private *)dev->priv;
+        struct lance_private *lp = netdev_priv(dev);
 	int res;
         DECLARE_LL;
         
@@ -474,7 +474,7 @@ int lance_open (struct net_device *dev)
 
 int lance_close (struct net_device *dev)
 {
-        struct lance_private *lp = (struct lance_private *) dev->priv;
+        struct lance_private *lp = netdev_priv(dev);
         DECLARE_LL;
         
 	netif_stop_queue (dev);
@@ -499,7 +499,7 @@ void lance_tx_timeout(struct net_device 
 
 int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
-        struct lance_private *lp = (struct lance_private *)dev->priv;
+        struct lance_private *lp = netdev_priv(dev);
         volatile struct lance_init_block *ib = lp->init_block;
         int entry, skblen, len;
         static int outs;
@@ -556,7 +556,7 @@ int lance_start_xmit (struct sk_buff *sk
 
 struct net_device_stats *lance_get_stats (struct net_device *dev)
 {
-        struct lance_private *lp = (struct lance_private *) dev->priv;
+        struct lance_private *lp = netdev_priv(dev);
 
         return &lp->stats;
 }
@@ -564,7 +564,7 @@ struct net_device_stats *lance_get_stats
 /* taken from the depca driver via a2065.c */
 static void lance_load_multicast (struct net_device *dev)
 {
-        struct lance_private *lp = (struct lance_private *) dev->priv;
+        struct lance_private *lp = netdev_priv(dev);
         volatile struct lance_init_block *ib = lp->init_block;
         volatile u16 *mcast_table = (u16 *)&ib->filter;
         struct dev_mc_list *dmi=dev->mc_list;
@@ -601,7 +601,7 @@ static void lance_load_multicast (struct
 
 void lance_set_multicast (struct net_device *dev)
 {
-        struct lance_private *lp = (struct lance_private *) dev->priv;
+        struct lance_private *lp = netdev_priv(dev);
         volatile struct lance_init_block *ib = lp->init_block;
 	int stopped;
         DECLARE_LL;
diff -puN drivers/net/a2065.c~net_lance_casts drivers/net/a2065.c
--- linux-264-302-priv/drivers/net/a2065.c~net_lance_casts	2004-03-03 12:20:02.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/a2065.c	2004-03-03 12:27:50.000000000 -0800
@@ -164,7 +164,7 @@ static void load_csrs (struct lance_priv
 /* Setup the Lance Rx and Tx rings */
 static void lance_init_ring (struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	volatile struct lance_init_block *aib; /* for LANCE_ADDR computations */
 	int leptr;
@@ -265,7 +265,7 @@ static int init_restart_lance (struct la
 
 static int lance_rx (struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	volatile struct lance_regs *ll = lp->ll;
 	volatile struct lance_rx_desc *rd;
@@ -342,7 +342,7 @@ static int lance_rx (struct net_device *
 
 static int lance_tx (struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	volatile struct lance_regs *ll = lp->ll;
 	volatile struct lance_tx_desc *td;
@@ -433,7 +433,7 @@ lance_interrupt (int irq, void *dev_id, 
 
 	dev = (struct net_device *) dev_id;
 
-	lp = (struct lance_private *) dev->priv;
+	lp = netdev_priv(dev);
 	ll = lp->ll;
 
 	ll->rap = LE_CSR0;		/* LANCE Controller Status */
@@ -481,7 +481,7 @@ struct net_device *last_dev = 0;
 
 static int lance_open (struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 	int ret;
 
@@ -506,7 +506,7 @@ static int lance_open (struct net_device
 
 static int lance_close (struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 
 	netif_stop_queue(dev);
@@ -522,7 +522,7 @@ static int lance_close (struct net_devic
 
 static inline int lance_reset (struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 	int status;
     
@@ -545,7 +545,7 @@ static inline int lance_reset (struct ne
 
 static void lance_tx_timeout(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 
 	printk(KERN_ERR "%s: transmit timed out, status %04x, reset\n",
@@ -556,7 +556,7 @@ static void lance_tx_timeout(struct net_
 
 static int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 	volatile struct lance_init_block *ib = lp->init_block;
 	int entry, skblen, len;
@@ -624,7 +624,7 @@ static int lance_start_xmit (struct sk_b
 
 static struct net_device_stats *lance_get_stats (struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 
 	return &lp->stats;
 }
@@ -632,7 +632,7 @@ static struct net_device_stats *lance_ge
 /* taken from the depca driver */
 static void lance_load_multicast (struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	volatile u16 *mcast_table = (u16 *)&ib->filter;
 	struct dev_mc_list *dmi=dev->mc_list;
@@ -668,7 +668,7 @@ static void lance_load_multicast (struct
 
 static void lance_set_multicast (struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	volatile struct lance_regs *ll = lp->ll;
 
@@ -748,7 +748,7 @@ static int __devinit a2065_init_one(stru
 	}
 
 	SET_MODULE_OWNER(dev);
-	priv = dev->priv;
+	priv = netdev_priv(dev);
 
 	r1->name = dev->name;
 	r2->name = dev->name;
diff -puN drivers/net/atari_pamsnet.c~net_lance_casts drivers/net/atari_pamsnet.c
--- linux-264-302-priv/drivers/net/atari_pamsnet.c~net_lance_casts	2004-03-03 12:20:02.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/atari_pamsnet.c	2004-03-03 12:25:05.000000000 -0800
@@ -667,7 +667,7 @@ struct net_device * __init pamsnet_probe
  */
 static int
 pamsnet_open(struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	if (pamsnet_debug > 0)
 		printk("pamsnet_open\n");
@@ -696,7 +696,7 @@ pamsnet_open(struct net_device *dev) {
 
 static int
 pamsnet_send_packet(struct sk_buff *skb, struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	/* Block a timer-based transmit from overlapping.  This could better be
@@ -742,7 +742,7 @@ pamsnet_send_packet(struct sk_buff *skb,
  */
 static void
 pamsnet_poll_rx(struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int boguscount;
 	int pkt_len;
 	struct sk_buff *skb;
@@ -817,7 +817,7 @@ pamsnet_poll_rx(struct net_device *dev) 
 static void
 pamsnet_tick(unsigned long data) {
 	struct net_device	 *dev = (struct net_device *)data;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	if( pamsnet_debug > 0 && (lp->open_time++ & 7) == 8 )
 		printk("pamsnet_tick: %ld\n", lp->open_time);
@@ -832,7 +832,7 @@ pamsnet_tick(unsigned long data) {
  */
 static int
 pamsnet_close(struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	if (pamsnet_debug > 0)
 		printk("pamsnet_close, open_time=%ld\n", lp->open_time);
@@ -859,7 +859,7 @@ pamsnet_close(struct net_device *dev) {
  */
 static struct net_device_stats *net_get_stats(struct net_device *dev) 
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	return &lp->stats;
 }
 
diff -puN drivers/net/bagetlance.c~net_lance_casts drivers/net/bagetlance.c
--- linux-264-302-priv/drivers/net/bagetlance.c~net_lance_casts	2004-03-03 12:20:02.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/bagetlance.c	2004-03-03 12:30:25.000000000 -0800
@@ -594,7 +594,7 @@ static int __init lance_probe1( struct n
 	return( 0 );
 
   probe_ok:
-	lp = (struct lance_private *)dev->priv;
+	lp = netdev_priv(dev);
 	MEM = (struct lance_memory *)memaddr;
 	IO = lp->iobase = (struct lance_ioreg *)ioaddr;
 	dev->base_addr = (unsigned long)ioaddr; /* informational only */
@@ -736,7 +736,7 @@ static int __init lance_probe1( struct n
 
 static int lance_open( struct net_device *dev )
 
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 	int i;
 
@@ -778,7 +778,7 @@ static int lance_open( struct net_device
 
 static void lance_init_ring( struct net_device *dev )
 
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{	struct lance_private *lp = netdev_priv(dev);
 	int i;
 	unsigned offset;
 
@@ -834,7 +834,7 @@ static void lance_init_ring( struct net_
 
 static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 	int entry, len;
 	struct lance_tx_head *head;
@@ -988,7 +988,7 @@ static irqreturn_t lance_interrupt( int 
 		return IRQ_NONE;
 	}
 
-	lp = (struct lance_private *)dev->priv;
+	lp = netdev_priv(dev);
 	IO = lp->iobase;
 	AREG = CSR0;
 
@@ -1101,7 +1101,7 @@ static irqreturn_t lance_interrupt( int 
 
 static int lance_rx( struct net_device *dev )
 
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{	struct lance_private *lp = netdev_priv(dev);
 	int entry = lp->cur_rx & RX_RING_MOD_MASK;
 	int i;
 
@@ -1225,7 +1225,7 @@ static int lance_rx( struct net_device *
 
 static int lance_close( struct net_device *dev )
 
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 
 	dev->start = 0;
@@ -1247,7 +1247,7 @@ static int lance_close( struct net_devic
 static struct net_device_stats *lance_get_stats( struct net_device *dev )
 
 {	
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	return &lp->stats;
 }
 
@@ -1261,7 +1261,7 @@ static struct net_device_stats *lance_ge
 
 static void set_multicast_list( struct net_device *dev )
 
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 
 	if (!dev->start)
@@ -1303,7 +1303,7 @@ static void set_multicast_list( struct n
 
 static int lance_set_mac_address( struct net_device *dev, void *addr )
 
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{	struct lance_private *lp = netdev_priv(dev);
 	struct sockaddr *saddr = addr;
 	int i;
 
diff -puN drivers/net/declance.c~net_lance_casts drivers/net/declance.c
--- linux-264-302-priv/drivers/net/declance.c~net_lance_casts	2004-03-03 12:20:02.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/declance.c	2004-03-03 12:29:44.000000000 -0800
@@ -433,7 +433,7 @@ void cp_from_buf(const int type, void *t
 /* Setup the Lance Rx and Tx rings */
 static void lance_init_ring(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib;
 	int leptr;
 	int i;
@@ -530,7 +530,7 @@ static int init_restart_lance(struct lan
 
 static int lance_rx(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib;
 	volatile struct lance_rx_desc *rd = 0;
 	unsigned char bits;
@@ -617,7 +617,7 @@ static int lance_rx(struct net_device *d
 
 static void lance_tx(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib;
 	volatile struct lance_regs *ll = lp->ll;
 	volatile struct lance_tx_desc *td;
@@ -709,7 +709,7 @@ static irqreturn_t
 lance_interrupt(const int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 	int csr0;
 
@@ -757,7 +757,7 @@ struct net_device *last_dev = 0;
 static int lance_open(struct net_device *dev)
 {
 	volatile struct lance_init_block *ib = (struct lance_init_block *) (dev->mem_start);
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 	int status = 0;
 
@@ -822,7 +822,7 @@ static int lance_open(struct net_device 
 
 static int lance_close(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 
 	netif_stop_queue(dev);
@@ -856,7 +856,7 @@ static int lance_close(struct net_device
 
 static inline int lance_reset(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 	int status;
 
@@ -873,7 +873,7 @@ static inline int lance_reset(struct net
 
 static void lance_tx_timeout(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 
 	printk(KERN_ERR "%s: transmit timed out, status %04x, reset\n",
@@ -884,7 +884,7 @@ static void lance_tx_timeout(struct net_
 
 static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_regs *ll = lp->ll;
 	volatile struct lance_init_block *ib = (struct lance_init_block *) (dev->mem_start);
 	int entry, skblen, len;
@@ -936,7 +936,7 @@ static int lance_start_xmit(struct sk_bu
 
 static struct net_device_stats *lance_get_stats(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 
 	return &lp->stats;
 }
@@ -982,7 +982,7 @@ static void lance_load_multicast(struct 
 
 static void lance_set_multicast(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib;
 	volatile struct lance_regs *ll = lp->ll;
 
@@ -1048,7 +1048,7 @@ static int __init dec_lance_init(const i
 	 * alloc_etherdev ensures the data structures used by the LANCE
 	 * are aligned.
 	 */
-	lp = (struct lance_private *) dev->priv;
+	lp = netdev_priv(dev);
 	spin_lock_init(&lp->lock);
 
 	lp->type = type;
@@ -1287,7 +1287,7 @@ static void __exit dec_lance_cleanup(voi
 {
 	while (root_lance_dev) {
 		struct net_device *dev = root_lance_dev;
-		struct lance_private *lp = (struct lance_private *)dev->priv;
+		struct lance_private *lp = netdev_priv(dev);
 		unregister_netdev(dev);
 #ifdef CONFIG_TC
 		if (lp->slot >= 0)
diff -puN drivers/net/hplance.c~net_lance_casts drivers/net/hplance.c
--- linux-264-302-priv/drivers/net/hplance.c~net_lance_casts	2004-03-03 12:20:02.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/hplance.c	2004-03-03 12:24:34.000000000 -0800
@@ -63,7 +63,7 @@ static struct hplance_private *root_hpla
 
 static void cleanup_card(struct net_device *dev)
 {
-        struct hplance_private *lp = dev->priv;
+        struct hplance_private *lp = netdev_priv(dev);
 	dio_unconfig_board(lp->scode);
 }
 
@@ -97,7 +97,7 @@ struct net_device * __init hplance_probe
 		dio_config_board(scode);
                 hplance_init(dev, scode);
 		if (!register_netdev(dev)) {
-			struct hplance_private *lp = dev->priv;
+			struct hplance_private *lp = netdev_priv(dev);
 			lp->next_module = root_hplance_dev;
 			root_hplance_dev = lp;
 			return dev;
@@ -141,7 +141,7 @@ static void __init hplance_init(struct n
                 printk("%c%2.2x", i == 0 ? ' ' : ':', dev->dev_addr[i]);
         }
         
-        lp = (struct hplance_private *)dev->priv;
+        lp = netdev_priv(dev);
         lp->lance.name = (char*)name;                   /* discards const, shut up gcc */
         lp->lance.ll = (struct lance_regs *)(va + HPLANCE_REGOFF);
         lp->lance.init_block = (struct lance_init_block *)(va + HPLANCE_MEMOFF); /* CPU addr */
@@ -195,7 +195,7 @@ static unsigned short hplance_readrdp(vo
 static int hplance_open(struct net_device *dev)
 {
         int status;
-        struct hplance_private *lp = (struct hplance_private *)dev->priv;
+        struct hplance_private *lp = netdev_priv(dev);
         struct hplance_reg *hpregs = (struct hplance_reg *)lp->base;
         
         status = lance_open(dev);                 /* call generic lance open code */
@@ -209,7 +209,7 @@ static int hplance_open(struct net_devic
 
 static int hplance_close(struct net_device *dev)
 {
-        struct hplance_private *lp = (struct hplance_private *)dev->priv;
+        struct hplance_private *lp = netdev_priv(dev);
         struct hplance_reg *hpregs = (struct hplance_reg *)lp->base;
         out_8(&(hpregs->status), 8);              /* disable interrupts at boardlevel */
         lance_close(dev);
diff -puN drivers/net/sun3lance.c~net_lance_casts drivers/net/sun3lance.c
--- linux-264-302-priv/drivers/net/sun3lance.c~net_lance_casts	2004-03-03 12:20:02.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/sun3lance.c	2004-03-03 12:31:02.000000000 -0800
@@ -332,7 +332,7 @@ static int __init lance_probe( struct ne
 		return 0;
 	}
 
-	lp = (struct lance_private *)dev->priv;
+	lp = netdev_priv(dev);
 
 	/* XXX - leak? */
 	MEM = dvma_malloc_align(sizeof(struct lance_memory), 0x10000);
@@ -402,7 +402,7 @@ static int __init lance_probe( struct ne
 
 static int lance_open( struct net_device *dev )
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	int i;
 
 	DPRINTK( 2, ( "%s: lance_open()\n", dev->name ));
@@ -439,7 +439,7 @@ static int lance_open( struct net_device
 
 static void lance_init_ring( struct net_device *dev )
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	int i;
 
 	lp->lock = 0;
@@ -499,7 +499,7 @@ static void lance_init_ring( struct net_
 
 static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	int entry, len;
 	struct lance_tx_head *head;
 	unsigned long flags;
@@ -646,7 +646,7 @@ static int lance_start_xmit( struct sk_b
 static irqreturn_t lance_interrupt( int irq, void *dev_id, struct pt_regs *fp)
 {
 	struct net_device *dev = dev_id;
-	struct lance_private *lp = dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	int csr0;
 	static int in_interrupt;
 
@@ -772,7 +772,7 @@ static irqreturn_t lance_interrupt( int 
 /* get packet, toss into skbuff */
 static int lance_rx( struct net_device *dev )
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	int entry = lp->new_rx;
 
 	/* If we own the next entry, it's a new packet. Send it up. */
@@ -870,7 +870,7 @@ static int lance_rx( struct net_device *
 
 static int lance_close( struct net_device *dev )
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -888,7 +888,7 @@ static int lance_close( struct net_devic
 
 static struct net_device_stats *lance_get_stats( struct net_device *dev )
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 
 	return &lp->stats;
 }
@@ -904,7 +904,7 @@ static struct net_device_stats *lance_ge
 /* completely untested on a sun3 */
 static void set_multicast_list( struct net_device *dev )
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 
 	if(netif_queue_stopped(dev))
 		/* Only possible if board is already started */
diff -puN drivers/net/sunlance.c~net_lance_casts drivers/net/sunlance.c
--- linux-264-302-priv/drivers/net/sunlance.c~net_lance_casts	2004-03-03 12:20:02.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/sunlance.c	2004-03-03 12:26:43.000000000 -0800
@@ -313,7 +313,7 @@ static void load_csrs(struct lance_priva
 /* Setup the Lance Rx and Tx rings */
 static void lance_init_ring_dvma(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	dma_addr_t aib = lp->init_block_dvma;
 	__u32 leptr;
@@ -370,7 +370,7 @@ static void lance_init_ring_dvma(struct 
 
 static void lance_init_ring_pio(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	u32 leptr;
 	int i;
@@ -500,7 +500,7 @@ static int init_restart_lance(struct lan
 
 static void lance_rx_dvma(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	volatile struct lance_rx_desc *rd;
 	u8 bits;
@@ -563,7 +563,7 @@ static void lance_rx_dvma(struct net_dev
 
 static void lance_tx_dvma(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	int i, j;
 
@@ -673,7 +673,7 @@ static void lance_piocopy_to_skb(struct 
 
 static void lance_rx_pio(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	volatile struct lance_rx_desc *rd;
 	unsigned char bits;
@@ -735,7 +735,7 @@ static void lance_rx_pio(struct net_devi
 
 static void lance_tx_pio(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	int i, j;
 
@@ -816,7 +816,7 @@ out:
 static irqreturn_t lance_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	int csr0;
     
 	sbus_writew(LE_CSR0, lp->lregs + RAP);
@@ -915,7 +915,7 @@ struct net_device *last_dev = 0;
 
 static int lance_open(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	int status = 0;
 
@@ -968,7 +968,7 @@ static int lance_open(struct net_device 
 
 static int lance_close(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 	del_timer_sync(&lp->multicast_timer);
@@ -981,7 +981,7 @@ static int lance_close(struct net_device
 
 static int lance_reset(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	int status;
     
 	STOP_LANCE(lp);
@@ -1102,7 +1102,7 @@ static void lance_piozero(volatile void 
 
 static void lance_tx_timeout(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 
 	printk(KERN_ERR "%s: transmit timed out, status %04x, reset\n",
 	       dev->name, sbus_readw(lp->lregs + RDP));
@@ -1112,7 +1112,7 @@ static void lance_tx_timeout(struct net_
 
 static int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	int entry, skblen, len;
 
@@ -1165,7 +1165,7 @@ static int lance_start_xmit(struct sk_bu
 
 static struct net_device_stats *lance_get_stats(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 
 	return &lp->stats;
 }
@@ -1173,7 +1173,7 @@ static struct net_device_stats *lance_ge
 /* taken from the depca driver */
 static void lance_load_multicast(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	volatile u16 *mcast_table = (u16 *) &ib->filter;
 	struct dev_mc_list *dmi = dev->mc_list;
@@ -1223,7 +1223,7 @@ static void lance_load_multicast(struct 
 
 static void lance_set_multicast(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	volatile struct lance_init_block *ib = lp->init_block;
 	u16 mode;
 
@@ -1291,7 +1291,7 @@ static void lance_free_hwresources(struc
 /* Ethtool support... */
 static void sparc_lance_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct lance_private *lp = dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 
 	strcpy(info->driver, "sunlance");
 	strcpy(info->version, "2.02");
@@ -1325,7 +1325,7 @@ static int __init sparc_lance_init(struc
 	if (!dev)
 		return -ENOMEM;
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 
 	if (sparc_lance_debug && version_printed++ == 0)
 		printk (KERN_INFO "%s", version);

_


--
~Randy
