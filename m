From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH v2 02/14] vlan: Rename VLAN_GROUP_ARRAY_LEN to VLAN_N_VID.
Date: Wed, 20 Oct 2010 16:56:02 -0700
Message-ID: <1287618974-4714-3-git-send-email-jesse@nicira.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:34344 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022Ab0JTX4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 19:56:24 -0400
Received: by mail-vw0-f46.google.com with SMTP id 2so2600261vws.19
        for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 16:56:23 -0700 (PDT)
In-Reply-To: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VLAN_GROUP_ARRAY_LEN is simply the number of possible vlan VIDs.
Since vlan groups will soon be more of an implementation detail
for vlan devices, rename the constant to be descriptive of its
actual purpose.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 drivers/net/benet/be.h             |    2 +-
 drivers/net/benet/be_main.c        |    2 +-
 drivers/net/e1000/e1000_main.c     |    2 +-
 drivers/net/e1000e/netdev.c        |    2 +-
 drivers/net/igb/igb_main.c         |    2 +-
 drivers/net/igbvf/netdev.c         |    2 +-
 drivers/net/ixgb/ixgb_main.c       |    2 +-
 drivers/net/ixgbe/ixgbe_main.c     |    2 +-
 drivers/net/ixgbevf/ixgbevf_main.c |    2 +-
 drivers/net/qlcnic/qlcnic_main.c   |    2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c  |    2 +-
 drivers/net/vxge/vxge-main.c       |    2 +-
 drivers/s390/net/qeth_l3_main.c    |    6 +++---
 include/linux/if_vlan.h            |    4 ++--
 net/8021q/vlan.c                   |   16 ++++++++--------
 net/bridge/netfilter/ebt_vlan.c    |    4 ++--
 16 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 1afabb1..59a17b5 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -263,7 +263,7 @@ struct be_adapter {
 	struct vlan_group *vlan_grp;
 	u16 vlans_added;
 	u16 max_vlans;	/* Number of vlans supported */
-	u8 vlan_tag[VLAN_GROUP_ARRAY_LEN];
+	u8 vlan_tag[VLAN_N_VID];
 	struct be_dma_mem mc_cmd_mem;
 
 	struct be_dma_mem stats_cmd;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 9a1cd28..4b59e53 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -626,7 +626,7 @@ static int be_vid_config(struct be_adapter *adapter, bool vf, u32 vf_num)
 
 	if (adapter->vlans_added <= adapter->max_vlans)  {
 		/* Construct VLAN Table to give to HW */
-		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+		for (i = 0; i < VLAN_N_VID; i++) {
 			if (adapter->vlan_tag[i]) {
 				vtag[ntags] = cpu_to_le16(i);
 				ntags++;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index cb3f84b..232ac2d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4541,7 +4541,7 @@ static void e1000_restore_vlan(struct e1000_adapter *adapter)
 
 	if (adapter->vlgrp) {
 		u16 vid;
-		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+		for (vid = 0; vid < VLAN_N_VID; vid++) {
 			if (!vlan_group_get_device(adapter->vlgrp, vid))
 				continue;
 			e1000_vlan_rx_add_vid(adapter->netdev, vid);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 992b622..5d6cdea 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2545,7 +2545,7 @@ static void e1000_restore_vlan(struct e1000_adapter *adapter)
 	if (!adapter->vlgrp)
 		return;
 
-	for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+	for (vid = 0; vid < VLAN_N_VID; vid++) {
 		if (!vlan_group_get_device(adapter->vlgrp, vid))
 			continue;
 		e1000_vlan_rx_add_vid(adapter->netdev, vid);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index b8dccc0..0f0939c 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -6153,7 +6153,7 @@ static void igb_restore_vlan(struct igb_adapter *adapter)
 
 	if (adapter->vlgrp) {
 		u16 vid;
-		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+		for (vid = 0; vid < VLAN_N_VID; vid++) {
 			if (!vlan_group_get_device(adapter->vlgrp, vid))
 				continue;
 			igb_vlan_rx_add_vid(adapter->netdev, vid);
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 6693323..ebfaa68 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -1254,7 +1254,7 @@ static void igbvf_restore_vlan(struct igbvf_adapter *adapter)
 	if (!adapter->vlgrp)
 		return;
 
-	for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+	for (vid = 0; vid < VLAN_N_VID; vid++) {
 		if (!vlan_group_get_device(adapter->vlgrp, vid))
 			continue;
 		igbvf_vlan_rx_add_vid(adapter->netdev, vid);
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 80e6257..666207a 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -2223,7 +2223,7 @@ ixgb_restore_vlan(struct ixgb_adapter *adapter)
 
 	if (adapter->vlgrp) {
 		u16 vid;
-		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+		for (vid = 0; vid < VLAN_N_VID; vid++) {
 			if (!vlan_group_get_device(adapter->vlgrp, vid))
 				continue;
 			ixgb_vlan_rx_add_vid(adapter->netdev, vid);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 790a0da..1d42442 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3185,7 +3185,7 @@ static void ixgbe_restore_vlan(struct ixgbe_adapter *adapter)
 
 	if (adapter->vlgrp) {
 		u16 vid;
-		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+		for (vid = 0; vid < VLAN_N_VID; vid++) {
 			if (!vlan_group_get_device(adapter->vlgrp, vid))
 				continue;
 			ixgbe_vlan_rx_add_vid(adapter->netdev, vid);
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 0866a1c..78bfbe4 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -1495,7 +1495,7 @@ static void ixgbevf_restore_vlan(struct ixgbevf_adapter *adapter)
 
 	if (adapter->vlgrp) {
 		u16 vid;
-		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+		for (vid = 0; vid < VLAN_N_VID; vid++) {
 			if (!vlan_group_get_device(adapter->vlgrp, vid))
 				continue;
 			ixgbevf_vlan_rx_add_vid(adapter->netdev, vid);
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 4aada0b..f047c7c 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -4093,7 +4093,7 @@ qlcnic_restore_indev_addr(struct net_device *netdev, unsigned long event)
 	if (!adapter->vlgrp)
 		return;
 
-	for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+	for (vid = 0; vid < VLAN_N_VID; vid++) {
 		dev = vlan_group_get_device(adapter->vlgrp, vid);
 		if (!dev)
 			continue;
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 198ce92..b1de73b 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1634,7 +1634,7 @@ vmxnet3_restore_vlan(struct vmxnet3_adapter *adapter)
 		u32 *vfTable = adapter->shared->devRead.rxFilterConf.vfTable;
 		bool activeVlan = false;
 
-		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+		for (vid = 0; vid < VLAN_N_VID; vid++) {
 			if (vlan_group_get_device(adapter->vlan_grp, vid)) {
 				VMXNET3_SET_VFTABLE_ENTRY(vfTable, vid);
 				activeVlan = true;
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 5378b84..0bda7fe 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -1862,7 +1862,7 @@ enum vxge_hw_status vxge_restore_vpath_vid_table(struct vxge_vpath *vpath)
 
 	if (vdev->vlgrp && vpath->is_open) {
 
-		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+		for (vid = 0; vid < VLAN_N_VID; vid++) {
 			if (!vlan_group_get_device(vdev->vlgrp, vid))
 				continue;
 			/* Add these vlan to the vid table */
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index c094707..74d1401 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1820,7 +1820,7 @@ static void qeth_l3_add_vlan_mc(struct qeth_card *card)
 		return;
 
 	vg = card->vlangrp;
-	for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+	for (i = 0; i < VLAN_N_VID; i++) {
 		struct net_device *netdev = vlan_group_get_device(vg, i);
 		if (netdev == NULL ||
 		    !(netdev->flags & IFF_UP))
@@ -1883,7 +1883,7 @@ static void qeth_l3_add_vlan_mc6(struct qeth_card *card)
 		return;
 
 	vg = card->vlangrp;
-	for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+	for (i = 0; i < VLAN_N_VID; i++) {
 		struct net_device *netdev = vlan_group_get_device(vg, i);
 		if (netdev == NULL ||
 		    !(netdev->flags & IFF_UP))
@@ -2247,7 +2247,7 @@ static int qeth_l3_verify_vlan_dev(struct net_device *dev,
 	if (!vg)
 		return rc;
 
-	for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+	for (i = 0; i < VLAN_N_VID; i++) {
 		if (vlan_group_get_device(vg, i) == dev) {
 			rc = QETH_VLAN_CARD;
 			break;
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index a523207..494cce8 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -68,6 +68,7 @@ static inline struct vlan_ethhdr *vlan_eth_hdr(const struct sk_buff *skb)
 #define VLAN_CFI_MASK		0x1000 /* Canonical Format Indicator */
 #define VLAN_TAG_PRESENT	VLAN_CFI_MASK
 #define VLAN_VID_MASK		0x0fff /* VLAN Identifier */
+#define VLAN_N_VID		4096
 
 /* found in socket.c */
 extern void vlan_ioctl_set(int (*hook)(struct net *, void __user *));
@@ -76,9 +77,8 @@ extern void vlan_ioctl_set(int (*hook)(struct net *, void __user *));
  * depends on completely exhausting the VLAN identifier space.  Thus
  * it gives constant time look-up, but in many cases it wastes memory.
  */
-#define VLAN_GROUP_ARRAY_LEN          4096
 #define VLAN_GROUP_ARRAY_SPLIT_PARTS  8
-#define VLAN_GROUP_ARRAY_PART_LEN     (VLAN_GROUP_ARRAY_LEN/VLAN_GROUP_ARRAY_SPLIT_PARTS)
+#define VLAN_GROUP_ARRAY_PART_LEN     (VLAN_N_VID/VLAN_GROUP_ARRAY_SPLIT_PARTS)
 
 struct vlan_group {
 	struct net_device	*real_dev; /* The ethernet(like) device
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 25c2133..54f22d8 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -439,7 +439,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	switch (event) {
 	case NETDEV_CHANGE:
 		/* Propagate real device state to vlan devices */
-		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+		for (i = 0; i < VLAN_N_VID; i++) {
 			vlandev = vlan_group_get_device(grp, i);
 			if (!vlandev)
 				continue;
@@ -450,7 +450,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 	case NETDEV_CHANGEADDR:
 		/* Adjust unicast filters on underlying device */
-		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+		for (i = 0; i < VLAN_N_VID; i++) {
 			vlandev = vlan_group_get_device(grp, i);
 			if (!vlandev)
 				continue;
@@ -464,7 +464,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		break;
 
 	case NETDEV_CHANGEMTU:
-		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+		for (i = 0; i < VLAN_N_VID; i++) {
 			vlandev = vlan_group_get_device(grp, i);
 			if (!vlandev)
 				continue;
@@ -478,7 +478,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 	case NETDEV_FEAT_CHANGE:
 		/* Propagate device features to underlying device */
-		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+		for (i = 0; i < VLAN_N_VID; i++) {
 			vlandev = vlan_group_get_device(grp, i);
 			if (!vlandev)
 				continue;
@@ -490,7 +490,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 	case NETDEV_DOWN:
 		/* Put all VLANs for this dev in the down state too.  */
-		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+		for (i = 0; i < VLAN_N_VID; i++) {
 			vlandev = vlan_group_get_device(grp, i);
 			if (!vlandev)
 				continue;
@@ -508,7 +508,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 	case NETDEV_UP:
 		/* Put all VLANs for this dev in the up state too.  */
-		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+		for (i = 0; i < VLAN_N_VID; i++) {
 			vlandev = vlan_group_get_device(grp, i);
 			if (!vlandev)
 				continue;
@@ -532,7 +532,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		/* Delete all VLANs for this dev. */
 		grp->killall = 1;
 
-		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+		for (i = 0; i < VLAN_N_VID; i++) {
 			vlandev = vlan_group_get_device(grp, i);
 			if (!vlandev)
 				continue;
@@ -540,7 +540,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			/* unregistration of last vlan destroys group, abort
 			 * afterwards */
 			if (grp->nr_vlans == 1)
-				i = VLAN_GROUP_ARRAY_LEN;
+				i = VLAN_N_VID;
 
 			unregister_vlan_dev(vlandev, &list);
 		}
diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
index cc11d6b..eae67bf 100644
--- a/net/bridge/netfilter/ebt_vlan.c
+++ b/net/bridge/netfilter/ebt_vlan.c
@@ -118,10 +118,10 @@ static int ebt_vlan_mt_check(const struct xt_mtchk_param *par)
 	 * 0 - The null VLAN ID.
 	 * 1 - The default Port VID (PVID)
 	 * 0x0FFF - Reserved for implementation use.
-	 * if_vlan.h: VLAN_GROUP_ARRAY_LEN 4096. */
+	 * if_vlan.h: VLAN_N_VID 4096. */
 	if (GET_BITMASK(EBT_VLAN_ID)) {
 		if (!!info->id) { /* if id!=0 => check vid range */
-			if (info->id > VLAN_GROUP_ARRAY_LEN) {
+			if (info->id > VLAN_N_VID) {
 				pr_debug("id %d is out of range (1-4096)\n",
 					 info->id);
 				return -EINVAL;
-- 
1.7.1

