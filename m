From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 02/18] netdevice: safe convert to netdev_priv() #part-2
Date: Fri, 05 Sep 2008 11:10:29 +0800
Message-ID: <48C0A325.1040103@cn.fujitsu.com>
References: <48C0A219.2030004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60202 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755248AbYIEDM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 23:12:56 -0400
In-Reply-To: <48C0A219.2030004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/declance.c               |    2 +-
 drivers/net/depca.c                  |   40 +++++++++---------
 drivers/net/dm9000.c                 |   32 +++++++-------
 drivers/net/e1000/e1000_main.c       |    9 ++--
 drivers/net/e1000e/netdev.c          |    3 +-
 drivers/net/eepro.c                  |    4 +-
 drivers/net/epic100.c                |   42 +++++++++---------
 drivers/net/eth16i.c                 |    2 +-
 drivers/net/fec.c                    |    2 +-
 drivers/net/ibmveth.c                |   34 +++++++-------
 drivers/net/igb/igb_ethtool.c        |    4 +-
 drivers/net/irda/ali-ircc.c          |   16 ++++----
 drivers/net/irda/donauboe.c          |    8 ++--
 drivers/net/irda/irda-usb.c          |   14 +++---
 drivers/net/irda/nsc-ircc.c          |   16 ++++----
 drivers/net/irda/sa1100_ir.c         |   26 ++++++------
 drivers/net/irda/sir_dev.c           |   12 +++---
 drivers/net/irda/via-ircc.c          |   16 ++++----
 drivers/net/irda/vlsi_ir.c           |   36 ++++++++--------
 drivers/net/irda/w83977af_ir.c       |   14 +++---
 drivers/net/mv643xx_eth.c            |    2 +-
 drivers/net/mvme147.c                |    4 +-
 drivers/net/myri_sbus.c              |   12 +++---
 drivers/net/ne2k-pci.c               |    2 +-
 drivers/net/netxen/netxen_nic_hw.c   |    2 +-
 drivers/net/netxen/netxen_nic_main.c |    4 +-
 drivers/net/ni5010.c                 |    2 +-
 drivers/net/ni52.c                   |   36 ++++++++--------
 drivers/net/pasemi_mac_ethtool.c     |    4 +-
 drivers/net/pcmcia/com20020_cs.c     |    6 +-
 drivers/net/plip.c                   |    8 ++--
 drivers/net/rionet.c                 |   26 ++++++------
 drivers/net/s2io.c                   |   78 +++++++++++++++++-----------------
 33 files changed, 258 insertions(+), 260 deletions(-)

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
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 1f11350..4792513 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -605,7 +605,7 @@ out:
 
 static void __init printEEPROMInfo(struct net_device *dev)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned short Word;
 	int i,j;
@@ -1676,7 +1676,7 @@ eepro_transmit_interrupt(struct net_device *dev)
 static int eepro_ethtool_get_settings(struct net_device *dev,
 					struct ethtool_cmd *cmd)
 {
-	struct eepro_local	*lp = (struct eepro_local *)dev->priv;
+	struct eepro_local	*lp = netdev_priv(dev);
 
 	cmd->supported = 	SUPPORTED_10baseT_Half |
 				SUPPORTED_10baseT_Full |
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 76118dd..02a554e 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -372,7 +372,7 @@ static int __devinit epic_init_one (struct pci_dev *pdev,
 #endif
 
 	pci_set_drvdata(pdev, dev);
-	ep = dev->priv;
+	ep = netdev_priv(dev);
 	ep->mii.dev = dev;
 	ep->mii.mdio_read = mdio_read;
 	ep->mii.mdio_write = mdio_write;
@@ -655,7 +655,7 @@ static void mdio_write(struct net_device *dev, int phy_id, int loc, int value)
 
 static int epic_open(struct net_device *dev)
 {
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int i;
 	int retval;
@@ -767,7 +767,7 @@ static int epic_open(struct net_device *dev)
 static void epic_pause(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 
 	netif_stop_queue (dev);
 
@@ -790,7 +790,7 @@ static void epic_pause(struct net_device *dev)
 static void epic_restart(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	int i;
 
 	/* Soft reset the chip. */
@@ -842,7 +842,7 @@ static void epic_restart(struct net_device *dev)
 
 static void check_media(struct net_device *dev)
 {
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int mii_lpa = ep->mii_phy_cnt ? mdio_read(dev, ep->phys[0], MII_LPA) : 0;
 	int negotiated = mii_lpa & ep->mii.advertising;
@@ -864,7 +864,7 @@ static void check_media(struct net_device *dev)
 static void epic_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int next_tick = 5*HZ;
 
@@ -885,7 +885,7 @@ static void epic_timer(unsigned long data)
 
 static void epic_tx_timeout(struct net_device *dev)
 {
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	if (debug > 0) {
@@ -914,7 +914,7 @@ static void epic_tx_timeout(struct net_device *dev)
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
 static void epic_init_ring(struct net_device *dev)
 {
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	int i;
 
 	ep->tx_full = 0;
@@ -960,7 +960,7 @@ static void epic_init_ring(struct net_device *dev)
 
 static int epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	int entry, free_count;
 	u32 ctrl_word;
 	unsigned long flags;
@@ -1088,7 +1088,7 @@ static void epic_tx(struct net_device *dev, struct epic_private *ep)
 static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	unsigned int handled = 0;
 	int status;
@@ -1156,7 +1156,7 @@ out:
 
 static int epic_rx(struct net_device *dev, int budget)
 {
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	int entry = ep->cur_rx % RX_RING_SIZE;
 	int rx_work_limit = ep->dirty_rx + RX_RING_SIZE - ep->cur_rx;
 	int work_done = 0;
@@ -1308,7 +1308,7 @@ rx_action:
 static int epic_close(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	struct sk_buff *skb;
 	int i;
 
@@ -1358,7 +1358,7 @@ static int epic_close(struct net_device *dev)
 
 static struct net_device_stats *epic_get_stats(struct net_device *dev)
 {
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	if (netif_running(dev)) {
@@ -1379,7 +1379,7 @@ static struct net_device_stats *epic_get_stats(struct net_device *dev)
 static void set_rx_mode(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	unsigned char mc_filter[8];		 /* Multicast hash filter */
 	int i;
 
@@ -1418,7 +1418,7 @@ static void set_rx_mode(struct net_device *dev)
 
 static void netdev_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct epic_private *np = dev->priv;
+	struct epic_private *np = netdev_priv(dev);
 
 	strcpy (info->driver, DRV_NAME);
 	strcpy (info->version, DRV_VERSION);
@@ -1427,7 +1427,7 @@ static void netdev_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *
 
 static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct epic_private *np = dev->priv;
+	struct epic_private *np = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&np->lock);
@@ -1439,7 +1439,7 @@ static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct epic_private *np = dev->priv;
+	struct epic_private *np = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&np->lock);
@@ -1451,13 +1451,13 @@ static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int netdev_nway_reset(struct net_device *dev)
 {
-	struct epic_private *np = dev->priv;
+	struct epic_private *np = netdev_priv(dev);
 	return mii_nway_restart(&np->mii);
 }
 
 static u32 netdev_get_link(struct net_device *dev)
 {
-	struct epic_private *np = dev->priv;
+	struct epic_private *np = netdev_priv(dev);
 	return mii_link_ok(&np->mii);
 }
 
@@ -1506,7 +1506,7 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct epic_private *np = dev->priv;
+	struct epic_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	struct mii_ioctl_data *data = if_mii(rq);
 	int rc;
@@ -1534,7 +1534,7 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 static void __devexit epic_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 
 	pci_free_consistent(pdev, TX_TOTAL_SIZE, ep->tx_ring, ep->tx_ring_dma);
 	pci_free_consistent(pdev, RX_TOTAL_SIZE, ep->rx_ring, ep->rx_ring_dma);
diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
index bee8b3f..8aa374e 100644
--- a/drivers/net/eth16i.c
+++ b/drivers/net/eth16i.c
@@ -1466,7 +1466,7 @@ void __exit cleanup_module(void)
 	for(this_dev = 0; this_dev < MAX_ETH16I_CARDS; this_dev++) {
 		struct net_device *dev = dev_eth16i[this_dev];
 
-		if(dev->priv) {
+		if (netdev_priv(dev)) {
 			unregister_netdev(dev);
 			free_irq(dev->irq, dev);
 			release_region(dev->base_addr, ETH16I_IO_EXTENT);
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index ecd5c71..e21262b 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1155,7 +1155,7 @@ static phy_info_t const phy_info_ks8721bl = {
 
 static void mii_parse_dp8384x_sr2(uint mii_reg, struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	volatile uint *s = &(fep->phy_status);
 
 	*s &= ~(PHY_STAT_SPMASK | PHY_STAT_LINK | PHY_STAT_ANC);
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index c2d57f8..7089094 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -527,7 +527,7 @@ retry:
 
 static int ibmveth_open(struct net_device *netdev)
 {
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	u64 mac_address = 0;
 	int rxq_entries = 1;
 	unsigned long lpar_rc;
@@ -666,7 +666,7 @@ static int ibmveth_open(struct net_device *netdev)
 
 static int ibmveth_close(struct net_device *netdev)
 {
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	long lpar_rc;
 
 	ibmveth_debug_printk("close starting\n");
@@ -722,7 +722,7 @@ static u32 netdev_get_link(struct net_device *dev) {
 
 static void ibmveth_set_rx_csum_flags(struct net_device *dev, u32 data)
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 
 	if (data)
 		adapter->rx_csum = 1;
@@ -741,7 +741,7 @@ static void ibmveth_set_rx_csum_flags(struct net_device *dev, u32 data)
 
 static void ibmveth_set_tx_csum_flags(struct net_device *dev, u32 data)
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 
 	if (data) {
 		dev->features |= NETIF_F_IP_CSUM;
@@ -753,7 +753,7 @@ static void ibmveth_set_tx_csum_flags(struct net_device *dev, u32 data)
 static int ibmveth_set_csum_offload(struct net_device *dev, u32 data,
 				    void (*done) (struct net_device *, u32))
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	u64 set_attr, clr_attr, ret_attr;
 	long ret;
 	int rc1 = 0, rc2 = 0;
@@ -805,7 +805,7 @@ static int ibmveth_set_csum_offload(struct net_device *dev, u32 data,
 
 static int ibmveth_set_rx_csum(struct net_device *dev, u32 data)
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 
 	if ((data && adapter->rx_csum) || (!data && !adapter->rx_csum))
 		return 0;
@@ -815,7 +815,7 @@ static int ibmveth_set_rx_csum(struct net_device *dev, u32 data)
 
 static int ibmveth_set_tx_csum(struct net_device *dev, u32 data)
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	int rc = 0;
 
 	if (data && (dev->features & NETIF_F_IP_CSUM))
@@ -833,7 +833,7 @@ static int ibmveth_set_tx_csum(struct net_device *dev, u32 data)
 
 static u32 ibmveth_get_rx_csum(struct net_device *dev)
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	return adapter->rx_csum;
 }
 
@@ -862,7 +862,7 @@ static void ibmveth_get_ethtool_stats(struct net_device *dev,
 				      struct ethtool_stats *stats, u64 *data)
 {
 	int i;
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 
 	for (i = 0; i < ARRAY_SIZE(ibmveth_stats); i++)
 		data[i] = IBMVETH_GET_STAT(adapter, ibmveth_stats[i].offset);
@@ -889,7 +889,7 @@ static int ibmveth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 static int ibmveth_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	union ibmveth_buf_desc desc;
 	unsigned long lpar_rc;
 	unsigned long correlator;
@@ -1045,7 +1045,7 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *netdev = dev_instance;
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	unsigned long lpar_rc;
 
 	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
@@ -1059,7 +1059,7 @@ static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance)
 
 static void ibmveth_set_multicast_list(struct net_device *netdev)
 {
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	unsigned long lpar_rc;
 
 	if((netdev->flags & IFF_PROMISC) || (netdev->mc_count > adapter->mcastFilterSize)) {
@@ -1107,7 +1107,7 @@ static void ibmveth_set_multicast_list(struct net_device *netdev)
 
 static int ibmveth_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	struct vio_dev *viodev = adapter->vdev;
 	int new_mtu_oh = new_mtu + IBMVETH_BUFF_OH;
 	int i;
@@ -1159,7 +1159,7 @@ static int ibmveth_change_mtu(struct net_device *dev, int new_mtu)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void ibmveth_poll_controller(struct net_device *dev)
 {
-	ibmveth_replenish_task(dev->priv);
+	ibmveth_replenish_task(netdev_priv(dev));
 	ibmveth_interrupt(dev->irq, dev);
 }
 #endif
@@ -1241,7 +1241,7 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
 	if(!netdev)
 		return -ENOMEM;
 
-	adapter = netdev->priv;
+	adapter = netdev_priv(netdev);
 	dev->dev.driver_data = netdev;
 
 	adapter->vdev = dev;
@@ -1337,7 +1337,7 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
 static int __devexit ibmveth_remove(struct vio_dev *dev)
 {
 	struct net_device *netdev = dev->dev.driver_data;
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	int i;
 
 	for(i = 0; i<IbmVethNumBufferPools; i++)
@@ -1472,7 +1472,7 @@ const char * buf, size_t count)
 						      kobj);
 	struct net_device *netdev =
 	    container_of(kobj->parent, struct device, kobj)->driver_data;
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	long value = simple_strtol(buf, NULL, 10);
 	long rc;
 
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 58906c9..f89fdc7 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -101,8 +101,8 @@ static const struct igb_stats igb_gstrings_stats[] = {
 };
 
 #define IGB_QUEUE_STATS_LEN \
-	((((struct igb_adapter *)netdev->priv)->num_rx_queues + \
-	 ((struct igb_adapter *)netdev->priv)->num_tx_queues) * \
+	((((struct igb_adapter *)netdev_priv(netdev))->num_rx_queues + \
+	 ((struct igb_adapter *)netdev_priv(netdev))->num_tx_queues) * \
 	(sizeof(struct igb_queue_stats) / sizeof(u64)))
 #define IGB_GLOBAL_STATS_LEN	\
 	sizeof(igb_gstrings_stats) / sizeof(struct igb_stats)
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 2ff1818..7151b3b 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -292,7 +292,7 @@ static int ali_ircc_open(int i, chipio_t *info)
 		return -ENOMEM;
 	}
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 	self->netdev = dev;
 	spin_lock_init(&self->lock);
    
@@ -665,7 +665,7 @@ static irqreturn_t ali_ircc_interrupt(int irq, void *dev_id)
 		
 	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 		
-	self = dev->priv;
+	self = netdev_priv(dev);
 	
 	spin_lock(&self->lock);
 	
@@ -1333,7 +1333,7 @@ static int ali_ircc_net_open(struct net_device *dev)
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 	
-	self = (struct ali_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	
 	IRDA_ASSERT(self != NULL, return 0;);
 	
@@ -1396,7 +1396,7 @@ static int ali_ircc_net_close(struct net_device *dev)
 		
 	IRDA_ASSERT(dev != NULL, return -1;);
 
-	self = (struct ali_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return 0;);
 
 	/* Stop device */
@@ -1436,7 +1436,7 @@ static int ali_ircc_fir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	
 	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );
 	
-	self = (struct ali_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	iobase = self->io.fir_base;
 
 	netif_stop_queue(dev);
@@ -1960,7 +1960,7 @@ static int ali_ircc_sir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	
 	IRDA_ASSERT(dev != NULL, return 0;);
 	
-	self = (struct ali_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return 0;);
 
 	iobase = self->io.sir_base;
@@ -2028,7 +2028,7 @@ static int ali_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -2114,7 +2114,7 @@ static int ali_ircc_is_receiving(struct ali_ircc_cb *self)
 
 static struct net_device_stats *ali_ircc_net_get_stats(struct net_device *dev)
 {
-	struct ali_ircc_cb *self = (struct ali_ircc_cb *) dev->priv;
+	struct ali_ircc_cb *self = netdev_priv(dev);
 	
 	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 		
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 69d16b3..687c2d5 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -979,7 +979,7 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
   unsigned long flags;
   struct irda_skb_cb *cb = (struct irda_skb_cb *) skb->cb;
 
-  self = (struct toshoboe_cb *) dev->priv;
+  self = netdev_priv(dev);
 
   IRDA_ASSERT (self != NULL, return 0; );
 
@@ -1384,7 +1384,7 @@ toshoboe_net_close (struct net_device *dev)
   IRDA_DEBUG (4, "%s()\n", __func__);
 
   IRDA_ASSERT (dev != NULL, return -1; );
-  self = (struct toshoboe_cb *) dev->priv;
+  self = netdev_priv(dev);
 
   /* Stop device */
   netif_stop_queue(dev);
@@ -1422,7 +1422,7 @@ toshoboe_net_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 
   IRDA_ASSERT (dev != NULL, return -1; );
 
-  self = dev->priv;
+  self = netdev_priv(dev);
 
   IRDA_ASSERT (self != NULL, return -1; );
 
@@ -1546,7 +1546,7 @@ toshoboe_open (struct pci_dev *pci_dev, const struct pci_device_id *pdid)
       return -ENOMEM;
     }
 
-  self = dev->priv;
+  self = netdev_priv(dev);
   self->netdev = dev;
   self->pdev = pci_dev;
   self->base = pci_resource_start(pci_dev,0);
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index b5d6b9a..3c8f6f1 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -384,7 +384,7 @@ static void speed_bulk_callback(struct urb *urb)
  */
 static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
-	struct irda_usb_cb *self = netdev->priv;
+	struct irda_usb_cb *self = netdev_priv(netdev);
 	struct urb *urb = self->tx_urb;
 	unsigned long flags;
 	s32 speed;
@@ -628,7 +628,7 @@ static void write_bulk_callback(struct urb *urb)
 static void irda_usb_net_timeout(struct net_device *netdev)
 {
 	unsigned long flags;
-	struct irda_usb_cb *self = netdev->priv;
+	struct irda_usb_cb *self = netdev_priv(netdev);
 	struct urb *urb;
 	int	done = 0;	/* If we have made any progress */
 
@@ -1175,7 +1175,7 @@ static int irda_usb_net_open(struct net_device *netdev)
 	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	IRDA_ASSERT(netdev != NULL, return -1;);
-	self = (struct irda_usb_cb *) netdev->priv;
+	self = netdev_priv(netdev);
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	spin_lock_irqsave(&self->lock, flags);
@@ -1257,7 +1257,7 @@ static int irda_usb_net_close(struct net_device *netdev)
 	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	IRDA_ASSERT(netdev != NULL, return -1;);
-	self = (struct irda_usb_cb *) netdev->priv;
+	self = netdev_priv(netdev);
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	/* Clear this flag *before* unlinking the urbs and *before*
@@ -1306,7 +1306,7 @@ static int irda_usb_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	int ret = 0;
 
 	IRDA_ASSERT(dev != NULL, return -1;);
-	self = dev->priv;
+	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return -1;);
 
 	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
@@ -1348,7 +1348,7 @@ static int irda_usb_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
  */
 static struct net_device_stats *irda_usb_net_get_stats(struct net_device *dev)
 {
-	struct irda_usb_cb *self = dev->priv;
+	struct irda_usb_cb *self = netdev_priv(dev);
 	return &self->stats;
 }
 
@@ -1641,7 +1641,7 @@ static int irda_usb_probe(struct usb_interface *intf,
 		goto err_out;
 
 	SET_NETDEV_DEV(net, &intf->dev);
-	self = net->priv;
+	self = netdev_priv(net);
 	self->netdev = net;
 	spin_lock_init(&self->lock);
 	init_timer(&self->rx_defer_timer);
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index 8583d95..84961fe 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -373,7 +373,7 @@ static int __init nsc_ircc_open(chipio_t *info)
 		return -ENOMEM;
 	}
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 	self->netdev = dev;
 	spin_lock_init(&self->lock);
    
@@ -1354,7 +1354,7 @@ static int nsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
 	__s32 speed;
 	__u8 bank;
 	
-	self = (struct nsc_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 
 	IRDA_ASSERT(self != NULL, return 0;);
 
@@ -1427,7 +1427,7 @@ static int nsc_ircc_hard_xmit_fir(struct sk_buff *skb, struct net_device *dev)
 	__u8 bank;
 	int mtt, diff;
 	
-	self = (struct nsc_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	iobase = self->io.fir_base;
 
 	netif_stop_queue(dev);
@@ -2085,7 +2085,7 @@ static irqreturn_t nsc_ircc_interrupt(int irq, void *dev_id)
 	__u8 bsr, eir;
 	int iobase;
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 
 	spin_lock(&self->lock);	
 
@@ -2166,7 +2166,7 @@ static int nsc_ircc_net_open(struct net_device *dev)
 	IRDA_DEBUG(4, "%s()\n", __func__);
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
-	self = (struct nsc_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	
 	IRDA_ASSERT(self != NULL, return 0;);
 	
@@ -2229,7 +2229,7 @@ static int nsc_ircc_net_close(struct net_device *dev)
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 
-	self = (struct nsc_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return 0;);
 
 	/* Stop device */
@@ -2275,7 +2275,7 @@ static int nsc_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -2310,7 +2310,7 @@ static int nsc_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 static struct net_device_stats *nsc_ircc_net_get_stats(struct net_device *dev)
 {
-	struct nsc_ircc_cb *self = (struct nsc_ircc_cb *) dev->priv;
+	struct nsc_ircc_cb *self = netdev_priv(dev);
 	
 	return &self->stats;
 }
diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
index a951889..f74b540 100644
--- a/drivers/net/irda/sa1100_ir.c
+++ b/drivers/net/irda/sa1100_ir.c
@@ -298,7 +298,7 @@ static int sa1100_irda_suspend(struct platform_device *pdev, pm_message_t state)
 	if (!dev)
 		return 0;
 
-	si = dev->priv;
+	si = netdev_priv(dev);
 	if (si->open) {
 		/*
 		 * Stop the transmit queue
@@ -323,7 +323,7 @@ static int sa1100_irda_resume(struct platform_device *pdev)
 	if (!dev)
 		return 0;
 
-	si = dev->priv;
+	si = netdev_priv(dev);
 	if (si->open) {
 		/*
 		 * If we missed a speed change, initialise at the new speed
@@ -359,7 +359,7 @@ static int sa1100_irda_resume(struct platform_device *pdev)
  */
 static void sa1100_irda_hpsir_irq(struct net_device *dev)
 {
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 	int status;
 
 	status = Ser2UTSR0;
@@ -534,7 +534,7 @@ static void sa1100_irda_fir_error(struct sa1100_irda *si, struct net_device *dev
  */
 static void sa1100_irda_fir_irq(struct net_device *dev)
 {
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 
 	/*
 	 * Stop RX DMA
@@ -582,7 +582,7 @@ static void sa1100_irda_fir_irq(struct net_device *dev)
 static irqreturn_t sa1100_irda_irq(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	if (IS_FIR(((struct sa1100_irda *)dev->priv)))
+	if (IS_FIR(((struct sa1100_irda *)netdev_priv(dev))))
 		sa1100_irda_fir_irq(dev);
 	else
 		sa1100_irda_hpsir_irq(dev);
@@ -595,7 +595,7 @@ static irqreturn_t sa1100_irda_irq(int irq, void *dev_id)
 static void sa1100_irda_txdma_irq(void *id)
 {
 	struct net_device *dev = id;
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 	struct sk_buff *skb = si->txskb;
 
 	si->txskb = NULL;
@@ -649,7 +649,7 @@ static void sa1100_irda_txdma_irq(void *id)
 
 static int sa1100_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 	int speed = irda_get_next_speed(skb);
 
 	/*
@@ -724,7 +724,7 @@ static int
 sa1100_irda_ioctl(struct net_device *dev, struct ifreq *ifreq, int cmd)
 {
 	struct if_irda_req *rq = (struct if_irda_req *)ifreq;
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 	int ret = -EOPNOTSUPP;
 
 	switch (cmd) {
@@ -766,13 +766,13 @@ sa1100_irda_ioctl(struct net_device *dev, struct ifreq *ifreq, int cmd)
 
 static struct net_device_stats *sa1100_irda_stats(struct net_device *dev)
 {
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 	return &si->stats;
 }
 
 static int sa1100_irda_start(struct net_device *dev)
 {
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 	int err;
 
 	si->speed = 9600;
@@ -835,7 +835,7 @@ err_irq:
 
 static int sa1100_irda_stop(struct net_device *dev)
 {
-	struct sa1100_irda *si = dev->priv;
+	struct sa1100_irda *si = netdev_priv(dev);
 
 	disable_irq(dev->irq);
 	sa1100_irda_shutdown(si);
@@ -908,7 +908,7 @@ static int sa1100_irda_probe(struct platform_device *pdev)
 	if (!dev)
 		goto err_mem_4;
 
-	si = dev->priv;
+	si = netdev_priv(dev);
 	si->dev = &pdev->dev;
 	si->pdata = pdev->dev.platform_data;
 
@@ -987,7 +987,7 @@ static int sa1100_irda_remove(struct platform_device *pdev)
 	struct net_device *dev = platform_get_drvdata(pdev);
 
 	if (dev) {
-		struct sa1100_irda *si = dev->priv;
+		struct sa1100_irda *si = netdev_priv(dev);
 		unregister_netdev(dev);
 		kfree(si->tx_buff.head);
 		kfree(si->rx_buff.head);
diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index 3f32909..ceef040 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -584,14 +584,14 @@ EXPORT_SYMBOL(sirdev_receive);
 
 static struct net_device_stats *sirdev_get_stats(struct net_device *ndev)
 {
-	struct sir_dev *dev = ndev->priv;
+	struct sir_dev *dev = netdev_priv(ndev);
 
 	return (dev) ? &dev->stats : NULL;
 }
 
 static int sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
-	struct sir_dev *dev = ndev->priv;
+	struct sir_dev *dev = netdev_priv(ndev);
 	unsigned long flags;
 	int actual = 0;
 	int err;
@@ -683,7 +683,7 @@ static int sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 static int sirdev_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 {
 	struct if_irda_req *irq = (struct if_irda_req *) rq;
-	struct sir_dev *dev = ndev->priv;
+	struct sir_dev *dev = netdev_priv(ndev);
 	int ret = 0;
 
 	IRDA_ASSERT(dev != NULL, return -1;);
@@ -795,7 +795,7 @@ static void sirdev_free_buffers(struct sir_dev *dev)
 
 static int sirdev_open(struct net_device *ndev)
 {
-	struct sir_dev *dev = ndev->priv;
+	struct sir_dev *dev = netdev_priv(ndev);
 	const struct sir_driver *drv = dev->drv;
 
 	if (!drv)
@@ -840,7 +840,7 @@ errout_dec:
 
 static int sirdev_close(struct net_device *ndev)
 {
-	struct sir_dev *dev = ndev->priv;
+	struct sir_dev *dev = netdev_priv(ndev);
 	const struct sir_driver *drv;
 
 //	IRDA_DEBUG(0, "%s\n", __func__);
@@ -896,7 +896,7 @@ struct sir_dev * sirdev_get_instance(const struct sir_driver *drv, const char *n
 		IRDA_ERROR("%s - Can't allocate memory for IrDA control block!\n", __func__);
 		goto out;
 	}
-	dev = ndev->priv;
+	dev = netdev_priv(ndev);
 
 	irda_init_max_qos_capabilies(&dev->qos);
 	dev->qos.baud_rate.bits = IR_9600|IR_19200|IR_38400|IR_57600|IR_115200;
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 84e609e..74c78cf 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -334,7 +334,7 @@ static __devinit int via_ircc_open(int i, chipio_t * info, unsigned int id)
 	if (dev == NULL) 
 		return -ENOMEM;
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 	self->netdev = dev;
 	spin_lock_init(&self->lock);
 
@@ -824,7 +824,7 @@ static int via_ircc_hard_xmit_sir(struct sk_buff *skb,
 	u16 iobase;
 	__u32 speed;
 
-	self = (struct via_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return 0;);
 	iobase = self->io.fir_base;
 
@@ -896,7 +896,7 @@ static int via_ircc_hard_xmit_fir(struct sk_buff *skb,
 	__u32 speed;
 	unsigned long flags;
 
-	self = (struct via_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	iobase = self->io.fir_base;
 
 	if (self->st_fifo.len)
@@ -1349,7 +1349,7 @@ static int RxTimerHandler(struct via_ircc_cb *self, int iobase)
 static irqreturn_t via_ircc_interrupt(int dummy, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	struct via_ircc_cb *self = dev->priv;
+	struct via_ircc_cb *self = netdev_priv(dev);
 	int iobase;
 	u8 iHostIntType, iRxIntType, iTxIntType;
 
@@ -1522,7 +1522,7 @@ static int via_ircc_net_open(struct net_device *dev)
 	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return -1;);
-	self = (struct via_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	self->stats.rx_packets = 0;
 	IRDA_ASSERT(self != NULL, return 0;);
 	iobase = self->io.fir_base;
@@ -1589,7 +1589,7 @@ static int via_ircc_net_close(struct net_device *dev)
 	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return -1;);
-	self = (struct via_ircc_cb *) dev->priv;
+	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return 0;);
 
 	/* Stop device */
@@ -1628,7 +1628,7 @@ static int via_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq,
 	int ret = 0;
 
 	IRDA_ASSERT(dev != NULL, return -1;);
-	self = dev->priv;
+	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_DEBUG(1, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name,
 		   cmd);
@@ -1663,7 +1663,7 @@ static int via_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq,
 static struct net_device_stats *via_ircc_net_get_stats(struct net_device
 						       *dev)
 {
-	struct via_ircc_cb *self = (struct via_ircc_cb *) dev->priv;
+	struct via_ircc_cb *self = netdev_priv(dev);
 
 	return &self->stats;
 }
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index 18f4b3a..1e205cc 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -178,7 +178,7 @@ static void vlsi_proc_pdev(struct seq_file *seq, struct pci_dev *pdev)
 		
 static void vlsi_proc_ndev(struct seq_file *seq, struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	u8 byte;
 	u16 word;
 	unsigned delta1, delta2;
@@ -346,7 +346,7 @@ static void vlsi_proc_ring(struct seq_file *seq, struct vlsi_ring *r)
 static int vlsi_seq_show(struct seq_file *seq, void *v)
 {
 	struct net_device *ndev = seq->private;
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	unsigned long flags;
 
 	seq_printf(seq, "\n%s %s\n\n", DRIVER_NAME, DRIVER_VERSION);
@@ -543,7 +543,7 @@ static int vlsi_process_rx(struct vlsi_ring *r, struct ring_descr *rd)
 	struct sk_buff	*skb;
 	int		ret = 0;
 	struct net_device *ndev = (struct net_device *)pci_get_drvdata(r->pdev);
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 
 	pci_dma_sync_single_for_cpu(r->pdev, rd_get_addr(rd), r->len, r->dir);
 	/* dma buffer now owned by the CPU */
@@ -638,7 +638,7 @@ static void vlsi_fill_rx(struct vlsi_ring *r)
 
 static void vlsi_rx_interrupt(struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	struct vlsi_ring *r = idev->rx_ring;
 	struct ring_descr *rd;
 	int ret;
@@ -856,7 +856,7 @@ static int vlsi_set_baud(vlsi_irda_dev_t *idev, unsigned iobase)
 
 static int vlsi_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	struct vlsi_ring	*r = idev->tx_ring;
 	struct ring_descr *rd;
 	unsigned long flags;
@@ -1063,7 +1063,7 @@ drop:
 
 static void vlsi_tx_interrupt(struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	struct vlsi_ring	*r = idev->tx_ring;
 	struct ring_descr	*rd;
 	unsigned	iobase;
@@ -1262,7 +1262,7 @@ static inline void vlsi_clear_regs(unsigned iobase)
 static int vlsi_init_chip(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	unsigned	iobase;
 	u16 ptr;
 
@@ -1376,14 +1376,14 @@ static int vlsi_stop_hw(vlsi_irda_dev_t *idev)
 
 static struct net_device_stats * vlsi_get_stats(struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 
 	return &idev->stats;
 }
 
 static void vlsi_tx_timeout(struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 
 
 	vlsi_reg_debug(ndev->base_addr, __func__);
@@ -1408,7 +1408,7 @@ static void vlsi_tx_timeout(struct net_device *ndev)
 
 static int vlsi_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	struct if_irda_req *irq = (struct if_irda_req *) rq;
 	unsigned long flags;
 	u16 fifocnt;
@@ -1458,7 +1458,7 @@ static int vlsi_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 static irqreturn_t vlsi_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *ndev = dev_instance;
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	unsigned	iobase;
 	u8		irintr;
 	int 		boguscount = 5;
@@ -1499,7 +1499,7 @@ static irqreturn_t vlsi_interrupt(int irq, void *dev_instance)
 
 static int vlsi_open(struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	int	err = -EAGAIN;
 	char	hwname[32];
 
@@ -1558,7 +1558,7 @@ errout:
 
 static int vlsi_close(struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 
 	netif_stop_queue(ndev);
 
@@ -1581,7 +1581,7 @@ static int vlsi_close(struct net_device *ndev)
 
 static int vlsi_irda_init(struct net_device *ndev)
 {
-	vlsi_irda_dev_t *idev = ndev->priv;
+	vlsi_irda_dev_t *idev = netdev_priv(ndev);
 	struct pci_dev *pdev = idev->pdev;
 
 	ndev->irq = pdev->irq;
@@ -1656,7 +1656,7 @@ vlsi_irda_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto out_disable;
 	}
 
-	idev = ndev->priv;
+	idev = netdev_priv(ndev);
 
 	spin_lock_init(&idev->lock);
 	mutex_init(&idev->mtx);
@@ -1713,7 +1713,7 @@ static void __devexit vlsi_irda_remove(struct pci_dev *pdev)
 
 	unregister_netdev(ndev);
 
-	idev = ndev->priv;
+	idev = netdev_priv(ndev);
 	mutex_lock(&idev->mtx);
 	if (idev->proc_entry) {
 		remove_proc_entry(ndev->name, vlsi_proc_root);
@@ -1748,7 +1748,7 @@ static int vlsi_irda_suspend(struct pci_dev *pdev, pm_message_t state)
 			   __func__, pci_name(pdev));
 		return 0;
 	}
-	idev = ndev->priv;	
+	idev = netdev_priv(ndev);
 	mutex_lock(&idev->mtx);
 	if (pdev->current_state != 0) {			/* already suspended */
 		if (state.event > pdev->current_state) {	/* simply go deeper */
@@ -1787,7 +1787,7 @@ static int vlsi_irda_resume(struct pci_dev *pdev)
 			   __func__, pci_name(pdev));
 		return 0;
 	}
-	idev = ndev->priv;	
+	idev = netdev_priv(ndev);
 	mutex_lock(&idev->mtx);
 	if (pdev->current_state == 0) {
 		mutex_unlock(&idev->mtx);
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 002a6d7..e178452 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -178,7 +178,7 @@ int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 		goto err_out;
 	}
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 	spin_lock_init(&self->lock);
    
 
@@ -497,7 +497,7 @@ int w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	__u8 set;
 	int mtt;
 	
-	self = (struct w83977af_ir *) dev->priv;
+	self = netdev_priv(dev);
 
 	iobase = self->io.fir_base;
 
@@ -1119,7 +1119,7 @@ static irqreturn_t w83977af_interrupt(int irq, void *dev_id)
 	__u8 set, icr, isr;
 	int iobase;
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 
 	iobase = self->io.fir_base;
 
@@ -1192,7 +1192,7 @@ static int w83977af_net_open(struct net_device *dev)
 	IRDA_DEBUG(0, "%s()\n", __func__ );
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
-	self = (struct w83977af_ir *) dev->priv;
+	self = netdev_priv(dev);
 	
 	IRDA_ASSERT(self != NULL, return 0;);
 	
@@ -1256,7 +1256,7 @@ static int w83977af_net_close(struct net_device *dev)
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 	
-	self = (struct w83977af_ir *) dev->priv;
+	self = netdev_priv(dev);
 	
 	IRDA_ASSERT(self != NULL, return 0;);
 	
@@ -1303,7 +1303,7 @@ static int w83977af_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 
-	self = dev->priv;
+	self = netdev_priv(dev);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -1339,7 +1339,7 @@ out:
 
 static struct net_device_stats *w83977af_net_get_stats(struct net_device *dev)
 {
-	struct w83977af_ir *self = (struct w83977af_ir *) dev->priv;
+	struct w83977af_ir *self = netdev_priv(dev);
 	
 	return &self->stats;
 }
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 0a18b9e..deee66d 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1277,7 +1277,7 @@ static void mv643xx_eth_get_ethtool_stats(struct net_device *dev,
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
 
diff --git a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
index de0de74..b42a980 100644
--- a/drivers/net/ne2k-pci.c
+++ b/drivers/net/ne2k-pci.c
@@ -626,7 +626,7 @@ static void ne2k_pci_block_output(struct net_device *dev, int count,
 static void ne2k_pci_get_drvinfo(struct net_device *dev,
 				 struct ethtool_drvinfo *info)
 {
-	struct ei_device *ei = dev->priv;
+	struct ei_device *ei = netdev_priv(dev);
 	struct pci_dev *pci_dev = (struct pci_dev *) ei->priv;
 
 	strcpy(info->driver, DRV_NAME);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 84978f8..86379fd 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -537,7 +537,7 @@ netxen_send_cmd_descs(struct netxen_adapter *adapter,
 static int nx_p3_sre_macaddr_change(struct net_device *dev,
 		u8 *addr, unsigned op)
 {
-	struct netxen_adapter *adapter = (struct netxen_adapter *)dev->priv;
+	struct netxen_adapter *adapter = netdev_priv(dev);
 	nx_nic_req_t req;
 	nx_mac_req_t mac_req;
 	int rv;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 32bb47a..3b380a0 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -553,7 +553,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
-	adapter = netdev->priv;
+	adapter = netdev_priv(netdev);
 	adapter->netdev  = netdev;
 	adapter->pdev    = pdev;
 	adapter->ahw.pci_func  = pci_func_id;
@@ -998,7 +998,7 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
  */
 static int netxen_nic_open(struct net_device *netdev)
 {
-	struct netxen_adapter *adapter = (struct netxen_adapter *)netdev->priv;
+	struct netxen_adapter *adapter = netdev_priv(netdev);
 	int err = 0;
 	int ctx, ring;
 	irq_handler_t handler;
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index 8e0ca9f..b13af97 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -329,7 +329,7 @@ static int __init ni5010_probe1(struct net_device *dev, int ioaddr)
         	outb(0, IE_RBUF);	/* set buffer byte 0 to 0 again */
 	}
         printk("-> bufsize rcv/xmt=%d/%d\n", bufsize_rcv, NI5010_BUFSIZE);
-	memset(dev->priv, 0, sizeof(struct ni5010_local));
+	memset(netdev_priv(dev), 0, sizeof(struct ni5010_local));
 
 	dev->open		= ni5010_open;
 	dev->stop		= ni5010_close;
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index b9a882d..aee6c35 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -214,7 +214,7 @@ struct priv {
 /* wait for command with timeout: */
 static void wait_for_scb_cmd(struct net_device *dev)
 {
-	struct priv *p = dev->priv;
+	struct priv *p = netdev_priv(dev);
 	int i;
 	for (i = 0; i < 16384; i++) {
 		if (readb(&p->scb->cmd_cuc) == 0)
@@ -233,7 +233,7 @@ static void wait_for_scb_cmd(struct net_device *dev)
 
 static void wait_for_scb_cmd_ruc(struct net_device *dev)
 {
-	struct priv *p = dev->priv;
+	struct priv *p = netdev_priv(dev);
 	int i;
 	for (i = 0; i < 16384; i++) {
 		if (readb(&p->scb->cmd_ruc) == 0)
@@ -298,7 +298,7 @@ static int ni52_open(struct net_device *dev)
 static int check_iscp(struct net_device *dev, void __iomem *addr)
 {
 	struct iscp_struct __iomem *iscp = addr;
-	struct priv *p = dev->priv;
+	struct priv *p = netdev_priv(dev);
 	memset_io(iscp, 0, sizeof(struct iscp_struct));
 
 	writel(make24(iscp), &p->scp->iscp);
@@ -318,7 +318,7 @@ static int check_iscp(struct net_device *dev, void __iomem *addr)
  */
 static int check586(struct net_device *dev, unsigned size)
 {
-	struct priv *p = dev->priv;
+	struct priv *p = netdev_priv(dev);
 	int i;
 
 	p->mapped = ioremap(dev->mem_start, size);
@@ -354,7 +354,7 @@ Enodev:
  */
 static void alloc586(struct net_device *dev)
 {
-	struct priv *p =	(struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	ni_reset586();
 	mdelay(32);
@@ -400,7 +400,7 @@ struct net_device * __init ni52_probe(int unit)
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
-	p = dev->priv;
+	p = netdev_priv(dev);
 
 	if (unit >= 0) {
 		sprintf(dev->name, "eth%d", unit);
@@ -446,7 +446,7 @@ out:
 static int __init ni52_probe1(struct net_device *dev, int ioaddr)
 {
 	int i, size, retval;
-	struct priv *priv = dev->priv;
+	struct priv *priv = netdev_priv(dev);
 
 	dev->base_addr = ioaddr;
 	dev->irq = irq;
@@ -588,7 +588,7 @@ static int init586(struct net_device *dev)
 {
 	void __iomem *ptr;
 	int i, result = 0;
-	struct priv *p = (struct priv *)dev->priv;
+	struct priv *p = netdev_priv(dev);
 	struct configure_cmd_struct __iomem *cfg_cmd;
 	struct iasetup_cmd_struct __iomem *ias_cmd;
 	struct tdr_cmd_struct __iomem *tdr_cmd;
@@ -829,7 +829,7 @@ static void __iomem *alloc_rfa(struct net_device *dev, void __iomem *ptr)
 	struct rfd_struct __iomem *rfd = ptr;
 	struct rbd_struct __iomem *rbd;
 	int i;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	memset_io(rfd, 0,
 		sizeof(struct rfd_struct) * (p->num_recv_buffs + rfdadd));
@@ -878,7 +878,7 @@ static irqreturn_t ni52_interrupt(int irq, void *dev_id)
 	int cnt = 0;
 	struct priv *p;
 
-	p = (struct priv *) dev->priv;
+	p = netdev_priv(dev);
 
 	if (debuglevel > 1)
 		printk("I");
@@ -950,7 +950,7 @@ static void ni52_rcv_int(struct net_device *dev)
 	unsigned short totlen;
 	struct sk_buff *skb;
 	struct rbd_struct __iomem *rbd;
-	struct priv *p = (struct priv *)dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	if (debuglevel > 0)
 		printk("R");
@@ -1040,7 +1040,7 @@ static void ni52_rcv_int(struct net_device *dev)
 
 static void ni52_rnr_int(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	p->stats.rx_errors++;
 
@@ -1065,7 +1065,7 @@ static void ni52_rnr_int(struct net_device *dev)
 static void ni52_xmt_int(struct net_device *dev)
 {
 	int status;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	if (debuglevel > 0)
 		printk("X");
@@ -1113,7 +1113,7 @@ static void ni52_xmt_int(struct net_device *dev)
 
 static void startrecv586(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	wait_for_scb_cmd(dev);
 	wait_for_scb_cmd_ruc(dev);
@@ -1126,7 +1126,7 @@ static void startrecv586(struct net_device *dev)
 
 static void ni52_timeout(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 #ifndef NO_NOPCOMMANDS
 	if (readb(&p->scb->cus) & CU_ACTIVE) { /* COMMAND-UNIT active? */
 		netif_wake_queue(dev);
@@ -1177,7 +1177,7 @@ static int ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
 #ifndef NO_NOPCOMMANDS
 	int next_nop;
 #endif
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	if (skb->len > XMIT_BUFF_SIZE) {
 		printk(KERN_ERR "%s: Sorry, max. framelength is %d bytes. The length of your frame is %d bytes.\n", dev->name, XMIT_BUFF_SIZE, skb->len);
@@ -1274,7 +1274,7 @@ static int ni52_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 static struct net_device_stats *ni52_get_stats(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	unsigned short crc, aln, rsc, ovrn;
 
 	/* Get error-statistics from the ni82586 */
@@ -1337,7 +1337,7 @@ int __init init_module(void)
 
 void __exit cleanup_module(void)
 {
-	struct priv *p = dev_ni52->priv;
+	struct priv *p = netdev_priv(dev_ni52);
 	unregister_netdev(dev_ni52);
 	iounmap(p->mapped);
 	release_region(dev_ni52->base_addr, NI52_TOTAL_SIZE);
diff --git a/drivers/net/pasemi_mac_ethtool.c b/drivers/net/pasemi_mac_ethtool.c
index 5e8df3a..064a4fe 100644
--- a/drivers/net/pasemi_mac_ethtool.c
+++ b/drivers/net/pasemi_mac_ethtool.c
@@ -109,7 +109,7 @@ static void
 pasemi_mac_ethtool_get_ringparam(struct net_device *netdev,
 				 struct ethtool_ringparam *ering)
 {
-	struct pasemi_mac *mac = netdev->priv;
+	struct pasemi_mac *mac = netdev_priv(netdev);
 
 	ering->tx_max_pending = TX_RING_SIZE/2;
 	ering->tx_pending = RING_USED(mac->tx)/2;
@@ -130,7 +130,7 @@ static int pasemi_mac_get_sset_count(struct net_device *netdev, int sset)
 static void pasemi_mac_get_ethtool_stats(struct net_device *netdev,
 		struct ethtool_stats *stats, u64 *data)
 {
-	struct pasemi_mac *mac = netdev->priv;
+	struct pasemi_mac *mac = netdev_priv(netdev);
 	int i;
 
 	data[0] = pasemi_read_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if))
diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
index ea9414c..68610c4 100644
--- a/drivers/net/pcmcia/com20020_cs.c
+++ b/drivers/net/pcmcia/com20020_cs.c
@@ -155,7 +155,7 @@ static int com20020_probe(struct pcmcia_device *p_dev)
     if (!dev)
 	goto fail_alloc_dev;
 
-    lp = dev->priv;
+    lp = netdev_priv(dev);
     lp->timeout = timeout;
     lp->backplane = backplane;
     lp->clockp = clockp;
@@ -303,7 +303,7 @@ static int com20020_config(struct pcmcia_device *link)
 	goto failed;
     }
     
-    lp = dev->priv;
+    lp = netdev_priv(dev);
     lp->card_name = "PCMCIA COM20020";
     lp->card_flags = ARC_CAN_10MBIT; /* pretend all of them can 10Mbit */
 
@@ -364,7 +364,7 @@ static int com20020_resume(struct pcmcia_device *link)
 
 	if (link->open) {
 		int ioaddr = dev->base_addr;
-		struct arcnet_local *lp = dev->priv;
+		struct arcnet_local *lp = netdev_priv(dev);
 		ARCRESET;
 	}
 
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index 1e96542..35e3e09 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -229,7 +229,7 @@ static inline void enable_parport_interrupts (struct net_device *dev)
 	if (dev->irq != -1)
 	{
 		struct parport *port =
-		   ((struct net_local *)dev->priv)->pardev->port;
+		   ((struct net_local *)netdev_priv(dev))->pardev->port;
 		port->ops->enable_irq (port);
 	}
 }
@@ -239,7 +239,7 @@ static inline void disable_parport_interrupts (struct net_device *dev)
 	if (dev->irq != -1)
 	{
 		struct parport *port =
-		   ((struct net_local *)dev->priv)->pardev->port;
+		   ((struct net_local *)netdev_priv(dev))->pardev->port;
 		port->ops->disable_irq (port);
 	}
 }
@@ -247,7 +247,7 @@ static inline void disable_parport_interrupts (struct net_device *dev)
 static inline void write_data (struct net_device *dev, unsigned char data)
 {
 	struct parport *port =
-	   ((struct net_local *)dev->priv)->pardev->port;
+	   ((struct net_local *)netdev_priv(dev))->pardev->port;
 
 	port->ops->write_data (port, data);
 }
@@ -255,7 +255,7 @@ static inline void write_data (struct net_device *dev, unsigned char data)
 static inline unsigned char read_status (struct net_device *dev)
 {
 	struct parport *port =
-	   ((struct net_local *)dev->priv)->pardev->port;
+	   ((struct net_local *)netdev_priv(dev))->pardev->port;
 
 	return port->ops->read_status (port);
 }
diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index 2b8fd68..d25cdd5 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -94,7 +94,7 @@ static int rionet_rx_clean(struct net_device *ndev)
 {
 	int i;
 	int error = 0;
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 	void *data;
 
 	i = rnet->rx_slot;
@@ -132,7 +132,7 @@ static int rionet_rx_clean(struct net_device *ndev)
 static void rionet_rx_fill(struct net_device *ndev, int end)
 {
 	int i;
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	i = rnet->rx_slot;
 	do {
@@ -151,7 +151,7 @@ static void rionet_rx_fill(struct net_device *ndev, int end)
 static int rionet_queue_tx_msg(struct sk_buff *skb, struct net_device *ndev,
 			       struct rio_dev *rdev)
 {
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	rio_add_outb_message(rnet->mport, rdev, 0, skb->data, skb->len);
 	rnet->tx_skb[rnet->tx_slot] = skb;
@@ -175,7 +175,7 @@ static int rionet_queue_tx_msg(struct sk_buff *skb, struct net_device *ndev,
 static int rionet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	int i;
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 	struct ethhdr *eth = (struct ethhdr *)skb->data;
 	u16 destid;
 	unsigned long flags;
@@ -215,7 +215,7 @@ static void rionet_dbell_event(struct rio_mport *mport, void *dev_id, u16 sid, u
 			       u16 info)
 {
 	struct net_device *ndev = dev_id;
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 	struct rionet_peer *peer;
 
 	if (netif_msg_intr(rnet))
@@ -243,7 +243,7 @@ static void rionet_inb_msg_event(struct rio_mport *mport, void *dev_id, int mbox
 {
 	int n;
 	struct net_device *ndev = dev_id;
-	struct rionet_private *rnet = (struct rionet_private *)ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	if (netif_msg_intr(rnet))
 		printk(KERN_INFO "%s: inbound message event, mbox %d slot %d\n",
@@ -258,7 +258,7 @@ static void rionet_inb_msg_event(struct rio_mport *mport, void *dev_id, int mbox
 static void rionet_outb_msg_event(struct rio_mport *mport, void *dev_id, int mbox, int slot)
 {
 	struct net_device *ndev = dev_id;
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	spin_lock(&rnet->lock);
 
@@ -287,7 +287,7 @@ static int rionet_open(struct net_device *ndev)
 	int i, rc = 0;
 	struct rionet_peer *peer, *tmp;
 	u32 pwdcsr;
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	if (netif_msg_ifup(rnet))
 		printk(KERN_INFO "%s: open\n", DRV_NAME);
@@ -351,7 +351,7 @@ static int rionet_open(struct net_device *ndev)
 
 static int rionet_close(struct net_device *ndev)
 {
-	struct rionet_private *rnet = (struct rionet_private *)ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 	struct rionet_peer *peer, *tmp;
 	int i;
 
@@ -400,7 +400,7 @@ static void rionet_remove(struct rio_dev *rdev)
 static void rionet_get_drvinfo(struct net_device *ndev,
 			       struct ethtool_drvinfo *info)
 {
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -410,14 +410,14 @@ static void rionet_get_drvinfo(struct net_device *ndev,
 
 static u32 rionet_get_msglevel(struct net_device *ndev)
 {
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	return rnet->msg_enable;
 }
 
 static void rionet_set_msglevel(struct net_device *ndev, u32 value)
 {
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	rnet->msg_enable = value;
 }
@@ -456,7 +456,7 @@ static int rionet_setup_netdev(struct rio_mport *mport)
 				RIO_MAX_ROUTE_ENTRIES(mport->sys_size));
 
 	/* Set up private area */
-	rnet = (struct rionet_private *)ndev->priv;
+	rnet = netdev_priv(ndev);
 	rnet->mport = mport;
 
 	/* Set the default MAC address */
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index a2b0730..617f15d 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -357,7 +357,7 @@ static void s2io_vlan_rx_register(struct net_device *dev,
 					struct vlan_group *grp)
 {
 	int i;
-	struct s2io_nic *nic = dev->priv;
+	struct s2io_nic *nic = netdev_priv(dev);
 	unsigned long flags[MAX_TX_FIFOS];
 	struct mac_info *mac_control = &nic->mac_control;
 	struct config_param *config = &nic->config;
@@ -378,7 +378,7 @@ static int vlan_strip_flag;
 static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned long vid)
 {
 	int i;
-	struct s2io_nic *nic = dev->priv;
+	struct s2io_nic *nic = netdev_priv(dev);
 	unsigned long flags[MAX_TX_FIFOS];
 	struct mac_info *mac_control = &nic->mac_control;
 	struct config_param *config = &nic->config;
@@ -2840,7 +2840,7 @@ static int s2io_poll_msix(struct napi_struct *napi, int budget)
 	int pkts_processed = 0;
 	u8 __iomem *addr = NULL;
 	u8 val8 = 0;
-	struct s2io_nic *nic = dev->priv;
+	struct s2io_nic *nic = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	int budget_org = budget;
 
@@ -2912,7 +2912,7 @@ static int s2io_poll_inta(struct napi_struct *napi, int budget)
  */
 static void s2io_netpoll(struct net_device *dev)
 {
-	struct s2io_nic *nic = dev->priv;
+	struct s2io_nic *nic = netdev_priv(dev);
 	struct mac_info *mac_control;
 	struct config_param *config;
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
@@ -3174,7 +3174,7 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 static void s2io_mdio_write(u32 mmd_type, u64 addr, u16 value, struct net_device *dev)
 {
 	u64 val64 = 0x0;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 
 	//address transaction
@@ -3223,7 +3223,7 @@ static u64 s2io_mdio_read(u32 mmd_type, u64 addr, struct net_device *dev)
 {
 	u64 val64 = 0x0;
 	u64 rval64 = 0x0;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 
 	/* address transaction */
@@ -3327,7 +3327,7 @@ static void s2io_updt_xpak_counter(struct net_device *dev)
 	u64 val64 = 0x0;
 	u64 addr  = 0x0;
 
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct stat_block *stat_info = sp->mac_control.stats_info;
 
 	/* Check the communication with the MDIO slave */
@@ -3993,7 +3993,7 @@ static void remove_inta_isr(struct s2io_nic *sp)
 
 static int s2io_open(struct net_device *dev)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	int err = 0;
 
 	/*
@@ -4051,7 +4051,7 @@ hw_init_failed:
 
 static int s2io_close(struct net_device *dev)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct config_param *config = &sp->config;
 	u64 tmp64;
 	int offset;
@@ -4090,7 +4090,7 @@ static int s2io_close(struct net_device *dev)
 
 static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	u16 frg_cnt, frg_len, i, queue, queue_len, put_off, get_off;
 	register u64 val64;
 	struct TxD *txdp;
@@ -4488,7 +4488,7 @@ static int do_s2io_chk_alarm_bit(u64 value, void __iomem * addr,
 static void s2io_handle_errors(void * dev_id)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	u64 temp64 = 0,val64=0;
 	int i = 0;
@@ -4755,7 +4755,7 @@ reset:
 static irqreturn_t s2io_isr(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	int i;
 	u64 reason = 0;
@@ -4884,7 +4884,7 @@ static void s2io_updt_stats(struct s2io_nic *sp)
 
 static struct net_device_stats *s2io_get_stats(struct net_device *dev)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct mac_info *mac_control;
 	struct config_param *config;
 	int i;
@@ -4951,7 +4951,7 @@ static void s2io_set_multicast(struct net_device *dev)
 {
 	int i, j, prev_cnt;
 	struct dev_mc_list *mclist;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	u64 val64 = 0, multi_mac = 0x010203040506ULL, mask =
 	    0xfeffffffffffULL;
@@ -5280,7 +5280,7 @@ static int s2io_set_mac_addr(struct net_device *dev, void *p)
 
 static int do_s2io_prog_unicast(struct net_device *dev, u8 *addr)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	register u64 mac_addr = 0, perm_addr = 0;
 	int i;
 	u64 tmp64;
@@ -5339,7 +5339,7 @@ static int do_s2io_prog_unicast(struct net_device *dev, u8 *addr)
 static int s2io_ethtool_sset(struct net_device *dev,
 			     struct ethtool_cmd *info)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	if ((info->autoneg == AUTONEG_ENABLE) ||
 	    (info->speed != SPEED_10000) || (info->duplex != DUPLEX_FULL))
 		return -EINVAL;
@@ -5365,7 +5365,7 @@ static int s2io_ethtool_sset(struct net_device *dev,
 
 static int s2io_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	info->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	info->advertising = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	info->port = PORT_FIBRE;
@@ -5400,7 +5400,7 @@ static int s2io_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)
 static void s2io_ethtool_gdrvinfo(struct net_device *dev,
 				  struct ethtool_drvinfo *info)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	strncpy(info->driver, s2io_driver_name, sizeof(info->driver));
 	strncpy(info->version, s2io_driver_version, sizeof(info->version));
@@ -5430,7 +5430,7 @@ static void s2io_ethtool_gregs(struct net_device *dev,
 	int i;
 	u64 reg;
 	u8 *reg_space = (u8 *) space;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	regs->len = XENA_REG_SPACE;
 	regs->version = sp->pdev->subsystem_device;
@@ -5490,7 +5490,7 @@ static void s2io_phy_id(unsigned long data)
 static int s2io_ethtool_idnic(struct net_device *dev, u32 data)
 {
 	u64 val64 = 0, last_gpio_ctrl_val;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	u16 subid;
 
@@ -5528,7 +5528,7 @@ static int s2io_ethtool_idnic(struct net_device *dev, u32 data)
 static void s2io_ethtool_gringparam(struct net_device *dev,
                                     struct ethtool_ringparam *ering)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	int i,tx_desc_count=0,rx_desc_count=0;
 
 	if (sp->rxd_mode == RXD_MODE_1)
@@ -5571,7 +5571,7 @@ static void s2io_ethtool_getpause_data(struct net_device *dev,
 				       struct ethtool_pauseparam *ep)
 {
 	u64 val64;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 
 	val64 = readq(&bar0->rmac_pause_cfg);
@@ -5598,7 +5598,7 @@ static int s2io_ethtool_setpause_data(struct net_device *dev,
 			       struct ethtool_pauseparam *ep)
 {
 	u64 val64;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 
 	val64 = readq(&bar0->rmac_pause_cfg);
@@ -5828,7 +5828,7 @@ static int s2io_ethtool_geeprom(struct net_device *dev,
 {
 	u32 i, valid;
 	u64 data;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	eeprom->magic = sp->pdev->vendor | (sp->pdev->device << 16);
 
@@ -5866,7 +5866,7 @@ static int s2io_ethtool_seeprom(struct net_device *dev,
 {
 	int len = eeprom->len, cnt = 0;
 	u64 valid = 0, data;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	if (eeprom->magic != (sp->pdev->vendor | (sp->pdev->device << 16))) {
 		DBG_PRINT(ERR_DBG,
@@ -6246,7 +6246,7 @@ static void s2io_ethtool_test(struct net_device *dev,
 			      struct ethtool_test *ethtest,
 			      uint64_t * data)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	int orig_state = netif_running(sp->dev);
 
 	if (ethtest->flags == ETH_TEST_FL_OFFLINE) {
@@ -6302,7 +6302,7 @@ static void s2io_get_ethtool_stats(struct net_device *dev,
 				   u64 * tmp_stats)
 {
 	int i = 0, k;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct stat_block *stat_info = sp->mac_control.stats_info;
 
 	s2io_updt_stats(sp);
@@ -6581,14 +6581,14 @@ static int s2io_ethtool_get_regs_len(struct net_device *dev)
 
 static u32 s2io_ethtool_get_rx_csum(struct net_device * dev)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	return (sp->rx_csum);
 }
 
 static int s2io_ethtool_set_rx_csum(struct net_device *dev, u32 data)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	if (data)
 		sp->rx_csum = 1;
@@ -6605,7 +6605,7 @@ static int s2io_get_eeprom_len(struct net_device *dev)
 
 static int s2io_get_sset_count(struct net_device *dev, int sset)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	switch (sset) {
 	case ETH_SS_TEST:
@@ -6628,7 +6628,7 @@ static void s2io_ethtool_get_strings(struct net_device *dev,
 				     u32 stringset, u8 * data)
 {
 	int stat_size = 0;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	switch (stringset) {
 	case ETH_SS_TEST:
@@ -6730,7 +6730,7 @@ static int s2io_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 static int s2io_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	int ret = 0;
 
 	if ((new_mtu < MIN_MTU) || (new_mtu > S2IO_JUMBO_SIZE)) {
@@ -7334,7 +7334,7 @@ out_unlock:
 
 static void s2io_tx_watchdog(struct net_device *dev)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	if (netif_carrier_ok(dev)) {
 		sp->mac_control.stats_info->sw_stat.watchdog_timer_cnt++;
@@ -7801,7 +7801,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	/*  Private member variable initialized to s2io NIC structure */
-	sp = dev->priv;
+	sp = netdev_priv(dev);
 	memset(sp, 0, sizeof(struct s2io_nic));
 	sp->dev = dev;
 	sp->pdev = pdev;
@@ -8253,7 +8253,7 @@ static void __devexit s2io_rem_nic(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
-	sp = dev->priv;
+	sp = netdev_priv(dev);
 	unregister_netdev(dev);
 
 	free_shared_mem(sp);
@@ -8588,7 +8588,7 @@ static void clear_lro_session(struct lro *lro)
 static void queue_rx_frame(struct sk_buff *skb, u16 vlan_tag)
 {
 	struct net_device *dev = skb->dev;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	skb->protocol = eth_type_trans(skb, dev);
 	if (sp->vlgrp && vlan_tag
@@ -8637,7 +8637,7 @@ static pci_ers_result_t s2io_io_error_detected(struct pci_dev *pdev,
                                                pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct s2io_nic *sp = netdev->priv;
+	struct s2io_nic *sp = netdev_priv(netdev);
 
 	netif_device_detach(netdev);
 
@@ -8662,7 +8662,7 @@ static pci_ers_result_t s2io_io_error_detected(struct pci_dev *pdev,
 static pci_ers_result_t s2io_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct s2io_nic *sp = netdev->priv;
+	struct s2io_nic *sp = netdev_priv(netdev);
 
 	if (pci_enable_device(pdev)) {
 		printk(KERN_ERR "s2io: "
@@ -8686,7 +8686,7 @@ static pci_ers_result_t s2io_io_slot_reset(struct pci_dev *pdev)
 static void s2io_io_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct s2io_nic *sp = netdev->priv;
+	struct s2io_nic *sp = netdev_priv(netdev);
 
 	if (netif_running(netdev)) {
 		if (s2io_card_up(sp)) {
-- 
1.5.3.4



