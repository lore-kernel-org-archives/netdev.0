From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC net-next 07/22] ipv6: rt6_info output redirect to tunnel output
Date: Fri, 10 Jul 2015 16:19:09 +0200
Message-ID: <990dd8e5ca6c1456ac50f9ac57fdd543d8df54ed.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40556 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932643AbbGJOTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 10:19:38 -0400
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This is similar to ipv4 redirect of dst output to lwtunnel
output function for encapsulation and xmit.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/ipv6/route.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index acfe25d..6c328bb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1783,6 +1783,7 @@ int ip6_route_add(struct fib6_config *cfg)
 			goto out;
 		lwtunnel_state_get(lwtstate);
 		rt->rt6i_lwtstate = lwtstate;
+		rt->dst.output = lwtunnel_output6;
 	}
 
 	ipv6_addr_prefix(&rt->rt6i_dst.addr, &cfg->fc_dst, cfg->fc_dst_len);
-- 
2.4.3
