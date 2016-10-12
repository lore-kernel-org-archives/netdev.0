From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] netfilter: nft_exthdr: fix error handling in
 nft_exthdr_init()
Date: Wed, 12 Oct 2016 09:09:12 +0300
Message-ID: <20161012060912.GF12841@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Laura Garcia Liebana <nevola@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:27541 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752607AbcJLGMp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 02:12:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"err" needs to be signed for the error handling to work.

Fixes: 36b701fae12a ('netfilter: nf_tables: validate maximum value of u32 netlink attributes')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/netfilter/nft_exthdr.c b/net/netfilter/nft_exthdr.c
index a84cf3d..47beb3a 100644
--- a/net/netfilter/nft_exthdr.c
+++ b/net/netfilter/nft_exthdr.c
@@ -59,7 +59,8 @@ static int nft_exthdr_init(const struct nft_ctx *ctx,
 			   const struct nlattr * const tb[])
 {
 	struct nft_exthdr *priv = nft_expr_priv(expr);
-	u32 offset, len, err;
+	u32 offset, len;
+	int err;
 
 	if (tb[NFTA_EXTHDR_DREG] == NULL ||
 	    tb[NFTA_EXTHDR_TYPE] == NULL ||
