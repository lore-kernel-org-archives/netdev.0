From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/10] netfilter: nft_ct: do cleanup work when NFTA_CT_DIRECTION is invalid
Date: Wed, 15 Mar 2017 18:01:12 +0100
Message-ID: <1489597272-30347-11-git-send-email-pablo@netfilter.org>
References: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

We should jump to invoke __nft_ct_set_destroy() instead of just
return error.

Fixes: edee4f1e9245 ("netfilter: nft_ct: add zone id set support")
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_ct.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 91585b5e5307..0264258c46fe 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -544,7 +544,8 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
 		case IP_CT_DIR_REPLY:
 			break;
 		default:
-			return -EINVAL;
+			err = -EINVAL;
+			goto err1;
 		}
 	}
 
-- 
2.1.4

