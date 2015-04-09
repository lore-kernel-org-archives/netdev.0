From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/20] netfilter: nf_tables: fix set selection when timeouts are requested
Date: Thu,  9 Apr 2015 13:35:00 +0200
Message-ID: <1428579304-5520-17-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

The NFT_SET_TIMEOUT flag is ignore in nft_select_set_ops, which may
lead to selection of a set implementation that doesn't actually
support timeouts.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 3aa92b3..0dab872 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2159,7 +2159,7 @@ nft_select_set_ops(const struct nlattr * const nla[],
 	features = 0;
 	if (nla[NFTA_SET_FLAGS] != NULL) {
 		features = ntohl(nla_get_be32(nla[NFTA_SET_FLAGS]));
-		features &= NFT_SET_INTERVAL | NFT_SET_MAP;
+		features &= NFT_SET_INTERVAL | NFT_SET_MAP | NFT_SET_TIMEOUT;
 	}
 
 	bops	   = NULL;
-- 
1.7.10.4

