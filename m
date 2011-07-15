From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 20/21] lro: kill lro_vlan_hwaccel_receive_frags
Date: Fri, 15 Jul 2011 23:33:38 +0200
Message-ID: <1310765619-27827-21-git-send-email-jpirko@redhat.com>
References: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32334 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753444Ab1GOVeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 17:34:21 -0400
In-Reply-To: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/inet_lro.h |    7 -------
 net/ipv4/inet_lro.c      |   20 --------------------
 2 files changed, 0 insertions(+), 27 deletions(-)

diff --git a/include/linux/inet_lro.h b/include/linux/inet_lro.h
index 940bbde..b27e773 100644
--- a/include/linux/inet_lro.h
+++ b/include/linux/inet_lro.h
@@ -155,13 +155,6 @@ void lro_receive_frags(struct net_lro_mgr *lro_mgr,
 		       struct skb_frag_struct *frags,
 		       int len, int true_size, void *priv, __wsum sum);
 
-void lro_vlan_hwaccel_receive_frags(struct net_lro_mgr *lro_mgr,
-				    struct skb_frag_struct *frags,
-				    int len, int true_size,
-				    struct vlan_group *vgrp,
-				    u16 vlan_tag,
-				    void *priv, __wsum sum);
-
 /*
  * Forward all aggregated SKBs held by lro_mgr to network stack
  */
diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index 775973b..fd45127 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -532,26 +532,6 @@ void lro_receive_frags(struct net_lro_mgr *lro_mgr,
 }
 EXPORT_SYMBOL(lro_receive_frags);
 
-void lro_vlan_hwaccel_receive_frags(struct net_lro_mgr *lro_mgr,
-				    struct skb_frag_struct *frags,
-				    int len, int true_size,
-				    struct vlan_group *vgrp,
-				    u16 vlan_tag, void *priv, __wsum sum)
-{
-	struct sk_buff *skb;
-
-	skb = __lro_proc_segment(lro_mgr, frags, len, true_size, vgrp,
-				 vlan_tag, priv, sum);
-	if (!skb)
-		return;
-
-	if (lro_mgr->features & LRO_F_NAPI)
-		vlan_hwaccel_receive_skb(skb, vgrp, vlan_tag);
-	else
-		vlan_hwaccel_rx(skb, vgrp, vlan_tag);
-}
-EXPORT_SYMBOL(lro_vlan_hwaccel_receive_frags);
-
 void lro_flush_all(struct net_lro_mgr *lro_mgr)
 {
 	int i;
-- 
1.7.6

