From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: consistent use of IP6_INC_STATS_BH() in
 ip6_forward()
Date: Thu, 05 Dec 2013 21:38:06 -0800
Message-ID: <1386308286.30495.227.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:64708 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752Ab3LFFiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 00:38:08 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so420919pbc.24
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 21:38:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ip6_forward() runs from softirq context, we can use the SNMP macros
assuming this.

Use same indentation for all IP6_INC_STATS_BH() calls.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_output.c |   25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 59df872e2f4d..5f70f88baa52 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -336,7 +336,8 @@ int ip6_forward(struct sk_buff *skb)
 		goto drop;
 
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_FWD, skb)) {
-		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_INDISCARDS);
+		IP6_INC_STATS_BH(net, ip6_dst_idev(dst),
+				 IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -370,8 +371,8 @@ int ip6_forward(struct sk_buff *skb)
 		/* Force OUTPUT device used as source address */
 		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT, 0);
-		IP6_INC_STATS_BH(net,
-				 ip6_dst_idev(dst), IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS_BH(net, ip6_dst_idev(dst),
+				 IPSTATS_MIB_INHDRERRORS);
 
 		kfree_skb(skb);
 		return -ETIMEDOUT;
@@ -384,14 +385,15 @@ int ip6_forward(struct sk_buff *skb)
 		if (proxied > 0)
 			return ip6_input(skb);
 		else if (proxied < 0) {
-			IP6_INC_STATS(net, ip6_dst_idev(dst),
-				      IPSTATS_MIB_INDISCARDS);
+			IP6_INC_STATS_BH(net, ip6_dst_idev(dst),
+					 IPSTATS_MIB_INDISCARDS);
 			goto drop;
 		}
 	}
 
 	if (!xfrm6_route_forward(skb)) {
-		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_INDISCARDS);
+		IP6_INC_STATS_BH(net, ip6_dst_idev(dst),
+				 IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 	dst = skb_dst(skb);
@@ -448,16 +450,17 @@ int ip6_forward(struct sk_buff *skb)
 		/* Again, force OUTPUT device used as source address */
 		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		IP6_INC_STATS_BH(net,
-				 ip6_dst_idev(dst), IPSTATS_MIB_INTOOBIGERRORS);
-		IP6_INC_STATS_BH(net,
-				 ip6_dst_idev(dst), IPSTATS_MIB_FRAGFAILS);
+		IP6_INC_STATS_BH(net, ip6_dst_idev(dst),
+				 IPSTATS_MIB_INTOOBIGERRORS);
+		IP6_INC_STATS_BH(net, ip6_dst_idev(dst),
+				 IPSTATS_MIB_FRAGFAILS);
 		kfree_skb(skb);
 		return -EMSGSIZE;
 	}
 
 	if (skb_cow(skb, dst->dev->hard_header_len)) {
-		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTDISCARDS);
+		IP6_INC_STATS_BH(net, ip6_dst_idev(dst),
+				 IPSTATS_MIB_OUTDISCARDS);
 		goto drop;
 	}
 
