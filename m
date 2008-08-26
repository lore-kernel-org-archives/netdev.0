From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-5
Date: Tue, 26 Aug 2008 22:18:34 +0800
Message-ID: <48B410BA.8010305@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63341 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756372AbYHZOVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:21:00 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index 3e35064..5fa4f03 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -1035,7 +1035,7 @@ static int __init dec_lance_probe(struct device *bdev, const int type)
 		dev = root_lance_dev;
 		while (dev) {
 			i++;
-			lp = (struct lance_private *)dev->priv;
+			lp = netdev_priv(dev);
 			dev = lp->next;
 		}
 		snprintf(name, sizeof(name), fmt, i);
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index ace39ec..d01b2bf 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -601,7 +601,7 @@ static int __init depca_hw_init (struct net_device *dev, struct device *device)
 		return -ENXIO;
 	}
 
-	lp = (struct depca_private *) dev->priv;
+	lp = netdev_priv(dev);
 	mem_start = lp->mem_start;
 
 	if (!mem_start || lp->adapter < DEPCA || lp->adapter >=unknown)
@@ -821,7 +821,7 @@ out_priv:
 
 static int depca_open(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	u_long ioaddr = dev->base_addr;
 	s16 nicsr;
 	int status = 0;
@@ -866,7 +866,7 @@ static int depca_open(struct net_device *dev)
 /* Initialize the lance Rx and Tx descriptor rings. */
 static void depca_init_ring(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	u_int i;
 	u_long offset;
 
@@ -924,7 +924,7 @@ static void depca_tx_timeout(struct net_device *dev)
 */
 static int depca_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	u_long ioaddr = dev->base_addr;
 	int status = 0;
 
@@ -972,7 +972,7 @@ static irqreturn_t depca_interrupt(int irq, void *dev_id)
 		return IRQ_NONE;
 	}
 
-	lp = (struct depca_private *) dev->priv;
+	lp = netdev_priv(dev);
 	ioaddr = dev->base_addr;
 
 	spin_lock(&lp->lock);
@@ -1010,7 +1010,7 @@ static irqreturn_t depca_interrupt(int irq, void *dev_id)
 /* Called with lp->lock held */
 static int depca_rx(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	int i, entry;
 	s32 status;
 
@@ -1108,7 +1108,7 @@ static int depca_rx(struct net_device *dev)
 */
 static int depca_tx(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	int entry;
 	s32 status;
 	u_long ioaddr = dev->base_addr;
@@ -1149,7 +1149,7 @@ static int depca_tx(struct net_device *dev)
 
 static int depca_close(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	s16 nicsr;
 	u_long ioaddr = dev->base_addr;
 
@@ -1185,7 +1185,7 @@ static int depca_close(struct net_device *dev)
 
 static void LoadCSRs(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	u_long ioaddr = dev->base_addr;
 
 	outw(CSR1, DEPCA_ADDR);	/* initialisation block address LSW */
@@ -1202,7 +1202,7 @@ static void LoadCSRs(struct net_device *dev)
 
 static int InitRestartDepca(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	u_long ioaddr = dev->base_addr;
 	int i, status = 0;
 
@@ -1234,7 +1234,7 @@ static int InitRestartDepca(struct net_device *dev)
 */
 static void set_multicast_list(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	u_long ioaddr = dev->base_addr;
 
 	netif_stop_queue(dev);
@@ -1263,7 +1263,7 @@ static void set_multicast_list(struct net_device *dev)
 */
 static void SetMulticastFilter(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	struct dev_mc_list *dmi = dev->mc_list;
 	char *addrs;
 	int i, j, bit, byte;
@@ -1431,7 +1431,7 @@ static int __init depca_mca_probe(struct device *device)
 
 	dev->irq = irq;
 	dev->base_addr = iobase;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->depca_bus = DEPCA_BUS_MCA;
 	lp->adapter = depca_mca_adapter_type[mdev->index];
 	lp->mem_start = mem_start;
@@ -1534,7 +1534,7 @@ static int __init depca_isa_probe (struct platform_device *device)
 	dev->base_addr = ioaddr;
 	dev->irq = irq;		/* Use whatever value the user gave
 				 * us, and 0 if he didn't. */
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->depca_bus = DEPCA_BUS_ISA;
 	lp->adapter = adapter;
 	lp->mem_start = mem_start;
@@ -1580,7 +1580,7 @@ static int __init depca_eisa_probe (struct device *device)
 
 	dev->base_addr = ioaddr;
 	dev->irq = irq;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->depca_bus = DEPCA_BUS_EISA;
 	lp->adapter = edev->id.driver_data;
 	lp->mem_start = mem_start;
@@ -1605,7 +1605,7 @@ static int __devexit depca_device_remove (struct device *device)
 	int bus;
 
 	dev  = device->driver_data;
-	lp   = dev->priv;
+	lp   = netdev_priv(dev);
 
 	unregister_netdev (dev);
 	iounmap (lp->sh_mem);
@@ -1747,7 +1747,7 @@ static int __init DevicePresent(u_long ioaddr)
 static int __init get_hw_addr(struct net_device *dev)
 {
 	u_long ioaddr = dev->base_addr;
-	struct depca_private *lp = dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	int i, k, tmp, status = 0;
 	u_short j, x, chksum;
 
@@ -1782,7 +1782,7 @@ static int __init get_hw_addr(struct net_device *dev)
 */
 static int load_packet(struct net_device *dev, struct sk_buff *skb)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	int i, entry, end, len, status = 0;
 
 	entry = lp->tx_new;	/* Ring around buffer number. */
@@ -1837,7 +1837,7 @@ static int load_packet(struct net_device *dev, struct sk_buff *skb)
 
 static void depca_dbg_open(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	u_long ioaddr = dev->base_addr;
 	struct depca_init *p = &lp->init_block;
 	int i;
@@ -1909,7 +1909,7 @@ static void depca_dbg_open(struct net_device *dev)
 */
 static int depca_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	struct depca_ioctl *ioc = (struct depca_ioctl *) &rq->ifr_ifru;
 	int i, status = 0;
 	u_long ioaddr = dev->base_addr;
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index f42c23f..3fcf77c 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -146,7 +146,7 @@ typedef struct board_info {
 
 static inline board_info_t *to_dm9000_board(struct net_device *dev)
 {
-	return dev->priv;
+	return netdev_priv(dev);
 }
 
 /* DM9000 network board routine ---------------------------- */
@@ -635,7 +635,7 @@ static unsigned char dm9000_type_to_char(enum dm9000_type type)
 static void
 dm9000_hash_table(struct net_device *dev)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = netdev_priv(dev);
 	struct dev_mc_list *mcptr = dev->mc_list;
 	int mc_cnt = dev->mc_count;
 	int i, oft;
@@ -686,7 +686,7 @@ dm9000_hash_table(struct net_device *dev)
 static void
 dm9000_init_dm9000(struct net_device *dev)
 {
-	board_info_t *db = dev->priv;
+	board_info_t *db = netdev_priv(dev);
 	unsigned int imr;
 
 	dm9000_dbg(db, 1, "entering %s\n", __func__);
@@ -732,7 +732,7 @@ dm9000_init_dm9000(struct net_device *dev)
 /* Our watchdog timed out. Called by the networking layer */
 static void dm9000_timeout(struct net_device *dev)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = netdev_priv(dev);
 	u8 reg_save;
 	unsigned long flags;
 
@@ -760,7 +760,7 @@ static int
 dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
-	board_info_t *db = dev->priv;
+	board_info_t *db = netdev_priv(dev);
 
 	dm9000_dbg(db, 3, "%s:\n", __func__);
 
@@ -840,7 +840,7 @@ struct dm9000_rxhdr {
 static void
 dm9000_rx(struct net_device *dev)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = netdev_priv(dev);
 	struct dm9000_rxhdr rxhdr;
 	struct sk_buff *skb;
 	u8 rxbyte, *rdptr;
@@ -937,7 +937,7 @@ dm9000_rx(struct net_device *dev)
 static irqreturn_t dm9000_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	board_info_t *db = dev->priv;
+	board_info_t *db = netdev_priv(dev);
 	int int_status;
 	u8 reg_save;
 
@@ -1005,7 +1005,7 @@ static void dm9000_poll_controller(struct net_device *dev)
 static int
 dm9000_open(struct net_device *dev)
 {
-	board_info_t *db = dev->priv;
+	board_info_t *db = netdev_priv(dev);
 	unsigned long irqflags = db->irq_res->flags & IRQF_TRIGGER_MASK;
 
 	if (netif_msg_ifup(db))
@@ -1055,7 +1055,7 @@ static void dm9000_msleep(board_info_t *db, unsigned int ms)
 static int
 dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = netdev_priv(dev);
 	unsigned long flags;
 	unsigned int reg_save;
 	int ret;
@@ -1102,7 +1102,7 @@ static void
 dm9000_phy_write(struct net_device *dev,
 		 int phyaddr_unused, int reg, int value)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = netdev_priv(dev);
 	unsigned long flags;
 	unsigned long reg_save;
 
@@ -1143,7 +1143,7 @@ dm9000_phy_write(struct net_device *dev,
 static void
 dm9000_shutdown(struct net_device *dev)
 {
-	board_info_t *db = dev->priv;
+	board_info_t *db = netdev_priv(dev);
 
 	/* RESET device */
 	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET);	/* PHY RESET */
@@ -1159,7 +1159,7 @@ dm9000_shutdown(struct net_device *dev)
 static int
 dm9000_stop(struct net_device *ndev)
 {
-	board_info_t *db = ndev->priv;
+	board_info_t *db = netdev_priv(ndev);
 
 	if (netif_msg_ifdown(db))
 		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
@@ -1206,7 +1206,7 @@ dm9000_probe(struct platform_device *pdev)
 	dev_dbg(&pdev->dev, "dm9000_probe()\n");
 
 	/* setup board info structure */
-	db = ndev->priv;
+	db = netdev_priv(ndev);
 	memset(db, 0, sizeof(*db));
 
 	db->dev = &pdev->dev;
@@ -1419,7 +1419,7 @@ dm9000_drv_suspend(struct platform_device *dev, pm_message_t state)
 	board_info_t *db;
 
 	if (ndev) {
-		db = (board_info_t *) ndev->priv;
+		db = netdev_priv(ndev);
 		db->in_suspend = 1;
 
 		if (netif_running(ndev)) {
@@ -1434,7 +1434,7 @@ static int
 dm9000_drv_resume(struct platform_device *dev)
 {
 	struct net_device *ndev = platform_get_drvdata(dev);
-	board_info_t *db = (board_info_t *) ndev->priv;
+	board_info_t *db = netdev_priv(ndev);
 
 	if (ndev) {
 
@@ -1458,7 +1458,7 @@ dm9000_drv_remove(struct platform_device *pdev)
 	platform_set_drvdata(pdev, NULL);
 
 	unregister_netdev(ndev);
-	dm9000_release_board(pdev, (board_info_t *) ndev->priv);
+	dm9000_release_board(pdev, (board_info_t *) netdev_priv(ndev);
 	free_netdev(ndev);		/* free device structure */
 
 	dev_dbg(&pdev->dev, "released and freed device\n");
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ad6da7b..9f974dd 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3893,8 +3893,7 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	struct net_device *poll_dev = adapter->netdev;
 	int tx_cleaned = 0, work_done = 0;
 
-	/* Must NOT use netdev_priv macro here. */
-	adapter = poll_dev->priv;
+	adapter = netdev_priv(poll_dev);
 
 	/* e1000_clean is called per-cpu.  This lock protects
 	 * tx_ring[0] from being cleaned by multiple cpus
@@ -5164,7 +5163,7 @@ static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev,
 						pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 
 	netif_device_detach(netdev);
 
@@ -5186,7 +5185,7 @@ static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev,
 static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	int err;
 
@@ -5220,7 +5219,7 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 static void e1000_io_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
 	e1000_init_manageability(adapter);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index d266510..addb9c8 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1676,8 +1676,7 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	struct net_device *poll_dev = adapter->netdev;
 	int tx_cleaned = 0, work_done = 0;
 
-	/* Must NOT use netdev_priv macro here. */
-	adapter = poll_dev->priv;
+	adapter = netdev_priv(poll_dev);
 
 	/*
 	 * e1000_clean is called per-cpu.  This lock protects
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 46819af..deb6307 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1273,7 +1273,7 @@ static void mv643xx_eth_get_ethtool_stats(struct net_device *dev,
 					  struct ethtool_stats *stats,
 					  uint64_t *data)
 {
-	struct mv643xx_eth_private *mp = dev->priv;
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int i;
 
 	mib_counters_update(mp);
diff --git a/drivers/net/mvme147.c b/drivers/net/mvme147.c
index 06ca425..6a82c59 100644
--- a/drivers/net/mvme147.c
+++ b/drivers/net/mvme147.c
@@ -106,7 +106,7 @@ struct net_device * __init mvme147lance_probe(int unit)
 	       dev->name, dev->base_addr, MVME147_LANCE_IRQ,
 	       print_mac(mac, dev->dev_addr));
 
-	lp = (struct m147lance_private *)dev->priv;
+	lp = netdev_priv(dev);
 	lp->ram = __get_dma_pages(GFP_ATOMIC, 3);	/* 16K */
 	if (!lp->ram)
 	{
@@ -190,7 +190,7 @@ int __init init_module(void)
 
 void __exit cleanup_module(void)
 {
-	struct m147lance_private *lp = dev_mvme147_lance->priv;
+	struct m147lance_private *lp = netdev_priv(dev_mvme147_lance);
 	unregister_netdev(dev_mvme147_lance);
 	free_pages(lp->ram, 3);
 	free_netdev(dev_mvme147_lance);
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 656a260..89363ea 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -532,7 +532,7 @@ static void myri_rx(struct myri_eth *mp, struct net_device *dev)
 static irqreturn_t myri_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev		= (struct net_device *) dev_id;
-	struct myri_eth *mp		= (struct myri_eth *) dev->priv;
+	struct myri_eth *mp		= netdev_priv(dev);
 	void __iomem *lregs		= mp->lregs;
 	struct myri_channel __iomem *chan = &mp->shmem->channel;
 	unsigned long flags;
@@ -571,14 +571,14 @@ static irqreturn_t myri_interrupt(int irq, void *dev_id)
 
 static int myri_open(struct net_device *dev)
 {
-	struct myri_eth *mp = (struct myri_eth *) dev->priv;
+	struct myri_eth *mp = netdev_priv(dev);
 
 	return myri_init(mp, in_interrupt());
 }
 
 static int myri_close(struct net_device *dev)
 {
-	struct myri_eth *mp = (struct myri_eth *) dev->priv;
+	struct myri_eth *mp = netdev_priv(dev);
 
 	myri_clean_rings(mp);
 	return 0;
@@ -586,7 +586,7 @@ static int myri_close(struct net_device *dev)
 
 static void myri_tx_timeout(struct net_device *dev)
 {
-	struct myri_eth *mp = (struct myri_eth *) dev->priv;
+	struct myri_eth *mp = netdev_priv(dev);
 
 	printk(KERN_ERR "%s: transmit timed out, resetting\n", dev->name);
 
@@ -597,7 +597,7 @@ static void myri_tx_timeout(struct net_device *dev)
 
 static int myri_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct myri_eth *mp = (struct myri_eth *) dev->priv;
+	struct myri_eth *mp = netdev_priv(dev);
 	struct sendq __iomem *sq = mp->sq;
 	struct myri_txd __iomem *txd;
 	unsigned long flags;
@@ -912,7 +912,7 @@ static int __devinit myri_ether_init(struct sbus_dev *sdev)
 
 	SET_NETDEV_DEV(dev, &sdev->ofdev.dev);
 
-	mp = (struct myri_eth *) dev->priv;
+	mp = netdev_priv(dev);
 	spin_lock_init(&mp->irq_lock);
 	mp->myri_sdev = sdev;
 
--


