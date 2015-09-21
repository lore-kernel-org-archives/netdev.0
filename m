From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 71/84] ipvs: Better derivation of ipvs in ip_vs_in_stats and ip_vs_out_stats
Date: Mon, 21 Sep 2015 13:02:48 -0500
Message-ID: <1442858581-15869-71-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35361 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932170AbbIUSOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 14:14:16 -0400
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 514596b7a324..1c9c52349b7c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -112,7 +112,7 @@ static inline void
 ip_vs_in_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest = cp->dest;
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+	struct netns_ipvs *ipvs = cp->ipvs;
 
 	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		struct ip_vs_cpu_stats *s;
@@ -146,7 +146,7 @@ static inline void
 ip_vs_out_stats(struct ip_vs_conn *cp, struct sk_buff *skb)
 {
 	struct ip_vs_dest *dest = cp->dest;
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+	struct netns_ipvs *ipvs = cp->ipvs;
 
 	if (dest && (dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		struct ip_vs_cpu_stats *s;
-- 
2.2.1
