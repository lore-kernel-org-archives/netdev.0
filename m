From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-4
Date: Tue, 26 Aug 2008 22:18:30 +0800
Message-ID: <48B410B6.8020808@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52161 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756010AbYHZOU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:20:56 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 6106660..965aa2f 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2346,7 +2346,7 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
 int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 {
 	struct slave *slave, *start_at;
-	struct bonding *bond = dev->priv;
+	struct bonding *bond = netdev_priv(dev);
 	int slave_agg_no;
 	int slaves_in_agg;
 	int agg_id;
@@ -2426,7 +2426,7 @@ out:
 
 int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type* ptype, struct net_device *orig_dev)
 {
-	struct bonding *bond = dev->priv;
+	struct bonding *bond = netdev_priv(dev);
 	struct slave *slave = NULL;
 	int ret = NET_RX_DROP;
 
@@ -2437,7 +2437,8 @@ int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, struct pac
 		goto out;
 
 	read_lock(&bond->lock);
-	slave = bond_get_slave_by_dev((struct bonding *)dev->priv, orig_dev);
+	slave = bond_get_slave_by_dev((struct bonding *)netdev_priv(dev),
+					orig_dev);
 	if (!slave)
 		goto out_unlock;
 
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index b211486..0c236c1 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -341,7 +341,7 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
 
 static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct packet_type *ptype, struct net_device *orig_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct arp_pkt *arp = (struct arp_pkt *)skb->data;
 	int res = NET_RX_DROP;
 
@@ -1280,7 +1280,7 @@ void bond_alb_deinitialize(struct bonding *bond)
 
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct ethhdr *eth_data;
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct slave *tx_slave = NULL;
@@ -1679,7 +1679,7 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
  */
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct sockaddr *sa = addr;
 	struct slave *slave, *swap_slave;
 	int res;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c792138..77edc2c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -442,7 +442,7 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_de
  */
 static void bond_vlan_rx_register(struct net_device *bond_dev, struct vlan_group *grp)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 	int i;
 
@@ -465,7 +465,7 @@ static void bond_vlan_rx_register(struct net_device *bond_dev, struct vlan_group
  */
 static void bond_vlan_rx_add_vid(struct net_device *bond_dev, uint16_t vid)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 	int i, res;
 
@@ -493,7 +493,7 @@ static void bond_vlan_rx_add_vid(struct net_device *bond_dev, uint16_t vid)
  */
 static void bond_vlan_rx_kill_vid(struct net_device *bond_dev, uint16_t vid)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 	struct net_device *vlan_dev;
 	int i, res;
@@ -927,7 +927,7 @@ static int bond_mc_list_copy(struct dev_mc_list *mc_list, struct bonding *bond,
  */
 static void bond_mc_list_flush(struct net_device *bond_dev, struct net_device *slave_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct dev_mc_list *dmi;
 
 	for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next) {
@@ -1362,7 +1362,7 @@ static int bond_compute_features(struct bonding *bond)
 static void bond_setup_by_slave(struct net_device *bond_dev,
 				struct net_device *slave_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 
 	bond_dev->neigh_setup           = slave_dev->neigh_setup;
 	bond_dev->header_ops		= slave_dev->header_ops;
@@ -1379,7 +1379,7 @@ static void bond_setup_by_slave(struct net_device *bond_dev,
 /* enslave device <slave> to bond device <master> */
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *new_slave = NULL;
 	struct dev_mc_list *dmi;
 	struct sockaddr addr;
@@ -1781,7 +1781,7 @@ err_undo_flags:
  */
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *oldcurrent;
 	struct sockaddr addr;
 	int mac_addr_differ;
@@ -1979,7 +1979,7 @@ void bond_destroy(struct bonding *bond)
 */
 int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	int ret;
 
 	ret = bond_release(bond_dev, slave_dev);
@@ -1996,7 +1996,7 @@ int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *sl
  */
 static int bond_release_all(struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 	struct net_device *slave_dev;
 	struct sockaddr addr;
@@ -2127,7 +2127,7 @@ out:
  */
 static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_device *slave_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *old_active = NULL;
 	struct slave *new_active = NULL;
 	int res = 0;
@@ -2176,7 +2176,7 @@ static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_devi
 
 static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 
 	info->bond_mode = bond->params.mode;
 	info->miimon = bond->params.miimon;
@@ -2190,7 +2190,7 @@ static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 
 static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *info)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 	int i, found = 0;
 
@@ -2676,7 +2676,7 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 	if (!(dev->priv_flags & IFF_BONDING) || !(dev->flags & IFF_MASTER))
 		goto out;
 
-	bond = dev->priv;
+	bond = netdev_priv(dev);
 	read_lock(&bond->lock);
 
 	dprintk("bond_arp_rcv: bond %s skb->dev %s orig_dev %s\n",
@@ -3483,7 +3483,7 @@ static int bond_event_changename(struct bonding *bond)
 
 static int bond_master_netdev_event(unsigned long event, struct net_device *bond_dev)
 {
-	struct bonding *event_bond = bond_dev->priv;
+	struct bonding *event_bond = netdev_priv(bond_dev);
 
 	switch (event) {
 	case NETDEV_CHANGENAME:
@@ -3501,7 +3501,7 @@ static int bond_master_netdev_event(unsigned long event, struct net_device *bond
 static int bond_slave_netdev_event(unsigned long event, struct net_device *slave_dev)
 {
 	struct net_device *bond_dev = slave_dev->master;
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 
 	switch (event) {
 	case NETDEV_UNREGISTER:
@@ -3752,7 +3752,7 @@ static int bond_xmit_hash_policy_l2(struct sk_buff *skb,
 
 static int bond_open(struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 
 	bond->kill_timers = 0;
 
@@ -3800,7 +3800,7 @@ static int bond_open(struct net_device *bond_dev)
 
 static int bond_close(struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		/* Unregister the receive of LACPDUs */
@@ -3853,7 +3853,7 @@ static int bond_close(struct net_device *bond_dev)
 
 static struct net_device_stats *bond_get_stats(struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct net_device_stats *stats = &(bond->stats), *sstats;
 	struct net_device_stats local_stats;
 	struct slave *slave;
@@ -3931,7 +3931,7 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 		}
 
 		if (mii->reg_num == 1) {
-			struct bonding *bond = bond_dev->priv;
+			struct bonding *bond = netdev_priv(bond_dev);
 			mii->val_out = 0;
 			read_lock(&bond->lock);
 			read_lock(&bond->curr_slave_lock);
@@ -4023,7 +4023,7 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 
 static void bond_set_multicast_list(struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct dev_mc_list *dmi;
 
 	/*
@@ -4084,7 +4084,7 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
  */
 static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *stop_at;
 	int res = 0;
 	int i;
@@ -4156,7 +4156,7 @@ unwind:
  */
 static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct sockaddr *sa = addr, tmp_sa;
 	struct slave *slave, *stop_at;
 	int res = 0;
@@ -4237,7 +4237,7 @@ unwind:
 
 static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *start_at;
 	int i, slave_no, res = 1;
 
@@ -4286,7 +4286,7 @@ out:
  */
 static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	int res = 1;
 
 	read_lock(&bond->lock);
@@ -4318,7 +4318,7 @@ out:
  */
 static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *start_at;
 	int slave_no;
 	int i;
@@ -4364,7 +4364,7 @@ out:
  */
 static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *start_at;
 	struct net_device *tx_dev = NULL;
 	int i;
@@ -4501,7 +4501,7 @@ static const struct ethtool_ops bond_ethtool_ops = {
  */
 static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 
 	dprintk("Begin bond_init for %s\n", bond_dev->name);
 
@@ -4582,7 +4582,7 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
  */
 static void bond_deinit(struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 
 	list_del(&bond->bond_list);
 
@@ -5071,7 +5071,7 @@ int bond_create(char *name, struct bond_params *params)
 
 	up_write(&bonding_rwsem);
 	rtnl_unlock(); /* allows sysfs registration of net device */
-	res = bond_create_sysfs_entry(bond_dev->priv);
+	res = bond_create_sysfs_entry(netdev_priv(bond_dev));
 	if (res < 0) {
 		rtnl_lock();
 		down_write(&bonding_rwsem);
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 3bdb473..eda0915 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -39,7 +39,7 @@
 /* #define BONDING_DEBUG 1 */
 #include "bonding.h"
 #define to_dev(obj)	container_of(obj,struct device,kobj)
-#define to_bond(cd)	((struct bonding *)(to_net_dev(cd)->priv))
+#define to_bond(cd)	((struct bonding *)(netdev_priv(to_net_dev(cd))))
 
 /*---------------------------- Declarations -------------------------------*/
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index fb730ec..e990b87 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -245,7 +245,7 @@ static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
 		return NULL;
 	}
 
-	return (struct bonding *)slave->dev->master->priv;
+	return (struct bonding *)netdev_priv(slave->dev->master);
 }
 
 #define BOND_FOM_NONE			0
@@ -275,7 +275,7 @@ static inline unsigned long slave_last_rx(struct bonding *bond,
 
 static inline void bond_set_slave_inactive_flags(struct slave *slave)
 {
-	struct bonding *bond = slave->dev->master->priv;
+	struct bonding *bond = netdev_priv(slave->dev->master);
 	if (bond->params.mode != BOND_MODE_TLB &&
 	    bond->params.mode != BOND_MODE_ALB)
 		slave->state = BOND_STATE_BACKUP;
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index 451acdc..ef09c41 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -144,7 +144,7 @@ static int __devinit mace_probe(struct macio_dev *mdev, const struct of_device_i
 	}
 	SET_NETDEV_DEV(dev, &mdev->ofdev.dev);
 
-	mp = dev->priv;
+	mp = netdev_priv(dev);
 	mp->mdev = mdev;
 	macio_set_drvdata(mdev, dev);
 
@@ -165,7 +165,7 @@ static int __devinit mace_probe(struct macio_dev *mdev, const struct of_device_i
 			in_8(&mp->mace->chipid_lo);
 
 
-	mp = (struct mace_data *) dev->priv;
+	mp = netdev_priv(dev);
 	mp->maccc = ENXMT | ENRCV;
 
 	mp->tx_dma = ioremap(macio_resource_start(mdev, 1), 0x1000);
@@ -276,7 +276,7 @@ static int __devexit mace_remove(struct macio_dev *mdev)
 
 	macio_set_drvdata(mdev, NULL);
 
-	mp = dev->priv;
+	mp = netdev_priv(dev);
 
 	unregister_netdev(dev);
 
@@ -312,7 +312,7 @@ static void dbdma_reset(volatile struct dbdma_regs __iomem *dma)
 
 static void mace_reset(struct net_device *dev)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     int i;
 
@@ -367,7 +367,7 @@ static void mace_reset(struct net_device *dev)
 
 static void __mace_set_address(struct net_device *dev, void *addr)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     unsigned char *p = addr;
     int i;
@@ -388,7 +388,7 @@ static void __mace_set_address(struct net_device *dev, void *addr)
 
 static int mace_set_address(struct net_device *dev, void *addr)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     unsigned long flags;
 
@@ -423,7 +423,7 @@ static inline void mace_clean_rings(struct mace_data *mp)
 
 static int mace_open(struct net_device *dev)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     volatile struct dbdma_regs __iomem *rd = mp->rx_dma;
     volatile struct dbdma_regs __iomem *td = mp->tx_dma;
@@ -493,7 +493,7 @@ static int mace_open(struct net_device *dev)
 
 static int mace_close(struct net_device *dev)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     volatile struct dbdma_regs __iomem *rd = mp->rx_dma;
     volatile struct dbdma_regs __iomem *td = mp->tx_dma;
@@ -513,7 +513,7 @@ static int mace_close(struct net_device *dev)
 
 static inline void mace_set_timeout(struct net_device *dev)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
 
     if (mp->timeout_active)
 	del_timer(&mp->tx_timeout);
@@ -526,7 +526,7 @@ static inline void mace_set_timeout(struct net_device *dev)
 
 static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct dbdma_regs __iomem *td = mp->tx_dma;
     volatile struct dbdma_cmd *cp, *np;
     unsigned long flags;
@@ -581,7 +581,7 @@ static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
 
 static void mace_set_multicast(struct net_device *dev)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     int i, j;
     u32 crc;
@@ -656,7 +656,7 @@ static void mace_handle_misc_intrs(struct mace_data *mp, int intr, struct net_de
 static irqreturn_t mace_interrupt(int irq, void *dev_id)
 {
     struct net_device *dev = (struct net_device *) dev_id;
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     volatile struct dbdma_regs __iomem *td = mp->tx_dma;
     volatile struct dbdma_cmd *cp;
@@ -802,7 +802,7 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
 static void mace_tx_timeout(unsigned long data)
 {
     struct net_device *dev = (struct net_device *) data;
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     volatile struct dbdma_regs __iomem *td = mp->tx_dma;
     volatile struct dbdma_regs __iomem *rd = mp->rx_dma;
@@ -873,7 +873,7 @@ static irqreturn_t mace_txdma_intr(int irq, void *dev_id)
 static irqreturn_t mace_rxdma_intr(int irq, void *dev_id)
 {
     struct net_device *dev = (struct net_device *) dev_id;
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct dbdma_regs __iomem *rd = mp->rx_dma;
     volatile struct dbdma_cmd *cp, *np;
     int i, nb, stat, next;
--




