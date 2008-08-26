From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-13
Date: Tue, 26 Aug 2008 22:19:11 +0800
Message-ID: <48B410DF.4040805@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52011 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756953AbYHZOVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:21:40 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
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
 


