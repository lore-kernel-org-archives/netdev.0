From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 46/53] netfilter: nft_ct: report error if mark and dir specified simultaneously
Date: Mon, 26 Sep 2016 01:06:56 +0200
Message-ID: <1474844823-2026-47-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

NFT_CT_MARK is unrelated to direction, so if NFTA_CT_DIRECTION attr is
specified, report EINVAL to the userspace. This validation check was
already done at nft_ct_get_init, but we missed it in nft_ct_set_init.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_ct.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 825fbbc62f48..d7b0d171172a 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -364,6 +364,8 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
 	switch (priv->key) {
 #ifdef CONFIG_NF_CONNTRACK_MARK
 	case NFT_CT_MARK:
+		if (tb[NFTA_CT_DIRECTION])
+			return -EINVAL;
 		len = FIELD_SIZEOF(struct nf_conn, mark);
 		break;
 #endif
-- 
2.1.4

