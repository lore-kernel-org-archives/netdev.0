From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] 8021q: make vlan_pcpu_stats visible without CONFIG_VLAN_8021Q
Date: Mon, 6 Jan 2014 01:41:20 +0100
Message-ID: <20140106004120.GA32217@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: roy.qing.li@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41019 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018AbaAFAlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 19:41:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macvlan needs vlan_pcpu_stats so make it visible even if compiling
without VLAN_8021Q support. Otherwise a very long compiler error happens.

Fixes: cdf3e274cf1b36 ("macvlan: unify macvlan_pcpu_stats and vlan_pcpu_stats")
Cc: Li RongQing <roy.qing.li@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/if_vlan.h | 38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index f252deb..bbedfb5 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -82,25 +82,6 @@ static inline int is_vlan_dev(struct net_device *dev)
 #define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESENT)
 #define vlan_tx_tag_get_id(__skb)	((__skb)->vlan_tci & VLAN_VID_MASK)
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-
-extern struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
-					       __be16 vlan_proto, u16 vlan_id);
-extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
-extern u16 vlan_dev_vlan_id(const struct net_device *dev);
-
-/**
- *	struct vlan_priority_tci_mapping - vlan egress priority mappings
- *	@priority: skb priority
- *	@vlan_qos: vlan priority: (skb->priority << 13) & 0xE000
- *	@next: pointer to next struct
- */
-struct vlan_priority_tci_mapping {
-	u32					priority;
-	u16					vlan_qos;
-	struct vlan_priority_tci_mapping	*next;
-};
-
 /**
  *	struct vlan_pcpu_stats - VLAN percpu rx/tx stats
  *	@rx_packets: number of received packets
@@ -123,6 +104,25 @@ struct vlan_pcpu_stats {
 	u32			tx_dropped;
 };
 
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+
+extern struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
+					       __be16 vlan_proto, u16 vlan_id);
+extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
+extern u16 vlan_dev_vlan_id(const struct net_device *dev);
+
+/**
+ *	struct vlan_priority_tci_mapping - vlan egress priority mappings
+ *	@priority: skb priority
+ *	@vlan_qos: vlan priority: (skb->priority << 13) & 0xE000
+ *	@next: pointer to next struct
+ */
+struct vlan_priority_tci_mapping {
+	u32					priority;
+	u16					vlan_qos;
+	struct vlan_priority_tci_mapping	*next;
+};
+
 struct proc_dir_entry;
 struct netpoll;
 
-- 
1.8.4.2
