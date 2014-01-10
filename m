From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/23] netfilter: nft_reject: fix compilation warning if NF_TABLES_IPV6 is disabled
Date: Fri, 10 Jan 2014 01:35:20 +0100
Message-ID: <1389314142-17969-2-git-send-email-pablo@netfilter.org>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51501 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756162AbaAJAgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 19:36:02 -0500
In-Reply-To: <1389314142-17969-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/netfilter/nft_reject.c: In function 'nft_reject_eval':
net/netfilter/nft_reject.c:37:14: warning: unused variable 'net' [-Wunused-variable]

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_reject.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nft_reject.c b/net/netfilter/nft_reject.c
index 0d690d4..7ae63cd 100644
--- a/net/netfilter/nft_reject.c
+++ b/net/netfilter/nft_reject.c
@@ -34,8 +34,9 @@ static void nft_reject_eval(const struct nft_expr *expr,
 			      const struct nft_pktinfo *pkt)
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
+#if IS_ENABLED(CONFIG_NF_TABLES_IPV6)
 	struct net *net = dev_net((pkt->in != NULL) ? pkt->in : pkt->out);
-
+#endif
 	switch (priv->type) {
 	case NFT_REJECT_ICMP_UNREACH:
 		if (priv->family == NFPROTO_IPV4)
-- 
1.7.10.4
