From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v3 PATCH 0/9] rhashtable: Multiple rehashing
Date: Tue, 24 Mar 2015 13:37:30 +1100
Message-ID: <20150324023729.GA7973@gondor.apana.org.au>
References: <20150323134955.GA16328@gondor.apana.org.au>
 <20150323.220913.317244497700484970.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, kaber@trash.net,
	josh@joshtriplett.org, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:50889 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712AbbCXCiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 22:38:01 -0400
Content-Disposition: inline
In-Reply-To: <20150323.220913.317244497700484970.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 10:09:13PM -0400, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Tue, 24 Mar 2015 00:49:55 +1100
> 
> > This series introduces multiple rehashing.
> 
> This looks great, nice work.  All applied to net-next.

Thanks!

> Could you please add a comment next to the "16" from patch
> #9 explaining why that value was choosen and the invariants
> that influence it?

Sure.

---8<---
rhashtable: Add comment on choice of elasticity value

This patch adds a comment on the choice of the value 16 as the
maximum chain length before we force a rehash.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index e96ad1a..8514f7c 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -736,6 +736,18 @@ int rhashtable_init(struct rhashtable *ht,
 
 	ht->p.min_size = max(ht->p.min_size, HASH_MIN_SIZE);
 
+	/* The maximum (not average) chain length grows with the
+	 * size of the hash table, at a rate of (log N)/(log log N).
+	 * The value of 16 is selected so that even if the hash
+	 * table grew to 2^32 you would not expect the maximum
+	 * chain length to exceed it unless we are under attack
+	 * (or extremely unlucky).
+	 *
+	 * As this limit is only to detect attacks, we don't need
+	 * to set it to a lower value as you'd need the chain
+	 * length to vastly exceed 16 to have any real effect
+	 * on the system.
+	 */
 	if (!params->insecure_elasticity)
 		ht->elasticity = 16;
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
