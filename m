From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4] 8139too: use netdev_priv
Date: Fri, 15 Oct 2004 15:33:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015153354.0c007eae@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use netdev_priv where appropriate, and get rid of "can't happen anymore" assert's.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/8139too.c b/drivers/net/8139too.c
--- a/drivers/net/8139too.c	2004-10-15 15:25:02 -07:00
+++ b/drivers/net/8139too.c	2004-10-15 15:25:02 -07:00
@@ -734,13 +734,10 @@
 
 static void __rtl8139_cleanup_dev (struct net_device *dev)
 {
-	struct rtl8139_private *tp;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	struct pci_dev *pdev;
 
 	assert (dev != NULL);
-	assert (dev->priv != NULL);
-
-	tp = dev->priv;
 	assert (tp->pci_dev != NULL);
 	pdev = tp->pci_dev;
 
@@ -792,7 +789,7 @@
 
 	*dev_out = NULL;
 
-	/* dev and dev->priv zeroed in alloc_etherdev */
+	/* dev and priv zeroed in alloc_etherdev */
 	dev = alloc_etherdev (sizeof (*tp));
 	if (dev == NULL) {
 		printk (KERN_ERR PFX "%s: Unable to alloc new net device\n", pci_name(pdev));
@@ -801,7 +798,7 @@
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 	tp->pci_dev = pdev;
 
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
@@ -983,8 +980,8 @@
 		return i;
 
 	assert (dev != NULL);
-	tp = dev->priv;
-	assert (tp != NULL);
+	tp = netdev_priv(dev);
+
 	ioaddr = tp->mmio_addr;
 	assert (ioaddr != NULL);
 
@@ -1017,8 +1014,8 @@
 
 	dev->irq = pdev->irq;
 
-	/* dev->priv/tp zeroed and aligned in alloc_etherdev */
-	tp = dev->priv;
+	/* tp zeroed and aligned in alloc_etherdev */
+	tp = netdev_priv(dev);
 
 	/* note: tp->chipset set in rtl8139_init_board */
 	tp->drv_flags = board_info[ent->driver_data].hw_flags;
@@ -1123,11 +1120,8 @@
 static void __devexit rtl8139_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct rtl8139_private *np;
 
 	assert (dev != NULL);
-	np = dev->priv;
-	assert (np != NULL);
 
 	unregister_netdev (dev);
 
@@ -1241,7 +1235,7 @@
 
 static int mdio_read (struct net_device *dev, int phy_id, int location)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	int retval = 0;
 #ifdef CONFIG_8139TOO_8129
 	void *mdio_addr = tp->mmio_addr + Config4;
@@ -1283,7 +1277,7 @@
 static void mdio_write (struct net_device *dev, int phy_id, int location,
 			int value)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 #ifdef CONFIG_8139TOO_8129
 	void *mdio_addr = tp->mmio_addr + Config4;
 	int mii_cmd = (0x5002 << 16) | (phy_id << 23) | (location << 18) | value;
@@ -1326,7 +1320,7 @@
 
 static int rtl8139_open (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	int retval;
 	void *ioaddr = tp->mmio_addr;
 
@@ -1374,7 +1368,7 @@
 
 static void rtl_check_media (struct net_device *dev, unsigned int init_media)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 
 	if (tp->phys[0] >= 0) {
 		mii_check_media(&tp->mii, netif_msg_link(tp), init_media);
@@ -1384,7 +1378,7 @@
 /* Start the hardware at open or resume. */
 static void rtl8139_hw_start (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u32 i;
 	u8 tmp;
@@ -1451,7 +1445,7 @@
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
 static void rtl8139_init_ring (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	int i;
 
 	tp->cur_rx = 0;
@@ -1618,7 +1612,7 @@
 static int rtl8139_thread (void *data)
 {
 	struct net_device *dev = data;
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	unsigned long timeout;
 
 	daemonize("%s", dev->name);
@@ -1650,7 +1644,7 @@
 
 static void rtl8139_start_thread(struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 
 	tp->thr_pid = -1;
 	tp->twistie = 0;
@@ -1678,7 +1672,7 @@
 
 static void rtl8139_tx_timeout (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int i;
 	u8 tmp8;
@@ -1723,7 +1717,7 @@
 
 static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned int entry;
 	unsigned int len = skb->len;
@@ -1771,7 +1765,6 @@
 	unsigned long dirty_tx, tx_left;
 
 	assert (dev != NULL);
-	assert (tp != NULL);
 	assert (ioaddr != NULL);
 
 	dirty_tx = tp->dirty_tx;
@@ -2130,7 +2123,7 @@
 
 static int rtl8139_poll(struct net_device *dev, int *budget)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int orig_budget = min(*budget, dev->quota);
 	int done = 1;
@@ -2168,7 +2161,7 @@
 			       struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u16 status, ackstat;
 	int link_changed = 0; /* avoid bogus "uninit" warning */
@@ -2244,7 +2237,7 @@
 
 static int rtl8139_close (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int ret = 0;
 	unsigned long flags;
@@ -2307,7 +2300,7 @@
    other threads or interrupts aren't messing with the 8139.  */
 static void rtl8139_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	void *ioaddr = np->mmio_addr;
 
 	spin_lock_irq(&np->lock);
@@ -2341,7 +2334,7 @@
    aren't messing with the 8139.  */
 static int rtl8139_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	void *ioaddr = np->mmio_addr;
 	u32 support;
 	u8 cfg3, cfg5;
@@ -2381,7 +2374,7 @@
 
 static void rtl8139_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
 	strcpy(info->bus_info, pci_name(np->pci_dev));
@@ -2390,7 +2383,7 @@
 
 static int rtl8139_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	spin_lock_irq(&np->lock);
 	mii_ethtool_gset(&np->mii, cmd);
 	spin_unlock_irq(&np->lock);
@@ -2399,7 +2392,7 @@
 
 static int rtl8139_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	int rc;
 	spin_lock_irq(&np->lock);
 	rc = mii_ethtool_sset(&np->mii, cmd);
@@ -2409,25 +2402,25 @@
 
 static int rtl8139_nway_reset(struct net_device *dev)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	return mii_nway_restart(&np->mii);
 }
 
 static u32 rtl8139_get_link(struct net_device *dev)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	return mii_link_ok(&np->mii);
 }
 
 static u32 rtl8139_get_msglevel(struct net_device *dev)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	return np->msg_enable;
 }
 
 static void rtl8139_set_msglevel(struct net_device *dev, u32 datum)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	np->msg_enable = datum;
 }
 
@@ -2438,13 +2431,13 @@
 #else
 static int rtl8139_get_regs_len(struct net_device *dev)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	return np->regs_len;
 }
 
 static void rtl8139_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *regbuf)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 
 	regs->version = RTL_REGS_VER;
 
@@ -2461,7 +2454,7 @@
 
 static void rtl8139_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *stats, u64 *data)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 
 	data[0] = np->xstats.early_rx;
 	data[1] = np->xstats.tx_buf_mapped;
@@ -2493,7 +2486,7 @@
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	int rc;
 
 	if (!netif_running(dev))
@@ -2509,7 +2502,7 @@
 
 static struct net_device_stats *rtl8139_get_stats (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
@@ -2528,7 +2521,7 @@
 
 static void __set_rx_mode (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u32 mc_filter[2];	/* Multicast hash filter */
 	int i, rx_mode;
@@ -2577,7 +2570,7 @@
 static void rtl8139_set_rx_mode (struct net_device *dev)
 {
 	unsigned long flags;
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 
 	spin_lock_irqsave (&tp->lock, flags);
 	__set_rx_mode(dev);
@@ -2589,7 +2582,7 @@
 static int rtl8139_suspend (struct pci_dev *pdev, u32 state)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
@@ -2621,7 +2614,7 @@
 static int rtl8139_resume (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 
 	pci_restore_state (pdev, tp->pci_state);
 	if (!netif_running (dev))
