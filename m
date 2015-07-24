From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/2] ipv6: copy lwtstate in ip6_rt_copy_init()
Date: Fri, 24 Jul 2015 12:28:35 +0200
Message-ID: <1437733716-4494-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:50858 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669AbbGXK2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 06:28:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to copy this field (ip6_rt_cache_alloc() and ip6_rt_pcpu_alloc()
use ip6_rt_copy_init() to build a dst).

CC: Thomas Graf <tgraf@suug.ch>
CC: Roopa Prabhu <roopa@cumulusnetworks.com>
Fixes: 19e42e451506 ("ipv6: support for fib route lwtunnel encap attributes")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/route.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 67b2367126f3..ac01ab0886a5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2164,6 +2164,10 @@ static void ip6_rt_copy_init(struct rt6_info *rt, struct rt6_info *ort)
 #endif
 	rt->rt6i_prefsrc = ort->rt6i_prefsrc;
 	rt->rt6i_table = ort->rt6i_table;
+	if (ort->rt6i_lwtstate) {
+		lwtunnel_state_get(ort->rt6i_lwtstate);
+		rt->rt6i_lwtstate = ort->rt6i_lwtstate;
+	}
 }
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
-- 
2.4.2
