From: kaber@trash.net
Subject: [PATCH 13/17] netfilter: kill redundant check code in which setting ip_summed value
Date: Tue, 15 Jun 2010 17:38:39 +0200
Message-ID: <1276616323-20880-14-git-send-email-kaber@trash.net>
References: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42187 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932281Ab0FOP34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 11:29:56 -0400
In-Reply-To: <1276616323-20880-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>

If the returned csum value is 0, We has set ip_summed with
CHECKSUM_UNNECESSARY flag in __skb_checksum_complete_head().

So this patch kills the check and changes to return to upper
caller directly.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter.c |    4 +---
 net/ipv6/netfilter.c |    4 +---
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 07de855..acd1ea8 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -212,9 +212,7 @@ static __sum16 nf_ip_checksum_partial(struct sk_buff *skb, unsigned int hook,
 		skb->csum = csum_tcpudp_nofold(iph->saddr, iph->daddr, protocol,
 					       skb->len - dataoff, 0);
 		skb->ip_summed = CHECKSUM_NONE;
-		csum = __skb_checksum_complete_head(skb, dataoff + len);
-		if (!csum)
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		return __skb_checksum_complete_head(skb, dataoff + len);
 	}
 	return csum;
 }
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index a74951c..7155b24 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -151,9 +151,7 @@ static __sum16 nf_ip6_checksum_partial(struct sk_buff *skb, unsigned int hook,
 							 protocol,
 							 csum_sub(0, hsum)));
 		skb->ip_summed = CHECKSUM_NONE;
-		csum = __skb_checksum_complete_head(skb, dataoff + len);
-		if (!csum)
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		return __skb_checksum_complete_head(skb, dataoff + len);
 	}
 	return csum;
 };
-- 
1.7.0.4

