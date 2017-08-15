From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 4/4] ipv4: route: set ipv4 RTM_GETROUTE to not use rtnl
Date: Tue, 15 Aug 2017 16:34:44 +0200
Message-ID: <20170815143444.17002-5-fw@strlen.de>
References: <20170815143444.17002-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:41036 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752401AbdHOOej (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 10:34:39 -0400
In-Reply-To: <20170815143444.17002-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6810d2076b1b..618bbe1405fc 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3073,7 +3073,8 @@ int __init ip_rt_init(void)
 	xfrm_init();
 	xfrm4_init();
 #endif
-	rtnl_register(PF_INET, RTM_GETROUTE, inet_rtm_getroute, NULL, 0);
+	rtnl_register(PF_INET, RTM_GETROUTE, inet_rtm_getroute, NULL,
+		      RTNL_FLAG_DOIT_UNLOCKED);
 
 #ifdef CONFIG_SYSCTL
 	register_pernet_subsys(&sysctl_route_ops);
-- 
2.13.0
