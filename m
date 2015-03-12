From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: netfilter: Fix potential crash in nft_hash walker
Date: Fri, 13 Mar 2015 10:52:14 +1100
Message-ID: <20150312235214.GA26546@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:53624 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbbCLXwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 19:52:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we get back an EAGAIN from rhashtable_walk_next we were
treating it as a valid object which obviously doesn't work too
well.
    
Luckily this is hard to trigger so it seems nobody has run into
it yet.
    
This patch fixes it by redoing the next call when we get an EAGAIN.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index c82df0a..37c15e6 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -153,6 +153,8 @@ static void nft_hash_walk(const struct nft_ctx *ctx, const struct nft_set *set,
 				iter->err = err;
 				goto out;
 			}
+
+			continue;
 		}
 
 		if (iter->count < iter->skip)
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
