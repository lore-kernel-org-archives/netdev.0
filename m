From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bug 6688] Memory allocation problem
Date: Wed, 12 Jul 2006 21:45:13 +1000
Message-ID: <20060712114513.GA16823@gondor.apana.org.au>
References: <20060620002433.28115714.akpm@osdl.org> <E1G0d94-0004My-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pstaszewski@artcom.pl,
	Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51985 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751323AbWGLLpW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 07:45:22 -0400
To: davem@davemloft.net, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <E1G0d94-0004My-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 12, 2006 at 09:44:46PM +1000, Herbert Xu wrote:
> 
> [IPV4]: Fix error handling for fib_insert_node call

Doh, fogot the patch.

[IPV4]: Fix error handling for fib_insert_node call

The error handling around fib_insert_node was broken because we always
zeroed the error before checking it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 1cb6530..23fb9d9 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1252,8 +1252,8 @@ fn_trie_insert(struct fib_table *tb, str
 	 */
 
 	if (!fa_head) {
-		fa_head = fib_insert_node(t, &err, key, plen);
 		err = 0;
+		fa_head = fib_insert_node(t, &err, key, plen);
 		if (err)
 			goto out_free_new_fa;
 	}
