From: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCHv1] net-next: treewide use is_vlan_dev() helper function.
Date: Sat,  4 Feb 2017 11:00:49 -0600
Message-ID: <1486227649-12648-1-git-send-email-parav@mellanox.com>
Cc: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
        ganeshgr-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, manish.chopra-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        rahul.verma-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, Dept-GELinuxNICDev-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        harish.patil-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, kys-0li6OtcxBFHby3iVrkZq2A@public.gmane.org, haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org,
        sthemmin-0li6OtcxBFHby3iVrkZq2A@public.gmane.org, QLogic-Storage-Upstream-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
        jth-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, arvid.brodin-SVm98a2vdck@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
        bart.vanassche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org, valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
        weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jmaxwell37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
        jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-tBiZLqfeLfOHmIFyCCdPziST3g8Odh+X@public.gmane.org,
        linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fcoe-devel@open-fcoe.o
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch makes use of is_vlan_dev() function instead of flag
comparison which is exactly done by is_vlan_dev() helper function.

Signed-off-by: Parav Pandit <parav-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Daniel Jurgens <danielj-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/cma.c                        |  6 ++----
 drivers/infiniband/sw/rxe/rxe_net.c                  |  2 +-
 drivers/net/ethernet/broadcom/cnic.c                 |  2 +-
 drivers/net/ethernet/chelsio/cxgb3/l2t.c             |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c      |  4 ++--
 drivers/net/ethernet/chelsio/cxgb4/l2t.c             |  2 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |  8 ++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c     |  4 ++--
 drivers/net/hyperv/netvsc_drv.c                      |  2 +-
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c                    |  6 +++---
 drivers/scsi/cxgbi/libcxgbi.c                        |  6 +++---
 drivers/scsi/fcoe/fcoe.c                             | 13 ++++++-------
 include/rdma/ib_addr.h                               |  6 ++----
 net/hsr/hsr_slave.c                                  |  3 ++-
 14 files changed, 31 insertions(+), 35 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 3e70a9c..4eb5a80 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -2467,14 +2467,12 @@ static int iboe_tos_to_sl(struct net_device *ndev, int tos)
 	struct net_device *dev;
 
 	prio = rt_tos2priority(tos);
-	dev = ndev->priv_flags & IFF_802_1Q_VLAN ?
-		vlan_dev_real_dev(ndev) : ndev;
-
+	dev = is_vlan_dev(ndev) ? vlan_dev_real_dev(ndev) : ndev;
 	if (dev->num_tc)
 		return netdev_get_prio_tc_map(dev, prio);
 
 #if IS_ENABLED(CONFIG_VLAN_8021Q)
-	if (ndev->priv_flags & IFF_802_1Q_VLAN)
+	if (is_vlan_dev(ndev))
 		return (vlan_dev_get_egress_qos_mask(ndev, prio) &
 			VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
 #endif
diff --git a/drivers/infiniband/sw/rxe/rxe_net.c b/drivers/infiniband/sw/rxe/rxe_net.c
index 4abdeb3..d9d1556 100644
--- a/drivers/infiniband/sw/rxe/rxe_net.c
+++ b/drivers/infiniband/sw/rxe/rxe_net.c
@@ -118,7 +118,7 @@ static struct device *dma_device(struct rxe_dev *rxe)
 
 	ndev = rxe->ndev;
 
-	if (ndev->priv_flags & IFF_802_1Q_VLAN)
+	if (is_vlan_dev(ndev))
 		ndev = vlan_dev_real_dev(ndev);
 
 	return ndev->dev.parent;
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index b1d2ac8..cec94bb 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -3665,7 +3665,7 @@ static int cnic_cm_destroy(struct cnic_sock *csk)
 static inline u16 cnic_get_vlan(struct net_device *dev,
 				struct net_device **vlan_dev)
 {
-	if (dev->priv_flags & IFF_802_1Q_VLAN) {
+	if (is_vlan_dev(dev)) {
 		*vlan_dev = vlan_dev_real_dev(dev);
 		return vlan_dev_vlan_id(dev);
 	}
diff --git a/drivers/net/ethernet/chelsio/cxgb3/l2t.c b/drivers/net/ethernet/chelsio/cxgb3/l2t.c
index 5f226ed..5206358 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/l2t.c
@@ -351,7 +351,7 @@ struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct dst_entry *dst,
 		e->smt_idx = smt_idx;
 		atomic_set(&e->refcnt, 1);
 		neigh_replace(e, neigh);
-		if (neigh->dev->priv_flags & IFF_802_1Q_VLAN)
+		if (is_vlan_dev(neigh->dev))
 			e->vlan = vlan_dev_vlan_id(neigh->dev);
 		else
 			e->vlan = VLAN_NONE;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index f4f5690..7059014 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1805,7 +1805,7 @@ static void check_neigh_update(struct neighbour *neigh)
 	const struct device *parent;
 	const struct net_device *netdev = neigh->dev;
 
-	if (netdev->priv_flags & IFF_802_1Q_VLAN)
+	if (is_vlan_dev(netdev))
 		netdev = vlan_dev_real_dev(netdev);
 	parent = netdev->dev.parent;
 	if (parent && parent->driver == &cxgb4_driver.driver)
@@ -2111,7 +2111,7 @@ static int cxgb4_inet6addr_handler(struct notifier_block *this,
 #if IS_ENABLED(CONFIG_BONDING)
 	struct adapter *adap;
 #endif
-	if (event_dev->priv_flags & IFF_802_1Q_VLAN)
+	if (is_vlan_dev(event_dev))
 		event_dev = vlan_dev_real_dev(event_dev);
 #if IS_ENABLED(CONFIG_BONDING)
 	if (event_dev->flags & IFF_MASTER) {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index 60a2603..7c8c5b9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -432,7 +432,7 @@ struct l2t_entry *cxgb4_l2t_get(struct l2t_data *d, struct neighbour *neigh,
 	else
 		lport = netdev2pinfo(physdev)->lport;
 
-	if (neigh->dev->priv_flags & IFF_802_1Q_VLAN)
+	if (is_vlan_dev(neigh->dev))
 		vlan = vlan_dev_vlan_id(neigh->dev);
 	else
 		vlan = VLAN_NONE;
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 0cf8a37..3b5d7cf 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -3264,7 +3264,7 @@ static ssize_t netxen_sysfs_write_mem(struct file *filp, struct kobject *kobj,
 		cur = kzalloc(sizeof(struct nx_ip_list), GFP_ATOMIC);
 		if (cur == NULL)
 			goto out;
-		if (dev->priv_flags & IFF_802_1Q_VLAN)
+		if (is_vlan_dev(dev))
 			dev = vlan_dev_real_dev(dev);
 		cur->master = !!netif_is_bond_master(dev);
 		cur->ip_addr = ifa->ifa_address;
@@ -3374,7 +3374,7 @@ static void netxen_config_master(struct net_device *dev, unsigned long event)
 	    !netif_is_bond_slave(dev)) {
 		netxen_config_indev_addr(adapter, master, event);
 		for_each_netdev_rcu(&init_net, slave)
-			if (slave->priv_flags & IFF_802_1Q_VLAN &&
+			if (is_vlan_dev(slave) &&
 			    vlan_dev_real_dev(slave) == master)
 				netxen_config_indev_addr(adapter, slave, event);
 	}
@@ -3400,7 +3400,7 @@ static int netxen_netdev_event(struct notifier_block *this,
 	if (dev == NULL)
 		goto done;
 
-	if (dev->priv_flags & IFF_802_1Q_VLAN) {
+	if (is_vlan_dev(dev)) {
 		dev = vlan_dev_real_dev(dev);
 		goto recheck;
 	}
@@ -3445,7 +3445,7 @@ static int netxen_netdev_event(struct notifier_block *this,
 	if (dev == NULL)
 		goto done;
 
-	if (dev->priv_flags & IFF_802_1Q_VLAN) {
+	if (is_vlan_dev(dev)) {
 		dev = vlan_dev_real_dev(dev);
 		goto recheck;
 	}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 4c0cce96..b6628aa 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -4220,7 +4220,7 @@ static int qlcnic_netdev_event(struct notifier_block *this,
 	if (dev == NULL)
 		goto done;
 
-	if (dev->priv_flags & IFF_802_1Q_VLAN) {
+	if (is_vlan_dev(dev)) {
 		dev = vlan_dev_real_dev(dev);
 		goto recheck;
 	}
@@ -4256,7 +4256,7 @@ static int qlcnic_netdev_event(struct notifier_block *this,
 	if (dev == NULL)
 		goto done;
 
-	if (dev->priv_flags & IFF_802_1Q_VLAN) {
+	if (is_vlan_dev(dev)) {
 		dev = vlan_dev_real_dev(dev);
 		goto recheck;
 	}
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 72b0c1f..425285f 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1605,7 +1605,7 @@ static int netvsc_netdev_event(struct notifier_block *this,
 		return NOTIFY_DONE;
 
 	/* Avoid Vlan dev with same MAC registering as VF */
-	if (event_dev->priv_flags & IFF_802_1Q_VLAN)
+	if (is_vlan_dev(event_dev))
 		return NOTIFY_DONE;
 
 	/* Avoid Bonding master dev with same MAC registering as VF */
diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index c639d5a..4b9e776 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -2282,7 +2282,7 @@ static int _bnx2fc_create(struct net_device *netdev,
 	}
 
 	/* obtain physical netdev */
-	if (netdev->priv_flags & IFF_802_1Q_VLAN)
+	if (is_vlan_dev(netdev))
 		phys_dev = vlan_dev_real_dev(netdev);
 
 	/* verify if the physical device is a netxtreme2 device */
@@ -2320,7 +2320,7 @@ static int _bnx2fc_create(struct net_device *netdev,
 		goto ifput_err;
 	}
 
-	if (netdev->priv_flags & IFF_802_1Q_VLAN) {
+	if (is_vlan_dev(netdev)) {
 		vlan_id = vlan_dev_vlan_id(netdev);
 		interface->vlan_enabled = 1;
 	}
@@ -2538,7 +2538,7 @@ static bool bnx2fc_match(struct net_device *netdev)
 	struct net_device *phys_dev = netdev;
 
 	mutex_lock(&bnx2fc_dev_lock);
-	if (netdev->priv_flags & IFF_802_1Q_VLAN)
+	if (is_vlan_dev(netdev))
 		phys_dev = vlan_dev_real_dev(netdev);
 
 	if (bnx2fc_hba_lookup(phys_dev)) {
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index 9167bcd..bd7d39e 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -223,7 +223,7 @@ struct cxgbi_device *cxgbi_device_find_by_netdev(struct net_device *ndev,
 	struct cxgbi_device *cdev, *tmp;
 	int i;
 
-	if (ndev->priv_flags & IFF_802_1Q_VLAN) {
+	if (is_vlan_dev(ndev)) {
 		vdev = ndev;
 		ndev = vlan_dev_real_dev(ndev);
 		log_debug(1 << CXGBI_DBG_DEV,
@@ -256,7 +256,7 @@ struct cxgbi_device *cxgbi_device_find_by_netdev_rcu(struct net_device *ndev,
 	struct cxgbi_device *cdev;
 	int i;
 
-	if (ndev->priv_flags & IFF_802_1Q_VLAN) {
+	if (is_vlan_dev(ndev)) {
 		vdev = ndev;
 		ndev = vlan_dev_real_dev(ndev);
 		pr_info("vlan dev %s -> %s.\n", vdev->name, ndev->name);
@@ -290,7 +290,7 @@ static struct cxgbi_device *cxgbi_device_find_by_mac(struct net_device *ndev,
 	struct cxgbi_device *cdev, *tmp;
 	int i;
 
-	if (ndev->priv_flags & IFF_802_1Q_VLAN) {
+	if (is_vlan_dev(ndev)) {
 		vdev = ndev;
 		ndev = vlan_dev_real_dev(ndev);
 		pr_info("vlan dev %s -> %s.\n", vdev->name, ndev->name);
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 59150ca..79160ff 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -326,8 +326,7 @@ static int fcoe_interface_setup(struct fcoe_interface *fcoe,
 
 	/* look for SAN MAC address, if multiple SAN MACs exist, only
 	 * use the first one for SPMA */
-	real_dev = (netdev->priv_flags & IFF_802_1Q_VLAN) ?
-		vlan_dev_real_dev(netdev) : netdev;
+	real_dev = is_vlan_dev(netdev) ? vlan_dev_real_dev(netdev) : netdev;
 	fcoe->realdev = real_dev;
 	rcu_read_lock();
 	for_each_dev_addr(real_dev, ha) {
@@ -730,7 +729,7 @@ static int fcoe_netdev_config(struct fc_lport *lport, struct net_device *netdev)
 	ctlr = fcoe_to_ctlr(fcoe);
 
 	/* Figure out the VLAN ID, if any */
-	if (netdev->priv_flags & IFF_802_1Q_VLAN)
+	if (is_vlan_dev(netdev))
 		lport->vlan = vlan_dev_vlan_id(netdev);
 	else
 		lport->vlan = 0;
@@ -959,13 +958,13 @@ static inline int fcoe_em_config(struct fc_lport *lport)
 	 * Reuse existing offload em instance in case
 	 * it is already allocated on real eth device
 	 */
-	if (fcoe->netdev->priv_flags & IFF_802_1Q_VLAN)
+	if (is_vlan_dev(fcoe->netdev))
 		cur_real_dev = vlan_dev_real_dev(fcoe->netdev);
 	else
 		cur_real_dev = fcoe->netdev;
 
 	list_for_each_entry(oldfcoe, &fcoe_hostlist, list) {
-		if (oldfcoe->netdev->priv_flags & IFF_802_1Q_VLAN)
+		if (is_vlan_dev(oldfcoe->netdev))
 			old_real_dev = vlan_dev_real_dev(oldfcoe->netdev);
 		else
 			old_real_dev = oldfcoe->netdev;
@@ -1563,7 +1562,7 @@ static int fcoe_xmit(struct fc_lport *lport, struct fc_frame *fp)
 	skb->protocol = htons(ETH_P_FCOE);
 	skb->priority = fcoe->priority;
 
-	if (fcoe->netdev->priv_flags & IFF_802_1Q_VLAN &&
+	if (is_vlan_dev(fcoe->netdev) &&
 	    fcoe->realdev->features & NETIF_F_HW_VLAN_CTAG_TX) {
 		/* must set skb->dev before calling vlan_put_tag */
 		skb->dev = fcoe->realdev;
@@ -1794,7 +1793,7 @@ static void fcoe_dev_cleanup(void)
 	struct net_device *real_dev;
 
 	list_for_each_entry(fcoe, &fcoe_hostlist, list) {
-		if (fcoe->netdev->priv_flags & IFF_802_1Q_VLAN)
+		if (is_vlan_dev(fcoe->netdev))
 			real_dev = vlan_dev_real_dev(fcoe->netdev);
 		else
 			real_dev = fcoe->netdev;
diff --git a/include/rdma/ib_addr.h b/include/rdma/ib_addr.h
index 1beab55..4b34c51 100644
--- a/include/rdma/ib_addr.h
+++ b/include/rdma/ib_addr.h
@@ -160,8 +160,7 @@ static inline int rdma_addr_gid_offset(struct rdma_dev_addr *dev_addr)
 
 static inline u16 rdma_vlan_dev_vlan_id(const struct net_device *dev)
 {
-	return dev->priv_flags & IFF_802_1Q_VLAN ?
-		vlan_dev_vlan_id(dev) : 0xffff;
+	return is_vlan_dev(dev) ? vlan_dev_vlan_id(dev) : 0xffff;
 }
 
 static inline int rdma_ip2gid(struct sockaddr *addr, union ib_gid *gid)
@@ -326,8 +325,7 @@ static inline u16 rdma_get_vlan_id(union ib_gid *dgid)
 
 static inline struct net_device *rdma_vlan_dev_real_dev(const struct net_device *dev)
 {
-	return dev->priv_flags & IFF_802_1Q_VLAN ?
-		vlan_dev_real_dev(dev) : NULL;
+	return is_vlan_dev(dev) ? vlan_dev_real_dev(dev) : NULL;
 }
 
 #endif /* IB_ADDR_H */
diff --git a/net/hsr/hsr_slave.c b/net/hsr/hsr_slave.c
index f5b6038..56080da 100644
--- a/net/hsr/hsr_slave.c
+++ b/net/hsr/hsr_slave.c
@@ -12,6 +12,7 @@
 #include "hsr_slave.h"
 #include <linux/etherdevice.h>
 #include <linux/if_arp.h>
+#include <linux/if_vlan.h>
 #include "hsr_main.h"
 #include "hsr_device.h"
 #include "hsr_forward.h"
@@ -81,7 +82,7 @@ static int hsr_check_dev_ok(struct net_device *dev)
 		return -EINVAL;
 	}
 
-	if (dev->priv_flags & IFF_802_1Q_VLAN) {
+	if (is_vlan_dev(dev)) {
 		netdev_info(dev, "HSR on top of VLAN is not yet supported in this driver.\n");
 		return -EINVAL;
 	}
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
