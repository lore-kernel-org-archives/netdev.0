From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] use netdev_priv() in 3com net drivers
Date: Thu, 4 Mar 2004 13:18:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304131858.14057195.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



| From: Carlo Perassi <carlo@linux.it>
| and Randy.Dunlap <rddunlap@osdl.org>

--
~Randy




 linux-264-302-priv-rddunlap/drivers/net/3c501.c |   16 +++----
 linux-264-302-priv-rddunlap/drivers/net/3c507.c |   18 ++++----
 linux-264-302-priv-rddunlap/drivers/net/3c509.c |   34 ++++++++--------
 linux-264-302-priv-rddunlap/drivers/net/3c527.c |   38 +++++++++---------
 linux-264-302-priv-rddunlap/drivers/net/3c59x.c |   50 ++++++++++++------------
 5 files changed, 78 insertions(+), 78 deletions(-)

diff -puN drivers/net/3c501.c~net_3cxyz_casts drivers/net/3c501.c
--- linux-264-302-priv/drivers/net/3c501.c~net_3cxyz_casts	2004-03-03 11:10:48.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/3c501.c	2004-03-03 11:12:56.000000000 -0800
@@ -306,7 +306,7 @@ static int __init el1_probe1(struct net_
 		printk(KERN_DEBUG "%s", version);
 
 	memset(dev->priv, 0, sizeof(struct net_local));
-	lp=dev->priv;
+	lp = netdev_priv(dev);
 	spin_lock_init(&lp->lock);
 	
 	/*
@@ -341,7 +341,7 @@ static int el_open(struct net_device *de
 {
 	int retval;
 	int ioaddr = dev->base_addr;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	if (el_debug > 2)
@@ -371,7 +371,7 @@ static int el_open(struct net_device *de
  
 static void el_timeout(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
  
 	if (el_debug)
@@ -411,7 +411,7 @@ static void el_timeout(struct net_device
 
 static int el_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -524,7 +524,7 @@ static irqreturn_t el_interrupt(int irq,
 	int axsr;			/* Aux. status reg. */
 
 	ioaddr = dev->base_addr;
-	lp = (struct net_local *)dev->priv;
+	lp = netdev_priv(dev);
 
 	spin_lock(&lp->lock);
 	
@@ -698,7 +698,7 @@ out:
 
 static void el_receive(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int pkt_len;
 	struct sk_buff *skb;
@@ -764,7 +764,7 @@ static void el_receive(struct net_device
 
 static void  el_reset(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	if (el_debug> 2)
@@ -828,7 +828,7 @@ static int el1_close(struct net_device *
  
 static struct net_device_stats *el1_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	return &lp->stats;
 }
 
diff -puN drivers/net/3c507.c~net_3cxyz_casts drivers/net/3c507.c
--- linux-264-302-priv/drivers/net/3c507.c~net_3cxyz_casts	2004-03-03 11:10:48.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/3c507.c	2004-03-03 11:16:05.000000000 -0800
@@ -441,7 +441,7 @@ static int __init el16_probe1(struct net
 	if (net_debug)
 		printk(version);
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
  	memset(lp, 0, sizeof(*lp));
 	spin_lock_init(&lp->lock);
 
@@ -471,7 +471,7 @@ static int el16_open(struct net_device *
 
 static void el16_tx_timeout (struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *) dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned long shmem = dev->mem_start;
 
@@ -501,7 +501,7 @@ static void el16_tx_timeout (struct net_
 
 static int el16_send_packet (struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *) dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 	short length = ETH_ZLEN < skb->len ? skb->len : ETH_ZLEN;
@@ -546,7 +546,7 @@ static irqreturn_t el16_interrupt(int ir
 	}
 
 	ioaddr = dev->base_addr;
-	lp = (struct net_local *)dev->priv;
+	lp = netdev_priv(dev);
 	shmem = dev->mem_start;
 
 	spin_lock(&lp->lock);
@@ -660,7 +660,7 @@ static int el16_close(struct net_device 
    closed. */
 static struct net_device_stats *el16_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 
 	/* ToDo: decide if there are any useful statistics from the SCB. */
 
@@ -670,7 +670,7 @@ static struct net_device_stats *el16_get
 /* Initialize the Rx-block list. */
 static void init_rx_bufs(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned long write_ptr;
 	unsigned short SCB_base = SCB_BASE;
 
@@ -713,7 +713,7 @@ static void init_rx_bufs(struct net_devi
 
 static void init_82586_mem(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 	unsigned long shmem = dev->mem_start;
 
@@ -771,7 +771,7 @@ static void init_82586_mem(struct net_de
 
 static void hardware_send_packet(struct net_device *dev, void *buf, short length, short pad)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 	ushort tx_block = lp->tx_head;
 	unsigned long write_ptr = dev->mem_start + tx_block;
@@ -820,7 +820,7 @@ static void hardware_send_packet(struct 
 
 static void el16_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = netdev_priv(dev);
 	unsigned long shmem = dev->mem_start;
 	ushort rx_head = lp->rx_head;
 	ushort rx_tail = lp->rx_tail;
diff -puN drivers/net/3c509.c~net_3cxyz_casts drivers/net/3c509.c
--- linux-264-302-priv/drivers/net/3c509.c~net_3cxyz_casts	2004-03-03 11:10:48.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/3c509.c	2004-03-03 11:19:54.000000000 -0800
@@ -304,7 +304,7 @@ static int nopnp;
 
 static int __init el3_common_init(struct net_device *dev)
 {
-	struct el3_private *lp = dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	short i;
 	int err;
 
@@ -355,7 +355,7 @@ static int __init el3_common_init(struct
 
 static void el3_common_remove (struct net_device *dev)
 {
-		struct el3_private *lp = dev->priv;
+		struct el3_private *lp = netdev_priv(dev);
 
 		(void) lp;				/* Keep gcc quiet... */
 #ifdef CONFIG_PM
@@ -575,7 +575,7 @@ no_pnp:
 	dev->base_addr = ioaddr;
 	dev->irq = irq;
 	dev->if_port = if_port;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 #if defined(__ISAPNP__) && !defined(CONFIG_X86_PC9800)
 	lp->dev = &idev->dev;
 #endif
@@ -671,7 +671,7 @@ static int __init el3_mca_probe(struct d
 		dev->base_addr = ioaddr;
 		dev->irq = irq;
 		dev->if_port = if_port;
-		lp = dev->priv;
+		lp = netdev_priv(dev);
 		lp->dev = device;
 		lp->type = EL3_MCA;
 		device->driver_data = dev;
@@ -732,7 +732,7 @@ static int __init el3_eisa_probe (struct
 	dev->base_addr = ioaddr;
 	dev->irq = irq;
 	dev->if_port = if_port;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->dev = device;
 	lp->type = EL3_EISA;
 	eisa_set_drvdata (edev, dev);
@@ -829,7 +829,7 @@ el3_open(struct net_device *dev)
 static void
 el3_tx_timeout (struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* Transmitter timeout, serious problems. */
@@ -849,7 +849,7 @@ el3_tx_timeout (struct net_device *dev)
 static int
 el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -943,7 +943,7 @@ el3_interrupt(int irq, void *dev_id, str
 		return IRQ_NONE;
 	}
 
-	lp = (struct el3_private *)dev->priv;
+	lp = netdev_priv(dev);
 	spin_lock(&lp->lock);
 
 	ioaddr = dev->base_addr;
@@ -975,7 +975,7 @@ el3_interrupt(int irq, void *dev_id, str
 				outw(AckIntr | RxEarly, ioaddr + EL3_CMD);
 			}
 			if (status & TxComplete) {			/* Really Tx error. */
-				struct el3_private *lp = (struct el3_private *)dev->priv;
+				struct el3_private *lp = netdev_priv(dev);
 				short tx_status;
 				int i = 4;
 
@@ -1022,7 +1022,7 @@ el3_interrupt(int irq, void *dev_id, str
 static struct net_device_stats *
 el3_get_stats(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	/*
@@ -1043,7 +1043,7 @@ el3_get_stats(struct net_device *dev)
 	*/
 static void update_stats(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	if (el3_debug > 5)
@@ -1073,7 +1073,7 @@ static void update_stats(struct net_devi
 static int
 el3_rx(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	short rx_status;
 
@@ -1145,7 +1145,7 @@ static void
 set_multicast_list(struct net_device *dev)
 {
 	unsigned long flags;
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	if (el3_debug > 1) {
@@ -1172,7 +1172,7 @@ static int
 el3_close(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 	
 	if (el3_debug > 2)
 		printk("%s: Shutting down ethercard.\n", dev->name);
@@ -1317,7 +1317,7 @@ static int
 netdev_ethtool_ioctl (struct net_device *dev, void *useraddr)
 {
 	u32 ethcmd;
-	struct el3_private *lp = dev->priv;
+	struct el3_private *lp = netdev_priv(dev);
 
 	/* dev_ioctl() in ../../net/core/dev.c has already checked
 	   capable(CAP_NET_ADMIN), so don't bother with that here.  */
@@ -1558,7 +1558,7 @@ el3_suspend(struct pm_dev *pdev)
 		return -EINVAL;
 
 	dev = (struct net_device *)pdev->data;
-	lp = (struct el3_private *)dev->priv;
+	lp = netdev_priv(dev);
 	ioaddr = dev->base_addr;
 
 	spin_lock_irqsave(&lp->lock, flags);
@@ -1585,7 +1585,7 @@ el3_resume(struct pm_dev *pdev)
 		return -EINVAL;
 
 	dev = (struct net_device *)pdev->data;
-	lp = (struct el3_private *)dev->priv;
+	lp = netdev_priv(dev);
 	ioaddr = dev->base_addr;
 
 	spin_lock_irqsave(&lp->lock, flags);
diff -puN drivers/net/3c527.c~net_3cxyz_casts drivers/net/3c527.c
--- linux-264-302-priv/drivers/net/3c527.c~net_3cxyz_casts	2004-03-03 11:10:48.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/3c527.c	2004-03-03 11:37:11.000000000 -0800
@@ -226,7 +226,7 @@ static struct ethtool_ops netdev_ethtool
 
 static void cleanup_card(struct net_device *dev)
 {
-	struct mc32_local *lp=dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	unsigned slot = lp->slot;
 	mca_mark_as_unused(slot);
 	mca_set_adapter_name(slot, NULL);
@@ -307,7 +307,7 @@ static int __init mc32_probe1(struct net
 	int i, err;
 	u8 POS;
 	u32 base;
-	struct mc32_local *lp = dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	static u16 mca_io_bases[]={
 		0x7280,0x7290,
 		0x7680,0x7690,
@@ -573,7 +573,7 @@ static inline void mc32_ready_poll(struc
 
 static int mc32_command_nowait(struct net_device *dev, u16 cmd, void *data, int len)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int ret = -1;
 
@@ -619,7 +619,7 @@ static int mc32_command_nowait(struct ne
   
 static int mc32_command(struct net_device *dev, u16 cmd, void *data, int len)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int ret = 0;
 	
@@ -671,7 +671,7 @@ static int mc32_command(struct net_devic
 
 static void mc32_start_transceiver(struct net_device *dev) {
 
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* Ignore RX overflow on device closure */ 
@@ -706,7 +706,7 @@ static void mc32_start_transceiver(struc
 
 static void mc32_halt_transceiver(struct net_device *dev) 
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	mc32_ready_poll(dev);	
@@ -743,7 +743,7 @@ static void mc32_halt_transceiver(struct
 	 
 static int mc32_load_rx_ring(struct net_device *dev)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	int i;
 	u16 rx_base;
 	volatile struct skb_header *p;
@@ -792,7 +792,7 @@ static int mc32_load_rx_ring(struct net_
 
 static void mc32_flush_rx_ring(struct net_device *dev)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	int i; 
 
 	for(i=0; i < RX_RING_LEN; i++) 
@@ -824,7 +824,7 @@ static void mc32_flush_rx_ring(struct ne
 
 static void mc32_load_tx_ring(struct net_device *dev)
 { 
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	volatile struct skb_header *p;
 	int i; 
 	u16 tx_base;
@@ -861,7 +861,7 @@ static void mc32_load_tx_ring(struct net
 
 static void mc32_flush_tx_ring(struct net_device *dev)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	int i;
 
 	for (i=0; i < TX_RING_LEN; i++)
@@ -899,7 +899,7 @@ static void mc32_flush_tx_ring(struct ne
 static int mc32_open(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	u8 one=1;
 	u8 regs;
 	u16 descnumbuffs[2] = {TX_RING_LEN, RX_RING_LEN};
@@ -1022,7 +1022,7 @@ static void mc32_timeout(struct net_devi
 
 static int mc32_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	u32 head = atomic_read(&lp->tx_ring_head);
 	
 	volatile struct skb_header *p, *np;
@@ -1092,7 +1092,7 @@ static int mc32_send_packet(struct sk_bu
 
 static void mc32_update_stats(struct net_device *dev)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	volatile struct mc32_stats *st = lp->stats; 
 
 	u32 rx_errors=0; 
@@ -1143,7 +1143,7 @@ static void mc32_update_stats(struct net
 
 static void mc32_rx_ring(struct net_device *dev)
 {
-	struct mc32_local *lp=dev->priv;		
+	struct mc32_local *lp = netdev_priv(dev);
 	volatile struct skb_header *p;
 	u16 rx_ring_tail;
 	u16 rx_old_tail;
@@ -1236,7 +1236,7 @@ static void mc32_rx_ring(struct net_devi
 
 static void mc32_tx_ring(struct net_device *dev) 
 {
-	struct mc32_local *lp=(struct mc32_local *)dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	volatile struct skb_header *np;
 
 	/*
@@ -1333,7 +1333,7 @@ static irqreturn_t mc32_interrupt(int ir
 	}
  
 	ioaddr = dev->base_addr;
-	lp = (struct mc32_local *)dev->priv;
+	lp = netdev_priv(dev);
 
 	/* See whats cooking */
 
@@ -1450,7 +1450,7 @@ static irqreturn_t mc32_interrupt(int ir
 
 static int mc32_close(struct net_device *dev)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	u8 regs;
@@ -1499,7 +1499,7 @@ static int mc32_close(struct net_device 
 
 static struct net_device_stats *mc32_get_stats(struct net_device *dev)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	
 	mc32_update_stats(dev); 
 	return &lp->net_stats;
@@ -1531,7 +1531,7 @@ static struct net_device_stats *mc32_get
 
 static void do_mc32_set_multicast_list(struct net_device *dev, int retry)
 {
-	struct mc32_local *lp = (struct mc32_local *)dev->priv;
+	struct mc32_local *lp = netdev_priv(dev);
 	u16 filt = (1<<2); /* Save Bad Packets, for stats purposes */ 
 
 	if (dev->flags&IFF_PROMISC)
diff -puN drivers/net/3c59x.c~net_3cxyz_casts drivers/net/3c59x.c
--- linux-264-302-priv/drivers/net/3c59x.c~net_3cxyz_casts	2004-03-03 11:10:48.000000000 -0800
+++ linux-264-302-priv-rddunlap/drivers/net/3c59x.c	2004-03-03 11:26:59.000000000 -0800
@@ -1013,7 +1013,7 @@ static int vortex_eisa_remove (struct de
 		BUG();
 	}
 
-	vp = dev->priv;
+	vp = netdev_priv(dev);
 	ioaddr = dev->base_addr;
 	
 	unregister_netdev (dev);
@@ -1115,7 +1115,7 @@ static int __devinit vortex_probe1(struc
 	}
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, gendev);
-	vp = dev->priv;
+	vp = netdev_priv(dev);
 
 	option = global_options;
 
@@ -1516,7 +1516,7 @@ static void
 vortex_up(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	unsigned int config;
 	int i;
 
@@ -1714,7 +1714,7 @@ vortex_up(struct net_device *dev)
 static int
 vortex_open(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	int i;
 	int retval;
 
@@ -1772,7 +1772,7 @@ static void
 vortex_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int next_tick = 60*HZ;
 	int ok = 0;
@@ -1898,7 +1898,7 @@ leave_media_alone:
 
 static void vortex_tx_timeout(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	printk(KERN_ERR "%s: transmit timed out, tx_status %2.2x status %4.4x.\n",
@@ -1968,7 +1968,7 @@ static void vortex_tx_timeout(struct net
 static void
 vortex_error(struct net_device *dev, int status)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int do_tx_reset = 0, reset_mask = 0;
 	unsigned char tx_status = 0;
@@ -2070,7 +2070,7 @@ vortex_error(struct net_device *dev, int
 static int
 vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	/* Put out the doubleword header... */
@@ -2125,7 +2125,7 @@ vortex_start_xmit(struct sk_buff *skb, s
 static int
 boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	/* Calculate the next Tx descriptor entry. */
 	int entry = vp->cur_tx % TX_RING_SIZE;
@@ -2225,7 +2225,7 @@ static irqreturn_t
 vortex_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = dev_id;
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	long ioaddr;
 	int status;
 	int work_done = max_interrupt_work;
@@ -2330,7 +2330,7 @@ static irqreturn_t
 boomerang_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = dev_id;
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	long ioaddr;
 	int status;
 	int work_done = max_interrupt_work;
@@ -2455,7 +2455,7 @@ handler_exit:
 
 static int vortex_rx(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int i;
 	short rx_status;
@@ -2525,7 +2525,7 @@ static int vortex_rx(struct net_device *
 static int
 boomerang_rx(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	int entry = vp->cur_rx % RX_RING_SIZE;
 	long ioaddr = dev->base_addr;
 	int rx_status;
@@ -2627,7 +2627,7 @@ static void
 rx_oom_timer(unsigned long arg)
 {
 	struct net_device *dev = (struct net_device *)arg;
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 
 	spin_lock_irq(&vp->lock);
 	if ((vp->cur_rx - vp->dirty_rx) == RX_RING_SIZE)	/* This test is redundant, but makes me feel good */
@@ -2642,7 +2642,7 @@ rx_oom_timer(unsigned long arg)
 static void
 vortex_down(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	netif_stop_queue (dev);
@@ -2678,7 +2678,7 @@ vortex_down(struct net_device *dev)
 static int
 vortex_close(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int i;
 
@@ -2740,7 +2740,7 @@ static void
 dump_tx_ring(struct net_device *dev)
 {
 	if (vortex_debug > 0) {
-		struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 		long ioaddr = dev->base_addr;
 		
 		if (vp->full_bus_master_tx) {
@@ -2773,7 +2773,7 @@ dump_tx_ring(struct net_device *dev)
 
 static struct net_device_stats *vortex_get_stats(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	unsigned long flags;
 
 	if (netif_device_present(dev)) {	/* AKPM: Used to be netif_running */
@@ -2793,7 +2793,7 @@ static struct net_device_stats *vortex_g
 	*/
 static void update_stats(long ioaddr, struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	int old_window = inw(ioaddr + EL3_CMD);
 
 	if (old_window == 0xffff)	/* Chip suspended or ejected. */
@@ -2834,7 +2834,7 @@ static void update_stats(long ioaddr, st
 static void vortex_get_drvinfo(struct net_device *dev,
 					struct ethtool_drvinfo *info)
 {
-	struct vortex_private *vp = dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -2855,7 +2855,7 @@ static struct ethtool_ops vortex_ethtool
 
 static int vortex_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	struct mii_ioctl_data *data = (struct mii_ioctl_data *)&rq->ifr_data;
 	int phy = vp->phys[0] & 0x1f;
@@ -2942,7 +2942,7 @@ static void mdio_sync(long ioaddr, int b
 
 static int mdio_read(struct net_device *dev, int phy_id, int location)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	int i;
 	long ioaddr = dev->base_addr;
 	int read_cmd = (0xf6 << 10) | (phy_id << 5) | location;
@@ -2976,7 +2976,7 @@ static int mdio_read(struct net_device *
 
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int write_cmd = 0x50020000 | (phy_id << 23) | (location << 18) | value;
 	long mdio_addr = ioaddr + Wn4_PhysicalMgmt;
@@ -3010,7 +3010,7 @@ static void mdio_write(struct net_device
 /* Set Wake-On-LAN mode and put the board into D3 (power-down) state. */
 static void acpi_set_WOL(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	/* Power up on: 1==Downloaded Filter, 2==Magic Packets, 4==Link Status. */
@@ -3036,7 +3036,7 @@ static void __devexit vortex_remove_one 
 		BUG();
 	}
 
-	vp = dev->priv;
+	vp = netdev_priv(dev);
 
 	/* AKPM: FIXME: we should have
 	 *	if (vp->cb_fn_base) iounmap(vp->cb_fn_base);

_


--
~Randy
