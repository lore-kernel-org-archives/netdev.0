From: Don Fry <pcnet32@verizon.net>
Subject: [PATCH 2/2] pcnet32: change to use netdev_priv
Date: Tue, 6 Mar 2007 10:55:00 -0800
Message-ID: <20070306185500.GA26515@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [71.117.224.81] ([71.117.224.81]:24214 "EHLO linux.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S966004AbXCFSyd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 13:54:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use netdev_priv() instead of dev->priv

Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Signed-off-by: Don Fry <pcnet32@verizon.net>
---
--- linux-2.6.21-rc2/drivers/net/one.pcnet32.c	2007-03-06 10:48:37.000000000 -0800
+++ linux-2.6.21-rc2/drivers/net/pcnet32.c	2007-03-05 18:03:32.000000000 -0800
@@ -653,7 +653,7 @@ static void pcnet32_realloc_rx_ring(stru
 
 static void pcnet32_purge_rx_ring(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int i;
 
 	/* free all allocated skbuffs */
@@ -681,7 +681,7 @@ static void pcnet32_poll_controller(stru
 
 static int pcnet32_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
 	int r = -EOPNOTSUPP;
 
@@ -696,7 +696,7 @@ static int pcnet32_get_settings(struct n
 
 static int pcnet32_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
 	int r = -EOPNOTSUPP;
 
@@ -711,7 +711,7 @@ static int pcnet32_set_settings(struct n
 static void pcnet32_get_drvinfo(struct net_device *dev,
 				struct ethtool_drvinfo *info)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -723,7 +723,7 @@ static void pcnet32_get_drvinfo(struct n
 
 static u32 pcnet32_get_link(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
 	int r;
 
@@ -743,19 +743,19 @@ static u32 pcnet32_get_link(struct net_d
 
 static u32 pcnet32_get_msglevel(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	return lp->msg_enable;
 }
 
 static void pcnet32_set_msglevel(struct net_device *dev, u32 value)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	lp->msg_enable = value;
 }
 
 static int pcnet32_nway_reset(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
 	int r = -EOPNOTSUPP;
 
@@ -770,7 +770,7 @@ static int pcnet32_nway_reset(struct net
 static void pcnet32_get_ringparam(struct net_device *dev,
 				  struct ethtool_ringparam *ering)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 
 	ering->tx_max_pending = TX_MAX_RING_SIZE;
 	ering->tx_pending = lp->tx_ring_size;
@@ -781,7 +781,7 @@ static void pcnet32_get_ringparam(struct
 static int pcnet32_set_ringparam(struct net_device *dev,
 				 struct ethtool_ringparam *ering)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
 	unsigned int size;
 	ulong ioaddr = dev->base_addr;
@@ -847,7 +847,7 @@ static int pcnet32_self_test_count(struc
 static void pcnet32_ethtool_test(struct net_device *dev,
 				 struct ethtool_test *test, u64 * data)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int rc;
 
 	if (test->flags == ETH_TEST_FL_OFFLINE) {
@@ -868,7 +868,7 @@ static void pcnet32_ethtool_test(struct 
 
 static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	struct pcnet32_access *a = &lp->a;	/* access to registers */
 	ulong ioaddr = dev->base_addr;	/* card base I/O address */
 	struct sk_buff *skb;	/* sk buff */
@@ -1047,7 +1047,7 @@ static int pcnet32_loopback_test(struct 
 
 static void pcnet32_led_blink_callback(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	struct pcnet32_access *a = &lp->a;
 	ulong ioaddr = dev->base_addr;
 	unsigned long flags;
@@ -1064,7 +1064,7 @@ static void pcnet32_led_blink_callback(s
 
 static int pcnet32_phys_id(struct net_device *dev, u32 data)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	struct pcnet32_access *a = &lp->a;
 	ulong ioaddr = dev->base_addr;
 	unsigned long flags;
@@ -1109,7 +1109,7 @@ static int pcnet32_suspend(struct net_de
 		int can_sleep)
 {
 	int csr5;
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	struct pcnet32_access *a = &lp->a;
 	ulong ioaddr = dev->base_addr;
 	int ticks;
@@ -1258,7 +1258,7 @@ static void pcnet32_rx_entry(struct net_
 
 static int pcnet32_rx(struct net_device *dev, int quota)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int entry = lp->cur_rx & lp->rx_mod_mask;
 	struct pcnet32_rx_head *rxp = &lp->rx_ring[entry];
 	int npackets = 0;
@@ -1283,7 +1283,7 @@ static int pcnet32_rx(struct net_device 
 
 static int pcnet32_tx(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned int dirty_tx = lp->dirty_tx;
 	int delta;
 	int must_restart = 0;
@@ -1382,7 +1382,7 @@ static int pcnet32_tx(struct net_device 
 #ifdef CONFIG_PCNET32_NAPI
 static int pcnet32_poll(struct net_device *dev, int *budget)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int quota = min(dev->quota, *budget);
 	unsigned long ioaddr = dev->base_addr;
 	unsigned long flags;
@@ -1429,7 +1429,7 @@ static int pcnet32_poll(struct net_devic
 #define PCNET32_MAX_PHYS	32
 static int pcnet32_get_regs_len(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int j = lp->phycount * PCNET32_REGS_PER_PHY;
 
 	return ((PCNET32_NUM_REGS + j) * sizeof(u16));
@@ -1440,7 +1440,7 @@ static void pcnet32_get_regs(struct net_
 {
 	int i, csr0;
 	u16 *buff = ptr;
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	struct pcnet32_access *a = &lp->a;
 	ulong ioaddr = dev->base_addr;
 	unsigned long flags;
@@ -1805,7 +1805,7 @@ pcnet32_probe1(unsigned long ioaddr, int
 	}
 
 	dev->base_addr = ioaddr;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	/* pci_alloc_consistent returns page-aligned memory, so we do not have to check the alignment */
 	if ((lp->init_block =
 	     pci_alloc_consistent(pdev, sizeof(*lp->init_block), &lp->init_dma_addr)) == NULL) {
@@ -1999,7 +1999,7 @@ pcnet32_probe1(unsigned long ioaddr, int
 /* if any allocation fails, caller must also call pcnet32_free_ring */
 static int pcnet32_alloc_ring(struct net_device *dev, char *name)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 
 	lp->tx_ring = pci_alloc_consistent(lp->pci_dev,
 					   sizeof(struct pcnet32_tx_head) *
@@ -2066,7 +2066,7 @@ static int pcnet32_alloc_ring(struct net
 
 static void pcnet32_free_ring(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 
 	kfree(lp->tx_skbuff);
 	lp->tx_skbuff = NULL;
@@ -2099,7 +2099,7 @@ static void pcnet32_free_ring(struct net
 
 static int pcnet32_open(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	u16 val;
 	int i;
@@ -2345,7 +2345,7 @@ static int pcnet32_open(struct net_devic
 
 static void pcnet32_purge_tx_ring(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int i;
 
 	for (i = 0; i < lp->tx_ring_size; i++) {
@@ -2365,7 +2365,7 @@ static void pcnet32_purge_tx_ring(struct
 /* Initialize the PCNET32 Rx and Tx rings. */
 static int pcnet32_init_ring(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int i;
 
 	lp->tx_full = 0;
@@ -2423,7 +2423,7 @@ static int pcnet32_init_ring(struct net_
  */
 static void pcnet32_restart(struct net_device *dev, unsigned int csr0_bits)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	int i;
 
@@ -2453,7 +2453,7 @@ static void pcnet32_restart(struct net_d
 
 static void pcnet32_tx_timeout(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr, flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
@@ -2494,7 +2494,7 @@ static void pcnet32_tx_timeout(struct ne
 
 static int pcnet32_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	u16 status;
 	int entry;
@@ -2559,7 +2559,7 @@ pcnet32_interrupt(int irq, void *dev_id)
 	int boguscnt = max_interrupt_work;
 
 	ioaddr = dev->base_addr;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 
 	spin_lock(&lp->lock);
 
@@ -2641,7 +2641,7 @@ pcnet32_interrupt(int irq, void *dev_id)
 static int pcnet32_close(struct net_device *dev)
 {
 	unsigned long ioaddr = dev->base_addr;
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	del_timer_sync(&lp->watchdog_timer);
@@ -2682,7 +2682,7 @@ static int pcnet32_close(struct net_devi
 
 static struct net_device_stats *pcnet32_get_stats(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -2696,7 +2696,7 @@ static struct net_device_stats *pcnet32_
 /* taken from the sunlance driver, which it took from the depca driver */
 static void pcnet32_load_multicast(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	volatile struct pcnet32_init_block *ib = lp->init_block;
 	volatile u16 *mcast_table = (u16 *) & ib->filter;
 	struct dev_mc_list *dmi = dev->mc_list;
@@ -2746,7 +2746,7 @@ static void pcnet32_load_multicast(struc
 static void pcnet32_set_multicast_list(struct net_device *dev)
 {
 	unsigned long ioaddr = dev->base_addr, flags;
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int csr15, suspended;
 
 	spin_lock_irqsave(&lp->lock, flags);
@@ -2785,7 +2785,7 @@ static void pcnet32_set_multicast_list(s
 /* This routine assumes that the lp->lock is held */
 static int mdio_read(struct net_device *dev, int phy_id, int reg_num)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	u16 val_out;
 
@@ -2801,7 +2801,7 @@ static int mdio_read(struct net_device *
 /* This routine assumes that the lp->lock is held */
 static void mdio_write(struct net_device *dev, int phy_id, int reg_num, int val)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 
 	if (!lp->mii)
@@ -2813,7 +2813,7 @@ static void mdio_write(struct net_device
 
 static int pcnet32_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int rc;
 	unsigned long flags;
 
@@ -2831,7 +2831,7 @@ static int pcnet32_ioctl(struct net_devi
 
 static int pcnet32_check_otherphy(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	struct mii_if_info mii = lp->mii_if;
 	u16 bmcr;
 	int i;
@@ -2878,7 +2878,7 @@ static int pcnet32_check_otherphy(struct
 
 static void pcnet32_check_media(struct net_device *dev, int verbose)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	int curr_link;
 	int prev_link = netif_carrier_ok(dev) ? 1 : 0;
 	u32 bcr9;
@@ -2934,7 +2934,7 @@ static void pcnet32_check_media(struct n
 
 static void pcnet32_watchdog(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_private *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	/* Print the link status if it has changed */
@@ -2950,7 +2950,7 @@ static void __devexit pcnet32_remove_one
 	struct net_device *dev = pci_get_drvdata(pdev);
 
 	if (dev) {
-		struct pcnet32_private *lp = dev->priv;
+		struct pcnet32_private *lp = netdev_priv(dev);
 
 		unregister_netdev(dev);
 		pcnet32_free_ring(dev);
@@ -3031,7 +3031,7 @@ static void __exit pcnet32_cleanup_modul
 	struct net_device *next_dev;
 
 	while (pcnet32_dev) {
-		struct pcnet32_private *lp = pcnet32_dev->priv;
+		struct pcnet32_private *lp = netdev_priv(pcnet32_dev);
 		next_dev = lp->next;
 		unregister_netdev(pcnet32_dev);
 		pcnet32_free_ring(pcnet32_dev);
