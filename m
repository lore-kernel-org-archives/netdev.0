From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/6] netfilter: nft_ct: keep counters away from CONFIG_NF_CONNTRACK_LABELS
Date: Wed, 20 Jan 2016 18:04:01 +0100
Message-ID: <1453309444-2297-4-git-send-email-pablo@netfilter.org>
References: <1453309444-2297-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1453309444-2297-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is accidental, they don't depend on the label infrastructure.

Fixes: 48f66c905a97 ("netfilter: nft_ct: add byte/packet counter support")
Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Florian Westphal <fw@strlen.de>
---
 net/netfilter/nft_ct.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index a0eb216..d4a4619 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -127,6 +127,7 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 			       NF_CT_LABELS_MAX_SIZE - size);
 		return;
 	}
+#endif
 	case NFT_CT_BYTES: /* fallthrough */
 	case NFT_CT_PKTS: {
 		const struct nf_conn_acct *acct = nf_conn_acct_find(ct);
@@ -138,7 +139,6 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 		memcpy(dest, &count, sizeof(count));
 		return;
 	}
-#endif
 	default:
 		break;
 	}
-- 
2.1.4

