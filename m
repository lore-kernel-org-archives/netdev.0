From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 26/50] netfilter: nft_fib: convert htonl to ntohl properly
Date: Wed,  7 Dec 2016 22:52:32 +0100
Message-ID: <1481147576-5690-27-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

Acctually ntohl and htonl are identical, so this doesn't affect
anything, but it is conceptually wrong.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nft_fib_ipv4.c | 2 +-
 net/ipv6/netfilter/nft_fib_ipv6.c | 2 +-
 net/netfilter/nft_fib.c           | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/nft_fib_ipv4.c b/net/ipv4/netfilter/nft_fib_ipv4.c
index 1b49966484b3..bfffa742f397 100644
--- a/net/ipv4/netfilter/nft_fib_ipv4.c
+++ b/net/ipv4/netfilter/nft_fib_ipv4.c
@@ -198,7 +198,7 @@ nft_fib4_select_ops(const struct nft_ctx *ctx,
 	if (!tb[NFTA_FIB_RESULT])
 		return ERR_PTR(-EINVAL);
 
-	result = htonl(nla_get_be32(tb[NFTA_FIB_RESULT]));
+	result = ntohl(nla_get_be32(tb[NFTA_FIB_RESULT]));
 
 	switch (result) {
 	case NFT_FIB_RESULT_OIF:
diff --git a/net/ipv6/netfilter/nft_fib_ipv6.c b/net/ipv6/netfilter/nft_fib_ipv6.c
index d526bb594956..c947aad8bcc6 100644
--- a/net/ipv6/netfilter/nft_fib_ipv6.c
+++ b/net/ipv6/netfilter/nft_fib_ipv6.c
@@ -235,7 +235,7 @@ nft_fib6_select_ops(const struct nft_ctx *ctx,
 	if (!tb[NFTA_FIB_RESULT])
 		return ERR_PTR(-EINVAL);
 
-	result = htonl(nla_get_be32(tb[NFTA_FIB_RESULT]));
+	result = ntohl(nla_get_be32(tb[NFTA_FIB_RESULT]));
 
 	switch (result) {
 	case NFT_FIB_RESULT_OIF:
diff --git a/net/netfilter/nft_fib.c b/net/netfilter/nft_fib.c
index 249c9b80c150..29a4906adc27 100644
--- a/net/netfilter/nft_fib.c
+++ b/net/netfilter/nft_fib.c
@@ -86,7 +86,7 @@ int nft_fib_init(const struct nft_ctx *ctx, const struct nft_expr *expr,
 	if ((priv->flags & (NFTA_FIB_F_SADDR | NFTA_FIB_F_DADDR)) == 0)
 		return -EINVAL;
 
-	priv->result = htonl(nla_get_be32(tb[NFTA_FIB_RESULT]));
+	priv->result = ntohl(nla_get_be32(tb[NFTA_FIB_RESULT]));
 	priv->dreg = nft_parse_register(tb[NFTA_FIB_DREG]);
 
 	switch (priv->result) {
-- 
2.1.4

