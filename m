From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Kill useless route tracing bits in net/ipv6/route.c
Date: Mon, 26 Dec 2011 15:25:13 -0500 (EST)
Message-ID: <20111226.152513.1781669230677259196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066Ab1LZUZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 15:25:15 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pBQKPDAO015255
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 12:25:14 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


RDBG() wasn't even used, and the messages printed by RT6_DEBUG() were
far from useful.  Just get rid of all this stuff, we can replace it
with something more suitable if we want.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

There's some similar garbage in ip6_fib.c, but one thing at a time...

 net/ipv6/route.c |   22 ++--------------------
 1 files changed, 2 insertions(+), 20 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5855e9e..35b07cc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -62,17 +62,6 @@
 #include <linux/sysctl.h>
 #endif
 
-/* Set to 3 to get tracing. */
-#define RT6_DEBUG 2
-
-#if RT6_DEBUG >= 3
-#define RDBG(x) printk x
-#define RT6_TRACE(x...) printk(KERN_DEBUG x)
-#else
-#define RDBG(x)
-#define RT6_TRACE(x...) do { ; } while (0)
-#endif
-
 static struct rt6_info *ip6_rt_copy(const struct rt6_info *ort,
 				    const struct in6_addr *dest);
 static struct dst_entry	*ip6_dst_check(struct dst_entry *dst, u32 cookie);
@@ -518,9 +507,6 @@ static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
 	struct rt6_info *match, *rt0;
 	struct net *net;
 
-	RT6_TRACE("%s(fn->leaf=%p, oif=%d)\n",
-		  __func__, fn->leaf, oif);
-
 	rt0 = fn->rr_ptr;
 	if (!rt0)
 		fn->rr_ptr = rt0 = fn->leaf;
@@ -539,9 +525,6 @@ static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
 			fn->rr_ptr = next;
 	}
 
-	RT6_TRACE("%s() => %p\n",
-		  __func__, match);
-
 	net = dev_net(rt0->rt6i_dev);
 	return match ? match : net->ipv6.ip6_null_entry;
 }
@@ -2173,10 +2156,9 @@ static int fib6_ifdown(struct rt6_info *rt, void *arg)
 	const struct net_device *dev = adn->dev;
 
 	if ((rt->rt6i_dev == dev || !dev) &&
-	    rt != adn->net->ipv6.ip6_null_entry) {
-		RT6_TRACE("deleted by ifdown %p\n", rt);
+	    rt != adn->net->ipv6.ip6_null_entry)
 		return -1;
-	}
+
 	return 0;
 }
 
-- 
1.7.7.4
