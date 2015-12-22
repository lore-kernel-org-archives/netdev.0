From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/2] netfilter: nft_ct: include direction when dumping NFT_CT_L3PROTOCOL key
Date: Tue, 22 Dec 2015 18:53:17 +0100
Message-ID: <1450806797-21788-3-git-send-email-pablo@netfilter.org>
References: <1450806797-21788-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1450806797-21788-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

one nft userspace test case fails with

'ct l3proto original ipv4' mismatches 'ct l3proto ipv4'

... because NFTA_CT_DIRECTION attr is missing.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_ct.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 8cbca34..9399215 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -366,6 +366,7 @@ static int nft_ct_get_dump(struct sk_buff *skb, const struct nft_expr *expr)
 		goto nla_put_failure;
 
 	switch (priv->key) {
+	case NFT_CT_L3PROTOCOL:
 	case NFT_CT_PROTOCOL:
 	case NFT_CT_SRC:
 	case NFT_CT_DST:
-- 
2.1.4

