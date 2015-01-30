From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2/9] nftables: reject NFT_SET_ELEM_INTERVAL_END flag for non-interval sets
Date: Fri, 30 Jan 2015 07:46:27 +0000
Message-ID: <1422603994-5836-3-git-send-email-kaber@trash.net>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
Cc: tgraf@suug.ch, davem@davemloft.net, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34102 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754176AbbA3Hqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 02:46:44 -0500
In-Reply-To: <1422603994-5836-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_tables_api.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 129a8da..92ba4a0 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3112,6 +3112,9 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 		elem.flags = ntohl(nla_get_be32(nla[NFTA_SET_ELEM_FLAGS]));
 		if (elem.flags & ~NFT_SET_ELEM_INTERVAL_END)
 			return -EINVAL;
+		if (!(set->flags & NFT_SET_INTERVAL) &&
+		    elem.flags & NFT_SET_ELEM_INTERVAL_END)
+			return -EINVAL;
 	}
 
 	if (set->flags & NFT_SET_MAP) {
-- 
2.1.0
