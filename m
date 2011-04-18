From: David Miller <davem@davemloft.net>
Subject: [PATCH 40/42] netfilter: ip6table_mangle: Fix set-but-unused
 variables.
Date: Sun, 17 Apr 2011 17:34:28 -0700 (PDT)
Message-ID: <20110417.173428.57473481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51105
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754214Ab1DRAfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:35:03 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id CBBA824C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:34:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'flowlabel' is set but unused in ip6t_mangle_out().

The intention here was to compare this key to the header value after
mangling, and trigger a route lookup on mismatch.

Make it so.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/netfilter/ip6table_mangle.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index 679a0a3..00d1917 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -64,7 +64,8 @@ ip6t_mangle_out(struct sk_buff *skb, const struct net_device *out)
 	    (memcmp(&ipv6_hdr(skb)->saddr, &saddr, sizeof(saddr)) ||
 	     memcmp(&ipv6_hdr(skb)->daddr, &daddr, sizeof(daddr)) ||
 	     skb->mark != mark ||
-	     ipv6_hdr(skb)->hop_limit != hop_limit))
+	     ipv6_hdr(skb)->hop_limit != hop_limit ||
+	     flowlabel != *((u_int32_t *)ipv6_hdr(skb))))
 		return ip6_route_me_harder(skb) == 0 ? ret : NF_DROP;
 
 	return ret;
-- 
1.7.4.3

