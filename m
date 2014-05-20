From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/6] netfilter: nf_tables: fix trace of matching non-terminal rule
Date: Tue, 20 May 2014 11:45:26 +0200
Message-ID: <1400579126-6451-7-git-send-email-pablo@netfilter.org>
References: <1400579126-6451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40905 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753292AbaETJpp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 05:45:45 -0400
In-Reply-To: <1400579126-6451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the corresponding trace if we have a full match in a non-terminal
rule. Note that the traces will look slightly different than in
x_tables since the log message after all expressions have been
evaluated (contrary to x_tables, that emits it before the target
action). This manifests in two differences in nf_tables wrt. x_tables:

1) The rule that enables the tracing is included in the trace.

2) If the rule emits some log message, that is shown before the
   trace log message.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_core.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 421c36a..345acfb 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -144,8 +144,10 @@ next_rule:
 		switch (data[NFT_REG_VERDICT].verdict) {
 		case NFT_BREAK:
 			data[NFT_REG_VERDICT].verdict = NFT_CONTINUE;
-			/* fall through */
+			continue;
 		case NFT_CONTINUE:
+			if (unlikely(pkt->skb->nf_trace))
+				nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RULE);
 			continue;
 		}
 		break;
-- 
1.7.10.4
