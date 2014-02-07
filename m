From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/18] netfilter: nf_tables: fix loop checking with end interval elements
Date: Fri,  7 Feb 2014 18:41:43 +0100
Message-ID: <1391794904-4017-18-git-send-email-pablo@netfilter.org>
References: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix access to uninitialized data for end interval elements. The
element data part is uninitialized in interval end elements.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index d0c790e3e..adce01e 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2998,6 +2998,9 @@ static int nf_tables_loop_check_setelem(const struct nft_ctx *ctx,
 					const struct nft_set_iter *iter,
 					const struct nft_set_elem *elem)
 {
+	if (elem->flags & NFT_SET_ELEM_INTERVAL_END)
+		return 0;
+
 	switch (elem->data.verdict) {
 	case NFT_JUMP:
 	case NFT_GOTO:
-- 
1.7.10.4

