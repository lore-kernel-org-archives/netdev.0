From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/9] netfilter: ip6t_REJECT: added missing icmpv6 codes
Date: Sat, 29 Aug 2015 00:50:15 +0200
Message-ID: <1440802217-13080-8-git-send-email-pablo@netfilter.org>
References: <1440802217-13080-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1440802217-13080-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Herz <andi@geekosphere.org>

RFC 4443 added two new codes values for ICMPv6 type 1:

 5 - Source address failed ingress/egress policy
 6 - Reject route to destination

And RFC 7084 states in L-14 that IPv6 Router MUST send ICMPv6 Destination
Unreachable with code 5 for packets forwarded to it that use an address
from a prefix that has been invalidated.

Codes 5 and 6 are more informative subsets of code 1.

Signed-off-by: Andreas Herz <andi@geekosphere.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter_ipv6/ip6t_REJECT.h |    4 +++-
 net/ipv6/netfilter/ip6t_REJECT.c                |    6 ++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/netfilter_ipv6/ip6t_REJECT.h b/include/uapi/linux/netfilter_ipv6/ip6t_REJECT.h
index 205ed62..cd2e940 100644
--- a/include/uapi/linux/netfilter_ipv6/ip6t_REJECT.h
+++ b/include/uapi/linux/netfilter_ipv6/ip6t_REJECT.h
@@ -10,7 +10,9 @@ enum ip6t_reject_with {
 	IP6T_ICMP6_ADDR_UNREACH,
 	IP6T_ICMP6_PORT_UNREACH,
 	IP6T_ICMP6_ECHOREPLY,
-	IP6T_TCP_RESET
+	IP6T_TCP_RESET,
+	IP6T_ICMP6_POLICY_FAIL,
+	IP6T_ICMP6_REJECT_ROUTE
 };
 
 struct ip6t_reject_info {
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 567367a..0ed841a 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -63,6 +63,12 @@ reject_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 	case IP6T_TCP_RESET:
 		nf_send_reset6(net, skb, par->hooknum);
 		break;
+	case IP6T_ICMP6_POLICY_FAIL:
+		nf_send_unreach6(net, skb, ICMPV6_POLICY_FAIL, par->hooknum);
+		break;
+	case IP6T_ICMP6_REJECT_ROUTE:
+		nf_send_unreach6(net, skb, ICMPV6_REJECT_ROUTE, par->hooknum);
+		break;
 	}
 
 	return NF_DROP;
-- 
1.7.10.4

