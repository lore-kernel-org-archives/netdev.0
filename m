From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 3/6] ipv6: use DST_* macro to set obselete field
Date: Fri, 19 Oct 2012 15:21:44 -0400
Message-ID: <20121019192144.GC8315@kvack.org>
References: <20121019191347.GD13515@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:43176 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757094Ab2JSTVq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 15:21:46 -0400
Content-Disposition: inline
In-Reply-To: <20121019191347.GD13515@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 2c20cbd7e3aa6e9dddc07975d3f3a89fe1f69c00
Author: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date:   Mon Sep 10 22:09:47 2012 +0000

    ipv6: use DST_* macro to set obselete field

    Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
    Acked-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

This is a slightly modified backport of the above commit that covers
additional locations setting dst->u.obsolete = -1.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 net/ipv6/route.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e307517..b420ea9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -129,7 +129,7 @@ static struct rt6_info ip6_null_entry_template = {
 		.dst = {
 			.__refcnt	= ATOMIC_INIT(1),
 			.__use		= 1,
-			.obsolete	= -1,
+			.obsolete	= DST_OBSOLETE_FORCE_CHK,
 			.error		= -ENETUNREACH,
 			.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
 			.input		= ip6_pkt_discard,
@@ -152,7 +152,7 @@ static struct rt6_info ip6_prohibit_entry_template = {
 		.dst = {
 			.__refcnt	= ATOMIC_INIT(1),
 			.__use		= 1,
-			.obsolete	= -1,
+			.obsolete	= DST_OBSOLETE_FORCE_CHK,
 			.error		= -EACCES,
 			.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
 			.input		= ip6_pkt_prohibit,
@@ -170,7 +170,7 @@ static struct rt6_info ip6_blk_hole_entry_template = {
 		.dst = {
 			.__refcnt	= ATOMIC_INIT(1),
 			.__use		= 1,
-			.obsolete	= -1,
+			.obsolete	= DST_OBSOLETE_FORCE_CHK,
 			.error		= -EINVAL,
 			.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
 			.input		= dst_discard,
@@ -1161,7 +1161,7 @@ int ip6_route_add(struct fib6_config *cfg)
 		goto out;
 	}
 
-	rt->u.dst.obsolete = -1;
+	rt->u.dst.obsolete = DST_OBSOLETE_FORCE_CHK;
 	rt->rt6i_expires = (cfg->fc_flags & RTF_EXPIRES) ?
 				jiffies + clock_t_to_jiffies(cfg->fc_expires) :
 				0;
@@ -1960,7 +1960,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
 	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, dst_mtu(&rt->u.dst));
 	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = -1;
-	rt->u.dst.obsolete = -1;
+	rt->u.dst.obsolete = DST_OBSOLETE_FORCE_CHK;
 
 	rt->rt6i_flags = RTF_UP | RTF_NONEXTHOP;
 	if (anycast)
-- 
1.7.1


-- 
"Thought is the essence of where you are now."
