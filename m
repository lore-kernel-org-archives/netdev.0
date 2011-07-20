From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 47/47] vlan: move vlan_group_[gs]et_device to public header
Date: Wed, 20 Jul 2011 16:54:49 +0200
Message-ID: <1311173689-17419-48-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48255 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752397Ab1GTO4U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:56:20 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

there are no users outside vlan code

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/if_vlan.h |   19 -------------------
 net/8021q/vlan.h        |   19 +++++++++++++++++++
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index f40369e..44da482 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -91,25 +91,6 @@ struct vlan_group {
 	struct rcu_head		rcu;
 };
 
-static inline struct net_device *vlan_group_get_device(struct vlan_group *vg,
-						       u16 vlan_id)
-{
-	struct net_device **array;
-	array = vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
-	return array ? array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] : NULL;
-}
-
-static inline void vlan_group_set_device(struct vlan_group *vg,
-					 u16 vlan_id,
-					 struct net_device *dev)
-{
-	struct net_device **array;
-	if (!vg)
-		return;
-	array = vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
-	array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] = dev;
-}
-
 static inline int is_vlan_dev(struct net_device *dev)
 {
         return dev->priv_flags & IFF_802_1Q_VLAN;
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index b132f54..9fd45f3 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -74,6 +74,25 @@ static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
 	return netdev_priv(dev);
 }
 
+static inline struct net_device *vlan_group_get_device(struct vlan_group *vg,
+						       u16 vlan_id)
+{
+	struct net_device **array;
+	array = vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
+	return array ? array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] : NULL;
+}
+
+static inline void vlan_group_set_device(struct vlan_group *vg,
+					 u16 vlan_id,
+					 struct net_device *dev)
+{
+	struct net_device **array;
+	if (!vg)
+		return;
+	array = vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
+	array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] = dev;
+}
+
 /* Must be invoked with rcu_read_lock or with RTNL. */
 static inline struct net_device *vlan_find_dev(struct net_device *real_dev,
 					       u16 vlan_id)
-- 
1.7.6

