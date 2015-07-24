From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] ipv6: use lwtunnel_output6() only if flag redirect is set
Date: Fri, 24 Jul 2015 10:59:41 +0200
Message-ID: <1437728381-4603-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:50613 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213AbbGXJDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 05:03:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function make sense only when LWTUNNEL_STATE_OUTPUT_REDIRECT is set.
The check is already done in IPv4.

CC: Thomas Graf <tgraf@suug.ch>
CC: Roopa Prabhu <roopa@cumulusnetworks.com>
Fixes: 74a0f2fe8ed5 ("ipv6: rt6_info output redirect to tunnel output")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f216cb998628..67b2367126f3 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1780,7 +1780,8 @@ int ip6_route_add(struct fib6_config *cfg)
 			goto out;
 		lwtunnel_state_get(lwtstate);
 		rt->rt6i_lwtstate = lwtstate;
-		rt->dst.output = lwtunnel_output6;
+		if (lwtunnel_output_redirect(rt->rt6i_lwtstate))
+			rt->dst.output = lwtunnel_output6;
 	}
 
 	ipv6_addr_prefix(&rt->rt6i_dst.addr, &cfg->fc_dst, cfg->fc_dst_len);
-- 
2.4.2
