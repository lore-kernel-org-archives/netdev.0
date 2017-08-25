From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net] ipv6: Fix may be used uninitialized warning in rt6_check
Date: Fri, 25 Aug 2017 09:05:42 +0200
Message-ID: <20170825070542.GV31224@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Wang <weiwan@google.com>, Eric Dumazet <edumazet@google.com>,
        "Martin KaFai Lau" <kafai@fb.com>, <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49434 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754138AbdHYHFo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 03:05:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rt_cookie might be used uninitialized, fix this by
initializing it.

Fixes: c5cff8561d2d ("ipv6: add rcu grace period before freeing fib6_node")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a9d3564..48c8c92 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1289,7 +1289,7 @@ static void rt6_dst_from_metrics_check(struct rt6_info *rt)
 
 static struct dst_entry *rt6_check(struct rt6_info *rt, u32 cookie)
 {
-	u32 rt_cookie;
+	u32 rt_cookie = 0;
 
 	if (!rt6_get_cookie_safe(rt, &rt_cookie) || rt_cookie != cookie)
 		return NULL;
-- 
2.7.4
