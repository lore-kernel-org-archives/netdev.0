From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 4/4] ipv6: stop multicast forwarding to process reserved/interface/link scoped addresses
Date: Sat, 16 Feb 2013 20:10:21 +0100
Message-ID: <20130216191021.GA23403@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yoshfuji@linux-ipv6.org, brian.haley@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39315 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037Ab3BPTKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 14:10:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2:
a) unchanged

Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: Brian Haley <brian.haley@hp.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 5b10414..974ba8b 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -279,7 +279,7 @@ int ip6_mc_input(struct sk_buff *skb)
 	 *      IPv6 multicast router mode is now supported ;)
 	 */
 	if (dev_net(skb->dev)->ipv6.devconf_all->mc_forwarding &&
-	    !(ipv6_addr_type(&hdr->daddr) & IPV6_ADDR_LINKLOCAL) &&
+	    !__ipv6_addr_needs_scope_id(__ipv6_addr_props(&hdr->daddr)) &&
 	    likely(!(IP6CB(skb)->flags & IP6SKB_FORWARDED))) {
 		/*
 		 * Okay, we try to forward - split and duplicate
-- 
1.8.1.2
