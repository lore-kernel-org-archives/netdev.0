From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] natsemi 1: switch to netdev_priv()
Date: Fri, 25 Jun 2004 22:32:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40DC8BC3.2000401@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030208040305040608050303"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030208040305040608050303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jeff,

the attached patch switches natsemi to netdev_priv(). Could you apply it 
to your tree? The diff is against 2.6.7-mm2.

--
    Manfred

--------------030208040305040608050303
Content-Type: text/plain;
 name="patch-natsemi-01-priv"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-natsemi-01-priv"

--- 2.6/drivers/net/natsemi.c	2004-06-25 21:30:08.454557400 +0200
+++ build-2.6/drivers/net/natsemi.c	2004-06-25 21:35:11.666462184 +0200
@@ -749,7 +749,7 @@
 
 static void move_int_phy(struct net_device *dev, int addr)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int target = 31;
 
 	/* 
@@ -840,7 +840,7 @@
 	dev->base_addr = ioaddr;
 	dev->irq = irq;
 
-	np = dev->priv;
+	np = netdev_priv(dev);
 
 	np->pci_dev = pdev;
 	pci_set_drvdata(pdev, dev);
@@ -1102,7 +1102,7 @@
 
 static int mdio_read(struct net_device *dev, int reg)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	/* The 83815 series has two ports:
 	 * - an internal transceiver
@@ -1116,7 +1116,7 @@
 
 static void mdio_write(struct net_device *dev, int reg, u16 data)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	/* The 83815 series has an internal transceiver; handle separately */
 	if (dev->if_port == PORT_TP)
@@ -1127,7 +1127,7 @@
 
 static void init_phy_fixup(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int i;
 	u32 cfg;
@@ -1239,7 +1239,7 @@
 
 static int switch_port_external(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u32 cfg;
 
 	cfg = readl(dev->base_addr + ChipConfig);
@@ -1271,7 +1271,7 @@
 
 static int switch_port_internal(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int i;
 	u32 cfg;
 	u16 bmcr;
@@ -1322,7 +1322,7 @@
  */
 static int find_mii(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int tmp;
 	int i;
 	int did_switch;
@@ -1371,7 +1371,7 @@
 	u32 rfcr;
 	u16 pmatch[3];
 	u16 sopass[3];
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	/*
 	 * Resetting the chip causes some registers to be lost.
@@ -1441,7 +1441,7 @@
 
 static void natsemi_reload_eeprom(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int i;
 
 	writel(EepromReload, dev->base_addr + PCIBusCfg);
@@ -1462,7 +1462,7 @@
 static void natsemi_stop_rxtx(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int i;
 
 	writel(RxOff | TxOff, ioaddr + ChipCmd);
@@ -1482,7 +1482,7 @@
 
 static int netdev_open(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int i;
 
@@ -1531,7 +1531,7 @@
 
 static void do_cable_magic(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	if (dev->if_port != PORT_TP)
 		return;
@@ -1559,7 +1559,7 @@
 		 * (these values all come from National)
 		 */
 		if (!(data & 0x80) || ((data >= 0xd8) && (data <= 0xff))) {
-			struct netdev_private *np = dev->priv;
+			struct netdev_private *np = netdev_priv(dev);
 
 			/* the bug has been triggered - fix the coefficient */
 			writew(TSTDAT_FIXED, dev->base_addr + TSTDAT);
@@ -1575,7 +1575,7 @@
 static void undo_cable_magic(struct net_device *dev)
 {
 	u16 data;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	if (dev->if_port != PORT_TP)
 		return;
@@ -1593,7 +1593,7 @@
 
 static void check_link(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int duplex;
 	u16 bmsr;
@@ -1654,7 +1654,7 @@
 
 static void init_registers(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	init_phy_fixup(dev);
@@ -1732,7 +1732,7 @@
 static void netdev_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int next_tick = 5*HZ;
 
 	if (netif_msg_timer(np)) {
@@ -1797,7 +1797,7 @@
 
 static void dump_ring(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	if (netif_msg_pktdata(np)) {
 		int i;
@@ -1820,7 +1820,7 @@
 
 static void tx_timeout(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	disable_irq(dev->irq);
@@ -1851,7 +1851,7 @@
 
 static int alloc_ring(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	np->rx_ring = pci_alloc_consistent(np->pci_dev,
 		sizeof(struct netdev_desc) * (RX_RING_SIZE+TX_RING_SIZE),
 		&np->ring_dma);
@@ -1863,7 +1863,7 @@
 
 static void refill_rx(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	/* Refill the Rx ring buffers. */
 	for (; np->cur_rx - np->dirty_rx > 0; np->dirty_rx++) {
@@ -1892,7 +1892,7 @@
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
 static void init_ring(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int i;
 
 	/* 1) TX ring */
@@ -1931,7 +1931,7 @@
 
 static void drain_tx(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int i;
 
 	for (i = 0; i < TX_RING_SIZE; i++) {
@@ -1948,7 +1948,7 @@
 
 static void drain_ring(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+ 	struct netdev_private *np = netdev_priv(dev);
 	unsigned int buflen = np->rx_buf_sz + RX_OFFSET;
 	int i;
 
@@ -1969,7 +1969,7 @@
 
 static void free_ring(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	pci_free_consistent(np->pci_dev,
 		sizeof(struct netdev_desc) * (RX_RING_SIZE+TX_RING_SIZE),
 		np->rx_ring, np->ring_dma);
@@ -1977,7 +1977,7 @@
 
 static void reinit_ring(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int i;
 
 	/* drain TX ring */
@@ -1999,7 +1999,7 @@
 
 static int start_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	unsigned entry;
 
 	/* Note: Ordering is important here, set the field with the
@@ -2046,7 +2046,7 @@
 
 static void netdev_tx_done(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	for (; np->cur_tx - np->dirty_tx > 0; np->dirty_tx++) {
 		int entry = np->dirty_tx % TX_RING_SIZE;
@@ -2092,7 +2092,7 @@
 static irqreturn_t intr_handler(int irq, void *dev_instance, struct pt_regs *rgs)
 {
 	struct net_device *dev = dev_instance;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int boguscnt = max_interrupt_work;
 	unsigned int handled = 0;
@@ -2150,7 +2150,7 @@
    for clarity and better register allocation. */
 static void netdev_rx(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int entry = np->cur_rx % RX_RING_SIZE;
 	int boguscnt = np->dirty_rx + RX_RING_SIZE - np->cur_rx;
 	s32 desc_status = le32_to_cpu(np->rx_head_desc->cmd_status);
@@ -2241,7 +2241,7 @@
 
 static void netdev_error(struct net_device *dev, int intr_status)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	spin_lock(&np->lock);
@@ -2296,7 +2296,7 @@
 static void __get_stats(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	/* The chip only need report frame silently dropped. */
 	np->stats.rx_crc_errors	+= readl(ioaddr + RxCRCErrs);
@@ -2305,7 +2305,7 @@
 
 static struct net_device_stats *get_stats(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	/* The chip only need report frame silently dropped. */
 	spin_lock_irq(&np->lock);
@@ -2320,7 +2320,7 @@
 static void __set_rx_mode(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u8 mc_filter[64]; /* Multicast hash filter */
 	u32 rx_mode;
 
@@ -2357,7 +2357,7 @@
 
 static void set_rx_mode(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	spin_lock_irq(&np->lock);
 	if (!np->hands_off)
 		__set_rx_mode(dev);
@@ -2366,7 +2366,7 @@
 
 static int netdev_ethtool_ioctl(struct net_device *dev, void __user *useraddr)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u32 cmd;
 
 	if (get_user(cmd, (u32 __user *)useraddr))
@@ -2537,7 +2537,7 @@
 
 static int netdev_set_wol(struct net_device *dev, u32 newval)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u32 data = readl(dev->base_addr + WOLCmd) & ~WakeOptsSummary;
 
 	/* translate to bitmasks this chip understands */
@@ -2566,7 +2566,7 @@
 
 static int netdev_get_wol(struct net_device *dev, u32 *supported, u32 *cur)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u32 regval = readl(dev->base_addr + WOLCmd);
 
 	*supported = (WAKE_PHY | WAKE_UCAST | WAKE_MCAST | WAKE_BCAST
@@ -2601,7 +2601,7 @@
 
 static int netdev_set_sopass(struct net_device *dev, u8 *newval)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u16 *sval = (u16 *)newval;
 	u32 addr;
 
@@ -2632,7 +2632,7 @@
 
 static int netdev_get_sopass(struct net_device *dev, u8 *data)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u16 *sval = (u16 *)data;
 	u32 addr;
 
@@ -2660,7 +2660,7 @@
 
 static int netdev_get_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u32 tmp;
 
 	ecmd->port        = dev->if_port;
@@ -2738,7 +2738,7 @@
 
 static int netdev_set_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	if (ecmd->port != PORT_TP && ecmd->port != PORT_MII && ecmd->port != PORT_FIBRE)
 		return -EINVAL;
@@ -2879,7 +2879,7 @@
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct mii_ioctl_data *data = if_mii(rq);
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	switch(cmd) {
 	case SIOCETHTOOL:
@@ -2938,7 +2938,7 @@
 static void enable_wol_mode(struct net_device *dev, int enable_intr)
 {
 	long ioaddr = dev->base_addr;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	if (netif_msg_wol(np))
 		printk(KERN_INFO "%s: remaining active for wake-on-lan\n",
@@ -2971,7 +2971,7 @@
 static int netdev_close(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	if (netif_msg_ifdown(np))
 		printk(KERN_DEBUG
@@ -3083,7 +3083,7 @@
 static int natsemi_suspend (struct pci_dev *pdev, u32 state)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	rtnl_lock();
@@ -3130,7 +3130,7 @@
 static int natsemi_resume (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	rtnl_lock();
 	if (netif_device_present(dev))

--------------030208040305040608050303--
