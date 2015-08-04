From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/18] netfilter: ip6t_REJECT: Remove debug messages from reject_tg6()
Date: Tue,  4 Aug 2015 12:02:48 +0200
Message-ID: <1438682568-8346-19-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>

Make it similar to reject_tg() in ipt_REJECT.

Suggested-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/ip6t_REJECT.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 12331ef..567367a 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -35,14 +35,12 @@ MODULE_AUTHOR("Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>");
 MODULE_DESCRIPTION("Xtables: packet \"rejection\" target for IPv6");
 MODULE_LICENSE("GPL");
 
-
 static unsigned int
 reject_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ip6t_reject_info *reject = par->targinfo;
 	struct net *net = dev_net((par->in != NULL) ? par->in : par->out);
 
-	pr_debug("%s: medium point\n", __func__);
 	switch (reject->with) {
 	case IP6T_ICMP6_NO_ROUTE:
 		nf_send_unreach6(net, skb, ICMPV6_NOROUTE, par->hooknum);
@@ -65,9 +63,6 @@ reject_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 	case IP6T_TCP_RESET:
 		nf_send_reset6(net, skb, par->hooknum);
 		break;
-	default:
-		net_info_ratelimited("case %u not handled yet\n", reject->with);
-		break;
 	}
 
 	return NF_DROP;
-- 
1.7.10.4

