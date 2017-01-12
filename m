From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v1 3/8] crypto:chcr- Fix key length for RFC4106
Date: Fri, 13 Jan 2017 00:09:59 +0800
Message-ID: <20170112160959.GA19732@gondor.apana.org.au>
References: <cover.1483599449.git.harsh@chelsio.com>
 <6d8e61299e051d51dacdb6bfd6c5e582b230027c.1483599449.git.harsh@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
        linux-crypto@vger.kernel.org
To: Harsh Jain <harsh@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:51405 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751049AbdALQKH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 11:10:07 -0500
Content-Disposition: inline
In-Reply-To: <6d8e61299e051d51dacdb6bfd6c5e582b230027c.1483599449.git.harsh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 06, 2017 at 02:01:34PM +0530, Harsh Jain wrote:
> Check keylen before copying salt to avoid wrap around of Integer.
> 
> Signed-off-by: Harsh Jain <harsh@chelsio.com>
> ---
>  drivers/crypto/chelsio/chcr_algo.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
> index deec7c0..6c2dea3 100644
> --- a/drivers/crypto/chelsio/chcr_algo.c
> +++ b/drivers/crypto/chelsio/chcr_algo.c
> @@ -2194,8 +2194,8 @@ static int chcr_gcm_setkey(struct crypto_aead *aead, const u8 *key,
>  	unsigned int ck_size;
>  	int ret = 0, key_ctx_size = 0;
>  
> -	if (get_aead_subtype(aead) ==
> -	    CRYPTO_ALG_SUB_TYPE_AEAD_RFC4106) {
> +	if (get_aead_subtype(aead) == CRYPTO_ALG_SUB_TYPE_AEAD_RFC4106 &&
> +	    keylen > 3) {
>  		keylen -= 4;  /* nonce/salt is present in the last 4 bytes */
>  		memcpy(aeadctx->salt, key + keylen, 4);
>  	}

We should return an error in this case.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
