From: roy.qing.li@gmail.com
Subject: [PATCH] ipv6: replace write lock with read lock when get route info
Date: Wed, 12 Sep 2012 13:25:53 +0800
Message-ID: <1347427553-17781-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:54876 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995Ab2ILF0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 01:26:03 -0400
Received: by dady13 with SMTP id y13so741323dad.19
        for <netdev@vger.kernel.org>; Tue, 11 Sep 2012 22:26:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

geting route info does not write rt->rt6i_table, so replace
write lock with read lock

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/route.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 399613b..8be1d86 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1837,7 +1837,7 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 	if (!table)
 		return NULL;
 
-	write_lock_bh(&table->tb6_lock);
+	read_lock_bh(&table->tb6_lock);
 	fn = fib6_locate(&table->tb6_root, prefix ,prefixlen, NULL, 0);
 	if (!fn)
 		goto out;
@@ -1853,7 +1853,7 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 		break;
 	}
 out:
-	write_unlock_bh(&table->tb6_lock);
+	read_unlock_bh(&table->tb6_lock);
 	return rt;
 }
 
@@ -1896,7 +1896,7 @@ struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_dev
 	if (!table)
 		return NULL;
 
-	write_lock_bh(&table->tb6_lock);
+	read_lock_bh(&table->tb6_lock);
 	for (rt = table->tb6_root.leaf; rt; rt=rt->dst.rt6_next) {
 		if (dev == rt->dst.dev &&
 		    ((rt->rt6i_flags & (RTF_ADDRCONF | RTF_DEFAULT)) == (RTF_ADDRCONF | RTF_DEFAULT)) &&
@@ -1905,7 +1905,7 @@ struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_dev
 	}
 	if (rt)
 		dst_hold(&rt->dst);
-	write_unlock_bh(&table->tb6_lock);
+	read_unlock_bh(&table->tb6_lock);
 	return rt;
 }
 
-- 
1.7.4.1
