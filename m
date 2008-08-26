From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-9
Date: Tue, 26 Aug 2008 22:18:51 +0800
Message-ID: <48B410CB.6010801@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61562 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756819AbYHZOVZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:21:25 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
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



