From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/2] netfilter: nf_tables: fix wrong length for jump/goto verdicts
Date: Mon, 27 Apr 2015 20:41:56 +0200
Message-ID: <1430160117-21150-2-git-send-email-pablo@netfilter.org>
References: <1430160117-21150-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44478 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753167AbbD0Shf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2015 14:37:35 -0400
In-Reply-To: <1430160117-21150-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

NFT_JUMP/GOTO erronously sets length to sizeof(void *).

We then allocate insufficient memory when such element is added to a vmap.

Suggested-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 78af83b..ad9d11f 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -4340,7 +4340,6 @@ static int nft_verdict_init(const struct nft_ctx *ctx, struct nft_data *data,
 	case NFT_CONTINUE:
 	case NFT_BREAK:
 	case NFT_RETURN:
-		desc->len = sizeof(data->verdict);
 		break;
 	case NFT_JUMP:
 	case NFT_GOTO:
@@ -4355,10 +4354,10 @@ static int nft_verdict_init(const struct nft_ctx *ctx, struct nft_data *data,
 
 		chain->use++;
 		data->verdict.chain = chain;
-		desc->len = sizeof(data);
 		break;
 	}
 
+	desc->len = sizeof(data->verdict);
 	desc->type = NFT_DATA_VERDICT;
 	return 0;
 }
-- 
1.7.10.4
