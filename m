From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/25] netfilter: nft_ct: add missing ifdef for NFT_MARK setting
Date: Wed, 21 May 2014 11:42:59 +0200
Message-ID: <1400665402-5835-2-git-send-email-pablo@netfilter.org>
References: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55909 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751120AbaEUJne (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 05:43:34 -0400
In-Reply-To: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

The set operation for ct mark is only valid if CONFIG_NF_CONNTRACK_MARK is
enabled.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_ct.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index bd0d41e..a2c45bd 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -268,8 +268,10 @@ static int nft_ct_init_validate_get(const struct nft_expr *expr,
 static int nft_ct_init_validate_set(uint32_t key)
 {
 	switch (key) {
+#ifdef CONFIG_NF_CONNTRACK_MARK
 	case NFT_CT_MARK:
 		break;
+#endif
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
1.7.10.4
