From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 4/7] chelsio: use netdev_priv
Date: Wed, 6 Dec 2006 01:16:52 +0100
Message-ID: <20061206001652.GD2377@electric-eye.fr.zoreil.com>
References: <20061206001007.GA27423@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58021 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758660AbWLFAQy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 19:16:54 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206001007.GA27423@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/chelsio/cxgb2.c |   60 +++++++++++++++++++++---------------------
 drivers/net/chelsio/sge.c   |    4 +-
 2 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index cb639d4..15be058 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -120,7 +120,7 @@ static const char pci_speed[][4] = {
  */
 static void t1_set_rxmode(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	struct cmac *mac = adapter->port[dev->if_port].mac;
 	struct t1_rx_mode rm;
 
@@ -253,7 +253,7 @@ static void cxgb_down(struct adapter *ad
 static int cxgb_open(struct net_device *dev)
 {
 	int err;
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	int other_ports = adapter->open_device_map & PORT_MASK;
 
 	if (!adapter->open_device_map && (err = cxgb_up(adapter)) < 0)
@@ -270,7 +270,7 @@ static int cxgb_open(struct net_device *
 
 static int cxgb_close(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	struct port_info *p = &adapter->port[dev->if_port];
 	struct cmac *mac = p->mac;
 
@@ -295,7 +295,7 @@ static int cxgb_close(struct net_device
 
 static struct net_device_stats *t1_get_stats(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	struct port_info *p = &adapter->port[dev->if_port];
 	struct net_device_stats *ns = &p->netstats;
 	const struct cmac_statistics *pstats;
@@ -343,14 +343,14 @@ static struct net_device_stats *t1_get_s
 
 static u32 get_msglevel(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 
 	return adapter->msg_enable;
 }
 
 static void set_msglevel(struct net_device *dev, u32 val)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 
 	adapter->msg_enable = val;
 }
@@ -428,7 +428,7 @@ static int get_regs_len(struct net_devic
 
 static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -450,7 +450,7 @@ static void get_strings(struct net_devic
 static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 		      u64 *data)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	struct cmac *mac = adapter->port[dev->if_port].mac;
 	const struct cmac_statistics *s;
 	const struct sge_intr_counts *t;
@@ -538,7 +538,7 @@ static inline void reg_block_dump(struct
 static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		     void *buf)
 {
-	struct adapter *ap = dev->priv;
+	struct adapter *ap = netdev_priv(dev);
 
 	/*
 	 * Version scheme: bits 0..9: chip version, bits 10..15: chip revision
@@ -560,7 +560,7 @@ static void get_regs(struct net_device *
 
 static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	struct port_info *p = &adapter->port[dev->if_port];
 
 	cmd->supported = p->link_config.supported;
@@ -620,7 +620,7 @@ static int speed_duplex_to_caps(int spee
 
 static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	struct port_info *p = &adapter->port[dev->if_port];
 	struct link_config *lc = &p->link_config;
 
@@ -655,7 +655,7 @@ static int set_settings(struct net_devic
 static void get_pauseparam(struct net_device *dev,
 			   struct ethtool_pauseparam *epause)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	struct port_info *p = &adapter->port[dev->if_port];
 
 	epause->autoneg = (p->link_config.requested_fc & PAUSE_AUTONEG) != 0;
@@ -666,7 +666,7 @@ static void get_pauseparam(struct net_de
 static int set_pauseparam(struct net_device *dev,
 			  struct ethtool_pauseparam *epause)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	struct port_info *p = &adapter->port[dev->if_port];
 	struct link_config *lc = &p->link_config;
 
@@ -695,14 +695,14 @@ static int set_pauseparam(struct net_dev
 
 static u32 get_rx_csum(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 
 	return (adapter->flags & RX_CSUM_ENABLED) != 0;
 }
 
 static int set_rx_csum(struct net_device *dev, u32 data)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 
 	if (data)
 		adapter->flags |= RX_CSUM_ENABLED;
@@ -713,7 +713,7 @@ static int set_rx_csum(struct net_device
 
 static int set_tso(struct net_device *dev, u32 value)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 
 	if (!(adapter->flags & TSO_CAPABLE))
 		return value ? -EOPNOTSUPP : 0;
@@ -722,7 +722,7 @@ static int set_tso(struct net_device *de
 
 static void get_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	int jumbo_fl = t1_is_T1B(adapter) ? 1 : 0;
 
 	e->rx_max_pending = MAX_RX_BUFFERS;
@@ -738,7 +738,7 @@ static void get_sge_param(struct net_dev
 
 static int set_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	int jumbo_fl = t1_is_T1B(adapter) ? 1 : 0;
 
 	if (e->rx_pending > MAX_RX_BUFFERS || e->rx_mini_pending ||
@@ -762,7 +762,7 @@ static int set_sge_param(struct net_devi
 
 static int set_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 
 	/*
 	 * If RX coalescing is requested we use NAPI, otherwise interrupts.
@@ -784,7 +784,7 @@ static int set_coalesce(struct net_devic
 
 static int get_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 
 	c->rx_coalesce_usecs = adapter->params.sge.rx_coalesce_usecs;
 	c->rate_sample_interval = adapter->params.sge.sample_interval_usecs;
@@ -794,7 +794,7 @@ static int get_coalesce(struct net_devic
 
 static int get_eeprom_len(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 
 	return t1_is_asic(adapter) ? EEPROM_SIZE : 0;
 }
@@ -807,7 +807,7 @@ static int get_eeprom(struct net_device
 {
 	int i;
 	u8 buf[EEPROM_SIZE] __attribute__((aligned(4)));
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 
 	e->magic = EEPROM_MAGIC(adapter);
 	for (i = e->offset & ~3; i < e->offset + e->len; i += sizeof(u32))
@@ -848,7 +848,7 @@ static const struct ethtool_ops t1_ethto
 
 static int t1_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	struct mii_ioctl_data *data = if_mii(req);
 
 	switch (cmd) {
@@ -887,7 +887,7 @@ static int t1_ioctl(struct net_device *d
 static int t1_change_mtu(struct net_device *dev, int new_mtu)
 {
 	int ret;
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	struct cmac *mac = adapter->port[dev->if_port].mac;
 
 	if (!mac->ops->set_mtu)
@@ -902,7 +902,7 @@ static int t1_change_mtu(struct net_devi
 
 static int t1_set_mac_addr(struct net_device *dev, void *p)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	struct cmac *mac = adapter->port[dev->if_port].mac;
 	struct sockaddr *addr = p;
 
@@ -918,7 +918,7 @@ static int t1_set_mac_addr(struct net_de
 static void vlan_rx_register(struct net_device *dev,
 				   struct vlan_group *grp)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 
 	spin_lock_irq(&adapter->async_lock);
 	adapter->vlan_grp = grp;
@@ -928,7 +928,7 @@ static void vlan_rx_register(struct net_
 
 static void vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 
 	spin_lock_irq(&adapter->async_lock);
 	if (adapter->vlan_grp)
@@ -941,7 +941,7 @@ static void vlan_rx_kill_vid(struct net_
 static void t1_netpoll(struct net_device *dev)
 {
 	unsigned long flags;
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 
 	local_irq_save(flags);
 	t1_select_intr_handler(adapter)(adapter->pdev->irq, adapter);
@@ -1086,7 +1086,7 @@ static int __devinit init_one(struct pci
 		SET_NETDEV_DEV(netdev, &pdev->dev);
 
 		if (!adapter) {
-			adapter = netdev->priv;
+			adapter = netdev_priv(netdev);
 			adapter->pdev = pdev;
 			adapter->port[0].dev = netdev;  /* so we don't leak it */
 
@@ -1396,7 +1396,7 @@ static void __devexit remove_one(struct
 
 	if (dev) {
 		int i;
-		struct adapter *adapter = dev->priv;
+		struct adapter *adapter = netdev_priv(dev);
 
 		for_each_port(adapter, i)
 			if (test_bit(i, &adapter->registered_device_map))
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index f168f99..f61d671 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1620,7 +1620,7 @@ static int process_pure_responses(struct
  */
 static int t1_poll(struct net_device *dev, int *budget)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	int effective_budget = min(*budget, dev->quota);
 
 	int work_done = process_responses(adapter, effective_budget);
@@ -1884,7 +1884,7 @@ static inline int eth_hdr_len(const void
  */
 int t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = netdev_priv(dev);
 	struct sge *sge = adapter->sge;
 	struct sge_port_stats *st = per_cpu_ptr(sge->port_stats[dev->if_port], smp_processor_id());
 	struct cpl_tx_pkt *cpl;
-- 
1.4.4.1

