From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-11
Date: Tue, 26 Aug 2008 22:19:04 +0800
Message-ID: <48B410D8.4060304@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62914 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756920AbYHZOVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:21:32 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index fa3a460..7bcc7a2 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -437,7 +437,7 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 	if (ret)
 		goto err_out;
 
-	sis_priv = net_dev->priv;
+	sis_priv = netdev_priv(net_dev);
 	net_dev->base_addr = ioaddr;
 	net_dev->irq = pci_dev->irq;
 	sis_priv->pci_dev = pci_dev;
@@ -570,7 +570,7 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 
 static int __devinit sis900_mii_probe(struct net_device * net_dev)
 {
-	struct sis900_private * sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	const char *dev_name = pci_name(sis_priv->pci_dev);
 	u16 poll_bit = MII_STAT_LINK, status = 0;
 	unsigned long timeout = jiffies + 5 * HZ;
@@ -698,7 +698,7 @@ static int __devinit sis900_mii_probe(struct net_device * net_dev)
 
 static u16 sis900_default_phy(struct net_device * net_dev)
 {
-	struct sis900_private * sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
  	struct mii_phy *phy = NULL, *phy_home = NULL,
 		*default_phy = NULL, *phy_lan = NULL;
 	u16 status;
@@ -999,7 +999,7 @@ static void sis900_poll(struct net_device *dev)
 static int
 sis900_open(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	int ret;
 
@@ -1055,7 +1055,7 @@ sis900_open(struct net_device *net_dev)
 static void
 sis900_init_rxfilter (struct net_device * net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	u32 rfcrSave;
 	u32 i;
@@ -1093,7 +1093,7 @@ sis900_init_rxfilter (struct net_device * net_dev)
 static void
 sis900_init_tx_ring(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	int i;
 
@@ -1127,7 +1127,7 @@ sis900_init_tx_ring(struct net_device *net_dev)
 static void
 sis900_init_rx_ring(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	int i;
 
@@ -1198,7 +1198,7 @@ sis900_init_rx_ring(struct net_device *net_dev)
 
 static void sis630_set_eq(struct net_device *net_dev, u8 revision)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	u16 reg14h, eq_value=0, max_value=0, min_value=0;
 	int i, maxcount=10;
 
@@ -1271,7 +1271,7 @@ static void sis630_set_eq(struct net_device *net_dev, u8 revision)
 static void sis900_timer(unsigned long data)
 {
 	struct net_device *net_dev = (struct net_device *)data;
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	struct mii_phy *mii_phy = sis_priv->mii;
 	static const int next_tick = 5*HZ;
 	u16 status;
@@ -1341,7 +1341,7 @@ static void sis900_timer(unsigned long data)
 
 static void sis900_check_mode(struct net_device *net_dev, struct mii_phy *mii_phy)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	int speed, duplex;
 
@@ -1420,7 +1420,7 @@ static void sis900_set_mode (long ioaddr, int speed, int duplex)
 
 static void sis900_auto_negotiate(struct net_device *net_dev, int phy_addr)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	int i = 0;
 	u32 status;
 
@@ -1455,7 +1455,7 @@ static void sis900_auto_negotiate(struct net_device *net_dev, int phy_addr)
 
 static void sis900_read_mode(struct net_device *net_dev, int *speed, int *duplex)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	struct mii_phy *phy = sis_priv->mii;
 	int phy_addr = sis_priv->cur_phy;
 	u32 status;
@@ -1510,7 +1510,7 @@ static void sis900_read_mode(struct net_device *net_dev, int *speed, int *duplex
 
 static void sis900_tx_timeout(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	unsigned long flags;
 	int i;
@@ -1569,7 +1569,7 @@ static void sis900_tx_timeout(struct net_device *net_dev)
 static int
 sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	unsigned int  entry;
 	unsigned long flags;
@@ -1639,7 +1639,7 @@ sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 static irqreturn_t sis900_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *net_dev = dev_instance;
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	int boguscnt = max_interrupt_work;
 	long ioaddr = net_dev->base_addr;
 	u32 status;
@@ -1701,7 +1701,7 @@ static irqreturn_t sis900_interrupt(int irq, void *dev_instance)
 
 static int sis900_rx(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	unsigned int entry = sis_priv->cur_rx % NUM_RX_DESC;
 	u32 rx_status = sis_priv->rx_ring[entry].cmdsts;
@@ -1851,7 +1851,7 @@ refill_rx_ring:
 
 static void sis900_finish_xmit (struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 
 	for (; sis_priv->dirty_tx != sis_priv->cur_tx; sis_priv->dirty_tx++) {
 		struct sk_buff *skb;
@@ -1920,7 +1920,7 @@ static void sis900_finish_xmit (struct net_device *net_dev)
 static int sis900_close(struct net_device *net_dev)
 {
 	long ioaddr = net_dev->base_addr;
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	struct sk_buff *skb;
 	int i;
 
@@ -1975,7 +1975,7 @@ static int sis900_close(struct net_device *net_dev)
 static void sis900_get_drvinfo(struct net_device *net_dev,
 			       struct ethtool_drvinfo *info)
 {
- 	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 
 	strcpy (info->driver, SIS900_MODULE_NAME);
 	strcpy (info->version, SIS900_DRV_VERSION);
@@ -1984,26 +1984,26 @@ static void sis900_get_drvinfo(struct net_device *net_dev,
 
 static u32 sis900_get_msglevel(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	return sis_priv->msg_enable;
 }
 
 static void sis900_set_msglevel(struct net_device *net_dev, u32 value)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	sis_priv->msg_enable = value;
 }
 
 static u32 sis900_get_link(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	return mii_link_ok(&sis_priv->mii_info);
 }
 
 static int sis900_get_settings(struct net_device *net_dev,
 				struct ethtool_cmd *cmd)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	spin_lock_irq(&sis_priv->lock);
 	mii_ethtool_gset(&sis_priv->mii_info, cmd);
 	spin_unlock_irq(&sis_priv->lock);
@@ -2013,7 +2013,7 @@ static int sis900_get_settings(struct net_device *net_dev,
 static int sis900_set_settings(struct net_device *net_dev,
 				struct ethtool_cmd *cmd)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	int rt;
 	spin_lock_irq(&sis_priv->lock);
 	rt = mii_ethtool_sset(&sis_priv->mii_info, cmd);
@@ -2023,7 +2023,7 @@ static int sis900_set_settings(struct net_device *net_dev,
 
 static int sis900_nway_reset(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	return mii_nway_restart(&sis_priv->mii_info);
 }
 
@@ -2040,7 +2040,7 @@ static int sis900_nway_reset(struct net_device *net_dev)
 
 static int sis900_set_wol(struct net_device *net_dev, struct ethtool_wolinfo *wol)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long pmctrl_addr = net_dev->base_addr + pmctrl;
 	u32 cfgpmcsr = 0, pmctrl_bits = 0;
 
@@ -2111,7 +2111,7 @@ static const struct ethtool_ops sis900_ethtool_ops = {
 
 static int mii_ioctl(struct net_device *net_dev, struct ifreq *rq, int cmd)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	struct mii_ioctl_data *data = if_mii(rq);
 
 	switch(cmd) {
@@ -2145,7 +2145,7 @@ static int mii_ioctl(struct net_device *net_dev, struct ifreq *rq, int cmd)
 
 static int sis900_set_config(struct net_device *dev, struct ifmap *map)
 {
-	struct sis900_private *sis_priv = dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(dev);
 	struct mii_phy *mii_phy = sis_priv->mii;
 
 	u16 status;
@@ -2268,7 +2268,7 @@ static inline u16 sis900_mcast_bitnr(u8 *addr, u8 revision)
 static void set_rx_mode(struct net_device *net_dev)
 {
 	long ioaddr = net_dev->base_addr;
-	struct sis900_private * sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	u16 mc_filter[16] = {0};	/* 256/128 bits multicast hash table */
 	int i, table_entries;
 	u32 rx_mode;
@@ -2343,7 +2343,7 @@ static void set_rx_mode(struct net_device *net_dev)
 
 static void sis900_reset(struct net_device *net_dev)
 {
-	struct sis900_private * sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	int i = 0;
 	u32 status = TxRCMP | RxRCMP;
@@ -2376,7 +2376,7 @@ static void sis900_reset(struct net_device *net_dev)
 static void __devexit sis900_remove(struct pci_dev *pci_dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
-	struct sis900_private * sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	struct mii_phy *phy = NULL;
 
 	while (sis_priv->first_mii) {
@@ -2420,7 +2420,7 @@ static int sis900_suspend(struct pci_dev *pci_dev, pm_message_t state)
 static int sis900_resume(struct pci_dev *pci_dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 
 	if(!netif_running(net_dev))
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index de67744..8dcbc42 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -1036,7 +1036,7 @@ static int __init smc_probe(struct net_device *dev, int ioaddr)
 	printk("ADDR: %s\n", print_mac(mac, dev->dev_addr));
 
 	/* set the private data to zero by default */
-	memset(dev->priv, 0, sizeof(struct smc_local));
+	memset(netdev_priv(dev), 0, sizeof(struct smc_local));
 
 	/* Grab the IRQ */
       	retval = request_irq(dev->irq, &smc_interrupt, 0, DRV_NAME, dev);
@@ -1110,7 +1110,7 @@ static int smc_open(struct net_device *dev)
 	int	i;	/* used to set hw ethernet address */
 
 	/* clear out all the junk that was put here before... */
-	memset(dev->priv, 0, sizeof(struct smc_local));
+	memset(netdev_priv(dev), 0, sizeof(struct smc_local));
 
 	/* reset the hardware */
 
@@ -1166,7 +1166,7 @@ static void smc_timeout(struct net_device *dev)
 	smc_enable( dev->base_addr );
 	dev->trans_start = jiffies;
 	/* clear anything saved */
-	((struct smc_local *)dev->priv)->saved_skb = NULL;
+	((struct smc_local *)netdev_priv(dev))->saved_skb = NULL;
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/sonic.h b/drivers/net/sonic.h
index 7db13e4..07091dd 100644
--- a/drivers/net/sonic.h
+++ b/drivers/net/sonic.h
@@ -371,7 +371,7 @@ static inline __u16 sonic_buf_get(void* base, int bitmode,
 static inline void sonic_cda_put(struct net_device* dev, int entry,
 				 int offset, __u16 val)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local *lp = netdev_priv(dev);
 	sonic_buf_put(lp->cda, lp->dma_bitmode,
 		      (entry * SIZEOF_SONIC_CD) + offset, val);
 }
@@ -379,27 +379,27 @@ static inline void sonic_cda_put(struct net_device* dev, int entry,
 static inline __u16 sonic_cda_get(struct net_device* dev, int entry,
 				  int offset)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local *lp = netdev_priv(dev);
 	return sonic_buf_get(lp->cda, lp->dma_bitmode,
 			     (entry * SIZEOF_SONIC_CD) + offset);
 }
 
 static inline void sonic_set_cam_enable(struct net_device* dev, __u16 val)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local *lp = netdev_priv(dev);
 	sonic_buf_put(lp->cda, lp->dma_bitmode, SONIC_CDA_CAM_ENABLE, val);
 }
 
 static inline __u16 sonic_get_cam_enable(struct net_device* dev)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local *lp = netdev_priv(dev);
 	return sonic_buf_get(lp->cda, lp->dma_bitmode, SONIC_CDA_CAM_ENABLE);
 }
 
 static inline void sonic_tda_put(struct net_device* dev, int entry,
 				 int offset, __u16 val)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local *lp = netdev_priv(dev);
 	sonic_buf_put(lp->tda, lp->dma_bitmode,
 		      (entry * SIZEOF_SONIC_TD) + offset, val);
 }
@@ -407,7 +407,7 @@ static inline void sonic_tda_put(struct net_device* dev, int entry,
 static inline __u16 sonic_tda_get(struct net_device* dev, int entry,
 				  int offset)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local *lp = netdev_priv(dev);
 	return sonic_buf_get(lp->tda, lp->dma_bitmode,
 			     (entry * SIZEOF_SONIC_TD) + offset);
 }
@@ -415,7 +415,7 @@ static inline __u16 sonic_tda_get(struct net_device* dev, int entry,
 static inline void sonic_rda_put(struct net_device* dev, int entry,
 				 int offset, __u16 val)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local *lp = netdev_priv(dev);
 	sonic_buf_put(lp->rda, lp->dma_bitmode,
 		      (entry * SIZEOF_SONIC_RD) + offset, val);
 }
@@ -423,7 +423,7 @@ static inline void sonic_rda_put(struct net_device* dev, int entry,
 static inline __u16 sonic_rda_get(struct net_device* dev, int entry,
 				  int offset)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local *lp = netdev_priv(dev);
 	return sonic_buf_get(lp->rda, lp->dma_bitmode,
 			     (entry * SIZEOF_SONIC_RD) + offset);
 }
@@ -431,7 +431,7 @@ static inline __u16 sonic_rda_get(struct net_device* dev, int entry,
 static inline void sonic_rra_put(struct net_device* dev, int entry,
 				 int offset, __u16 val)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local *lp = netdev_priv(dev);
 	sonic_buf_put(lp->rra, lp->dma_bitmode,
 		      (entry * SIZEOF_SONIC_RR) + offset, val);
 }
@@ -439,7 +439,7 @@ static inline void sonic_rra_put(struct net_device* dev, int entry,
 static inline __u16 sonic_rra_get(struct net_device* dev, int entry,
 				  int offset)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local *lp = netdev_priv(dev);
 	return sonic_buf_get(lp->rra, lp->dma_bitmode,
 			     (entry * SIZEOF_SONIC_RR) + offset);
 }
diff --git a/drivers/net/spider_net_ethtool.c b/drivers/net/spider_net_ethtool.c
index 85691d2..5bae728 100644
--- a/drivers/net/spider_net_ethtool.c
+++ b/drivers/net/spider_net_ethtool.c
@@ -118,7 +118,7 @@ spider_net_ethtool_nway_reset(struct net_device *netdev)
 static u32
 spider_net_ethtool_get_rx_csum(struct net_device *netdev)
 {
-	struct spider_net_card *card = netdev->priv;
+	struct spider_net_card *card = netdev_priv(netdev);
 
 	return card->options.rx_csum;
 }
@@ -126,7 +126,7 @@ spider_net_ethtool_get_rx_csum(struct net_device *netdev)
 static int
 spider_net_ethtool_set_rx_csum(struct net_device *netdev, u32 n)
 {
-	struct spider_net_card *card = netdev->priv;
+	struct spider_net_card *card = netdev_priv(netdev);
 
 	card->options.rx_csum = n;
 	return 0;
@@ -137,7 +137,7 @@ static void
 spider_net_ethtool_get_ringparam(struct net_device *netdev,
 				 struct ethtool_ringparam *ering)
 {
-	struct spider_net_card *card = netdev->priv;
+	struct spider_net_card *card = netdev_priv(netdev);
 
 	ering->tx_max_pending = SPIDER_NET_TX_DESCRIPTORS_MAX;
 	ering->tx_pending = card->tx_chain.num_desc;
@@ -158,7 +158,7 @@ static int spider_net_get_sset_count(struct net_device *netdev, int sset)
 static void spider_net_get_ethtool_stats(struct net_device *netdev,
 		struct ethtool_stats *stats, u64 *data)
 {
-	struct spider_net_card *card = netdev->priv;
+	struct spider_net_card *card = netdev_priv(netdev);
 
 	data[0] = netdev->stats.tx_packets;
 	data[1] = netdev->stats.tx_bytes;
diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index e531302..e8f97d5 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -247,7 +247,7 @@ static int check586(struct net_device *dev,char *where,unsigned size)
  */
 static void alloc586(struct net_device *dev)
 {
-	struct priv *p =	(struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	sun3_reset586();
 	DELAY(1);
@@ -363,17 +363,21 @@ static int __init sun3_82586_probe1(struct net_device *dev,int ioaddr)
 		goto out;
 	}
 
-	((struct priv *) (dev->priv))->memtop = (char *)dvma_btov(dev->mem_start);
-	((struct priv *) (dev->priv))->base = (unsigned long) dvma_btov(0);
+	((struct priv *)netdev_priv(dev))->memtop =
+					(char *)dvma_btov(dev->mem_start);
+	((struct priv *)netdev_priv(dev))->base = (unsigned long) dvma_btov(0);
 	alloc586(dev);
 
 	/* set number of receive-buffs according to memsize */
 	if(size == 0x2000)
-		((struct priv *) dev->priv)->num_recv_buffs = NUM_RECV_BUFFS_8;
+		((struct priv *)netdev_priv(dev))->num_recv_buffs =
+							NUM_RECV_BUFFS_8;
 	else if(size == 0x4000)
-		((struct priv *) dev->priv)->num_recv_buffs = NUM_RECV_BUFFS_16;
+		((struct priv *)netdev_priv(dev))->num_recv_buffs =
+							NUM_RECV_BUFFS_16;
 	else
-		((struct priv *) dev->priv)->num_recv_buffs = NUM_RECV_BUFFS_32;
+		((struct priv *)netdev_priv(dev))->num_recv_buffs =
+							NUM_RECV_BUFFS_32;
 
 	printk("Memaddr: 0x%lx, Memsize: %d, IRQ %d\n",dev->mem_start,size, dev->irq);
 
@@ -397,7 +401,7 @@ static int init586(struct net_device *dev)
 {
 	void *ptr;
 	int i,result=0;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	volatile struct configure_cmd_struct	*cfg_cmd;
 	volatile struct iasetup_cmd_struct *ias_cmd;
 	volatile struct tdr_cmd_struct *tdr_cmd;
@@ -631,7 +635,7 @@ static void *alloc_rfa(struct net_device *dev,void *ptr)
 	volatile struct rfd_struct *rfd = (struct rfd_struct *)ptr;
 	volatile struct rbd_struct *rbd;
 	int i;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	memset((char *) rfd,0,sizeof(struct rfd_struct)*(p->num_recv_buffs+rfdadd));
 	p->rfd_first = rfd;
@@ -683,7 +687,7 @@ static irqreturn_t sun3_82586_interrupt(int irq,void *dev_id)
 		printk ("sun3_82586-interrupt: irq %d for unknown device.\n",irq);
 		return IRQ_NONE;
 	}
-	p = (struct priv *) dev->priv;
+	p = netdev_priv(dev);
 
 	if(debuglevel > 1)
 		printk("I");
@@ -753,7 +757,7 @@ static void sun3_82586_rcv_int(struct net_device *dev)
 	unsigned short totlen;
 	struct sk_buff *skb;
 	struct rbd_struct *rbd;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	if(debuglevel > 0)
 		printk("R");
@@ -871,7 +875,7 @@ static void sun3_82586_rcv_int(struct net_device *dev)
 
 static void sun3_82586_rnr_int(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	p->stats.rx_errors++;
 
@@ -895,7 +899,7 @@ static void sun3_82586_rnr_int(struct net_device *dev)
 static void sun3_82586_xmt_int(struct net_device *dev)
 {
 	int status;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	if(debuglevel > 0)
 		printk("X");
@@ -945,7 +949,7 @@ static void sun3_82586_xmt_int(struct net_device *dev)
 
 static void startrecv586(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	WAIT_4_SCB_CMD();
 	WAIT_4_SCB_CMD_RUC();
@@ -957,7 +961,7 @@ static void startrecv586(struct net_device *dev)
 
 static void sun3_82586_timeout(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 #ifndef NO_NOPCOMMANDS
 	if(p->scb->cus & CU_ACTIVE) /* COMMAND-UNIT active? */
 	{
@@ -999,7 +1003,7 @@ static int sun3_82586_send_packet(struct sk_buff *skb, struct net_device *dev)
 #ifndef NO_NOPCOMMANDS
 	int next_nop;
 #endif
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	if(skb->len > XMIT_BUFF_SIZE)
 	{
@@ -1108,7 +1112,7 @@ static int sun3_82586_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 static struct net_device_stats *sun3_82586_get_stats(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	unsigned short crc,aln,rsc,ovrn;
 
 	crc = swab16(p->scb->crc_errs); /* get error-statistic from the ni82586 */
@@ -1171,7 +1175,7 @@ void cleanup_module(void)
  */
 void sun3_82586_dump(struct net_device *dev,void *ptr)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	struct dump_cmd_struct *dump_cmd = (struct dump_cmd_struct *) ptr;
 	int i;
 


