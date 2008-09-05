From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 03/18] netdevice: safe convert to netdev_priv() #part-3
Date: Fri, 05 Sep 2008 11:11:10 +0800
Message-ID: <48C0A34E.4030905@cn.fujitsu.com>
References: <48C0A219.2030004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55468 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756887AbYIEDNh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 23:13:37 -0400
In-Reply-To: <48C0A219.2030004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/sgiseeq.c                      |    2 +-
 drivers/net/sis900.c                       |   64 ++++++++++++++--------------
 drivers/net/smc9194.c                      |    6 +-
 drivers/net/sonic.h                        |   20 ++++----
 drivers/net/spider_net_ethtool.c           |    8 ++--
 drivers/net/sun3_82586.c                   |   38 +++++++++-------
 drivers/net/sunbmac.c                      |   18 ++++----
 drivers/net/sungem.c                       |   52 +++++++++++-----------
 drivers/net/sunhme.c                       |   26 ++++++------
 drivers/net/sunqe.c                        |   14 +++---
 drivers/net/tehuti.c                       |   38 ++++++++--------
 drivers/net/tokenring/tms380tr.c           |   14 ++++--
 drivers/net/tulip/de2104x.c                |   44 ++++++++++----------
 drivers/net/tulip/eeprom.c                 |    2 +-
 drivers/net/tulip/uli526x.c                |    2 +-
 drivers/net/typhoon.c                      |    2 +-
 drivers/net/usb/mcs7830.c                  |    4 +-
 drivers/net/virtio_net.c                   |    3 +-
 drivers/net/wan/dlci.c                     |   36 ++++++++--------
 drivers/net/wan/sdla.c                     |   48 ++++++++++----------
 drivers/net/wan/x25_asy.c                  |   28 ++++++------
 drivers/net/wireless/libertas/ethtool.c    |   12 +++---
 drivers/net/wireless/libertas/persistcfg.c |   16 ++++----
 drivers/net/wireless/libertas/scan.c       |    4 +-
 drivers/net/wireless/libertas/tx.c         |    2 +-
 25 files changed, 256 insertions(+), 247 deletions(-)

diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 6261201..cc6317a 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -657,7 +657,7 @@ static void timeout(struct net_device *dev)
 
 static void sgiseeq_set_multicast(struct net_device *dev)
 {
-	struct sgiseeq_private *sp = (struct sgiseeq_private *) dev->priv;
+	struct sgiseeq_private *sp = netdev_priv(dev);
 	unsigned char oldmode = sp->mode;
 
 	if(dev->flags & IFF_PROMISC)
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
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index e811331..22875d2 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -511,7 +511,7 @@ static irqreturn_t qec_interrupt(int irq, void *dev_id)
 
 static int qe_open(struct net_device *dev)
 {
-	struct sunqe *qep = (struct sunqe *) dev->priv;
+	struct sunqe *qep = netdev_priv(dev);
 
 	qep->mconfig = (MREGS_MCONFIG_TXENAB |
 			MREGS_MCONFIG_RXENAB |
@@ -521,7 +521,7 @@ static int qe_open(struct net_device *dev)
 
 static int qe_close(struct net_device *dev)
 {
-	struct sunqe *qep = (struct sunqe *) dev->priv;
+	struct sunqe *qep = netdev_priv(dev);
 
 	qe_stop(qep);
 	return 0;
@@ -547,7 +547,7 @@ static void qe_tx_reclaim(struct sunqe *qep)
 
 static void qe_tx_timeout(struct net_device *dev)
 {
-	struct sunqe *qep = (struct sunqe *) dev->priv;
+	struct sunqe *qep = netdev_priv(dev);
 	int tx_full;
 
 	spin_lock_irq(&qep->lock);
@@ -573,7 +573,7 @@ out:
 /* Get a packet queued to go onto the wire. */
 static int qe_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct sunqe *qep = (struct sunqe *) dev->priv;
+	struct sunqe *qep = netdev_priv(dev);
 	struct sunqe_buffers *qbufs = qep->buffers;
 	__u32 txbuf_dvma, qbufs_dvma = qep->buffers_dvma;
 	unsigned char *txbuf;
@@ -625,7 +625,7 @@ static int qe_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static void qe_set_multicast(struct net_device *dev)
 {
-	struct sunqe *qep = (struct sunqe *) dev->priv;
+	struct sunqe *qep = netdev_priv(dev);
 	struct dev_mc_list *dmi = dev->mc_list;
 	u8 new_mconfig = qep->mconfig;
 	char *addrs;
@@ -690,7 +690,7 @@ static void qe_set_multicast(struct net_device *dev)
 /* Ethtool support... */
 static void qe_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct sunqe *qep = dev->priv;
+	struct sunqe *qep = netdev_priv(dev);
 
 	strcpy(info->driver, "sunqe");
 	strcpy(info->version, "3.0");
@@ -700,7 +700,7 @@ static void qe_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 
 static u32 qe_get_link(struct net_device *dev)
 {
-	struct sunqe *qep = dev->priv;
+	struct sunqe *qep = netdev_priv(dev);
 	void __iomem *mregs = qep->mregs;
 	u8 phyconfig;
 
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 91f9054..a372a5a 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -251,7 +251,7 @@ static void bdx_isr_extra(struct bdx_priv *priv, u32 isr)
 static irqreturn_t bdx_isr_napi(int irq, void *dev)
 {
 	struct net_device *ndev = dev;
-	struct bdx_priv *priv = ndev->priv;
+	struct bdx_priv *priv = netdev_priv(ndev);
 	u32 isr;
 
 	ENTER;
@@ -559,7 +559,7 @@ static int bdx_close(struct net_device *ndev)
 	struct bdx_priv *priv = NULL;
 
 	ENTER;
-	priv = ndev->priv;
+	priv = netdev_priv(ndev);
 
 	napi_disable(&priv->napi);
 
@@ -588,7 +588,7 @@ static int bdx_open(struct net_device *ndev)
 	int rc;
 
 	ENTER;
-	priv = ndev->priv;
+	priv = netdev_priv(ndev);
 	bdx_reset(priv);
 	if (netif_running(ndev))
 		netif_stop_queue(priv->ndev);
@@ -633,7 +633,7 @@ static int bdx_range_check(struct bdx_priv *priv, u32 offset)
 
 static int bdx_ioctl_priv(struct net_device *ndev, struct ifreq *ifr, int cmd)
 {
-	struct bdx_priv *priv = ndev->priv;
+	struct bdx_priv *priv = netdev_priv(ndev);
 	u32 data[3];
 	int error;
 
@@ -698,7 +698,7 @@ static int bdx_ioctl(struct net_device *ndev, struct ifreq *ifr, int cmd)
  */
 static void __bdx_vlan_rx_vid(struct net_device *ndev, uint16_t vid, int enable)
 {
-	struct bdx_priv *priv = ndev->priv;
+	struct bdx_priv *priv = netdev_priv(ndev);
 	u32 reg, bit, val;
 
 	ENTER;
@@ -748,7 +748,7 @@ static void bdx_vlan_rx_kill_vid(struct net_device *ndev, unsigned short vid)
 static void
 bdx_vlan_rx_register(struct net_device *ndev, struct vlan_group *grp)
 {
-	struct bdx_priv *priv = ndev->priv;
+	struct bdx_priv *priv = netdev_priv(ndev);
 
 	ENTER;
 	DBG("device='%s', group='%p'\n", ndev->name, grp);
@@ -787,7 +787,7 @@ static int bdx_change_mtu(struct net_device *ndev, int new_mtu)
 
 static void bdx_setmulti(struct net_device *ndev)
 {
-	struct bdx_priv *priv = ndev->priv;
+	struct bdx_priv *priv = netdev_priv(ndev);
 
 	u32 rxf_val =
 	    GMAC_RX_FILTER_AM | GMAC_RX_FILTER_AB | GMAC_RX_FILTER_OSEN;
@@ -847,7 +847,7 @@ static void bdx_setmulti(struct net_device *ndev)
 
 static int bdx_set_mac(struct net_device *ndev, void *p)
 {
-	struct bdx_priv *priv = ndev->priv;
+	struct bdx_priv *priv = netdev_priv(ndev);
 	struct sockaddr *addr = p;
 
 	ENTER;
@@ -929,7 +929,7 @@ static void bdx_update_stats(struct bdx_priv *priv)
 
 static struct net_device_stats *bdx_get_stats(struct net_device *ndev)
 {
-	struct bdx_priv *priv = ndev->priv;
+	struct bdx_priv *priv = netdev_priv(ndev);
 	struct net_device_stats *net_stat = &priv->net_stats;
 	return net_stat;
 }
@@ -1624,7 +1624,7 @@ static inline int bdx_tx_space(struct bdx_priv *priv)
  */
 static int bdx_tx_transmit(struct sk_buff *skb, struct net_device *ndev)
 {
-	struct bdx_priv *priv = ndev->priv;
+	struct bdx_priv *priv = netdev_priv(ndev);
 	struct txd_fifo *f = &priv->txd_fifo0;
 	int txd_checksum = 7;	/* full checksum */
 	int txd_lgsnd = 0;
@@ -2027,7 +2027,7 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			ndev->features |= NETIF_F_HIGHDMA;
 
 	/************** priv ****************/
-		priv = nic->priv[port] = ndev->priv;
+		priv = nic->priv[port] = netdev_priv(ndev);
 
 		memset(priv, 0, sizeof(struct bdx_priv));
 		priv->pBdxRegs = nic->regs + port * 0x8000;
@@ -2150,7 +2150,7 @@ static int bdx_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	u32 rdintcm;
 	u32 tdintcm;
-	struct bdx_priv *priv = netdev->priv;
+	struct bdx_priv *priv = netdev_priv(netdev);
 
 	rdintcm = priv->rdintcm;
 	tdintcm = priv->tdintcm;
@@ -2181,7 +2181,7 @@ static int bdx_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 static void
 bdx_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 {
-	struct bdx_priv *priv = netdev->priv;
+	struct bdx_priv *priv = netdev_priv(netdev);
 
 	strlcat(drvinfo->driver, BDX_DRV_NAME, sizeof(drvinfo->driver));
 	strlcat(drvinfo->version, BDX_DRV_VERSION, sizeof(drvinfo->version));
@@ -2223,7 +2223,7 @@ bdx_get_coalesce(struct net_device *netdev, struct ethtool_coalesce *ecoal)
 {
 	u32 rdintcm;
 	u32 tdintcm;
-	struct bdx_priv *priv = netdev->priv;
+	struct bdx_priv *priv = netdev_priv(netdev);
 
 	rdintcm = priv->rdintcm;
 	tdintcm = priv->tdintcm;
@@ -2252,7 +2252,7 @@ bdx_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *ecoal)
 {
 	u32 rdintcm;
 	u32 tdintcm;
-	struct bdx_priv *priv = netdev->priv;
+	struct bdx_priv *priv = netdev_priv(netdev);
 	int rx_coal;
 	int tx_coal;
 	int rx_max_coal;
@@ -2310,7 +2310,7 @@ static inline int bdx_tx_fifo_size_to_packets(int tx_size)
 static void
 bdx_get_ringparam(struct net_device *netdev, struct ethtool_ringparam *ring)
 {
-	struct bdx_priv *priv = netdev->priv;
+	struct bdx_priv *priv = netdev_priv(netdev);
 
 	/*max_pending - the maximum-sized FIFO we allow */
 	ring->rx_max_pending = bdx_rx_fifo_size_to_packets(3);
@@ -2327,7 +2327,7 @@ bdx_get_ringparam(struct net_device *netdev, struct ethtool_ringparam *ring)
 static int
 bdx_set_ringparam(struct net_device *netdev, struct ethtool_ringparam *ring)
 {
-	struct bdx_priv *priv = netdev->priv;
+	struct bdx_priv *priv = netdev_priv(netdev);
 	int rx_size = 0;
 	int tx_size = 0;
 
@@ -2388,7 +2388,7 @@ static void bdx_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
  */
 static int bdx_get_stats_count(struct net_device *netdev)
 {
-	struct bdx_priv *priv = netdev->priv;
+	struct bdx_priv *priv = netdev_priv(netdev);
 	BDX_ASSERT(ARRAY_SIZE(bdx_stat_names)
 		   != sizeof(struct bdx_stats) / sizeof(u64));
 	return ((priv->stats_flag) ? ARRAY_SIZE(bdx_stat_names)	: 0);
@@ -2403,7 +2403,7 @@ static int bdx_get_stats_count(struct net_device *netdev)
 static void bdx_get_ethtool_stats(struct net_device *netdev,
 				  struct ethtool_stats *stats, u64 *data)
 {
-	struct bdx_priv *priv = netdev->priv;
+	struct bdx_priv *priv = netdev_priv(netdev);
 
 	if (priv->stats_flag) {
 
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index d07c452..edd1d38 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -180,10 +180,14 @@ void	 	tms380tr_wait(unsigned long time);
 static void 	tms380tr_write_rpl_status(RPL *rpl, unsigned int Status);
 static void 	tms380tr_write_tpl_status(TPL *tpl, unsigned int Status);
 
-#define SIFREADB(reg) (((struct net_local *)dev->priv)->sifreadb(dev, reg))
-#define SIFWRITEB(val, reg) (((struct net_local *)dev->priv)->sifwriteb(dev, val, reg))
-#define SIFREADW(reg) (((struct net_local *)dev->priv)->sifreadw(dev, reg))
-#define SIFWRITEW(val, reg) (((struct net_local *)dev->priv)->sifwritew(dev, val, reg))
+#define SIFREADB(reg) \
+	(((struct net_local *)netdev_priv(dev))->sifreadb(dev, reg))
+#define SIFWRITEB(val, reg) \
+	(((struct net_local *)netdev_priv(dev))->sifwriteb(dev, val, reg))
+#define SIFREADW(reg) \
+	(((struct net_local *)netdev_priv(dev))->sifreadw(dev, reg))
+#define SIFWRITEW(val, reg) \
+	(((struct net_local *)netdev_priv(dev))->sifwritew(dev, val, reg))
 
 
 
@@ -2331,7 +2335,7 @@ int tmsdev_init(struct net_device *dev, struct device *pdev)
 {
 	struct net_local *tms_local;
 
-	memset(dev->priv, 0, sizeof(struct net_local));
+	memset(netdev_priv(dev), 0, sizeof(struct net_local));
 	tms_local = netdev_priv(dev);
 	init_waitqueue_head(&tms_local->wait_for_tok_int);
 	if (pdev->dma_mask)
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 9281d06..66bebab 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -484,7 +484,7 @@ rx_next:
 static irqreturn_t de_interrupt (int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 	u32 status;
 
 	status = dr32(MacStatus);
@@ -590,7 +590,7 @@ next:
 
 static int de_start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 	unsigned int entry, tx_free;
 	u32 mapping, len, flags = FirstFrag | LastFrag;
 	struct de_desc *txd;
@@ -653,7 +653,7 @@ static int de_start_xmit (struct sk_buff *skb, struct net_device *dev)
 
 static void build_setup_frame_hash(u16 *setup_frm, struct net_device *dev)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 	u16 hash_table[32];
 	struct dev_mc_list *mclist;
 	int i;
@@ -684,7 +684,7 @@ static void build_setup_frame_hash(u16 *setup_frm, struct net_device *dev)
 
 static void build_setup_frame_perfect(u16 *setup_frm, struct net_device *dev)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 	struct dev_mc_list *mclist;
 	int i;
 	u16 *eaddrs;
@@ -712,7 +712,7 @@ static void build_setup_frame_perfect(u16 *setup_frm, struct net_device *dev)
 
 static void __de_set_rx_mode (struct net_device *dev)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 	u32 macmode;
 	unsigned int entry;
 	u32 mapping;
@@ -797,7 +797,7 @@ out:
 static void de_set_rx_mode (struct net_device *dev)
 {
 	unsigned long flags;
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 
 	spin_lock_irqsave (&de->lock, flags);
 	__de_set_rx_mode(dev);
@@ -821,7 +821,7 @@ static void __de_get_stats(struct de_private *de)
 
 static struct net_device_stats *de_get_stats(struct net_device *dev)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 
 	/* The chip only need report frame silently dropped. */
 	spin_lock_irq(&de->lock);
@@ -1355,7 +1355,7 @@ static void de_free_rings (struct de_private *de)
 
 static int de_open (struct net_device *dev)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 	int rc;
 
 	if (netif_msg_ifup(de))
@@ -1400,7 +1400,7 @@ err_out_free:
 
 static int de_close (struct net_device *dev)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 	unsigned long flags;
 
 	if (netif_msg_ifdown(de))
@@ -1424,7 +1424,7 @@ static int de_close (struct net_device *dev)
 
 static void de_tx_timeout (struct net_device *dev)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 
 	printk(KERN_DEBUG "%s: NIC status %08x mode %08x sia %08x desc %u/%u/%u\n",
 	       dev->name, dr32(MacStatus), dr32(MacMode), dr32(SIAStatus),
@@ -1575,7 +1575,7 @@ static int __de_set_settings(struct de_private *de, struct ethtool_cmd *ecmd)
 
 static void de_get_drvinfo (struct net_device *dev,struct ethtool_drvinfo *info)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 
 	strcpy (info->driver, DRV_NAME);
 	strcpy (info->version, DRV_VERSION);
@@ -1590,7 +1590,7 @@ static int de_get_regs_len(struct net_device *dev)
 
 static int de_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&de->lock);
@@ -1602,7 +1602,7 @@ static int de_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 
 static int de_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&de->lock);
@@ -1614,14 +1614,14 @@ static int de_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 
 static u32 de_get_msglevel(struct net_device *dev)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 
 	return de->msg_enable;
 }
 
 static void de_set_msglevel(struct net_device *dev, u32 msglvl)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 
 	de->msg_enable = msglvl;
 }
@@ -1629,7 +1629,7 @@ static void de_set_msglevel(struct net_device *dev, u32 msglvl)
 static int de_get_eeprom(struct net_device *dev,
 			 struct ethtool_eeprom *eeprom, u8 *data)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 
 	if (!de->ee_data)
 		return -EOPNOTSUPP;
@@ -1643,7 +1643,7 @@ static int de_get_eeprom(struct net_device *dev,
 
 static int de_nway_reset(struct net_device *dev)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 	u32 status;
 
 	if (de->media_type != DE_MEDIA_TP_AUTO)
@@ -1662,7 +1662,7 @@ static int de_nway_reset(struct net_device *dev)
 static void de_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 			void *data)
 {
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 
 	regs->version = (DE_REGS_VER << 2) | de->de21040;
 
@@ -1956,7 +1956,7 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 	dev->tx_timeout = de_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-	de = dev->priv;
+	de = netdev_priv(dev);
 	de->de21040 = ent->driver_data == 0 ? 1 : 0;
 	de->pdev = pdev;
 	de->dev = dev;
@@ -2078,7 +2078,7 @@ err_out_free:
 static void __devexit de_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 
 	BUG_ON(!dev);
 	unregister_netdev(dev);
@@ -2095,7 +2095,7 @@ static void __devexit de_remove_one (struct pci_dev *pdev)
 static int de_suspend (struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 
 	rtnl_lock();
 	if (netif_running (dev)) {
@@ -2130,7 +2130,7 @@ static int de_suspend (struct pci_dev *pdev, pm_message_t state)
 static int de_resume (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct de_private *de = dev->priv;
+	struct de_private *de = netdev_priv(dev);
 	int retval = 0;
 
 	rtnl_lock();
diff --git a/drivers/net/tulip/eeprom.c b/drivers/net/tulip/eeprom.c
index 0dcced1..391acd3 100644
--- a/drivers/net/tulip/eeprom.c
+++ b/drivers/net/tulip/eeprom.c
@@ -337,7 +337,7 @@ int __devinit tulip_read_eeprom(struct net_device *dev, int location, int addr_l
 {
 	int i;
 	unsigned retval = 0;
-	struct tulip_private *tp = dev->priv;
+	struct tulip_private *tp = netdev_priv(dev);
 	void __iomem *ee_addr = tp->base_addr + CSR9;
 	int read_cmd = location | (EE_READ_CMD << addr_len);
 
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index e9e6286..730c27e 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -892,7 +892,7 @@ static struct net_device_stats * uli526x_get_stats(struct net_device *dev)
 
 static void uli526x_set_filter_mode(struct net_device * dev)
 {
-	struct uli526x_board_info *db = dev->priv;
+	struct uli526x_board_info *db = netdev_priv(dev);
 	unsigned long flags;
 
 	ULI526X_DBUG(0, "uli526x_set_filter_mode()", 0);
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 734ce09..44a85be 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1798,7 +1798,7 @@ static irqreturn_t
 typhoon_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
-	struct typhoon *tp = dev->priv;
+	struct typhoon *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->ioaddr;
 	u32 intr_status;
 
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index ca9d00c..947be48 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -344,14 +344,14 @@ out:
 static int mcs7830_mdio_read(struct net_device *netdev, int phy_id,
 			     int location)
 {
-	struct usbnet *dev = netdev->priv;
+	struct usbnet *dev = netdev_priv(netdev);
 	return mcs7830_read_phy(dev, location);
 }
 
 static void mcs7830_mdio_write(struct net_device *netdev, int phy_id,
 				int location, int val)
 {
-	struct usbnet *dev = netdev->priv;
+	struct usbnet *dev = netdev_priv(netdev);
 	mcs7830_write_phy(dev, location, val);
 }
 
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0196a0d..cc155f3 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -125,7 +125,8 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 		unsigned int i;
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-			give_a_page(dev->priv, skb_shinfo(skb)->frags[i].page);
+			give_a_page(netdev_priv(dev),
+				    skb_shinfo(skb)->frags[i].page);
 		skb->data_len = 0;
 		skb_shinfo(skb)->nr_frags = 0;
 	}
diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index b142427..c79f0ac 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -74,7 +74,7 @@ static int dlci_header(struct sk_buff *skb, struct net_device *dev,
 	unsigned int		hlen;
 	char			*dest;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	hdr.control = FRAD_I_UI;
 	switch(type)
@@ -110,7 +110,7 @@ static void dlci_receive(struct sk_buff *skb, struct net_device *dev)
 	struct frhdr		*hdr;
 	int					process, header;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 	if (!pskb_may_pull(skb, sizeof(*hdr))) {
 		printk(KERN_NOTICE "%s: invalid data no header\n",
 		       dev->name);
@@ -197,7 +197,7 @@ static int dlci_transmit(struct sk_buff *skb, struct net_device *dev)
 	if (!skb || !dev)
 		return(0);
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 	
@@ -235,9 +235,9 @@ static int dlci_config(struct net_device *dev, struct dlci_conf __user *conf, in
 	struct frad_local	*flp;
 	int			err;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
-	flp = dlp->slave->priv;
+	flp = netdev_priv(dlp->slave);
 
 	if (!get)
 	{
@@ -269,7 +269,7 @@ static int dlci_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	if (!capable(CAP_NET_ADMIN))
 		return(-EPERM);
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	switch(cmd)
 	{
@@ -298,7 +298,7 @@ static int dlci_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct dlci_local *dlp;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	return((*dlp->slave->change_mtu)(dlp->slave, new_mtu));
 }
@@ -309,7 +309,7 @@ static int dlci_open(struct net_device *dev)
 	struct frad_local	*flp;
 	int			err;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	if (!*(short *)(dev->dev_addr))
 		return(-EINVAL);
@@ -317,7 +317,7 @@ static int dlci_open(struct net_device *dev)
 	if (!netif_running(dlp->slave))
 		return(-ENOTCONN);
 
-	flp = dlp->slave->priv;
+	flp = netdev_priv(dlp->slave);
 	err = (*flp->activate)(dlp->slave, dev);
 	if (err)
 		return(err);
@@ -335,9 +335,9 @@ static int dlci_close(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
-	flp = dlp->slave->priv;
+	flp = netdev_priv(dlp->slave);
 	err = (*flp->deactivate)(dlp->slave, dev);
 
 	return 0;
@@ -347,7 +347,7 @@ static struct net_device_stats *dlci_get_stats(struct net_device *dev)
 {
 	struct dlci_local *dlp;
 
-	dlp = dev->priv;
+	dlp = netdev_priv(dev);
 
 	return(&dlp->stats);
 }
@@ -365,7 +365,7 @@ static int dlci_add(struct dlci_add *dlci)
 	if (!slave)
 		return -ENODEV;
 
-	if (slave->type != ARPHRD_FRAD || slave->priv == NULL)
+	if (slave->type != ARPHRD_FRAD || netdev_priv(slave) == NULL)
 		goto err1;
 
 	/* create device name */
@@ -391,11 +391,11 @@ static int dlci_add(struct dlci_add *dlci)
 
 	*(short *)(master->dev_addr) = dlci->dlci;
 
-	dlp = (struct dlci_local *) master->priv;
+	dlp = netdev_priv(master);
 	dlp->slave = slave;
 	dlp->master = master;
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 	err = (*flp->assoc)(slave, master);
 	if (err < 0)
 		goto err2;
@@ -435,9 +435,9 @@ static int dlci_del(struct dlci_add *dlci)
 		return(-EBUSY);
 	}
 
-	dlp = master->priv;
+	dlp = netdev_priv(master);
 	slave = dlp->slave;
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	rtnl_lock();
 	err = (*flp->deassoc)(slave, master);
@@ -491,7 +491,7 @@ static const struct header_ops dlci_header_ops = {
 
 static void dlci_setup(struct net_device *dev)
 {
-	struct dlci_local *dlp = dev->priv;
+	struct dlci_local *dlp = netdev_priv(dev);
 
 	dev->flags		= 0;
 	dev->open		= dlci_open;
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index 73e2f27..6a07ba9 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -185,7 +185,7 @@ static void sdla_stop(struct net_device *dev)
 {
 	struct frad_local *flp;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 	switch(flp->type)
 	{
 		case SDLA_S502A:
@@ -212,7 +212,7 @@ static void sdla_start(struct net_device *dev)
 {
 	struct frad_local *flp;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 	switch(flp->type)
 	{
 		case SDLA_S502A:
@@ -432,7 +432,7 @@ static int sdla_cmd(struct net_device *dev, int cmd, short dlci, short flags,
 	int                      ret, waiting, len;
 	long                     window;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 	window = flp->type == SDLA_S508 ? SDLA_508_CMD_BUF : SDLA_502_CMD_BUF;
 	cmd_buf = (struct sdla_cmd *)(dev->mem_start + (window & SDLA_ADDR_MASK));
 	ret = 0;
@@ -509,7 +509,7 @@ static int sdla_activate(struct net_device *slave, struct net_device *master)
 	struct frad_local *flp;
 	int i;
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 		if (flp->master[i] == master)
@@ -531,7 +531,7 @@ static int sdla_deactivate(struct net_device *slave, struct net_device *master)
 	struct frad_local *flp;
 	int               i;
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 		if (flp->master[i] == master)
@@ -556,7 +556,7 @@ static int sdla_assoc(struct net_device *slave, struct net_device *master)
 	if (master->type != ARPHRD_DLCI)
 		return(-EINVAL);
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 	{
@@ -589,7 +589,7 @@ static int sdla_deassoc(struct net_device *slave, struct net_device *master)
 	struct frad_local *flp;
 	int               i;
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 		if (flp->master[i] == master)
@@ -619,7 +619,7 @@ static int sdla_dlci_conf(struct net_device *slave, struct net_device *master, i
 	int               i;
 	short             len, ret;
 
-	flp = slave->priv;
+	flp = netdev_priv(slave);
 
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 		if (flp->master[i] == master)
@@ -628,7 +628,7 @@ static int sdla_dlci_conf(struct net_device *slave, struct net_device *master, i
 	if (i == CONFIG_DLCI_MAX)
 		return(-ENODEV);
 
-	dlp = master->priv;
+	dlp = netdev_priv(master);
 
 	ret = SDLA_RET_OK;
 	len = sizeof(struct dlci_conf);
@@ -659,7 +659,7 @@ static int sdla_transmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long     flags;
 	struct buf_entry  *pbuf;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 	ret = 0;
 	accept = 1;
 
@@ -755,7 +755,7 @@ static void sdla_receive(struct net_device *dev)
 	int               i=0, received, success, addr, buf_base, buf_top;
 	short             dlci, len, len2, split;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 	success = 1;
 	received = addr = buf_top = buf_base = 0;
 	len = dlci = 0;
@@ -860,7 +860,7 @@ static void sdla_receive(struct net_device *dev)
 	if (success)
 	{
 		flp->stats.rx_packets++;
-		dlp = master->priv;
+		dlp = netdev_priv(master);
 		(*dlp->receive)(skb, master);
 	}
 
@@ -925,7 +925,7 @@ static void sdla_poll(unsigned long device)
 	struct frad_local *flp;
 
 	dev = (struct net_device *) device;
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (sdla_byte(dev, SDLA_502_RCV_BUF))
 		sdla_receive(dev);
@@ -941,7 +941,7 @@ static int sdla_close(struct net_device *dev)
 	int               len, i;
 	short             dlcis[CONFIG_DLCI_MAX];
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	len = 0;
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
@@ -1002,7 +1002,7 @@ static int sdla_open(struct net_device *dev)
 	int               len, i;
 	char              byte;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (!flp->initialized)
 		return(-EPERM);
@@ -1079,7 +1079,7 @@ static int sdla_open(struct net_device *dev)
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
 		if (flp->dlci[i])
 		{
-			dlp = flp->master[i]->priv;
+			dlp = netdev_priv(flp->master[i]);
 			if (dlp->configured)
 				sdla_cmd(dev, SDLA_SET_DLCI_CONFIGURATION, abs(flp->dlci[i]), 0, &dlp->config, sizeof(struct dlci_conf), NULL, NULL);
 		}
@@ -1099,7 +1099,7 @@ static int sdla_config(struct net_device *dev, struct frad_conf __user *conf, in
 	if (dev->type == 0xFFFF)
 		return(-EUNATCH);
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (!get)
 	{
@@ -1230,7 +1230,7 @@ static int sdla_reconfig(struct net_device *dev)
 	struct conf_data  data;
 	int               i, len;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	len = 0;
 	for(i=0;i<CONFIG_DLCI_MAX;i++)
@@ -1255,7 +1255,7 @@ static int sdla_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	if(!capable(CAP_NET_ADMIN))
 		return -EPERM;
 		
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (!flp->initialized)
 		return(-EINVAL);
@@ -1321,7 +1321,7 @@ static int sdla_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct frad_local *flp;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (netif_running(dev))
 		return(-EBUSY);
@@ -1338,7 +1338,7 @@ static int sdla_set_config(struct net_device *dev, struct ifmap *map)
 	unsigned base;
 	int err = -EINVAL;
 
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	if (flp->initialized)
 		return(-EINVAL);
@@ -1593,14 +1593,14 @@ fail:
 static struct net_device_stats *sdla_stats(struct net_device *dev)
 {
 	struct frad_local *flp;
-	flp = dev->priv;
+	flp = netdev_priv(dev);
 
 	return(&flp->stats);
 }
 
 static void setup_sdla(struct net_device *dev)
 {
-	struct frad_local *flp = dev->priv;
+	struct frad_local *flp = netdev_priv(dev);
 
 	netdev_boot_setup_check(dev);
 
@@ -1651,7 +1651,7 @@ static int __init init_sdla(void)
 
 static void __exit exit_sdla(void)
 {
-	struct frad_local *flp = sdla->priv;
+	struct frad_local *flp = netdev_priv(sdla);
 
 	unregister_netdev(sdla);
 	if (flp->initialized) {
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 2a6c7a6..9c453ae 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -64,7 +64,7 @@ static struct x25_asy *x25_asy_alloc(void)
 		if (dev == NULL)
 			break;
 
-		sl = dev->priv;
+		sl = netdev_priv(dev);
 		/* Not in use ? */
 		if (!test_and_set_bit(SLF_INUSE, &sl->flags))
 			return sl;
@@ -86,7 +86,7 @@ static struct x25_asy *x25_asy_alloc(void)
 			return NULL;
 
 		/* Initialize channel control data */
-		sl = dev->priv;
+		sl = netdev_priv(dev);
 		dev->base_addr    = i;
 
 		/* register device so that it can be ifconfig'ed       */
@@ -120,7 +120,7 @@ static void x25_asy_free(struct x25_asy *sl)
 
 static int x25_asy_change_mtu(struct net_device *dev, int newmtu)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	unsigned char *xbuff, *rbuff;
 	int len = 2 * newmtu;
 
@@ -280,7 +280,7 @@ static void x25_asy_write_wakeup(struct tty_struct *tty)
 
 static void x25_asy_timeout(struct net_device *dev)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 
 	spin_lock(&sl->lock);
 	if (netif_queue_stopped(dev)) {
@@ -301,7 +301,7 @@ static void x25_asy_timeout(struct net_device *dev)
 
 static int x25_asy_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	int err;
 
 	if (!netif_running(sl->dev)) {
@@ -373,7 +373,7 @@ static int x25_asy_data_indication(struct net_device *dev, struct sk_buff *skb)
 
 static void x25_asy_data_transmit(struct net_device *dev, struct sk_buff *skb)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 
 	spin_lock(&sl->lock);
 	if (netif_queue_stopped(sl->dev) || sl->tty == NULL) {
@@ -398,7 +398,7 @@ static void x25_asy_data_transmit(struct net_device *dev, struct sk_buff *skb)
 
 static void x25_asy_connected(struct net_device *dev, int reason)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	struct sk_buff *skb;
 	unsigned char *ptr;
 
@@ -418,7 +418,7 @@ static void x25_asy_connected(struct net_device *dev, int reason)
 
 static void x25_asy_disconnected(struct net_device *dev, int reason)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	struct sk_buff *skb;
 	unsigned char *ptr;
 
@@ -450,7 +450,7 @@ static struct lapb_register_struct x25_asy_callbacks = {
 /* Open the low-level part of the X.25 channel. Easy! */
 static int x25_asy_open(struct net_device *dev)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	unsigned long len;
 	int err;
 
@@ -499,7 +499,7 @@ norbuff:
 /* Close the low-level part of the X.25 channel. Easy! */
 static int x25_asy_close(struct net_device *dev)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	int err;
 
 	spin_lock(&sl->lock);
@@ -615,7 +615,7 @@ static void x25_asy_close_tty(struct tty_struct *tty)
 
 static struct net_device_stats *x25_asy_get_stats(struct net_device *dev)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	return &sl->stats;
 }
 
@@ -717,7 +717,7 @@ static int x25_asy_ioctl(struct tty_struct *tty, struct file *file,
 
 static int x25_asy_open_dev(struct net_device *dev)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	if (sl->tty == NULL)
 		return -ENODEV;
 	return 0;
@@ -726,7 +726,7 @@ static int x25_asy_open_dev(struct net_device *dev)
 /* Initialise the X.25 driver.  Called by the device init code */
 static void x25_asy_setup(struct net_device *dev)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 
 	sl->magic  = X25_ASY_MAGIC;
 	sl->dev	   = dev;
@@ -793,7 +793,7 @@ static void __exit exit_x25_asy(void)
 	for (i = 0; i < x25_asy_maxdev; i++) {
 		dev = x25_asy_devs[i];
 		if (dev) {
-			struct x25_asy *sl = dev->priv;
+			struct x25_asy *sl = netdev_priv(dev);
 
 			spin_lock_bh(&sl->lock);
 			if (sl->tty)
diff --git a/drivers/net/wireless/libertas/ethtool.c b/drivers/net/wireless/libertas/ethtool.c
index 688d60d..156f471 100644
--- a/drivers/net/wireless/libertas/ethtool.c
+++ b/drivers/net/wireless/libertas/ethtool.c
@@ -23,7 +23,7 @@ static const char * mesh_stat_strings[]= {
 static void lbs_ethtool_get_drvinfo(struct net_device *dev,
 					 struct ethtool_drvinfo *info)
 {
-	struct lbs_private *priv = (struct lbs_private *) dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	snprintf(info->fw_version, 32, "%u.%u.%u.p%u",
 		priv->fwrelease >> 24 & 0xff,
@@ -47,7 +47,7 @@ static int lbs_ethtool_get_eeprom_len(struct net_device *dev)
 static int lbs_ethtool_get_eeprom(struct net_device *dev,
                                   struct ethtool_eeprom *eeprom, u8 * bytes)
 {
-	struct lbs_private *priv = (struct lbs_private *) dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct cmd_ds_802_11_eeprom_access cmd;
 	int ret;
 
@@ -76,7 +76,7 @@ out:
 static void lbs_ethtool_get_stats(struct net_device *dev,
 				  struct ethtool_stats *stats, uint64_t *data)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct cmd_ds_mesh_access mesh_access;
 	int ret;
 
@@ -113,7 +113,7 @@ static void lbs_ethtool_get_stats(struct net_device *dev,
 
 static int lbs_ethtool_get_sset_count(struct net_device *dev, int sset)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	if (sset == ETH_SS_STATS && dev == priv->mesh_dev)
 		return MESH_STATS_NUM;
@@ -143,7 +143,7 @@ static void lbs_ethtool_get_strings(struct net_device *dev,
 static void lbs_ethtool_get_wol(struct net_device *dev,
 				struct ethtool_wolinfo *wol)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	if (priv->wol_criteria == 0xffffffff) {
 		/* Interface driver didn't configure wake */
@@ -166,7 +166,7 @@ static void lbs_ethtool_get_wol(struct net_device *dev,
 static int lbs_ethtool_set_wol(struct net_device *dev,
 			       struct ethtool_wolinfo *wol)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	uint32_t criteria = 0;
 
 	if (priv->wol_criteria == 0xffffffff && wol->wolopts)
diff --git a/drivers/net/wireless/libertas/persistcfg.c b/drivers/net/wireless/libertas/persistcfg.c
index 3309a9c..dfbd139 100644
--- a/drivers/net/wireless/libertas/persistcfg.c
+++ b/drivers/net/wireless/libertas/persistcfg.c
@@ -18,7 +18,7 @@
 static int mesh_get_default_parameters(struct device *dev,
 				       struct mrvl_mesh_defaults *defs)
 {
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	struct cmd_ds_mesh_config cmd;
 	int ret;
 
@@ -57,7 +57,7 @@ static ssize_t bootflag_get(struct device *dev,
 static ssize_t bootflag_set(struct device *dev, struct device_attribute *attr,
 			    const char *buf, size_t count)
 {
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	struct cmd_ds_mesh_config cmd;
 	uint32_t datum;
 	int ret;
@@ -100,7 +100,7 @@ static ssize_t boottime_get(struct device *dev,
 static ssize_t boottime_set(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	struct cmd_ds_mesh_config cmd;
 	uint32_t datum;
 	int ret;
@@ -152,7 +152,7 @@ static ssize_t channel_get(struct device *dev,
 static ssize_t channel_set(struct device *dev, struct device_attribute *attr,
 			   const char *buf, size_t count)
 {
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	struct cmd_ds_mesh_config cmd;
 	uint32_t datum;
 	int ret;
@@ -210,7 +210,7 @@ static ssize_t mesh_id_set(struct device *dev, struct device_attribute *attr,
 	struct cmd_ds_mesh_config cmd;
 	struct mrvl_mesh_defaults defs;
 	struct mrvl_meshie *ie;
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	int len;
 	int ret;
 
@@ -269,7 +269,7 @@ static ssize_t protocol_id_set(struct device *dev,
 	struct cmd_ds_mesh_config cmd;
 	struct mrvl_mesh_defaults defs;
 	struct mrvl_meshie *ie;
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	uint32_t datum;
 	int ret;
 
@@ -323,7 +323,7 @@ static ssize_t metric_id_set(struct device *dev, struct device_attribute *attr,
 	struct cmd_ds_mesh_config cmd;
 	struct mrvl_mesh_defaults defs;
 	struct mrvl_meshie *ie;
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	uint32_t datum;
 	int ret;
 
@@ -377,7 +377,7 @@ static ssize_t capability_set(struct device *dev, struct device_attribute *attr,
 	struct cmd_ds_mesh_config cmd;
 	struct mrvl_mesh_defaults defs;
 	struct mrvl_meshie *ie;
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	uint32_t datum;
 	int ret;
 
diff --git a/drivers/net/wireless/libertas/scan.c b/drivers/net/wireless/libertas/scan.c
index 4b27456..33b77f8 100644
--- a/drivers/net/wireless/libertas/scan.c
+++ b/drivers/net/wireless/libertas/scan.c
@@ -939,7 +939,7 @@ out:
 int lbs_set_scan(struct net_device *dev, struct iw_request_info *info,
 		 union iwreq_data *wrqu, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	int ret = 0;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -997,7 +997,7 @@ int lbs_get_scan(struct net_device *dev, struct iw_request_info *info,
 		 struct iw_point *dwrq, char *extra)
 {
 #define SCAN_ITEM_SIZE 128
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	int err = 0;
 	char *ev = extra;
 	char *stop = ev + dwrq->length;
diff --git a/drivers/net/wireless/libertas/tx.c b/drivers/net/wireless/libertas/tx.c
index a4972fe..dac4626 100644
--- a/drivers/net/wireless/libertas/tx.c
+++ b/drivers/net/wireless/libertas/tx.c
@@ -60,7 +60,7 @@ static u32 convert_radiotap_rate_to_mv(u8 rate)
 int lbs_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct txpd *txpd;
 	char *p802x_hdr;
 	uint16_t pkt_len;
-- 
1.5.3.4


