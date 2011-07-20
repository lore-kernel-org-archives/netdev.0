From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 34/47] vlan: kill __vlan_hwaccel_rx and vlan_hwaccel_rx
Date: Wed, 20 Jul 2011 16:54:36 +0200
Message-ID: <1311173689-17419-35-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36573 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752242Ab1GTOz7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:59 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/if_vlan.h |   22 ----------------------
 net/8021q/vlan_core.c   |    9 ---------
 2 files changed, 0 insertions(+), 31 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 3996713..d81bece 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -125,8 +125,6 @@ extern struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
 extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
-extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
-			     u16 vlan_tci, int polling);
 extern bool vlan_do_receive(struct sk_buff **skb);
 extern struct sk_buff *vlan_untag(struct sk_buff *skb);
 extern gro_result_t
@@ -155,13 +153,6 @@ static inline u16 vlan_dev_vlan_id(const struct net_device *dev)
 	return 0;
 }
 
-static inline int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
-				    u16 vlan_tci, int polling)
-{
-	BUG();
-	return NET_XMIT_SUCCESS;
-}
-
 static inline bool vlan_do_receive(struct sk_buff **skb)
 {
 	if ((*skb)->vlan_tci & VLAN_VID_MASK)
@@ -190,19 +181,6 @@ vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 #endif
 
 /**
- * vlan_hwaccel_rx - netif_rx wrapper for VLAN RX acceleration
- * @skb: buffer
- * @grp: vlan group
- * @vlan_tci: VLAN TCI as received from the card
- */
-static inline int vlan_hwaccel_rx(struct sk_buff *skb,
-				  struct vlan_group *grp,
-				  u16 vlan_tci)
-{
-	return __vlan_hwaccel_rx(skb, grp, vlan_tci, 0);
-}
-
-/**
  * vlan_insert_tag - regular VLAN tag inserting
  * @skb: skbuff to tag
  * @vlan_tci: VLAN TCI to insert
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 5940366..68b04ea 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -96,15 +96,6 @@ u16 vlan_dev_vlan_id(const struct net_device *dev)
 }
 EXPORT_SYMBOL(vlan_dev_vlan_id);
 
-/* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
-int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
-		      u16 vlan_tci, int polling)
-{
-	__vlan_hwaccel_put_tag(skb, vlan_tci);
-	return polling ? netif_receive_skb(skb) : netif_rx(skb);
-}
-EXPORT_SYMBOL(__vlan_hwaccel_rx);
-
 gro_result_t vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 			      unsigned int vlan_tci, struct sk_buff *skb)
 {
-- 
1.7.6

