From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] remove unneeded casts in lance drivers
Date: Sun, 29 Feb 2004 14:53:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229145318.2a88771e.rddunlap@osdl.org>
References: <20040229142516.3d218ed0.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik <jgarzik@pobox.com>
In-Reply-To: <20040229142516.3d218ed0.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Carlo Perassi <carlo@linux.it>


 drivers/net/7990.c          |    8 ++++----
 drivers/net/a2065.c         |    6 +++---
 drivers/net/atari_pamsnet.c |   12 ++++++------
 drivers/net/bagetlance.c    |    2 +-
 drivers/net/declance.c      |    2 +-
 drivers/net/hplance.c       |    4 ++--
 drivers/net/sun3lance.c     |   14 +++++++-------
 drivers/net/sunlance.c      |    4 ++--
 8 files changed, 26 insertions(+), 26 deletions(-)

diff -puN drivers/net/7990.c~net_lance_casts drivers/net/7990.c
--- linux-263-229/drivers/net/7990.c~net_lance_casts	2004-02-29 14:02:29.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/7990.c	2004-02-29 14:02:29.000000000 -0800
@@ -216,7 +216,7 @@ static int init_restart_lance (struct la
 
 static int lance_reset (struct net_device *dev)
 {
-        struct lance_private *lp = (struct lance_private *)dev->priv;
+        struct lance_private *lp = dev->priv;
         int status;
         DECLARE_LL;
     
@@ -401,7 +401,7 @@ static irqreturn_t
 lance_interrupt (int irq, void *dev_id, struct pt_regs *regs)
 {
         struct net_device *dev = (struct net_device *)dev_id;
-        struct lance_private *lp = (struct lance_private *)dev->priv;
+        struct lance_private *lp = dev->priv;
         int csr0;
         DECLARE_LL;
 
@@ -457,7 +457,7 @@ lance_interrupt (int irq, void *dev_id, 
 
 int lance_open (struct net_device *dev)
 {
-        struct lance_private *lp = (struct lance_private *)dev->priv;
+        struct lance_private *lp = dev->priv;
 	int res;
         DECLARE_LL;
         
@@ -499,7 +499,7 @@ void lance_tx_timeout(struct net_device 
 
 int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
-        struct lance_private *lp = (struct lance_private *)dev->priv;
+        struct lance_private *lp = dev->priv;
         volatile struct lance_init_block *ib = lp->init_block;
         int entry, skblen, len;
         static int outs;
diff -puN drivers/net/a2065.c~net_lance_casts drivers/net/a2065.c
--- linux-263-229/drivers/net/a2065.c~net_lance_casts	2004-02-29 14:02:29.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/a2065.c	2004-02-29 14:02:29.000000000 -0800
@@ -481,7 +481,7 @@ struct net_device *last_dev = 0;
 
 static int lance_open (struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = dev->priv;
 	volatile struct lance_regs *ll = lp->ll;
 	int ret;
 
@@ -522,7 +522,7 @@ static int lance_close (struct net_devic
 
 static inline int lance_reset (struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = dev->priv;
 	volatile struct lance_regs *ll = lp->ll;
 	int status;
     
@@ -556,7 +556,7 @@ static void lance_tx_timeout(struct net_
 
 static int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = dev->priv;
 	volatile struct lance_regs *ll = lp->ll;
 	volatile struct lance_init_block *ib = lp->init_block;
 	int entry, skblen, len;
diff -puN drivers/net/atari_pamsnet.c~net_lance_casts drivers/net/atari_pamsnet.c
--- linux-263-229/drivers/net/atari_pamsnet.c~net_lance_casts	2004-02-29 14:02:29.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/atari_pamsnet.c	2004-02-29 14:02:29.000000000 -0800
@@ -667,7 +667,7 @@ struct net_device * __init pamsnet_probe
  */
 static int
 pamsnet_open(struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	if (pamsnet_debug > 0)
 		printk("pamsnet_open\n");
@@ -696,7 +696,7 @@ pamsnet_open(struct net_device *dev) {
 
 static int
 pamsnet_send_packet(struct sk_buff *skb, struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned long flags;
 
 	/* Block a timer-based transmit from overlapping.  This could better be
@@ -742,7 +742,7 @@ pamsnet_send_packet(struct sk_buff *skb,
  */
 static void
 pamsnet_poll_rx(struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int boguscount;
 	int pkt_len;
 	struct sk_buff *skb;
@@ -817,7 +817,7 @@ pamsnet_poll_rx(struct net_device *dev) 
 static void
 pamsnet_tick(unsigned long data) {
 	struct net_device	 *dev = (struct net_device *)data;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	if( pamsnet_debug > 0 && (lp->open_time++ & 7) == 8 )
 		printk("pamsnet_tick: %ld\n", lp->open_time);
@@ -832,7 +832,7 @@ pamsnet_tick(unsigned long data) {
  */
 static int
 pamsnet_close(struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	if (pamsnet_debug > 0)
 		printk("pamsnet_close, open_time=%ld\n", lp->open_time);
@@ -859,7 +859,7 @@ pamsnet_close(struct net_device *dev) {
  */
 static struct net_device_stats *net_get_stats(struct net_device *dev) 
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	return &lp->stats;
 }
 
diff -puN drivers/net/bagetlance.c~net_lance_casts drivers/net/bagetlance.c
--- linux-263-229/drivers/net/bagetlance.c~net_lance_casts	2004-02-29 14:02:29.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/bagetlance.c	2004-02-29 14:02:29.000000000 -0800
@@ -1247,7 +1247,7 @@ static int lance_close( struct net_devic
 static struct net_device_stats *lance_get_stats( struct net_device *dev )
 
 {	
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = dev->priv;
 	return &lp->stats;
 }
 
diff -puN drivers/net/declance.c~net_lance_casts drivers/net/declance.c
--- linux-263-229/drivers/net/declance.c~net_lance_casts	2004-02-29 14:02:29.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/declance.c	2004-02-29 14:02:29.000000000 -0800
@@ -1287,7 +1287,7 @@ static void __exit dec_lance_cleanup(voi
 {
 	while (root_lance_dev) {
 		struct net_device *dev = root_lance_dev;
-		struct lance_private *lp = (struct lance_private *)dev->priv;
+		struct lance_private *lp = dev->priv;
 		unregister_netdev(dev);
 #ifdef CONFIG_TC
 		if (lp->slot >= 0)
diff -puN drivers/net/hplance.c~net_lance_casts drivers/net/hplance.c
--- linux-263-229/drivers/net/hplance.c~net_lance_casts	2004-02-29 14:02:29.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/hplance.c	2004-02-29 14:02:29.000000000 -0800
@@ -195,7 +195,7 @@ static unsigned short hplance_readrdp(vo
 static int hplance_open(struct net_device *dev)
 {
         int status;
-        struct hplance_private *lp = (struct hplance_private *)dev->priv;
+        struct hplance_private *lp = dev->priv;
         struct hplance_reg *hpregs = (struct hplance_reg *)lp->base;
         
         status = lance_open(dev);                 /* call generic lance open code */
@@ -209,7 +209,7 @@ static int hplance_open(struct net_devic
 
 static int hplance_close(struct net_device *dev)
 {
-        struct hplance_private *lp = (struct hplance_private *)dev->priv;
+        struct hplance_private *lp = dev->priv;
         struct hplance_reg *hpregs = (struct hplance_reg *)lp->base;
         out_8(&(hpregs->status), 8);              /* disable interrupts at boardlevel */
         lance_close(dev);
diff -puN drivers/net/sun3lance.c~net_lance_casts drivers/net/sun3lance.c
--- linux-263-229/drivers/net/sun3lance.c~net_lance_casts	2004-02-29 14:02:29.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/sun3lance.c	2004-02-29 14:02:29.000000000 -0800
@@ -402,7 +402,7 @@ static int __init lance_probe( struct ne
 
 static int lance_open( struct net_device *dev )
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = dev->priv;
 	int i;
 
 	DPRINTK( 2, ( "%s: lance_open()\n", dev->name ));
@@ -439,7 +439,7 @@ static int lance_open( struct net_device
 
 static void lance_init_ring( struct net_device *dev )
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = dev->priv;
 	int i;
 
 	lp->lock = 0;
@@ -499,7 +499,7 @@ static void lance_init_ring( struct net_
 
 static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = dev->priv;
 	int entry, len;
 	struct lance_tx_head *head;
 	unsigned long flags;
@@ -772,7 +772,7 @@ static irqreturn_t lance_interrupt( int 
 /* get packet, toss into skbuff */
 static int lance_rx( struct net_device *dev )
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = dev->priv;
 	int entry = lp->new_rx;
 
 	/* If we own the next entry, it's a new packet. Send it up. */
@@ -870,7 +870,7 @@ static int lance_rx( struct net_device *
 
 static int lance_close( struct net_device *dev )
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = dev->priv;
 
 	netif_stop_queue(dev);
 
@@ -888,7 +888,7 @@ static int lance_close( struct net_devic
 
 static struct net_device_stats *lance_get_stats( struct net_device *dev )
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = dev->priv;
 
 	return &lp->stats;
 }
@@ -904,7 +904,7 @@ static struct net_device_stats *lance_ge
 /* completely untested on a sun3 */
 static void set_multicast_list( struct net_device *dev )
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = dev->priv;
 
 	if(netif_queue_stopped(dev))
 		/* Only possible if board is already started */
diff -puN drivers/net/sunlance.c~net_lance_casts drivers/net/sunlance.c
--- linux-263-229/drivers/net/sunlance.c~net_lance_casts	2004-02-29 14:02:29.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/sunlance.c	2004-02-29 14:02:29.000000000 -0800
@@ -816,7 +816,7 @@ out:
 static irqreturn_t lance_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = dev->priv;
 	int csr0;
     
 	sbus_writew(LE_CSR0, lp->lregs + RAP);
@@ -915,7 +915,7 @@ struct net_device *last_dev = 0;
 
 static int lance_open(struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *)dev->priv;
+	struct lance_private *lp = dev->priv;
 	volatile struct lance_init_block *ib = lp->init_block;
 	int status = 0;
 

_


--
~Randy
