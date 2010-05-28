From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] xt_tee: use skb_dst_drop()
Date: Fri, 28 May 2010 11:24:58 +0200
Message-ID: <1275038698.2650.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38105 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893Ab0E1JZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 05:25:01 -0400
Received: by fxm10 with SMTP id 10so549731fxm.19
        for <netdev@vger.kernel.org>; Fri, 28 May 2010 02:25:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 7fee226a (net: add a noref bit on skb dst), its wrong to
use : dst_release(skb_dst(skb)), since we could decrement a refcount
while skb dst was not refcounted.

We should use skb_dst_drop(skb) instead.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/netfilter/xt_TEE.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index d7920d9..859d9fd 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -76,7 +76,7 @@ tee_tg_route4(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 	if (ip_route_output_key(net, &rt, &fl) != 0)
 		return false;
 
-	dst_release(skb_dst(skb));
+	skb_dst_drop(skb);
 	skb_dst_set(skb, &rt->u.dst);
 	skb->dev      = rt->u.dst.dev;
 	skb->protocol = htons(ETH_P_IP);
@@ -157,7 +157,7 @@ tee_tg_route6(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 	if (dst == NULL)
 		return false;
 
-	dst_release(skb_dst(skb));
+	skb_dst_drop(skb);
 	skb_dst_set(skb, dst);
 	skb->dev      = dst->dev;
 	skb->protocol = htons(ETH_P_IPV6);


