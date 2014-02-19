From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/6] netfilter: nf_tables: check if payload length is a power of 2
Date: Wed, 19 Feb 2014 12:41:41 +0100
Message-ID: <1392810102-13877-6-git-send-email-pablo@netfilter.org>
References: <1392810102-13877-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45012 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753017AbaBSLl7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 06:41:59 -0500
In-Reply-To: <1392810102-13877-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>

Add a check if payload's length is a power of 2 when selecting ops.
The fast ops were meant for well aligned loads, also this fixes a
small bug when using a length of 3 with some offsets which causes
only 1 byte to be loaded because the fast ops are chosen.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
Acked-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_payload.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index a2aeb31..85daa84 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -135,7 +135,8 @@ nft_payload_select_ops(const struct nft_ctx *ctx,
 	if (len == 0 || len > FIELD_SIZEOF(struct nft_data, data))
 		return ERR_PTR(-EINVAL);
 
-	if (len <= 4 && IS_ALIGNED(offset, len) && base != NFT_PAYLOAD_LL_HEADER)
+	if (len <= 4 && is_power_of_2(len) && IS_ALIGNED(offset, len) &&
+	    base != NFT_PAYLOAD_LL_HEADER)
 		return &nft_payload_fast_ops;
 	else
 		return &nft_payload_ops;
-- 
1.7.10.4
