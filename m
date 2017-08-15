From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 3/4] ipv6: route: set ipv6 RTM_GETROUTE to not use rtnl
Date: Tue, 15 Aug 2017 16:34:43 +0200
Message-ID: <20170815143444.17002-4-fw@strlen.de>
References: <20170815143444.17002-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:41032 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752401AbdHOOeg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 10:34:36 -0400
In-Reply-To: <20170815143444.17002-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ec694fdb8cc5..3c15f005c90e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -4112,7 +4112,8 @@ int __init ip6_route_init(void)
 	ret = -ENOBUFS;
 	if (__rtnl_register(PF_INET6, RTM_NEWROUTE, inet6_rtm_newroute, NULL, 0) ||
 	    __rtnl_register(PF_INET6, RTM_DELROUTE, inet6_rtm_delroute, NULL, 0) ||
-	    __rtnl_register(PF_INET6, RTM_GETROUTE, inet6_rtm_getroute, NULL, 0))
+	    __rtnl_register(PF_INET6, RTM_GETROUTE, inet6_rtm_getroute, NULL,
+			    RTNL_FLAG_DOIT_UNLOCKED))
 		goto out_register_late_subsys;
 
 	ret = register_netdevice_notifier(&ip6_route_dev_notifier);
-- 
2.13.0
