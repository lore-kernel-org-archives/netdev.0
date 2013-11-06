From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv6: replace RTF_ROUTEINFO with RTF_ADDRCONF in  rt6_get_route_info()
Date: Wed, 06 Nov 2013 15:26:41 +0800
Message-ID: <5279EF31.4040705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:21727 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750803Ab3KFH2p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Nov 2013 02:28:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As the rfc 4191 said, the Router Preference and Lifetime values in a
::/0 Route Information Option should override the preference and lifetime
values in the Router Advertisement header. But when the kernel deals with
a ::/0 Route Information Option, the rt6_get_route_info() always return
NULL, that means that overriding will not happen, because those default
routers were added without flag RTF_ROUTEINFO in rt6_add_dflt_router().

In order to match those default routers, we can replace RTF_ROUTEINFO 
with RTF_ADDRCONF in rt6_get_route_info().

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 04e17b3..549aa3b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1940,7 +1940,8 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 	for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
 		if (rt->dst.dev->ifindex != ifindex)
 			continue;
-		if ((rt->rt6i_flags & (RTF_ROUTEINFO|RTF_GATEWAY)) != (RTF_ROUTEINFO|RTF_GATEWAY))
+		if ((rt->rt6i_flags & (RTF_ADDRCONF|RTF_GATEWAY)) !=
+		    (RTF_ADDRCONF|RTF_GATEWAY))
 			continue;
 		if (!ipv6_addr_equal(&rt->rt6i_gateway, gwaddr))
 			continue;
-- 
1.8.3.1
