From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] remove casts in drivers/net/arm/
Date: Sun, 29 Feb 2004 14:34:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229143436.4bb884ee.rddunlap@osdl.org>
References: <20040229142516.3d218ed0.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, rking <rmk@arm.linux.org.uk>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik <jgarzik@pobox.com>
In-Reply-To: <20040229142516.3d218ed0.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Carlo Perassi <carlo@linux.it>


 drivers/net/arm/am79c961a.c |   18 +++++++++---------
 drivers/net/arm/ether1.c    |   18 +++++++++---------
 drivers/net/arm/ether3.c    |   18 +++++++++---------
 drivers/net/arm/etherh.c    |    4 ++--
 4 files changed, 29 insertions(+), 29 deletions(-)

diff -puN drivers/net/arm/am79c961a.c~net_arm_casts drivers/net/arm/am79c961a.c
--- linux-263-229/drivers/net/arm/am79c961a.c~net_arm_casts	2004-02-29 13:53:00.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/arm/am79c961a.c	2004-02-29 13:53:00.000000000 -0800
@@ -196,7 +196,7 @@ am79c961_ramtest(struct net_device *dev,
 static void
 am79c961_init_for_open(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 	unsigned long flags;
 	unsigned char *p;
 	u_int hdr_addr, first_free_addr;
@@ -271,7 +271,7 @@ am79c961_init_for_open(struct net_device
 static void am79c961_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 	unsigned int lnkstat, carrier;
 
 	lnkstat = read_ireg(dev->base_addr, ISALED0) & ISALED0_LNKST;
@@ -291,7 +291,7 @@ static void am79c961_timer(unsigned long
 static int
 am79c961_open(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 	int ret;
 
 	memset (&priv->stats, 0, sizeof (priv->stats));
@@ -318,7 +318,7 @@ am79c961_open(struct net_device *dev)
 static int
 am79c961_close(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 	unsigned long flags;
 
 	del_timer_sync(&priv->timer);
@@ -341,7 +341,7 @@ am79c961_close(struct net_device *dev)
  */
 static struct net_device_stats *am79c961_getstats (struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 	return &priv->stats;
 }
 
@@ -365,7 +365,7 @@ static void am79c961_mc_hash(struct dev_
  */
 static void am79c961_setmulticastlist (struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 	unsigned long flags;
 	unsigned short multi_hash[4], mode;
 	int i, stopped;
@@ -444,7 +444,7 @@ static void am79c961_timeout(struct net_
 static int
 am79c961_sendpacket(struct sk_buff *skb, struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 	unsigned int hdraddr, bufaddr;
 	unsigned int head;
 	unsigned long flags;
@@ -593,7 +593,7 @@ static irqreturn_t
 am79c961_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 	u_int status, n = 100;
 	int handled = 0;
 
@@ -630,7 +630,7 @@ am79c961_interrupt(int irq, void *dev_id
 static int
 am79c961_hw_init(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 
 	spin_lock_irq(&priv->chip_lock);
 	write_rreg (dev->base_addr, CSR0, CSR0_STOP);
diff -puN drivers/net/arm/ether1.c~net_arm_casts drivers/net/arm/ether1.c
--- linux-263-229/drivers/net/arm/ether1.c~net_arm_casts	2004-02-29 13:53:00.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/arm/ether1.c	2004-02-29 13:53:00.000000000 -0800
@@ -447,7 +447,7 @@ static rbd_t  init_rbd	= {
 static int
 ether1_init_for_open (struct net_device *dev)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = dev->priv;
 	int i, status, addr, next, next2;
 	int failures = 0;
 	unsigned long timeout;
@@ -616,7 +616,7 @@ ether1_init_for_open (struct net_device 
 static int
 ether1_txalloc (struct net_device *dev, int size)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = dev->priv;
 	int start, tail;
 
 	size = (size + 1) & ~1;
@@ -642,7 +642,7 @@ ether1_txalloc (struct net_device *dev, 
 static int
 ether1_open (struct net_device *dev)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = dev->priv;
 
 	if (!is_valid_ether_addr(dev->dev_addr)) {
 		printk(KERN_WARNING "%s: invalid ethernet MAC address\n",
@@ -668,7 +668,7 @@ ether1_open (struct net_device *dev)
 static void
 ether1_timeout(struct net_device *dev)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = dev->priv;
 
 	printk(KERN_WARNING "%s: transmit timeout, network cable problem?\n",
 		dev->name);
@@ -686,7 +686,7 @@ ether1_timeout(struct net_device *dev)
 static int
 ether1_sendpacket (struct sk_buff *skb, struct net_device *dev)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = dev->priv;
 	int tmp, tst, nopaddr, txaddr, tbdaddr, dataddr;
 	unsigned long flags;
 	tx_t tx;
@@ -762,7 +762,7 @@ ether1_sendpacket (struct sk_buff *skb, 
 static void
 ether1_xmit_done (struct net_device *dev)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = dev->priv;
 	nop_t nop;
 	int caddr, tst;
 
@@ -863,7 +863,7 @@ again:
 static void
 ether1_recv_done (struct net_device *dev)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = dev->priv;
 	int status;
 	int nexttail, rbdaddr;
 	rbd_t rbd;
@@ -919,7 +919,7 @@ static irqreturn_t
 ether1_interrupt (int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = dev->priv;
 	int status;
 
 	status = ether1_inw (dev, SCB_ADDR, scb_t, scb_status, NORMALIRQS);
@@ -978,7 +978,7 @@ ether1_close (struct net_device *dev)
 static struct net_device_stats *
 ether1_getstats (struct net_device *dev)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = dev->priv;
 	return &priv->stats;
 }
 
diff -puN drivers/net/arm/ether3.c~net_arm_casts drivers/net/arm/ether3.c
--- linux-263-229/drivers/net/arm/ether3.c~net_arm_casts	2004-02-29 13:53:00.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/arm/ether3.c	2004-02-29 13:53:00.000000000 -0800
@@ -121,7 +121,7 @@ static inline void ether3_outw(int v, co
 static int
 ether3_setbuffer(struct net_device *dev, buffer_rw_t read, int start)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 	int timeout = 1000;
 
 	ether3_outw(priv->regs.config1 | CFG1_LOCBUFMEM, REG_CONFIG1);
@@ -180,7 +180,7 @@ static void
 ether3_ledoff(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 	ether3_outw(priv->regs.config2 |= CFG2_CTRLO, REG_CONFIG2);
 }
 
@@ -280,7 +280,7 @@ ether3_ramtest(struct net_device *dev, u
 static int __init
 ether3_init_2(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 	int i;
 
 	priv->regs.config1 = CFG1_RECVCOMPSTAT0|CFG1_DMABURST8;
@@ -330,7 +330,7 @@ ether3_init_2(struct net_device *dev)
 static void
 ether3_init_for_open(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 	int i;
 
 	memset(&priv->stats, 0, sizeof(struct net_device_stats));
@@ -434,7 +434,7 @@ ether3_open(struct net_device *dev)
 static int
 ether3_close(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 
 	netif_stop_queue(dev);
 
@@ -457,7 +457,7 @@ ether3_close(struct net_device *dev)
  */
 static struct net_device_stats *ether3_getstats(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 	return &priv->stats;
 }
 
@@ -469,7 +469,7 @@ static struct net_device_stats *ether3_g
  */
 static void ether3_setmulticastlist(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 
 	priv->regs.config1 &= ~CFG1_RECVPROMISC;
 
@@ -487,7 +487,7 @@ static void ether3_setmulticastlist(stru
 static void
 ether3_timeout(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 	unsigned long flags;
 
 	del_timer(&priv->timer);
@@ -518,7 +518,7 @@ ether3_timeout(struct net_device *dev)
 static int
 ether3_sendpacket(struct sk_buff *skb, struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = dev->priv;
 	unsigned long flags;
 	unsigned int length = ETH_ZLEN < skb->len ? skb->len : ETH_ZLEN;
 	unsigned int ptr, next_ptr;
diff -puN drivers/net/arm/etherh.c~net_arm_casts drivers/net/arm/etherh.c
--- linux-263-229/drivers/net/arm/etherh.c~net_arm_casts	2004-02-29 13:53:00.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/arm/etherh.c	2004-02-29 13:53:00.000000000 -0800
@@ -144,7 +144,7 @@ static expansioncard_ops_t etherh_ops = 
 static void
 etherh_setif(struct net_device *dev)
 {
-	struct etherh_priv *eh = (struct etherh_priv *)dev->priv;
+	struct etherh_priv *eh = dev->priv;
 	struct ei_device *ei_local = &eh->eidev;
 	unsigned long addr, flags;
 
@@ -188,7 +188,7 @@ etherh_setif(struct net_device *dev)
 static int
 etherh_getifstat(struct net_device *dev)
 {
-	struct etherh_priv *eh = (struct etherh_priv *)dev->priv;
+	struct etherh_priv *eh = dev->priv;
 	struct ei_device *ei_local = &eh->eidev;
 	int stat = 0;
 

_


--
~Randy
--
~Randy
