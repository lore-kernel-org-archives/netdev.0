From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 3/3] ns83820: use netdev_priv properly
Date: Fri, 15 Oct 2004 15:45:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015154520.3f0b3ac9@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace ugly local inline with call to netdev_priv.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/drivers/net/ns83820.c b/drivers/net/ns83820.c
--- a/drivers/net/ns83820.c	2004-10-15 15:30:43 -07:00
+++ b/drivers/net/ns83820.c	2004-10-15 15:30:43 -07:00
@@ -482,16 +482,11 @@
 	struct timer_list	tx_watchdog;
 };
 
-static inline struct ns83820 *PRIV(struct net_device *dev)
-{
-	return netdev_priv(dev);
-}
-
 #define __kick_rx(dev)	writel(CR_RXE, dev->base + CR)
 
 static inline void kick_rx(struct net_device *ndev)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	dprintk("kick_rx: maybe kicking\n");
 	if (test_and_clear_bit(0, &dev->rx_info.idle)) {
 		dprintk("actually kicking\n");
@@ -513,7 +508,7 @@
 #ifdef NS83820_VLAN_ACCEL_SUPPORT 
 static void ns83820_vlan_rx_register(struct net_device *ndev, struct vlan_group *grp)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 
 	spin_lock_irq(&dev->misc_lock);
 	spin_lock(&dev->tx_lock);
@@ -526,7 +521,7 @@
 
 static void ns83820_vlan_rx_kill_vid(struct net_device *ndev, unsigned short vid)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 
 	spin_lock_irq(&dev->misc_lock);
 	spin_lock(&dev->tx_lock);
@@ -602,7 +597,7 @@
 
 static inline int rx_refill(struct net_device *ndev, int gfp)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	unsigned i;
 	unsigned long flags = 0;
 
@@ -652,7 +647,7 @@
 static inline void queue_refill(void *_dev)
 {
 	struct net_device *ndev = _dev;
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 
 	rx_refill(ndev, GFP_KERNEL);
 	if (dev->rx_info.up)
@@ -667,7 +662,7 @@
 static void FASTCALL(phy_intr(struct net_device *ndev));
 static void fastcall phy_intr(struct net_device *ndev)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	static char *speeds[] = { "10", "100", "1000", "1000(?)", "1000F" };
 	u32 cfg, new_cfg;
 	u32 tbisr, tanar, tanlpar;
@@ -762,7 +757,7 @@
 
 static int ns83820_setup_rx(struct net_device *ndev)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	unsigned i;
 	int ret;
 
@@ -854,7 +849,7 @@
 static void FASTCALL(ns83820_rx_kick(struct net_device *ndev));
 static void fastcall ns83820_rx_kick(struct net_device *ndev)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	/*if (nr_rx_empty(dev) >= NR_RX_DESC/4)*/ {
 		if (dev->rx_info.up) {
 			rx_refill_atomic(ndev);
@@ -876,7 +871,7 @@
 static void FASTCALL(rx_irq(struct net_device *ndev));
 static void fastcall rx_irq(struct net_device *ndev)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	struct rx_info *info = &dev->rx_info;
 	unsigned next_rx;
 	int rx_rc, len;
@@ -988,7 +983,7 @@
 static void rx_action(unsigned long _dev)
 {
 	struct net_device *ndev = (void *)_dev;
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	rx_irq(ndev);
 	writel(ihr, dev->base + IHR);
 
@@ -1015,7 +1010,7 @@
  */
 static void do_tx_done(struct net_device *ndev)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	u32 cmdsts, tx_done_idx, *desc;
 
 	spin_lock_irq(&dev->tx_lock);
@@ -1107,7 +1102,7 @@
  */
 static int ns83820_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	u32 free_idx, cmdsts, extsts;
 	int nr_free, nr_frags;
 	unsigned tx_done_idx, last_idx;
@@ -1264,7 +1259,7 @@
 
 static struct net_device_stats *ns83820_get_stats(struct net_device *ndev)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 
 	/* somewhat overkill */
 	spin_lock_irq(&dev->misc_lock);
@@ -1276,7 +1271,7 @@
 
 static void ns83820_get_drvinfo(struct net_device *ndev, struct ethtool_drvinfo *info)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	strcpy(info->driver, "ns83820");
 	strcpy(info->version, VERSION);
 	strcpy(info->bus_info, pci_name(dev->pci_dev));
@@ -1284,7 +1279,7 @@
 
 static u32 ns83820_get_link(struct net_device *ndev)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	u32 cfg = readl(dev->base + CFG) ^ SPDSTS_POLARITY;
 	return cfg & CFG_LNKSTS ? 1 : 0;
 }
@@ -1305,7 +1300,7 @@
 static irqreturn_t ns83820_irq(int foo, void *data, struct pt_regs *regs)
 {
 	struct net_device *ndev = data;
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	u32 isr;
 	dprintk("ns83820_irq(%p)\n", ndev);
 
@@ -1319,7 +1314,7 @@
 
 static void ns83820_do_isr(struct net_device *ndev, u32 isr)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 #ifdef DEBUG
 	if (isr & ~(ISR_PHY | ISR_RXDESC | ISR_RXEARLY | ISR_RXOK | ISR_RXERR | ISR_TXIDLE | ISR_TXOK | ISR_TXDESC))
 		Dprintk("odd isr? 0x%08x\n", isr);
@@ -1435,7 +1430,7 @@
 
 static int ns83820_stop(struct net_device *ndev)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 
 	/* FIXME: protect against interrupt handler? */
 	del_timer_sync(&dev->tx_watchdog);
@@ -1464,7 +1459,7 @@
 
 static void ns83820_tx_timeout(struct net_device *ndev)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
         u32 tx_done_idx, *desc;
 	unsigned long flags;
 
@@ -1501,7 +1496,7 @@
 static void ns83820_tx_watch(unsigned long data)
 {
 	struct net_device *ndev = (void *)data;
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 
 #if defined(DEBUG)
 	printk("ns83820_tx_watch: %u %u %d\n",
@@ -1523,7 +1518,7 @@
 
 static int ns83820_open(struct net_device *ndev)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	unsigned i;
 	u32 desc;
 	int ret;
@@ -1593,7 +1588,7 @@
 
 static void ns83820_set_multicast(struct net_device *ndev)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	u8 *rfcr = dev->base + RFCR;
 	u32 and_mask = 0xffffffff;
 	u32 or_mask = 0;
@@ -1619,7 +1614,7 @@
 
 static void ns83820_run_bist(struct net_device *ndev, const char *name, u32 enable, u32 done, u32 fail)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	int timed_out = 0;
 	long start;
 	u32 status;
@@ -1779,7 +1774,7 @@
 
 static void ns83820_probe_phy(struct net_device *ndev)
 {
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = netdev_priv(ndev);
 	static int first;
 	int i;
 #define MII_PHYIDR1	0x02
@@ -1852,7 +1847,7 @@
 	}
 
 	ndev = alloc_etherdev(sizeof(struct ns83820));
-	dev = PRIV(ndev);
+	dev = netdev_priv(ndev);
 	err = -ENOMEM;
 	if (!dev)
 		goto out;
@@ -2156,7 +2151,7 @@
 static void __devexit ns83820_remove_one(struct pci_dev *pci_dev)
 {
 	struct net_device *ndev = pci_get_drvdata(pci_dev);
-	struct ns83820 *dev = PRIV(ndev); /* ok even if NULL */
+	struct ns83820 *dev = netdev_priv(ndev); /* ok even if NULL */
 
 	if (!ndev)			/* paranoia */
 		return;
