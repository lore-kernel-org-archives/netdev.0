From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/38] netfilter: nf_tables: accept QUEUE/DROP verdict parameters
Date: Mon, 17 Mar 2014 13:42:27 +0100
Message-ID: <1395060178-11833-8-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Allow userspace to specify the queue number or the errno code for QUEUE
and DROP verdicts.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 4b7e14d..0b56340 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3174,9 +3174,16 @@ static int nft_verdict_init(const struct nft_ctx *ctx, struct nft_data *data,
 	data->verdict = ntohl(nla_get_be32(tb[NFTA_VERDICT_CODE]));
 
 	switch (data->verdict) {
-	case NF_ACCEPT:
-	case NF_DROP:
-	case NF_QUEUE:
+	default:
+		switch (data->verdict & NF_VERDICT_MASK) {
+		case NF_ACCEPT:
+		case NF_DROP:
+		case NF_QUEUE:
+			break;
+		default:
+			return -EINVAL;
+		}
+		/* fall through */
 	case NFT_CONTINUE:
 	case NFT_BREAK:
 	case NFT_RETURN:
@@ -3197,8 +3204,6 @@ static int nft_verdict_init(const struct nft_ctx *ctx, struct nft_data *data,
 		data->chain = chain;
 		desc->len = sizeof(data);
 		break;
-	default:
-		return -EINVAL;
 	}
 
 	desc->type = NFT_DATA_VERDICT;
-- 
1.7.10.4

