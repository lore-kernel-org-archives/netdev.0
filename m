From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH net-next] ipv6: remove parameter rt from fib6_prune_clones()
Date: Fri, 9 May 2014 13:31:43 +0800
Message-ID: <536C683F.40408@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:17527 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751553AbaEIFeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 01:34:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


the parameter rt will be assigned to c.arg in function fib6_clean_tree(),
but function fib6_prune_clone() doesn't use c.arg, so we can remove it
safely.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/ip6_fib.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 34e0ded..6fefd44 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -71,8 +71,7 @@ static DEFINE_RWLOCK(fib6_walker_lock);
 #define FWS_INIT FWS_L
 #endif
 
-static void fib6_prune_clones(struct net *net, struct fib6_node *fn,
-			      struct rt6_info *rt);
+static void fib6_prune_clones(struct net *net, struct fib6_node *fn);
 static struct rt6_info *fib6_find_prefix(struct net *net, struct fib6_node *fn);
 static struct fib6_node *fib6_repair_tree(struct net *net, struct fib6_node *fn);
 static int fib6_walk(struct fib6_walker_t *w);
@@ -941,7 +940,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 	if (!err) {
 		fib6_start_gc(info->nl_net, rt);
 		if (!(rt->rt6i_flags & RTF_CACHE))
-			fib6_prune_clones(info->nl_net, pn, rt);
+			fib6_prune_clones(info->nl_net, pn);
 	}
 
 out:
@@ -1375,7 +1374,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 			pn = pn->parent;
 		}
 #endif
-		fib6_prune_clones(info->nl_net, pn, rt);
+		fib6_prune_clones(info->nl_net, pn);
 	}
 
 	/*
@@ -1600,10 +1599,9 @@ static int fib6_prune_clone(struct rt6_info *rt, void *arg)
 	return 0;
 }
 
-static void fib6_prune_clones(struct net *net, struct fib6_node *fn,
-			      struct rt6_info *rt)
+static void fib6_prune_clones(struct net *net, struct fib6_node *fn)
 {
-	fib6_clean_tree(net, fn, fib6_prune_clone, 1, rt);
+	fib6_clean_tree(net, fn, fib6_prune_clone, 1, NULL);
 }
 
 /*
-- 
1.8.3.1
