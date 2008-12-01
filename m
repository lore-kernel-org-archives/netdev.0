From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 3/5] crypto: add possibility to force sync transform
Date: Mon, 1 Dec 2008 19:22:25 +0800
Message-ID: <20081201112225.GA20659@gondor.apana.org.au>
References: <20081201071614.GP476@secunet.com> <20081201071903.GS476@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58950 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751318AbYLALW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 06:22:29 -0500
Content-Disposition: inline
In-Reply-To: <20081201071903.GS476@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 08:19:03AM +0100, Steffen Klassert wrote:
.
> diff --git a/crypto/chainiv.c b/crypto/chainiv.c
> index 7c37a49..2079fdd 100644
> --- a/crypto/chainiv.c
> +++ b/crypto/chainiv.c
> @@ -168,8 +168,12 @@ static int async_chainiv_givencrypt_tail(struct skcipher_givcrypt_request *req)
>  	memcpy(subreq->info, ctx->iv, ivsize);
>  
>  	ctx->err = crypto_ablkcipher_encrypt(subreq);
> -	if (ctx->err)
> -		goto out;
> +	if (ctx->err) {
> +		if (ablkcipher_request_flags(&req->creq) & CRYPTO_TFM_REQ_FORCE_SYNC)

If you want sync algorithms, you should request for that at alloc
time:

	crypto_alloc_ablkcipher("foo", 0, CRYPTO_ALG_ASYNC);

Doing so at run-time is going to end in tears.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
