From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 1/3] vlan: make a new function vlan_dev_vlan_proto() and export
Date: Thu, 20 Mar 2014 16:15:33 +0800
Message-ID: <1395303335-10088-2-git-send-email-dingtianhong@huawei.com>
References: <1395303335-10088-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<joe@perches.com>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:13775 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883AbaCTIRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 04:17:05 -0400
In-Reply-To: <1395303335-10088-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vlan support 2 proto: 802.1q and 802.1ad, so make a new function
called vlan_dev_vlan_proto() which could return the vlan proto for
input dev.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 include/linux/if_vlan.h | 7 +++++++
 net/8021q/vlan_core.c   | 6 ++++++
 2 files changed, 13 insertions(+)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index bbedfb5..967a428 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -110,6 +110,7 @@ extern struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
 					       __be16 vlan_proto, u16 vlan_id);
 extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
+extern __be16 vlan_dev_vlan_proto(const struct net_device *dev);
 
 /**
  *	struct vlan_priority_tci_mapping - vlan egress priority mappings
@@ -216,6 +217,12 @@ static inline u16 vlan_dev_vlan_id(const struct net_device *dev)
 	return 0;
 }
 
+static inline __be16 vlan_dev_vlan_proto(const struct net_device *dev)
+{
+	BUG();
+	return 0;
+}
+
 static inline u16 vlan_dev_get_egress_qos_mask(struct net_device *dev,
 					       u32 skprio)
 {
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 35b3c19..3c32bd2 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -106,6 +106,12 @@ u16 vlan_dev_vlan_id(const struct net_device *dev)
 }
 EXPORT_SYMBOL(vlan_dev_vlan_id);
 
+__be16 vlan_dev_vlan_proto(const struct net_device *dev)
+{
+	return vlan_dev_priv(dev)->vlan_proto;
+}
+EXPORT_SYMBOL(vlan_dev_vlan_proto);
+
 static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
 {
 	if (skb_cow(skb, skb_headroom(skb)) < 0)
-- 
1.8.0
