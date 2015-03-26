From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/15] netfilter: nf_tables: restore nf_log_trace() in nf_tables_core.c
Date: Thu, 26 Mar 2015 13:06:50 +0100
Message-ID: <1427371622-4466-4-git-send-email-pablo@netfilter.org>
References: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38271 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752456AbbCZMDZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2015 08:03:25 -0400
In-Reply-To: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As described by 4017a7e ("netfilter: restore rule tracing via
nfnetlink_log"), this accidentally slipped through during conflict
resolution in d5c1d8c.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_core.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 763a9d8..4429008 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -50,10 +50,10 @@ static void __nft_trace_packet(const struct nft_pktinfo *pkt,
 {
 	struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
 
-	nf_log_packet(net, pkt->xt.family, pkt->ops->hooknum, pkt->skb, pkt->in,
-		      pkt->out, &trace_loginfo, "TRACE: %s:%s:%s:%u ",
-		      chain->table->name, chain->name, comments[type],
-		      rulenum);
+	nf_log_trace(net, pkt->xt.family, pkt->ops->hooknum, pkt->skb, pkt->in,
+		     pkt->out, &trace_loginfo, "TRACE: %s:%s:%s:%u ",
+		     chain->table->name, chain->name, comments[type],
+		     rulenum);
 }
 
 static inline void nft_trace_packet(const struct nft_pktinfo *pkt,
-- 
1.7.10.4
