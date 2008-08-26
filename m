From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-6
Date: Tue, 26 Aug 2008 22:18:39 +0800
Message-ID: <48B410BF.2080606@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52575 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756502AbYHZOVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:21:06 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
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
 
--



