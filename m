From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] ipv4: Kill flowi arg to fib_select_multipath()
Date: Thu, 10 Mar 2011 17:04:37 -0800 (PST)
Message-ID: <20110310.170437.28803671.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48116
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751251Ab1CKBD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 20:03:59 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 810C824C08B
	for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 17:04:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Completely unused.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    2 +-
 net/ipv4/fib_semantics.c |    2 +-
 net/ipv4/route.c         |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 3f6c943..d948e23 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -230,7 +230,7 @@ extern int fib_sync_down_dev(struct net_device *dev, int force);
 extern int fib_sync_down_addr(struct net *net, __be32 local);
 extern void fib_update_nh_saddrs(struct net_device *dev);
 extern int fib_sync_up(struct net_device *dev);
-extern void fib_select_multipath(const struct flowi *flp, struct fib_result *res);
+extern void fib_select_multipath(struct fib_result *res);
 
 /* Exported by fib_trie.c */
 extern void fib_trie_init(void);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index d73d758..b5d523b 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1210,7 +1210,7 @@ int fib_sync_up(struct net_device *dev)
  * The algorithm is suboptimal, but it provides really
  * fair weighted route distribution.
  */
-void fib_select_multipath(const struct flowi *flp, struct fib_result *res)
+void fib_select_multipath(struct fib_result *res)
 {
 	struct fib_info *fi = res->fi;
 	int w;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 336a38f..e72279e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1319,7 +1319,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res->fi && res->fi->fib_nhs > 1)
-		fib_select_multipath(fl, res);
+		fib_select_multipath(res);
 #endif
 
 	/* create a routing cache entry */
@@ -1803,7 +1803,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi *fl)
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res.fi->fib_nhs > 1 && fl.oif == 0)
-		fib_select_multipath(fl, &res);
+		fib_select_multipath(&res);
 	else
 #endif
 	if (!res.prefixlen && res.type == RTN_UNICAST && !fl->oif)
-- 
1.7.4.1

