From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Using the aesni generic gcm(aes) aead in atomic context
Date: Tue, 31 Oct 2017 12:10:15 +0800
Message-ID: <20171031041015.GB24806@gondor.apana.org.au>
References: <AM4PR0501MB2723742986C5098642C50D01D4590@AM4PR0501MB2723.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "sd@queasysnail.net" <sd@queasysnail.net>,
        Boris Pismenny <borisp@mellanox.com>
To: Ilya Lesokhin <ilyal@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:51254 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751024AbdJaEKl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 00:10:41 -0400
Content-Disposition: inline
In-Reply-To: <AM4PR0501MB2723742986C5098642C50D01D4590@AM4PR0501MB2723.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 03:18:21PM +0000, Ilya Lesokhin wrote:
> Hi,
> I've tried using the aesni generic gcm(aes) aead to implement TLS SW fallback and
> I'm getting 
> [ 3356.839506] BUG: sleeping function called from invalid context at ./include/crypto/algapi.h:417
> 
> The warning is coming from a ___might_sleep() macro that is called if CRYPTO_TFM_REQ_MAY_SLEEP is set.
> I'm getting the warning regardless of if pass CRYPTO_ALG_ASYNC or 0 as flags to crypto_alloc_aead("gcm(aes)", 0, flags).
> 
> I've also noticed that rfc4106_encrypt() includes a irq_fpu_usable() check while generic_gcmaes_encrypt() doesn't. 
> Is the generic gcm(aes) aead unsafe in atomic context?
> And if so which aead should I use?
> 
> Finally, out of curiosity, doesn't macsec crypto run in atomic context?

Are you allocating the tfm from atomic context? That is not allowed.

Normally you would allocate the tfm in process context, e.g., when
the connection is setup.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
