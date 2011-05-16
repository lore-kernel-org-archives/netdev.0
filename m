From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Trivial rt->rt_src conversions in net/ipv4/route.c
Date: Mon, 16 May 2011 13:52:09 -0400 (EDT)
Message-ID: <20110516.135209.1461836387190998351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562Ab1EPRwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 13:52:12 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4GHqAt1019373
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 16 May 2011 10:52:11 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


At these points we have a fully filled in value via the IP
header the form of ip_hdr(skb)->saddr

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ad141d8..cb93c32 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1435,7 +1435,7 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 		    peer->rate_tokens == ip_rt_redirect_number &&
 		    net_ratelimit())
 			printk(KERN_WARNING "host %pI4/if%d ignores redirects for %pI4 to %pI4.\n",
-				&rt->rt_src, rt->rt_iif,
+			       &ip_hdr(skb)->saddr, rt->rt_iif,
 				&rt->rt_dst, &rt->rt_gateway);
 #endif
 	}
@@ -1704,7 +1704,7 @@ void ip_rt_get_source(u8 *addr, struct sk_buff *skb, struct rtable *rt)
 	__be32 src;
 
 	if (rt_is_output_route(rt))
-		src = rt->rt_src;
+		src = ip_hdr(skb)->saddr;
 	else {
 		struct fib_result res;
 		struct flowi4 fl4;
-- 
1.7.4.4

