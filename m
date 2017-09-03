From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/47] netfilter: nf_tables: No need to check chain existence when tracing
Date: Mon,  4 Sep 2017 00:27:13 +0200
Message-ID: <1504477667-12130-4-git-send-email-pablo@netfilter.org>
References: <1504477667-12130-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504477667-12130-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Phil Sutter <phil@nwl.cc>

nft_trace_notify() is called only from __nft_trace_packet(), which
assigns its parameter 'chain' to info->chain. __nft_trace_packet() in
turn later dereferences 'chain' unconditionally, which indicates that
it's never NULL. Same does nft_do_chain(), the only user of the tracing
infrastructure. Hence it is safe to assume the check removed here is not
needed.

Signed-off-by: Phil Sutter <phil@nwl.cc>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_trace.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nf_tables_trace.c b/net/netfilter/nf_tables_trace.c
index e1b15e7a5793..0c3a0049e4aa 100644
--- a/net/netfilter/nf_tables_trace.c
+++ b/net/netfilter/nf_tables_trace.c
@@ -217,14 +217,11 @@ void nft_trace_notify(struct nft_traceinfo *info)
 	if (trace_fill_id(skb, pkt->skb))
 		goto nla_put_failure;
 
-	if (info->chain) {
-		if (nla_put_string(skb, NFTA_TRACE_CHAIN,
-				   info->chain->name))
-			goto nla_put_failure;
-		if (nla_put_string(skb, NFTA_TRACE_TABLE,
-				   info->chain->table->name))
-			goto nla_put_failure;
-	}
+	if (nla_put_string(skb, NFTA_TRACE_CHAIN, info->chain->name))
+		goto nla_put_failure;
+
+	if (nla_put_string(skb, NFTA_TRACE_TABLE, info->chain->table->name))
+		goto nla_put_failure;
 
 	if (nf_trace_fill_rule_info(skb, info))
 		goto nla_put_failure;
-- 
2.1.4


