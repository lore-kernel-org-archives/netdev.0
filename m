From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH] net: 8139too netdev_priv conversion
Date: Wed, 27 Oct 2004 13:29:32 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098872973.9269.1.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Use netdev_priv() in 8139too driver instead of dev->priv.

Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---

 8139too.c |   72 +++++++++++++++++++++++++++++++-------------------------------
 1 files changed, 36 insertions(+), 36 deletions(-)

Index: 2.6.10-rc1-bk1/drivers/net/8139too.c
===================================================================
--- 2.6.10-rc1-bk1.orig/drivers/net/8139too.c	2004-10-24 10:58:03.000000000 +0300
+++ 2.6.10-rc1-bk1/drivers/net/8139too.c	2004-10-27 13:25:23.846685248 +0300
@@ -731,9 +731,9 @@
 	struct pci_dev *pdev;
 
 	assert (dev != NULL);
-	assert (dev->priv != NULL);
 
-	tp = dev->priv;
+	tp = netdev_priv(dev);
+	assert (tp != NULL);
 	assert (tp->pci_dev != NULL);
 	pdev = tp->pci_dev;
 
@@ -794,7 +794,7 @@
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 	tp->pci_dev = pdev;
 
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
@@ -976,7 +976,7 @@
 		return i;
 
 	assert (dev != NULL);
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 	assert (tp != NULL);
 	ioaddr = tp->mmio_addr;
 	assert (ioaddr != NULL);
@@ -1011,7 +1011,7 @@
 	dev->irq = pdev->irq;
 
 	/* dev->priv/tp zeroed and aligned in alloc_etherdev */
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 
 	/* note: tp->chipset set in rtl8139_init_board */
 	tp->drv_flags = board_info[ent->driver_data].hw_flags;
@@ -1119,7 +1119,7 @@
 	struct rtl8139_private *np;
 
 	assert (dev != NULL);
-	np = dev->priv;
+	np = netdev_priv(dev);
 	assert (np != NULL);
 
 	unregister_netdev (dev);
@@ -1234,7 +1234,7 @@
 
 static int mdio_read (struct net_device *dev, int phy_id, int location)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	int retval = 0;
 #ifdef CONFIG_8139TOO_8129
 	void *mdio_addr = tp->mmio_addr + Config4;
@@ -1276,7 +1276,7 @@
 static void mdio_write (struct net_device *dev, int phy_id, int location,
 			int value)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 #ifdef CONFIG_8139TOO_8129
 	void *mdio_addr = tp->mmio_addr + Config4;
 	int mii_cmd = (0x5002 << 16) | (phy_id << 23) | (location << 18) | value;
@@ -1319,7 +1319,7 @@
 
 static int rtl8139_open (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	int retval;
 	void *ioaddr = tp->mmio_addr;
 
@@ -1367,7 +1367,7 @@
 
 static void rtl_check_media (struct net_device *dev, unsigned int init_media)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 
 	if (tp->phys[0] >= 0) {
 		mii_check_media(&tp->mii, netif_msg_link(tp), init_media);
@@ -1377,7 +1377,7 @@
 /* Start the hardware at open or resume. */
 static void rtl8139_hw_start (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u32 i;
 	u8 tmp;
@@ -1446,7 +1446,7 @@
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
 static void rtl8139_init_ring (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	int i;
 
 	tp->cur_rx = 0;
@@ -1613,7 +1613,7 @@
 static int rtl8139_thread (void *data)
 {
 	struct net_device *dev = data;
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	unsigned long timeout;
 
 	daemonize("%s", dev->name);
@@ -1645,7 +1645,7 @@
 
 static void rtl8139_start_thread(struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 
 	tp->thr_pid = -1;
 	tp->twistie = 0;
@@ -1673,7 +1673,7 @@
 
 static void rtl8139_tx_timeout (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int i;
 	u8 tmp8;
@@ -1718,7 +1718,7 @@
 
 static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned int entry;
 	unsigned int len = skb->len;
@@ -2125,7 +2125,7 @@
 
 static int rtl8139_poll(struct net_device *dev, int *budget)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int orig_budget = min(*budget, dev->quota);
 	int done = 1;
@@ -2163,7 +2163,7 @@
 			       struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u16 status, ackstat;
 	int link_changed = 0; /* avoid bogus "uninit" warning */
@@ -2239,7 +2239,7 @@
 
 static int rtl8139_close (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int ret = 0;
 	unsigned long flags;
@@ -2302,7 +2302,7 @@
    other threads or interrupts aren't messing with the 8139.  */
 static void rtl8139_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	void *ioaddr = np->mmio_addr;
 
 	spin_lock_irq(&np->lock);
@@ -2336,7 +2336,7 @@
    aren't messing with the 8139.  */
 static int rtl8139_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	void *ioaddr = np->mmio_addr;
 	u32 support;
 	u8 cfg3, cfg5;
@@ -2376,7 +2376,7 @@
 
 static void rtl8139_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
 	strcpy(info->bus_info, pci_name(np->pci_dev));
@@ -2385,7 +2385,7 @@
 
 static int rtl8139_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	spin_lock_irq(&np->lock);
 	mii_ethtool_gset(&np->mii, cmd);
 	spin_unlock_irq(&np->lock);
@@ -2394,7 +2394,7 @@
 
 static int rtl8139_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	int rc;
 	spin_lock_irq(&np->lock);
 	rc = mii_ethtool_sset(&np->mii, cmd);
@@ -2404,25 +2404,25 @@
 
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
 
@@ -2433,13 +2433,13 @@
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
+	struct rtl8139_private *np = netdev_priv(priv);
 
 	regs->version = RTL_REGS_VER;
 
@@ -2456,7 +2456,7 @@
 
 static void rtl8139_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *stats, u64 *data)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 
 	data[0] = np->xstats.early_rx;
 	data[1] = np->xstats.tx_buf_mapped;
@@ -2488,7 +2488,7 @@
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct rtl8139_private *np = dev->priv;
+	struct rtl8139_private *np = netdev_priv(dev);
 	int rc;
 
 	if (!netif_running(dev))
@@ -2504,7 +2504,7 @@
 
 static struct net_device_stats *rtl8139_get_stats (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
@@ -2523,7 +2523,7 @@
 
 static void __set_rx_mode (struct net_device *dev)
 {
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u32 mc_filter[2];	/* Multicast hash filter */
 	int i, rx_mode;
@@ -2572,7 +2572,7 @@
 static void rtl8139_set_rx_mode (struct net_device *dev)
 {
 	unsigned long flags;
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 
 	spin_lock_irqsave (&tp->lock, flags);
 	__set_rx_mode(dev);
@@ -2584,7 +2584,7 @@
 static int rtl8139_suspend (struct pci_dev *pdev, u32 state)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct rtl8139_private *tp = dev->priv;
+	struct rtl8139_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
