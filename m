From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/8] netfilter: nft_exthdr: call ipv6_find_hdr() with explicitly initialized offset
Date: Sat, 28 Dec 2013 23:03:01 +0100
Message-ID: <1388268187-11569-3-git-send-email-pablo@netfilter.org>
References: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <dborkman@redhat.com>

In nft's nft_exthdr_eval() routine we process IPv6 extension header
through invoking ipv6_find_hdr(), but we call it with an uninitialized
offset variable that contains some stack value. In ipv6_find_hdr()
we then test if the value of offset != 0 and call skb_header_pointer()
on that offset in order to map struct ipv6hdr into it. Fix it up by
initializing offset to 0 as it was probably intended to be.

Fixes: 96518518cc41 ("netfilter: add nftables")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_exthdr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index 8e0bb75..55c939f 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -31,7 +31,7 @@ static void nft_exthdr_eval(const struct nft_expr *expr,
 {
 	struct nft_exthdr *priv = nft_expr_priv(expr);
 	struct nft_data *dest = &data[priv->dreg];
-	unsigned int offset;
+	unsigned int offset = 0;
 	int err;
 
 	err = ipv6_find_hdr(pkt->skb, &offset, priv->type, NULL, NULL);
-- 
1.7.10.4

