From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] convert natsemi.c to netdev_priv
Date: Sun, 20 Jun 2004 14:30:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D5836D.4090503@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010206030700040001010702"
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010206030700040001010702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jeff,

the attached promised patch that converts natsemi to netdev_priv() 
instead of directly dereferencing dev->priv, no other changes.
The patch is relative to my previous patch that updates the RxAcceptLong 
handling.

Could you apply it to your tree? Thanks.

--
    Manfred

--------------010206030700040001010702
Content-Type: text/plain;
 name="patch-natsemi-priv"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-natsemi-priv"

--- 2.6/drivers/net/natsemi.c	2004-06-20 14:17:48.713142163 +0200
+++ build-2.6/drivers/net/natsemi.c	2004-06-20 14:17:35.052055243 +0200
@@ -756,7 +756,7 @@
 
 static void move_int_phy(struct net_device *dev, int addr)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int target = 31;
 
 	/* 
@@ -847,7 +847,7 @@
 	dev->base_addr = ioaddr;
 	dev->irq = irq;
 
-	np = dev->priv;
+	np = netdev_priv(dev);
 
 	np->pci_dev = pdev;
 	pci_set_drvdata(pdev, dev);
@@ -1109,7 +1109,7 @@
 
 static int mdio_read(struct net_device *dev, int reg)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	/* The 83815 series has two ports:
 	 * - an internal transceiver
@@ -1123,7 +1123,7 @@
 
 static void mdio_write(struct net_device *dev, int reg, u16 data)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	/* The 83815 series has an internal transceiver; handle separately */
 	if (dev->if_port == PORT_TP)
@@ -1134,7 +1134,7 @@
 
 static void init_phy_fixup(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int i;
 	u32 cfg;
@@ -1246,7 +1246,7 @@
 
 static int switch_port_external(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u32 cfg;
 
 	cfg = readl(dev->base_addr + ChipConfig);
@@ -1278,7 +1278,7 @@
 
 static int switch_port_internal(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int i;
 	u32 cfg;
 	u16 bmcr;
@@ -1329,7 +1329,7 @@
  */
 static int find_mii(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int tmp;
 	int i;
 	int did_switch;
@@ -1378,7 +1378,7 @@
 	u32 rfcr;
 	u16 pmatch[3];
 	u16 sopass[3];
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	/*
 	 * Resetting the chip causes some registers to be lost.
@@ -1448,7 +1448,7 @@
 
 static void natsemi_reload_eeprom(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int i;
 
 	writel(EepromReload, dev->base_addr + PCIBusCfg);
@@ -1469,7 +1469,7 @@
 static void natsemi_stop_rxtx(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int i;
 
 	writel(RxOff | TxOff, ioaddr + ChipCmd);
@@ -1489,7 +1489,7 @@
 
 static int netdev_open(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int i;
 
@@ -1538,7 +1538,7 @@
 
 static void do_cable_magic(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	if (dev->if_port != PORT_TP)
 		return;
@@ -1566,7 +1566,7 @@
 		 * (these values all come from National)
 		 */
 		if (!(data & 0x80) || ((data >= 0xd8) && (data <= 0xff))) {
-			struct netdev_private *np = dev->priv;
+			struct netdev_private *np = netdev_priv(dev);
 
 			/* the bug has been triggered - fix the coefficient */
 			writew(TSTDAT_FIXED, dev->base_addr + TSTDAT);
@@ -1582,7 +1582,7 @@
 static void undo_cable_magic(struct net_device *dev)
 {
 	u16 data;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	if (dev->if_port != PORT_TP)
 		return;
@@ -1600,7 +1600,7 @@
 
 static void check_link(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int duplex;
 	u16 bmsr;
@@ -1661,7 +1661,7 @@
 
 static void init_registers(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	init_phy_fixup(dev);
@@ -1739,7 +1739,7 @@
 static void netdev_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int next_tick = 5*HZ;
 
 	if (netif_msg_timer(np)) {
@@ -1804,7 +1804,7 @@
 
 static void dump_ring(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	if (netif_msg_pktdata(np)) {
 		int i;
@@ -1827,7 +1827,7 @@
 
 static void tx_timeout(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	disable_irq(dev->irq);
@@ -1858,7 +1858,7 @@
 
 static int alloc_ring(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	np->rx_ring = pci_alloc_consistent(np->pci_dev,
 		sizeof(struct netdev_desc) * (RX_RING_SIZE+TX_RING_SIZE),
 		&np->ring_dma);
@@ -1870,7 +1870,7 @@
 
 static void refill_rx(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	/* Refill the Rx ring buffers. */
 	for (; np->cur_rx - np->dirty_rx > 0; np->dirty_rx++) {
@@ -1899,7 +1899,7 @@
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
 static void init_ring(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int i;
 
 	/* 1) TX ring */
@@ -1942,7 +1942,7 @@
 
 static void drain_tx(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int i;
 
 	for (i = 0; i < TX_RING_SIZE; i++) {
@@ -1959,7 +1959,7 @@
 
 static void drain_ring(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	unsigned int buflen = np->rx_buf_sz;
 	int i;
 
@@ -1980,7 +1980,7 @@
 
 static void free_ring(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	pci_free_consistent(np->pci_dev,
 		sizeof(struct netdev_desc) * (RX_RING_SIZE+TX_RING_SIZE),
 		np->rx_ring, np->ring_dma);
@@ -1988,7 +1988,7 @@
 
 static void reinit_ring(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int i;
 
 	/* drain TX ring */
@@ -2010,7 +2010,7 @@
 
 static int start_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	unsigned entry;
 
 	/* Note: Ordering is important here, set the field with the
@@ -2057,7 +2057,7 @@
 
 static void netdev_tx_done(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	for (; np->cur_tx - np->dirty_tx > 0; np->dirty_tx++) {
 		int entry = np->dirty_tx % TX_RING_SIZE;
@@ -2103,7 +2103,7 @@
 static irqreturn_t intr_handler(int irq, void *dev_instance, struct pt_regs *rgs)
 {
 	struct net_device *dev = dev_instance;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int boguscnt = max_interrupt_work;
 	unsigned int handled = 0;
@@ -2161,7 +2161,7 @@
    for clarity and better register allocation. */
 static void netdev_rx(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	int entry = np->cur_rx % RX_RING_SIZE;
 	int boguscnt = np->dirty_rx + RX_RING_SIZE - np->cur_rx;
 	s32 desc_status = le32_to_cpu(np->rx_head_desc->cmd_status);
@@ -2257,7 +2257,7 @@
 
 static void netdev_error(struct net_device *dev, int intr_status)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	spin_lock(&np->lock);
@@ -2312,7 +2312,7 @@
 static void __get_stats(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	/* The chip only need report frame silently dropped. */
 	np->stats.rx_crc_errors	+= readl(ioaddr + RxCRCErrs);
@@ -2321,7 +2321,7 @@
 
 static struct net_device_stats *get_stats(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	/* The chip only need report frame silently dropped. */
 	spin_lock_irq(&np->lock);
@@ -2336,7 +2336,7 @@
 static void __set_rx_mode(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u8 mc_filter[64]; /* Multicast hash filter */
 	u32 rx_mode;
 
@@ -2373,7 +2373,7 @@
 
 static void set_rx_mode(struct net_device *dev)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	spin_lock_irq(&np->lock);
 	if (!np->hands_off)
 		__set_rx_mode(dev);
@@ -2382,7 +2382,7 @@
 
 static int netdev_ethtool_ioctl(struct net_device *dev, void __user *useraddr)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u32 cmd;
 
 	if (get_user(cmd, (u32 __user *)useraddr))
@@ -2553,7 +2553,7 @@
 
 static int netdev_set_wol(struct net_device *dev, u32 newval)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u32 data = readl(dev->base_addr + WOLCmd) & ~WakeOptsSummary;
 
 	/* translate to bitmasks this chip understands */
@@ -2582,7 +2582,7 @@
 
 static int netdev_get_wol(struct net_device *dev, u32 *supported, u32 *cur)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u32 regval = readl(dev->base_addr + WOLCmd);
 
 	*supported = (WAKE_PHY | WAKE_UCAST | WAKE_MCAST | WAKE_BCAST
@@ -2617,7 +2617,7 @@
 
 static int netdev_set_sopass(struct net_device *dev, u8 *newval)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u16 *sval = (u16 *)newval;
 	u32 addr;
 
@@ -2648,7 +2648,7 @@
 
 static int netdev_get_sopass(struct net_device *dev, u8 *data)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u16 *sval = (u16 *)data;
 	u32 addr;
 
@@ -2676,7 +2676,7 @@
 
 static int netdev_get_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	u32 tmp;
 
 	ecmd->port        = dev->if_port;
@@ -2754,7 +2754,7 @@
 
 static int netdev_set_ecmd(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	if (ecmd->port != PORT_TP && ecmd->port != PORT_MII && ecmd->port != PORT_FIBRE)
 		return -EINVAL;
@@ -2896,7 +2896,7 @@
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct mii_ioctl_data *data = if_mii(rq);
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	switch(cmd) {
 	case SIOCETHTOOL:
@@ -2955,7 +2955,7 @@
 static void enable_wol_mode(struct net_device *dev, int enable_intr)
 {
 	long ioaddr = dev->base_addr;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	if (netif_msg_wol(np))
 		printk(KERN_INFO "%s: remaining active for wake-on-lan\n",
@@ -2988,7 +2988,7 @@
 static int netdev_close(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	if (netif_msg_ifdown(np))
 		printk(KERN_DEBUG
@@ -3100,7 +3100,7 @@
 static int natsemi_suspend (struct pci_dev *pdev, u32 state)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	rtnl_lock();
@@ -3147,7 +3147,7 @@
 static int natsemi_resume (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct netdev_private *np = dev->priv;
+	struct netdev_private *np = netdev_priv(dev);
 
 	rtnl_lock();
 	if (netif_device_present(dev))

--------------010206030700040001010702--
