From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] use netdev_priv() in net/arm drivers
Date: Thu, 4 Mar 2004 13:19:22 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304131922.1eab1cb4.rddunlap@osdl.org>
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



 linux-264-302-priv-rddunlap/drivers/net/arm/am79c961a.c |   20 +++++++-------
 linux-264-302-priv-rddunlap/drivers/net/arm/ether1.c    |   20 +++++++-------
 linux-264-302-priv-rddunlap/drivers/net/arm/ether3.c    |   22 ++++++++--------
 linux-264-302-priv-rddunlap/drivers/net/arm/etherh.c    |   18 ++++++-------
 4 files changed, 40 insertions(+), 40 deletions(-)

diff -puN drivers/net/arm/am79c961a.c~net_arm_casts drivers/net/arm/am79c961a.c
--- linux-264-302-priv/drivers/net/arm/am79c961a.c~net_arm_casts	2004-03-02 15:08:30.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/arm/am79c961a.c	2004-03-02 15:15:12.000000000 -0800
@@ -196,7 +196,7 @@ am79c961_ramtest(struct net_device *dev,
 static void
 am79c961_init_for_open(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 	unsigned long flags;
 	unsigned char *p;
 	u_int hdr_addr, first_free_addr;
@@ -271,7 +271,7 @@ am79c961_init_for_open(struct net_device
 static void am79c961_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 	unsigned int lnkstat, carrier;
 
 	lnkstat = read_ireg(dev->base_addr, ISALED0) & ISALED0_LNKST;
@@ -291,7 +291,7 @@ static void am79c961_timer(unsigned long
 static int
 am79c961_open(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 	int ret;
 
 	memset (&priv->stats, 0, sizeof (priv->stats));
@@ -318,7 +318,7 @@ am79c961_open(struct net_device *dev)
 static int
 am79c961_close(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 	unsigned long flags;
 
 	del_timer_sync(&priv->timer);
@@ -341,7 +341,7 @@ am79c961_close(struct net_device *dev)
  */
 static struct net_device_stats *am79c961_getstats (struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 	return &priv->stats;
 }
 
@@ -365,7 +365,7 @@ static void am79c961_mc_hash(struct dev_
  */
 static void am79c961_setmulticastlist (struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 	unsigned long flags;
 	unsigned short multi_hash[4], mode;
 	int i, stopped;
@@ -444,7 +444,7 @@ static void am79c961_timeout(struct net_
 static int
 am79c961_sendpacket(struct sk_buff *skb, struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 	unsigned int hdraddr, bufaddr;
 	unsigned int head;
 	unsigned long flags;
@@ -593,7 +593,7 @@ static irqreturn_t
 am79c961_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 	u_int status, n = 100;
 	int handled = 0;
 
@@ -630,7 +630,7 @@ am79c961_interrupt(int irq, void *dev_id
 static int
 am79c961_hw_init(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 
 	spin_lock_irq(&priv->chip_lock);
 	write_rreg (dev->base_addr, CSR0, CSR0_STOP);
@@ -662,7 +662,7 @@ static int __init am79c961_init(void)
 	if (!dev)
 		goto out;
 
-	priv = dev->priv;
+	priv = netdev_priv(dev);
 
 	/*
 	 * Fixed address and IRQ lines here.
diff -puN drivers/net/arm/ether1.c~net_arm_casts drivers/net/arm/ether1.c
--- linux-264-302-priv/drivers/net/arm/ether1.c~net_arm_casts	2004-03-02 15:08:30.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/arm/ether1.c	2004-03-02 15:11:48.000000000 -0800
@@ -447,7 +447,7 @@ static rbd_t  init_rbd	= {
 static int
 ether1_init_for_open (struct net_device *dev)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = netdev_priv(dev);
 	int i, status, addr, next, next2;
 	int failures = 0;
 	unsigned long timeout;
@@ -616,7 +616,7 @@ ether1_init_for_open (struct net_device 
 static int
 ether1_txalloc (struct net_device *dev, int size)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = netdev_priv(dev);
 	int start, tail;
 
 	size = (size + 1) & ~1;
@@ -642,7 +642,7 @@ ether1_txalloc (struct net_device *dev, 
 static int
 ether1_open (struct net_device *dev)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = netdev_priv(dev);
 
 	if (!is_valid_ether_addr(dev->dev_addr)) {
 		printk(KERN_WARNING "%s: invalid ethernet MAC address\n",
@@ -668,7 +668,7 @@ ether1_open (struct net_device *dev)
 static void
 ether1_timeout(struct net_device *dev)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = netdev_priv(dev);
 
 	printk(KERN_WARNING "%s: transmit timeout, network cable problem?\n",
 		dev->name);
@@ -686,7 +686,7 @@ ether1_timeout(struct net_device *dev)
 static int
 ether1_sendpacket (struct sk_buff *skb, struct net_device *dev)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = netdev_priv(dev);
 	int tmp, tst, nopaddr, txaddr, tbdaddr, dataddr;
 	unsigned long flags;
 	tx_t tx;
@@ -762,7 +762,7 @@ ether1_sendpacket (struct sk_buff *skb, 
 static void
 ether1_xmit_done (struct net_device *dev)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = netdev_priv(dev);
 	nop_t nop;
 	int caddr, tst;
 
@@ -863,7 +863,7 @@ again:
 static void
 ether1_recv_done (struct net_device *dev)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = netdev_priv(dev);
 	int status;
 	int nexttail, rbdaddr;
 	rbd_t rbd;
@@ -919,7 +919,7 @@ static irqreturn_t
 ether1_interrupt (int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = netdev_priv(dev);
 	int status;
 
 	status = ether1_inw (dev, SCB_ADDR, scb_t, scb_status, NORMALIRQS);
@@ -978,7 +978,7 @@ ether1_close (struct net_device *dev)
 static struct net_device_stats *
 ether1_getstats (struct net_device *dev)
 {
-	struct ether1_priv *priv = (struct ether1_priv *)dev->priv;
+	struct ether1_priv *priv = netdev_priv(dev);
 	return &priv->stats;
 }
 
@@ -1030,7 +1030,7 @@ ether1_probe(struct expansion_card *ec, 
 	request_region(dev->base_addr, 16, dev->name);
 	request_region(dev->base_addr + 0x800, 4096, dev->name);
 
-	priv = (struct ether1_priv *)dev->priv;
+	priv = netdev_priv(dev);
 	if ((priv->bus_type = ether1_reset(dev)) == 0) {
 		ret = -ENODEV;
 		goto release;
diff -puN drivers/net/arm/ether3.c~net_arm_casts drivers/net/arm/ether3.c
--- linux-264-302-priv/drivers/net/arm/ether3.c~net_arm_casts	2004-03-02 15:08:30.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/arm/ether3.c	2004-03-02 15:13:34.000000000 -0800
@@ -121,7 +121,7 @@ static inline void ether3_outw(int v, co
 static int
 ether3_setbuffer(struct net_device *dev, buffer_rw_t read, int start)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 	int timeout = 1000;
 
 	ether3_outw(priv->regs.config1 | CFG1_LOCBUFMEM, REG_CONFIG1);
@@ -180,7 +180,7 @@ static void
 ether3_ledoff(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 	ether3_outw(priv->regs.config2 |= CFG2_CTRLO, REG_CONFIG2);
 }
 
@@ -280,7 +280,7 @@ ether3_ramtest(struct net_device *dev, u
 static int __init
 ether3_init_2(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 	int i;
 
 	priv->regs.config1 = CFG1_RECVCOMPSTAT0|CFG1_DMABURST8;
@@ -330,7 +330,7 @@ ether3_init_2(struct net_device *dev)
 static void
 ether3_init_for_open(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 	int i;
 
 	memset(&priv->stats, 0, sizeof(struct net_device_stats));
@@ -434,7 +434,7 @@ ether3_open(struct net_device *dev)
 static int
 ether3_close(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -457,7 +457,7 @@ ether3_close(struct net_device *dev)
  */
 static struct net_device_stats *ether3_getstats(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 	return &priv->stats;
 }
 
@@ -469,7 +469,7 @@ static struct net_device_stats *ether3_g
  */
 static void ether3_setmulticastlist(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 
 	priv->regs.config1 &= ~CFG1_RECVPROMISC;
 
@@ -487,7 +487,7 @@ static void ether3_setmulticastlist(stru
 static void
 ether3_timeout(struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 	unsigned long flags;
 
 	del_timer(&priv->timer);
@@ -518,7 +518,7 @@ ether3_timeout(struct net_device *dev)
 static int
 ether3_sendpacket(struct sk_buff *skb, struct net_device *dev)
 {
-	struct dev_priv *priv = (struct dev_priv *)dev->priv;
+	struct dev_priv *priv = netdev_priv(dev);
 	unsigned long flags;
 	unsigned int length = ETH_ZLEN < skb->len ? skb->len : ETH_ZLEN;
 	unsigned int ptr, next_ptr;
@@ -594,7 +594,7 @@ ether3_interrupt(int irq, void *dev_id, 
 		printk("eth3irq: %d ", irq);
 #endif
 
-	priv = (struct dev_priv *)dev->priv;
+	priv = netdev_priv(dev);
 
 	status = ether3_inw(REG_STATUS);
 
@@ -844,7 +844,7 @@ ether3_probe(struct expansion_card *ec, 
 		goto free;
 	}
 
-	priv = (struct dev_priv *) dev->priv;
+	priv = netdev_priv(dev);
 	init_timer(&priv->timer);
 
 	/* Reset card...
diff -puN drivers/net/arm/etherh.c~net_arm_casts drivers/net/arm/etherh.c
--- linux-264-302-priv/drivers/net/arm/etherh.c~net_arm_casts	2004-03-02 15:08:30.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/arm/etherh.c	2004-03-02 15:15:42.000000000 -0800
@@ -144,7 +144,7 @@ static expansioncard_ops_t etherh_ops = 
 static void
 etherh_setif(struct net_device *dev)
 {
-	struct etherh_priv *eh = (struct etherh_priv *)dev->priv;
+	struct etherh_priv *eh = netdev_priv(dev);
 	struct ei_device *ei_local = &eh->eidev;
 	unsigned long addr, flags;
 
@@ -188,7 +188,7 @@ etherh_setif(struct net_device *dev)
 static int
 etherh_getifstat(struct net_device *dev)
 {
-	struct etherh_priv *eh = (struct etherh_priv *)dev->priv;
+	struct etherh_priv *eh = netdev_priv(dev);
 	struct ei_device *ei_local = &eh->eidev;
 	int stat = 0;
 
@@ -256,7 +256,7 @@ static int etherh_set_config(struct net_
 static void
 etherh_reset(struct net_device *dev)
 {
-	struct ei_device *ei_local = (struct ei_device *) dev->priv;
+	struct ei_device *ei_local = netdev_priv(dev);
 
 	outb_p(E8390_NODMA+E8390_PAGE0+E8390_STOP, dev->base_addr);
 
@@ -283,7 +283,7 @@ etherh_reset(struct net_device *dev)
 static void
 etherh_block_output (struct net_device *dev, int count, const unsigned char *buf, int start_page)
 {
-	struct ei_device *ei_local = (struct ei_device *) dev->priv;
+	struct ei_device *ei_local = netdev_priv(dev);
 	unsigned int addr, dma_addr;
 	unsigned long dma_start;
 
@@ -349,7 +349,7 @@ etherh_block_output (struct net_device *
 static void
 etherh_block_input (struct net_device *dev, int count, struct sk_buff *skb, int ring_offset)
 {
-	struct ei_device *ei_local = (struct ei_device *) dev->priv;
+	struct ei_device *ei_local = netdev_priv(dev);
 	unsigned int addr, dma_addr;
 	unsigned char *buf;
 
@@ -390,7 +390,7 @@ etherh_block_input (struct net_device *d
 static void
 etherh_get_header (struct net_device *dev, struct e8390_pkt_hdr *hdr, int ring_page)
 {
-	struct ei_device *ei_local = (struct ei_device *) dev->priv;
+	struct ei_device *ei_local = netdev_priv(dev);
 	unsigned int addr, dma_addr;
 
 	if (ei_local->dmaing) {
@@ -432,7 +432,7 @@ etherh_get_header (struct net_device *de
 static int
 etherh_open(struct net_device *dev)
 {
-	struct ei_device *ei_local = (struct ei_device *) dev->priv;
+	struct ei_device *ei_local = netdev_priv(dev);
 
 	if (!is_valid_ether_addr(dev->dev_addr)) {
 		printk(KERN_WARNING "%s: invalid ethernet MAC address\n",
@@ -557,7 +557,7 @@ etherh_probe(struct expansion_card *ec, 
 		goto out;
 	}
 
-	eh = dev->priv;
+	eh = netdev_priv(dev);
 
 	spin_lock_init(&eh->eidev.page_lock);
 
@@ -653,7 +653,7 @@ etherh_probe(struct expansion_card *ec, 
 		break;
 	}
 
-	ei_local = (struct ei_device *) dev->priv;
+	ei_local = netdev_priv(dev);
 	if (ec->cid.product == PROD_ANT_ETHERM) {
 		ei_local->tx_start_page = ETHERM_TX_START_PAGE;
 		ei_local->stop_page     = ETHERM_STOP_PAGE;

_


--
~Randy
