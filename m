From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] br_netfilter: use skb_set_noref()
Date: Mon, 31 May 2010 23:23:13 +0200
Message-ID: <1275340993.2478.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:57837 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973Ab0EaVXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 17:23:17 -0400
Received: by wwb28 with SMTP id 28so1551095wwb.19
        for <netdev@vger.kernel.org>; Mon, 31 May 2010 14:23:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid dirtying bridge_parent_rtable refcount, using new dst noref
infrastructure.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
net/bridge/br_netfilter.c |    6 ++----
1 file changed, 2 insertions(+), 4 deletions(-)

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



