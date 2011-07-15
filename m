From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 19/21] lro: unify vlan and nonvlan rx path
Date: Fri, 15 Jul 2011 23:33:37 +0200
Message-ID: <1310765619-27827-20-git-send-email-jpirko@redhat.com>
References: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753282Ab1GOVeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 17:34:21 -0400
In-Reply-To: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/ipv4/inet_lro.c |   21 ++++++---------------
 1 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index e54425d..775973b 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -310,21 +310,12 @@ static void lro_flush(struct net_lro_mgr *lro_mgr,
 	skb_shinfo(lro_desc->parent)->gso_size = lro_desc->mss;
 
 	if (lro_desc->vgrp) {
-		if (lro_mgr->features & LRO_F_NAPI)
-			vlan_hwaccel_receive_skb(lro_desc->parent,
-						 lro_desc->vgrp,
-						 lro_desc->vlan_tag);
-		else
-			vlan_hwaccel_rx(lro_desc->parent,
-					lro_desc->vgrp,
-					lro_desc->vlan_tag);
+		__vlan_hwaccel_put_tag(skb, lro_desc->vlan_tag);
 
-	} else {
-		if (lro_mgr->features & LRO_F_NAPI)
-			netif_receive_skb(lro_desc->parent);
-		else
-			netif_rx(lro_desc->parent);
-	}
+	if (lro_mgr->features & LRO_F_NAPI)
+		netif_receive_skb(lro_desc->parent);
+	else
+		netif_rx(lro_desc->parent);
 
 	LRO_INC_STATS(lro_mgr, flushed);
 	lro_clear_desc(lro_desc);
-- 
1.7.6

