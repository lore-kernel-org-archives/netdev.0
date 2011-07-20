From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 06/47] lro: kill lro_vlan_hwaccel_receive_skb
Date: Wed, 20 Jul 2011 16:54:08 +0200
Message-ID: <1311173689-17419-7-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47326 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751656Ab1GTOzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:05 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

no longer used

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/inet_lro.h |   10 ----------
 net/ipv4/inet_lro.c      |   15 ---------------
 2 files changed, 0 insertions(+), 25 deletions(-)

diff --git a/include/linux/inet_lro.h b/include/linux/inet_lro.h
index c4335fa..940bbde 100644
--- a/include/linux/inet_lro.h
+++ b/include/linux/inet_lro.h
@@ -137,16 +137,6 @@ void lro_receive_skb(struct net_lro_mgr *lro_mgr,
 		     void *priv);
 
 /*
- * Processes a SKB with VLAN HW acceleration support
- */
-
-void lro_vlan_hwaccel_receive_skb(struct net_lro_mgr *lro_mgr,
-				  struct sk_buff *skb,
-				  struct vlan_group *vgrp,
-				  u16 vlan_tag,
-				  void *priv);
-
-/*
  * Processes a fragment list
  *
  * This functions aggregate fragments and generate SKBs do pass
diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index 85a0f75..e54425d 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -523,21 +523,6 @@ void lro_receive_skb(struct net_lro_mgr *lro_mgr,
 }
 EXPORT_SYMBOL(lro_receive_skb);
 
-void lro_vlan_hwaccel_receive_skb(struct net_lro_mgr *lro_mgr,
-				  struct sk_buff *skb,
-				  struct vlan_group *vgrp,
-				  u16 vlan_tag,
-				  void *priv)
-{
-	if (__lro_proc_skb(lro_mgr, skb, vgrp, vlan_tag, priv)) {
-		if (lro_mgr->features & LRO_F_NAPI)
-			vlan_hwaccel_receive_skb(skb, vgrp, vlan_tag);
-		else
-			vlan_hwaccel_rx(skb, vgrp, vlan_tag);
-	}
-}
-EXPORT_SYMBOL(lro_vlan_hwaccel_receive_skb);
-
 void lro_receive_frags(struct net_lro_mgr *lro_mgr,
 		       struct skb_frag_struct *frags,
 		       int len, int true_size, void *priv, __wsum sum)
-- 
1.7.6

