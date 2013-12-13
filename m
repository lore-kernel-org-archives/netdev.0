From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/2] netfilter: nft_reject: fix endianness in dump function
Date: Fri, 13 Dec 2013 19:24:59 +0100
Message-ID: <1386959099-24582-3-git-send-email-pablo@netfilter.org>
References: <1386959099-24582-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49748 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753228Ab3LMSZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 13:25:10 -0500
In-Reply-To: <1386959099-24582-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Leblond <eric@regit.org>

The dump function in nft_reject_ipv4 was not converting a u32
field to network order before sending it to userspace, this
needs to happen for consistency with other nf_tables and
nfnetlink subsystems.

Signed-off-by: Eric Leblond <eric@regit.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nft_reject_ipv4.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/nft_reject_ipv4.c b/net/ipv4/netfilter/nft_reject_ipv4.c
index fff5ba1..4a5e94a 100644
--- a/net/ipv4/netfilter/nft_reject_ipv4.c
+++ b/net/ipv4/netfilter/nft_reject_ipv4.c
@@ -72,7 +72,7 @@ static int nft_reject_dump(struct sk_buff *skb, const struct nft_expr *expr)
 {
 	const struct nft_reject *priv = nft_expr_priv(expr);
 
-	if (nla_put_be32(skb, NFTA_REJECT_TYPE, priv->type))
+	if (nla_put_be32(skb, NFTA_REJECT_TYPE, htonl(priv->type)))
 		goto nla_put_failure;
 
 	switch (priv->type) {
-- 
1.7.10.4
