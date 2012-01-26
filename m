From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4/ipv6: Prepare for new route gateway semantics.
Date: Thu, 26 Jan 2012 16:29:44 -0500 (EST)
Message-ID: <20120126.162944.519956918126453122.davem@davemloft.net>
References: <20120126.155544.2054995753871805122.davem@davemloft.net>
	<4F21C482.4070707@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34736 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600Ab2AZVas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 16:30:48 -0500
In-Reply-To: <4F21C482.4070707@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 27 Jan 2012 06:24:18 +0900

> Why not use ipv6_addr_any()?

Yep, makes sense:

--------------------
ipv6: Use ipv6_addr_any()

Suggested by YOSHIFUJI Hideaki.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/route.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7d7f306..92be12b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -125,8 +125,7 @@ static inline const void *choose_neigh_daddr(struct rt6_info *rt, const void *da
 {
 	struct in6_addr *p = &rt->rt6i_gateway;
 
-	if (p->s6_addr32[0] | p->s6_addr32[1] |
-	    p->s6_addr32[2] | p->s6_addr32[3])
+	if (!ipv6_addr_any(p))
 		return (const void *) p;
 	return daddr;
 }
-- 
1.7.7.6
