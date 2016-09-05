From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/29] netfilter: nf_dup4: remove redundant checksum recalculation
Date: Mon,  5 Sep 2016 12:58:18 +0200
Message-ID: <1473073124-5015-4-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

IP header checksum will be recalculated at ip_local_out, so
there's no need to calculated it here, remove it. Also update
code comments to illustrate it, and delete the misleading
comments about checksum recalculation.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_dup_ipv4.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/nf_dup_ipv4.c b/net/ipv4/netfilter/nf_dup_ipv4.c
index ceb1873..cf986e1 100644
--- a/net/ipv4/netfilter/nf_dup_ipv4.c
+++ b/net/ipv4/netfilter/nf_dup_ipv4.c
@@ -74,21 +74,19 @@ void nf_dup_ipv4(struct net *net, struct sk_buff *skb, unsigned int hooknum,
 	nf_conntrack_get(skb->nfct);
 #endif
 	/*
-	 * If we are in PREROUTING/INPUT, the checksum must be recalculated
-	 * since the length could have changed as a result of defragmentation.
-	 *
-	 * We also decrease the TTL to mitigate potential loops between two
-	 * hosts.
+	 * If we are in PREROUTING/INPUT, decrease the TTL to mitigate potential
+	 * loops between two hosts.
 	 *
 	 * Set %IP_DF so that the original source is notified of a potentially
 	 * decreased MTU on the clone route. IPv6 does this too.
+	 *
+	 * IP header checksum will be recalculated at ip_local_out.
 	 */
 	iph = ip_hdr(skb);
 	iph->frag_off |= htons(IP_DF);
 	if (hooknum == NF_INET_PRE_ROUTING ||
 	    hooknum == NF_INET_LOCAL_IN)
 		--iph->ttl;
-	ip_send_check(iph);
 
 	if (nf_dup_ipv4_route(net, skb, gw, oif)) {
 		__this_cpu_write(nf_skb_duplicated, true);
-- 
2.1.4

