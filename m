From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-12
Date: Tue, 26 Aug 2008 22:19:08 +0800
Message-ID: <48B410DC.5010907@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50728 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756604AbYHZOVe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:21:34 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index 0e4a88d..370a356 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -914,7 +914,7 @@ static irqreturn_t bigmac_interrupt(int irq, void *dev_id)
 
 static int bigmac_open(struct net_device *dev)
 {
-	struct bigmac *bp = (struct bigmac *) dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 	int ret;
 
 	ret = request_irq(dev->irq, &bigmac_interrupt, IRQF_SHARED, dev->name, bp);
@@ -931,7 +931,7 @@ static int bigmac_open(struct net_device *dev)
 
 static int bigmac_close(struct net_device *dev)
 {
-	struct bigmac *bp = (struct bigmac *) dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 
 	del_timer(&bp->bigmac_timer);
 	bp->timer_state = asleep;
@@ -945,7 +945,7 @@ static int bigmac_close(struct net_device *dev)
 
 static void bigmac_tx_timeout(struct net_device *dev)
 {
-	struct bigmac *bp = (struct bigmac *) dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 
 	bigmac_init_hw(bp, 0);
 	netif_wake_queue(dev);
@@ -954,7 +954,7 @@ static void bigmac_tx_timeout(struct net_device *dev)
 /* Put a packet on the wire. */
 static int bigmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct bigmac *bp = (struct bigmac *) dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 	int len, entry;
 	u32 mapping;
 
@@ -986,7 +986,7 @@ static int bigmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static struct net_device_stats *bigmac_get_stats(struct net_device *dev)
 {
-	struct bigmac *bp = (struct bigmac *) dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 
 	bigmac_get_counters(bp, bp->bregs);
 	return &bp->enet_stats;
@@ -994,7 +994,7 @@ static struct net_device_stats *bigmac_get_stats(struct net_device *dev)
 
 static void bigmac_set_multicast(struct net_device *dev)
 {
-	struct bigmac *bp = (struct bigmac *) dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 	void __iomem *bregs = bp->bregs;
 	struct dev_mc_list *dmi = dev->mc_list;
 	char *addrs;
@@ -1051,7 +1051,7 @@ static void bigmac_set_multicast(struct net_device *dev)
 /* Ethtool support... */
 static void bigmac_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct bigmac *bp = dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 
 	strcpy(info->driver, "sunbmac");
 	strcpy(info->version, "2.0");
@@ -1061,7 +1061,7 @@ static void bigmac_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *i
 
 static u32 bigmac_get_link(struct net_device *dev)
 {
-	struct bigmac *bp = dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 
 	spin_lock_irq(&bp->lock);
 	bp->sw_bmsr = bigmac_tcvr_read(bp, bp->tregs, BIGMAC_BMSR);
@@ -1097,7 +1097,7 @@ static int __devinit bigmac_ether_init(struct sbus_dev *qec_sdev)
 		dev->dev_addr[i] = idprom->id_ethaddr[i];
 
 	/* Setup softc, with backpointers to QEC and BigMAC SBUS device structs. */
-	bp = dev->priv;
+	bp = netdev_priv(dev);
 	bp->qec_sdev = qec_sdev;
 	bp->bigmac_sdev = qec_sdev->child;
 
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 4291458..96eb777 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -164,7 +164,7 @@ static u16 __phy_read(struct gem *gp, int phy_addr, int reg)
 
 static inline int _phy_read(struct net_device *dev, int mii_id, int reg)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	return __phy_read(gp, mii_id, reg);
 }
 
@@ -197,7 +197,7 @@ static void __phy_write(struct gem *gp, int phy_addr, int reg, u16 val)
 
 static inline void _phy_write(struct net_device *dev, int mii_id, int reg, int val)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	__phy_write(gp, mii_id, reg, val & 0xffff);
 }
 
@@ -933,7 +933,7 @@ static int gem_poll(struct napi_struct *napi, int budget)
 static irqreturn_t gem_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	unsigned long flags;
 
 	/* Swallow interrupts when shutting the chip down, though
@@ -979,7 +979,7 @@ static void gem_poll_controller(struct net_device *dev)
 
 static void gem_tx_timeout(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	printk(KERN_ERR "%s: transmit timed out, resetting\n", dev->name);
 	if (!gp->running) {
@@ -1018,7 +1018,7 @@ static __inline__ int gem_intme(int entry)
 
 static int gem_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	int entry;
 	u64 ctrl;
 	unsigned long flags;
@@ -2191,7 +2191,7 @@ static void gem_stop_phy(struct gem *gp, int wol)
 
 static int gem_do_start(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&gp->lock, flags);
@@ -2238,7 +2238,7 @@ static int gem_do_start(struct net_device *dev)
 
 static void gem_do_stop(struct net_device *dev, int wol)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&gp->lock, flags);
@@ -2313,7 +2313,7 @@ static void gem_reset_task(struct work_struct *work)
 
 static int gem_open(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	int rc = 0;
 
 	mutex_lock(&gp->pm_mutex);
@@ -2332,7 +2332,7 @@ static int gem_open(struct net_device *dev)
 
 static int gem_close(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	mutex_lock(&gp->pm_mutex);
 
@@ -2351,7 +2351,7 @@ static int gem_close(struct net_device *dev)
 static int gem_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	unsigned long flags;
 
 	mutex_lock(&gp->pm_mutex);
@@ -2415,7 +2415,7 @@ static int gem_suspend(struct pci_dev *pdev, pm_message_t state)
 static int gem_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	unsigned long flags;
 
 	printk(KERN_INFO "%s: resuming\n", dev->name);
@@ -2489,7 +2489,7 @@ static int gem_resume(struct pci_dev *pdev)
 
 static struct net_device_stats *gem_get_stats(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	struct net_device_stats *stats = &gp->net_stats;
 
 	spin_lock_irq(&gp->lock);
@@ -2525,7 +2525,7 @@ static struct net_device_stats *gem_get_stats(struct net_device *dev)
 static int gem_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *macaddr = (struct sockaddr *) addr;
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	unsigned char *e = &dev->dev_addr[0];
 
 	if (!is_valid_ether_addr(macaddr->sa_data))
@@ -2553,7 +2553,7 @@ static int gem_set_mac_address(struct net_device *dev, void *addr)
 
 static void gem_set_multicast(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	u32 rxcfg, rxcfg_new;
 	int limit = 10000;
 
@@ -2602,7 +2602,7 @@ static void gem_set_multicast(struct net_device *dev)
 
 static int gem_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	if (new_mtu < GEM_MIN_MTU || new_mtu > GEM_MAX_MTU)
 		return -EINVAL;
@@ -2633,7 +2633,7 @@ static int gem_change_mtu(struct net_device *dev, int new_mtu)
 
 static void gem_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -2642,7 +2642,7 @@ static void gem_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 
 static int gem_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	if (gp->phy_type == phy_mii_mdio0 ||
 	    gp->phy_type == phy_mii_mdio1) {
@@ -2688,7 +2688,7 @@ static int gem_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int gem_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	/* Verify the settings we care about. */
 	if (cmd->autoneg != AUTONEG_ENABLE &&
@@ -2719,7 +2719,7 @@ static int gem_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int gem_nway_reset(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	if (!gp->want_autoneg)
 		return -EINVAL;
@@ -2736,13 +2736,13 @@ static int gem_nway_reset(struct net_device *dev)
 
 static u32 gem_get_msglevel(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	return gp->msg_enable;
 }
 
 static void gem_set_msglevel(struct net_device *dev, u32 value)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	gp->msg_enable = value;
 }
 
@@ -2754,7 +2754,7 @@ static void gem_set_msglevel(struct net_device *dev, u32 value)
 
 static void gem_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	/* Add more when I understand how to program the chip */
 	if (gp->has_wol) {
@@ -2768,7 +2768,7 @@ static void gem_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 
 static int gem_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	if (!gp->has_wol)
 		return -EOPNOTSUPP;
@@ -2790,7 +2790,7 @@ static const struct ethtool_ops gem_ethtool_ops = {
 
 static int gem_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	struct mii_ioctl_data *data = if_mii(ifr);
 	int rc = -EOPNOTSUPP;
 	unsigned long flags;
@@ -2922,7 +2922,7 @@ static void gem_remove_one(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 
 	if (dev) {
-		struct gem *gp = dev->priv;
+		struct gem *gp = netdev_priv(dev);
 
 		unregister_netdev(dev);
 
@@ -3026,7 +3026,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	}
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	gp = dev->priv;
+	gp = netdev_priv(dev);
 
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index b79d5f0..970c05a 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2144,7 +2144,7 @@ static irqreturn_t quattro_sbus_interrupt(int irq, void *cookie)
 
 	for (i = 0; i < 4; i++) {
 		struct net_device *dev = qp->happy_meals[i];
-		struct happy_meal *hp  = dev->priv;
+		struct happy_meal *hp  = netdev_priv(dev);
 		u32 happy_status       = hme_read32(hp, hp->gregs + GREG_STAT);
 
 		HMD(("quattro_interrupt: status=%08x ", happy_status));
@@ -2189,7 +2189,7 @@ static irqreturn_t quattro_sbus_interrupt(int irq, void *cookie)
 
 static int happy_meal_open(struct net_device *dev)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 	int res;
 
 	HMD(("happy_meal_open: "));
@@ -2221,7 +2221,7 @@ static int happy_meal_open(struct net_device *dev)
 
 static int happy_meal_close(struct net_device *dev)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 
 	spin_lock_irq(&hp->happy_lock);
 	happy_meal_stop(hp, hp->gregs);
@@ -2250,7 +2250,7 @@ static int happy_meal_close(struct net_device *dev)
 
 static void happy_meal_tx_timeout(struct net_device *dev)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 
 	printk (KERN_ERR "%s: transmit timed out, resetting\n", dev->name);
 	tx_dump_log();
@@ -2268,7 +2268,7 @@ static void happy_meal_tx_timeout(struct net_device *dev)
 
 static int happy_meal_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
  	int entry;
  	u32 tx_flags;
 
@@ -2357,7 +2357,7 @@ static int happy_meal_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static struct net_device_stats *happy_meal_get_stats(struct net_device *dev)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 
 	spin_lock_irq(&hp->happy_lock);
 	happy_meal_get_counters(hp, hp->bigmacregs);
@@ -2368,7 +2368,7 @@ static struct net_device_stats *happy_meal_get_stats(struct net_device *dev)
 
 static void happy_meal_set_multicast(struct net_device *dev)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 	void __iomem *bregs = hp->bigmacregs;
 	struct dev_mc_list *dmi = dev->mc_list;
 	char *addrs;
@@ -2414,7 +2414,7 @@ static void happy_meal_set_multicast(struct net_device *dev)
 /* Ethtool support... */
 static int hme_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 
 	cmd->supported =
 		(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
@@ -2459,7 +2459,7 @@ static int hme_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int hme_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 
 	/* Verify the settings we care about. */
 	if (cmd->autoneg != AUTONEG_ENABLE &&
@@ -2483,7 +2483,7 @@ static int hme_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static void hme_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 
 	strcpy(info->driver, "sunhme");
 	strcpy(info->version, "2.02");
@@ -2502,7 +2502,7 @@ static void hme_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
 
 static u32 hme_get_link(struct net_device *dev)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 
 	spin_lock_irq(&hp->happy_lock);
 	hp->sw_bmcr = happy_meal_tcvr_read(hp, hp->tcvregs, MII_BMCR);
@@ -2713,7 +2713,7 @@ static int __devinit happy_meal_sbus_probe_one(struct sbus_dev *sdev, int is_qfe
 			memcpy(dev->dev_addr, idprom->id_ethaddr, 6);
 	}
 
-	hp = dev->priv;
+	hp = netdev_priv(dev);
 
 	hp->happy_dev = sdev;
 
@@ -3031,7 +3031,7 @@ static int __devinit happy_meal_pci_probe(struct pci_dev *pdev,
 
 	dev->base_addr = (long) pdev;
 
-	hp = (struct happy_meal *)dev->priv;
+	hp = netdev_priv(dev);
 	memset(hp, 0, sizeof(*hp));
 
 	hp->happy_dev = pdev;


