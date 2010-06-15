From: kaber@trash.net
Subject: [PATCH 01/17] netfilter: br_netfilter: use skb_set_noref()
Date: Tue, 15 Jun 2010 17:38:27 +0200
Message-ID: <1276616323-20880-2-git-send-email-kaber@trash.net>
References: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276616323-20880-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

Avoid dirtying bridge_parent_rtable refcount, using new dst noref
infrastructure.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/bridge/br_netfilter.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 4442099..cbea5af 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -244,8 +244,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 		kfree_skb(skb);
 		return 0;
 	}
-	dst_hold(&rt->u.dst);
-	skb_dst_set(skb, &rt->u.dst);
+	skb_dst_set_noref(skb, &rt->u.dst);
 
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_update_protocol(skb);
@@ -396,8 +395,7 @@ bridged_dnat:
 			kfree_skb(skb);
 			return 0;
 		}
-		dst_hold(&rt->u.dst);
-		skb_dst_set(skb, &rt->u.dst);
+		skb_dst_set_noref(skb, &rt->u.dst);
 	}
 
 	skb->dev = nf_bridge->physindev;
-- 
1.7.0.4

