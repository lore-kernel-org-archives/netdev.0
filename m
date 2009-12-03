From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] crypto: gmac - Add RFC4543 wrapper for GCM
Date: Thu, 3 Dec 2009 11:50:13 +0800
Message-ID: <20091203035013.GA15252@gondor.apana.org.au>
References: <4B154918.7070008@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Tobias Brunner <tobias@strongswan.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B154918.7070008@strongswan.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 01, 2009 at 05:49:28PM +0100, Tobias Brunner wrote:
> This patch adds the RFC4543 (GMAC) wrapper for GCM similar to the
> existing RFC4106 wrapper. The main differences between GCM and GMAC are
> the contents of the AAD and that the plaintext is empty for the latter.
> 
> Signed-off-by: Tobias Brunner <tobias@strongswan.org>
> ---
>  crypto/gcm.c            |  275 +++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/pfkeyv2.h |    1 +
>  net/xfrm/xfrm_algo.c    |   16 +++
>  3 files changed, 292 insertions(+), 0 deletions(-)
> 
> diff --git a/crypto/gcm.c b/crypto/gcm.c
> index 5fc3292..b097eb4 100644
> --- a/crypto/gcm.c
> +++ b/crypto/gcm.c
> @@ -37,6 +37,15 @@ struct crypto_rfc4106_ctx {
>  	u8 nonce[4];
>  };
>  
> +struct crypto_rfc4543_ctx {
> +	struct crypto_aead *child;
> +	u8 nonce[4];
> +	u8 auth_tag[16];

This field needs to be aligned to whatever alignment needed by
the underlying cipher algorithm (currently the biggest is padlock
which needs 16-byte alignment).

See for example how rfc4543/gcm handles it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
