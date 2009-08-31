From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Crypto oops in async_chainiv_do_postponed
Date: Tue, 1 Sep 2009 08:04:59 +1000
Message-ID: <20090831220459.GA15713@gondor.apana.org.au>
References: <19095.1264.682820.125602@waldo.imnotcreative.homeip.net> <20090829104606.GA13141@gondor.apana.org.au> <19099.63038.425414.514063@waldo.imnotcreative.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	offbase0@gmail.com
To: Brad Bosch <bradbosch@comcast.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37400 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751442AbZHaWFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 18:05:03 -0400
Content-Disposition: inline
In-Reply-To: <19099.63038.425414.514063@waldo.imnotcreative.homeip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2009 at 11:11:42AM -0500, Brad Bosch wrote:
>
> OK.  I was looking for something subtle because the crash takes a long
> time to happen.  But do you agree that the race I described above also
> a real bug?

No I don't think it is.  CHAINV_STATE_INUSE guarantees that only
one entity can use ctx->err at any time.

> Yes, I see that this bug must be the bug we would likely encounter first.
> Apparently, async_chainiv_do_postponed was never tested?  But I don't
> see how the patch you proposed below helps.  We still don't seem to be
> returning NULL from skcipher_dequeue_givcrypt when we reach the end of
> the queue because __crypto_dequeue_request is not checking for NULL
> before it subtracts offset.

Where we subtract the offset the pointer can never be NULL.  Please
try my patch.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
