From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/6] netfilter: nf_tables: fix missing return trace at the end of non-base chain
Date: Tue, 20 May 2014 11:45:25 +0200
Message-ID: <1400579126-6451-6-git-send-email-pablo@netfilter.org>
References: <1400579126-6451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1400579126-6451-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Display "return" for implicit rule at the end of a non-base chain,
instead of when popping chain from the stack.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_core.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index be08a96..421c36a 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -182,18 +182,16 @@ next_rule:
 	case NFT_RETURN:
 		if (unlikely(pkt->skb->nf_trace))
 			nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RETURN);
-
-		/* fall through */
+		break;
 	case NFT_CONTINUE:
+		if (unlikely(pkt->skb->nf_trace && !(chain->flags & NFT_BASE_CHAIN)))
+			nft_trace_packet(pkt, chain, ++rulenum, NFT_TRACE_RETURN);
 		break;
 	default:
 		WARN_ON(1);
 	}
 
 	if (stackptr > 0) {
-		if (unlikely(pkt->skb->nf_trace))
-			nft_trace_packet(pkt, chain, ++rulenum, NFT_TRACE_RETURN);
-
 		stackptr--;
 		chain = jumpstack[stackptr].chain;
 		rule  = jumpstack[stackptr].rule;
-- 
1.7.10.4

