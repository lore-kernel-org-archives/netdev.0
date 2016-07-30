From: fxp2001640163@gmail.com
Subject: [PATCH 3/3] netfilter: nat: don't assign a null snat rule to bridged traffic if no matching
Date: Sat, 30 Jul 2016 14:54:20 -0700
Message-ID: <1469915660-16904-1-git-send-email-xfan@codeaurora.org>
Cc: Xiaoping Fan <xfan@codeaurora.org>
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32963 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281AbcG3VyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 17:54:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xiaoping Fan <xfan@codeaurora.org>

In some case, bridged packet will come back again for routing. When bridge
netfilter is enabled, a null snat rule is assigned to bridged packet if no
matching in nat chain. Then nat rule matching is skipped when packet comes
back for routing. This result in private IP address exported to public
network. So we don't assign a null snat rule to bridged traffic if no
matching.

Signed-off-by: Xiaoping Fan <xfan@codeaurora.org>
---
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c | 3 +++
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
index 41c7992..151eee6 100644
--- a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
@@ -315,6 +315,9 @@ nf_nat_ipv4_fn(void *priv, struct sk_buff *skb,
 				break;
 			}
 
+			if (nf_nat_is_bridged_pkt(skb))
+				break;
+
 			ret = nf_nat_alloc_null_binding(ct, state->hook);
 			if (ret != NF_ACCEPT)
 				return ret;
diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index dc8df3a..c94eae4 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -324,6 +324,9 @@ nf_nat_ipv6_fn(void *priv, struct sk_buff *skb,
 				break;
 			}
 
+			if (nf_nat_is_bridged_pkt(skb))
+				break;
+
 			ret = nf_nat_alloc_null_binding(ct, state->hook);
 			if (ret != NF_ACCEPT)
 				return ret;
-- 
1.9.1
