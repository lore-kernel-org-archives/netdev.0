From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/17] netfilter: nf_tables: nft_payload: fix transport header base
Date: Mon, 14 Oct 2013 18:38:51 +0200
Message-ID: <1381768738-17739-11-git-send-email-pablo@netfilter.org>
References: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34780 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757281Ab3JNQjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 12:39:22 -0400
In-Reply-To: <1381768738-17739-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We cannot use skb->transport_header since it's unset, use
pkt->xt.thoff instead.

Now possible using information made available through the x_tables
compatibility layer.

Reported-by: Eric Leblond <eric@regit.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_core.c |    2 +-
 net/netfilter/nft_payload.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index e51a45c..3c13007 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -44,7 +44,7 @@ static bool nft_payload_fast_eval(const struct nft_expr *expr,
 	if (priv->base == NFT_PAYLOAD_NETWORK_HEADER)
 		ptr = skb_network_header(skb);
 	else
-		ptr = skb_transport_header(skb);
+		ptr = skb_network_header(skb) + pkt->xt.thoff;
 
 	ptr += priv->offset;
 
diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index bc8bdb2..a2aeb31 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -36,7 +36,7 @@ static void nft_payload_eval(const struct nft_expr *expr,
 		offset = skb_network_offset(skb);
 		break;
 	case NFT_PAYLOAD_TRANSPORT_HEADER:
-		offset = skb_transport_offset(skb);
+		offset = pkt->xt.thoff;
 		break;
 	default:
 		BUG();
-- 
1.7.10.4
