From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 40/47] vlan: kill vlan_gro_frags and vlan_gro_receive
Date: Wed, 20 Jul 2011 16:54:42 +0200
Message-ID: <1311173689-17419-41-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47880 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752316Ab1GTO4K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:56:10 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/if_vlan.h |   20 --------------------
 net/8021q/vlan_core.c   |   16 ----------------
 2 files changed, 0 insertions(+), 36 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index d81bece..f40369e 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -127,12 +127,6 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
 extern bool vlan_do_receive(struct sk_buff **skb);
 extern struct sk_buff *vlan_untag(struct sk_buff *skb);
-extern gro_result_t
-vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
-		 unsigned int vlan_tci, struct sk_buff *skb);
-extern gro_result_t
-vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
-	       unsigned int vlan_tci);
 
 #else
 static inline struct net_device *
@@ -164,20 +158,6 @@ static inline struct sk_buff *vlan_untag(struct sk_buff *skb)
 {
 	return skb;
 }
-
-static inline gro_result_t
-vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
-		 unsigned int vlan_tci, struct sk_buff *skb)
-{
-	return GRO_DROP;
-}
-
-static inline gro_result_t
-vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
-	       unsigned int vlan_tci)
-{
-	return GRO_DROP;
-}
 #endif
 
 /**
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 68b04ea..5f27f8e 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -96,22 +96,6 @@ u16 vlan_dev_vlan_id(const struct net_device *dev)
 }
 EXPORT_SYMBOL(vlan_dev_vlan_id);
 
-gro_result_t vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
-			      unsigned int vlan_tci, struct sk_buff *skb)
-{
-	__vlan_hwaccel_put_tag(skb, vlan_tci);
-	return napi_gro_receive(napi, skb);
-}
-EXPORT_SYMBOL(vlan_gro_receive);
-
-gro_result_t vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
-			    unsigned int vlan_tci)
-{
-	__vlan_hwaccel_put_tag(napi->skb, vlan_tci);
-	return napi_gro_frags(napi);
-}
-EXPORT_SYMBOL(vlan_gro_frags);
-
 static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
 {
 	if (skb_cow(skb, skb_headroom(skb)) < 0)
-- 
1.7.6

