From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Crypto oops in async_chainiv_do_postponed
Date: Wed, 2 Sep 2009 08:17:21 +1000
Message-ID: <20090901221721.GA1964@gondor.apana.org.au>
References: <19095.1264.682820.125602@waldo.imnotcreative.homeip.net> <20090829104606.GA13141@gondor.apana.org.au> <19099.63038.425414.514063@waldo.imnotcreative.homeip.net> <20090831220459.GA15713@gondor.apana.org.au> <19101.16628.347039.619378@waldo.imnotcreative.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	offbase0@gmail.com
To: Brad Bosch <bradbosch@comcast.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42716 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755259AbZIAWRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 18:17:22 -0400
Content-Disposition: inline
In-Reply-To: <19101.16628.347039.619378@waldo.imnotcreative.homeip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2009 at 10:42:44AM -0500, Brad Bosch wrote:
> 
> Now, ctx-err may be used by both async_chainiv_postpone_request to
> store the return value from skcipher_enqueue_givcrypt and by
> async_chainiv_givencrypt_tail to store the return value from
> crypto_ablkcipher_encrypt at the same time.  This can cause the
> calling function to think async_chainiv_givencrypt has completed it's
> work, when in fact, the work was defered.

async_chainiv_postpone_request never touches ctx->err unless
it can obtain the INUSE bit lock.  On the other hand, the normal
patch async_chainiv_givencrypt_tail never relinquishes the INUSE
bit until it is finisehd with ctx->err.
 
> OK.  I see now that your offset patch should indeed solve that
> problem.  But why did you choose to fix it in a complex way?  My
> suggestion just adds a single test while yours adds new parameters, a
> new function and an extra function call.

Because that introduces two NULL checks where the second one is
useless.  Not a big deal but then again, my patch wasn't that
complicated either :)

Please let me know whether it actually fixes your problem though
so I can get this upstream.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
