From: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Subject: Re: [PATCH 3/4] xfrm: Prepare for CRYPTO_MAX_ALG_NAME expansion
Date: Thu, 6 Apr 2017 17:10:56 +0200
Message-ID: <b80cd89e-0ec2-1d81-9c34-f0d31d079db8@nokia.com>
References: <20170406081509.GB30557@gondor.apana.org.au>
 <E1cw2aQ-00085u-SY@gondobar>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        <linux-crypto@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <E1cw2aQ-00085u-SY@gondobar>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/04/17 10:16, Herbert Xu wrote:
> This patch fixes the xfrm_user code to use the actual array size
> rather than the hard-coded CRYPTO_MAX_ALG_NAME length.  This is
> because the array size is fixed at 64 bytes while we want to increase
> the in-kernel CRYPTO_MAX_ALG_NAME value.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Tested-by: Alexander Sverdlin <alexander.sverdlin@nokia.com>

> ---
> 
>  net/xfrm/xfrm_user.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> index 9705c27..96557cf 100644
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
> @@ -55,7 +55,7 @@ static int verify_one_alg(struct nlattr **attrs, enum xfrm_attr_type_t type)
>  		return -EINVAL;
>  	}
>  
> -	algp->alg_name[CRYPTO_MAX_ALG_NAME - 1] = '\0';
> +	algp->alg_name[sizeof(algp->alg_name) - 1] = '\0';
>  	return 0;
>  }
>  
> @@ -71,7 +71,7 @@ static int verify_auth_trunc(struct nlattr **attrs)
>  	if (nla_len(rt) < xfrm_alg_auth_len(algp))
>  		return -EINVAL;
>  
> -	algp->alg_name[CRYPTO_MAX_ALG_NAME - 1] = '\0';
> +	algp->alg_name[sizeof(algp->alg_name) - 1] = '\0';
>  	return 0;
>  }
>  
> @@ -87,7 +87,7 @@ static int verify_aead(struct nlattr **attrs)
>  	if (nla_len(rt) < aead_len(algp))
>  		return -EINVAL;
>  
> -	algp->alg_name[CRYPTO_MAX_ALG_NAME - 1] = '\0';
> +	algp->alg_name[sizeof(algp->alg_name) - 1] = '\0';
>  	return 0;
>  }
>  
> 

-- 
Best regards,
Alexander Sverdlin.
