From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/21] ipv6: fib: Unlink replaced routes from their nodes
Date: Thu,  3 Aug 2017 13:28:22 +0200
Message-ID: <20170803112831.1831-13-jiri@resnulli.us>
References: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35653 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751925AbdHCL24 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:28:56 -0400
Received: by mail-wr0-f196.google.com with SMTP id c24so806216wra.2
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:28:56 -0700 (PDT)
In-Reply-To: <20170803112831.1831-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a route is deleted its node pointer is set to NULL to indicate it's
no longer linked to its node. Do the same for routes that are replaced.

This will later allow us to test if a route is still in the FIB by
checking its node pointer instead of its reference count.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/ipv6/ip6_fib.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index fa27905..fe193b4 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1019,6 +1019,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			fn->fn_flags |= RTN_RTINFO;
 		}
 		nsiblings = iter->rt6i_nsiblings;
+		iter->rt6i_node = NULL;
 		fib6_purge_rt(iter, fn, info->nl_net);
 		rt6_release(iter);
 
@@ -1031,6 +1032,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 					break;
 				if (rt6_qualify_for_ecmp(iter)) {
 					*ins = iter->dst.rt6_next;
+					iter->rt6i_node = NULL;
 					fib6_purge_rt(iter, fn, info->nl_net);
 					rt6_release(iter);
 					nsiblings--;
-- 
2.9.3
