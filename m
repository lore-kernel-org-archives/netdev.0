From: pablo@netfilter.org
Subject: [PATCH 2/8] ipvs: IPv6 extend ICMPv6 handling for future types
Date: Fri, 26 Oct 2012 11:24:32 +0200
Message-ID: <1351243478-4852-3-git-send-email-pablo@netfilter.org>
References: <1351243478-4852-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59581 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755880Ab2JZJYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 05:24:50 -0400
In-Reply-To: <1351243478-4852-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>

Extend handling of ICMPv6, to all none Informational Messages
(via ICMPV6_INFOMSG_MASK).  This actually only extend our handling to
type ICMPV6_PARAMPROB (Parameter Problem), and future types.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4edb654..ebd105c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -950,9 +950,7 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 	 * this means that some packets will manage to get a long way
 	 * down this stack and then be rejected, but that's life.
 	 */
-	if ((ic->icmp6_type != ICMPV6_DEST_UNREACH) &&
-	    (ic->icmp6_type != ICMPV6_PKT_TOOBIG) &&
-	    (ic->icmp6_type != ICMPV6_TIME_EXCEED)) {
+	if (ic->icmp6_type & ICMPV6_INFOMSG_MASK) {
 		*related = 0;
 		return NF_ACCEPT;
 	}
@@ -1498,9 +1496,7 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	 * this means that some packets will manage to get a long way
 	 * down this stack and then be rejected, but that's life.
 	 */
-	if ((ic->icmp6_type != ICMPV6_DEST_UNREACH) &&
-	    (ic->icmp6_type != ICMPV6_PKT_TOOBIG) &&
-	    (ic->icmp6_type != ICMPV6_TIME_EXCEED)) {
+	if (ic->icmp6_type & ICMPV6_INFOMSG_MASK) {
 		*related = 0;
 		return NF_ACCEPT;
 	}
-- 
1.7.10.4
