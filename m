From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/12] netfilter: nf_tables: allow expressions to return STOLEN
Date: Tue,  1 Nov 2016 22:26:24 +0100
Message-ID: <1478035593-1362-4-git-send-email-pablo@netfilter.org>
References: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Currently not supported, we'd oops as skb was (or is) free'd elsewhere.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 0dd5c695482f..70de32a6d5c0 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -178,6 +178,7 @@ nft_do_chain(struct nft_pktinfo *pkt, void *priv)
 	case NF_ACCEPT:
 	case NF_DROP:
 	case NF_QUEUE:
+	case NF_STOLEN:
 		nft_trace_packet(&info, chain, rule,
 				 rulenum, NFT_TRACETYPE_RULE);
 		return regs.verdict.code;
-- 
2.1.4

