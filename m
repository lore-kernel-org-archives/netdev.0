From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/6] netfilter: nf_tables: fix tracing of the goto action
Date: Tue, 20 May 2014 11:45:23 +0200
Message-ID: <1400579126-6451-4-git-send-email-pablo@netfilter.org>
References: <1400579126-6451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1400579126-6451-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add missing code to trace goto actions.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_core.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 7d83a49..f55fb28 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -171,8 +171,12 @@ next_rule:
 		jumpstack[stackptr].rule  = rule;
 		jumpstack[stackptr].rulenum = rulenum;
 		stackptr++;
-		/* fall through */
+		chain = data[NFT_REG_VERDICT].chain;
+		goto do_chain;
 	case NFT_GOTO:
+		if (unlikely(pkt->skb->nf_trace))
+			nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RULE);
+
 		chain = data[NFT_REG_VERDICT].chain;
 		goto do_chain;
 	case NFT_RETURN:
-- 
1.7.10.4

