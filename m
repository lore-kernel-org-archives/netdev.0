From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 8/8] netfilter: ip6t_REJECT: check for IP6T_F_PROTO
Date: Mon, 23 Mar 2015 12:36:24 +0100
Message-ID: <1427110584-5190-9-git-send-email-pablo@netfilter.org>
References: <1427110584-5190-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60124 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151AbbCWLcj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 07:32:39 -0400
In-Reply-To: <1427110584-5190-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure IP6T_F_PROTO is set to enforce layer 4 protocol matching from
the ip6_tables core.

Suggested-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/ip6t_REJECT.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 544b0a9..12331ef 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -83,7 +83,8 @@ static int reject_tg6_check(const struct xt_tgchk_param *par)
 		return -EINVAL;
 	} else if (rejinfo->with == IP6T_TCP_RESET) {
 		/* Must specify that it's a TCP packet */
-		if (e->ipv6.proto != IPPROTO_TCP ||
+		if (!(e->ipv6.flags & IP6T_F_PROTO) ||
+		    e->ipv6.proto != IPPROTO_TCP ||
 		    (e->ipv6.invflags & XT_INV_PROTO)) {
 			pr_info("TCP_RESET illegal for non-tcp\n");
 			return -EINVAL;
-- 
1.7.10.4
