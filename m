From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 3/6] tc35815: Use netdev_priv()
Date: Fri, 11 Apr 2008 00:24:36 +0900 (JST)
Message-ID: <20080411.002436.122621005.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:49482 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756662AbYDJPXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 11:23:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_priv() instead of dev->priv.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |   78 ++++++++++++++++++++++++------------------------
 1 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 1f623e5..5f4a14f 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -616,7 +616,7 @@ static int __devinit tc35815_mac_match(struct device *dev, void *data)
 
 static int __devinit tc35815_read_plat_dev_addr(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct device *pd = bus_find_device(&platform_bus_type, NULL,
 					    lp->pci_dev, tc35815_mac_match);
 	if (pd) {
@@ -686,7 +686,7 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 		return -ENOMEM;
 	}
 	SET_NETDEV_DEV(dev, &pdev->dev);
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->dev = dev;
 
 	/* enable device (incl. PCI PM wakeup), and bus-mastering */
@@ -823,7 +823,7 @@ static void __devexit tc35815_remove_one (struct pci_dev *pdev)
 static int
 tc35815_init_queues(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int i;
 	unsigned long fd_addr;
 
@@ -960,7 +960,7 @@ tc35815_init_queues(struct net_device *dev)
 static void
 tc35815_clear_queues(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int i;
 
 	for (i = 0; i < TX_FD_NUM; i++) {
@@ -991,7 +991,7 @@ tc35815_clear_queues(struct net_device *dev)
 static void
 tc35815_free_queues(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int i;
 
 	if (lp->tfd_base) {
@@ -1105,7 +1105,7 @@ dump_frfd(struct FrFD *fd)
 static void
 panic_queues(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int i;
 
 	printk("TxFD base %p, start %u, end %u\n",
@@ -1136,13 +1136,13 @@ static void print_eth(const u8 *add)
 
 static int tc35815_tx_full(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	return ((lp->tfd_start + 1) % TX_FD_NUM == lp->tfd_end);
 }
 
 static void tc35815_restart(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	int do_phy_reset = 1;
 	del_timer(&lp->timer);		/* Kill if running	*/
@@ -1173,7 +1173,7 @@ static void tc35815_restart(struct net_device *dev)
 
 static void tc35815_tx_timeout(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
 
@@ -1212,7 +1212,7 @@ static void tc35815_tx_timeout(struct net_device *dev)
 static int
 tc35815_open(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 
 	/*
 	 * This is used if the interrupt line can turned off (shared).
@@ -1254,7 +1254,7 @@ tc35815_open(struct net_device *dev)
  */
 static int tc35815_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct TxFD *txfd;
 	unsigned long flags;
 
@@ -1368,7 +1368,7 @@ static int tc35815_do_interrupt(struct net_device *dev, u32 status, int limit)
 static int tc35815_do_interrupt(struct net_device *dev, u32 status)
 #endif
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
 	int ret = -1;
@@ -1485,7 +1485,7 @@ static void
 tc35815_rx(struct net_device *dev)
 #endif
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	unsigned int fdctl;
 	int i;
 	int buf_free_count = 0;
@@ -1769,7 +1769,7 @@ static int tc35815_poll(struct napi_struct *napi, int budget)
 static void
 tc35815_check_tx_stat(struct net_device *dev, int status)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	const char *msg = NULL;
 
 	/* count collisions */
@@ -1846,7 +1846,7 @@ tc35815_check_tx_stat(struct net_device *dev, int status)
 static void
 tc35815_txdone(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct TxFD *txfd;
 	unsigned int fdctl;
 
@@ -1944,7 +1944,7 @@ tc35815_txdone(struct net_device *dev)
 static int
 tc35815_close(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 #ifdef TC35815_NAPI
@@ -1980,7 +1980,7 @@ static struct net_device_stats *tc35815_get_stats(struct net_device *dev)
 
 static void tc35815_set_cam_entry(struct net_device *dev, int index, unsigned char *addr)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
 	int cam_index = index * 6;
@@ -2037,7 +2037,7 @@ tc35815_set_multicast_list(struct net_device *dev)
 #ifdef WORKAROUND_100HALF_PROMISC
 		/* With some (all?) 100MHalf HUB, controller will hang
 		 * if we enabled promiscuous mode before linkup... */
-		struct tc35815_local *lp = dev->priv;
+		struct tc35815_local *lp = netdev_priv(dev);
 		int pid = lp->phy_addr;
 		if (!(tc_mdio_read(dev, pid, MII_BMSR) & BMSR_LSTATUS))
 			return;
@@ -2077,7 +2077,7 @@ tc35815_set_multicast_list(struct net_device *dev)
 
 static void tc35815_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	strcpy(info->driver, MODNAME);
 	strcpy(info->version, DRV_VERSION);
 	strcpy(info->bus_info, pci_name(lp->pci_dev));
@@ -2085,7 +2085,7 @@ static void tc35815_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *
 
 static int tc35815_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	spin_lock_irq(&lp->lock);
 	mii_ethtool_gset(&lp->mii, cmd);
 	spin_unlock_irq(&lp->lock);
@@ -2094,7 +2094,7 @@ static int tc35815_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int tc35815_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int rc;
 #if 1	/* use our negotiation method... */
 	/* Verify the settings we care about. */
@@ -2124,7 +2124,7 @@ static int tc35815_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int tc35815_nway_reset(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int rc;
 	spin_lock_irq(&lp->lock);
 	rc = mii_nway_restart(&lp->mii);
@@ -2134,7 +2134,7 @@ static int tc35815_nway_reset(struct net_device *dev)
 
 static u32 tc35815_get_link(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int rc;
 	spin_lock_irq(&lp->lock);
 	rc = mii_link_ok(&lp->mii);
@@ -2144,19 +2144,19 @@ static u32 tc35815_get_link(struct net_device *dev)
 
 static u32 tc35815_get_msglevel(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	return lp->msg_enable;
 }
 
 static void tc35815_set_msglevel(struct net_device *dev, u32 datum)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	lp->msg_enable = datum;
 }
 
 static int tc35815_get_sset_count(struct net_device *dev, int sset)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 
 	switch (sset) {
 	case ETH_SS_STATS:
@@ -2168,7 +2168,7 @@ static int tc35815_get_sset_count(struct net_device *dev, int sset)
 
 static void tc35815_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *stats, u64 *data)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	data[0] = lp->lstats.max_tx_qlen;
 	data[1] = lp->lstats.tx_ints;
 	data[2] = lp->lstats.rx_ints;
@@ -2204,7 +2204,7 @@ static const struct ethtool_ops tc35815_ethtool_ops = {
 
 static int tc35815_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int rc;
 
 	if (!netif_running(dev))
@@ -2276,7 +2276,7 @@ static void tc_mdio_write(struct net_device *dev, int phy_id, int location,
 
 static int tc35815_try_next_permutation(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	unsigned short bmcr;
 
@@ -2305,7 +2305,7 @@ static int tc35815_try_next_permutation(struct net_device *dev)
 static void
 tc35815_display_link_mode(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	unsigned short lpa, bmcr;
 	char *speed = "", *duplex = "";
@@ -2331,7 +2331,7 @@ tc35815_display_link_mode(struct net_device *dev)
 
 static void tc35815_display_forced_link_mode(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	unsigned short bmcr;
 	char *speed = "", *duplex = "";
@@ -2353,7 +2353,7 @@ static void tc35815_display_forced_link_mode(struct net_device *dev)
 
 static void tc35815_set_link_modes(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
 	int pid = lp->phy_addr;
@@ -2420,7 +2420,7 @@ static void tc35815_set_link_modes(struct net_device *dev)
 static void tc35815_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	unsigned short bmsr, bmcr, lpa;
 	int restart_timer = 0;
@@ -2628,7 +2628,7 @@ out:
 static void tc35815_start_auto_negotiation(struct net_device *dev,
 					   struct ethtool_cmd *ep)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	unsigned short bmsr, bmcr, advertize;
 	int timeout;
@@ -2752,7 +2752,7 @@ force_link:
 
 static void tc35815_find_phy(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	unsigned short id0;
 
@@ -2781,7 +2781,7 @@ static void tc35815_find_phy(struct net_device *dev)
 
 static void tc35815_phy_chip_init(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	unsigned short bmcr;
 	struct ethtool_cmd ecmd, *ep;
@@ -2855,7 +2855,7 @@ static void tc35815_chip_reset(struct net_device *dev)
 
 static void tc35815_chip_init(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
 	unsigned long txctl = TX_CTL_CMD;
@@ -2917,7 +2917,7 @@ static void tc35815_chip_init(struct net_device *dev)
 static int tc35815_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	pci_save_state(pdev);
@@ -2935,7 +2935,7 @@ static int tc35815_suspend(struct pci_dev *pdev, pm_message_t state)
 static int tc35815_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	pci_restore_state(pdev);
