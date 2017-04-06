From: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Subject: Re: [PATCH 1/4] crypto: user - Prepare for CRYPTO_MAX_ALG_NAME
 expansion
Date: Thu, 6 Apr 2017 17:10:27 +0200
Message-ID: <508e733a-b0ba-0978-8ec3-b07f151c47df@nokia.com>
References: <20170406081509.GB30557@gondor.apana.org.au>
 <E1cw2aO-00085E-NH@gondobar>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        <linux-crypto@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <E1cw2aO-00085E-NH@gondobar>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/04/17 10:16, Herbert Xu wrote:
> This patch hard-codes CRYPTO_MAX_NAME in the user-space API to
> 64, which is the current value of CRYPTO_MAX_ALG_NAME.  This patch
> also replaces all remaining occurences of CRYPTO_MAX_ALG_NAME
> in the user-space API with CRYPTO_MAX_NAME.
> 
> This way the user-space API will not be modified when we raise
> the value of CRYPTO_MAX_ALG_NAME.
> 
> Furthermore, the code has been updated to handle names longer than
> the user-space API.  They will be truncated.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Tested-by: Alexander Sverdlin <alexander.sverdlin@nokia.com>

> ---
> 
>  crypto/crypto_user.c            |   18 +++++++++---------
>  include/uapi/linux/cryptouser.h |   10 +++++-----
>  2 files changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
> index a90404a..89acaab 100644
> --- a/crypto/crypto_user.c
> +++ b/crypto/crypto_user.c
> @@ -83,7 +83,7 @@ static int crypto_report_cipher(struct sk_buff *skb, struct crypto_alg *alg)
>  {
>  	struct crypto_report_cipher rcipher;
>  
> -	strncpy(rcipher.type, "cipher", sizeof(rcipher.type));
> +	strlcpy(rcipher.type, "cipher", sizeof(rcipher.type));
>  
>  	rcipher.blocksize = alg->cra_blocksize;
>  	rcipher.min_keysize = alg->cra_cipher.cia_min_keysize;
> @@ -102,7 +102,7 @@ static int crypto_report_comp(struct sk_buff *skb, struct crypto_alg *alg)
>  {
>  	struct crypto_report_comp rcomp;
>  
> -	strncpy(rcomp.type, "compression", sizeof(rcomp.type));
> +	strlcpy(rcomp.type, "compression", sizeof(rcomp.type));
>  	if (nla_put(skb, CRYPTOCFGA_REPORT_COMPRESS,
>  		    sizeof(struct crypto_report_comp), &rcomp))
>  		goto nla_put_failure;
> @@ -116,7 +116,7 @@ static int crypto_report_acomp(struct sk_buff *skb, struct crypto_alg *alg)
>  {
>  	struct crypto_report_acomp racomp;
>  
> -	strncpy(racomp.type, "acomp", sizeof(racomp.type));
> +	strlcpy(racomp.type, "acomp", sizeof(racomp.type));
>  
>  	if (nla_put(skb, CRYPTOCFGA_REPORT_ACOMP,
>  		    sizeof(struct crypto_report_acomp), &racomp))
> @@ -131,7 +131,7 @@ static int crypto_report_akcipher(struct sk_buff *skb, struct crypto_alg *alg)
>  {
>  	struct crypto_report_akcipher rakcipher;
>  
> -	strncpy(rakcipher.type, "akcipher", sizeof(rakcipher.type));
> +	strlcpy(rakcipher.type, "akcipher", sizeof(rakcipher.type));
>  
>  	if (nla_put(skb, CRYPTOCFGA_REPORT_AKCIPHER,
>  		    sizeof(struct crypto_report_akcipher), &rakcipher))
> @@ -146,7 +146,7 @@ static int crypto_report_kpp(struct sk_buff *skb, struct crypto_alg *alg)
>  {
>  	struct crypto_report_kpp rkpp;
>  
> -	strncpy(rkpp.type, "kpp", sizeof(rkpp.type));
> +	strlcpy(rkpp.type, "kpp", sizeof(rkpp.type));
>  
>  	if (nla_put(skb, CRYPTOCFGA_REPORT_KPP,
>  		    sizeof(struct crypto_report_kpp), &rkpp))
> @@ -160,10 +160,10 @@ static int crypto_report_kpp(struct sk_buff *skb, struct crypto_alg *alg)
>  static int crypto_report_one(struct crypto_alg *alg,
>  			     struct crypto_user_alg *ualg, struct sk_buff *skb)
>  {
> -	strncpy(ualg->cru_name, alg->cra_name, sizeof(ualg->cru_name));
> -	strncpy(ualg->cru_driver_name, alg->cra_driver_name,
> +	strlcpy(ualg->cru_name, alg->cra_name, sizeof(ualg->cru_name));
> +	strlcpy(ualg->cru_driver_name, alg->cra_driver_name,
>  		sizeof(ualg->cru_driver_name));
> -	strncpy(ualg->cru_module_name, module_name(alg->cra_module),
> +	strlcpy(ualg->cru_module_name, module_name(alg->cra_module),
>  		sizeof(ualg->cru_module_name));
>  
>  	ualg->cru_type = 0;
> @@ -176,7 +176,7 @@ static int crypto_report_one(struct crypto_alg *alg,
>  	if (alg->cra_flags & CRYPTO_ALG_LARVAL) {
>  		struct crypto_report_larval rl;
>  
> -		strncpy(rl.type, "larval", sizeof(rl.type));
> +		strlcpy(rl.type, "larval", sizeof(rl.type));
>  		if (nla_put(skb, CRYPTOCFGA_REPORT_LARVAL,
>  			    sizeof(struct crypto_report_larval), &rl))
>  			goto nla_put_failure;
> diff --git a/include/uapi/linux/cryptouser.h b/include/uapi/linux/cryptouser.h
> index 11d21fc..b4def5c 100644
> --- a/include/uapi/linux/cryptouser.h
> +++ b/include/uapi/linux/cryptouser.h
> @@ -31,7 +31,7 @@ enum {
>  #define CRYPTO_MSG_MAX (__CRYPTO_MSG_MAX - 1)
>  #define CRYPTO_NR_MSGTYPES (CRYPTO_MSG_MAX + 1 - CRYPTO_MSG_BASE)
>  
> -#define CRYPTO_MAX_NAME CRYPTO_MAX_ALG_NAME
> +#define CRYPTO_MAX_NAME 64
>  
>  /* Netlink message attributes.  */
>  enum crypto_attr_type_t {
> @@ -53,9 +53,9 @@ enum crypto_attr_type_t {
>  };
>  
>  struct crypto_user_alg {
> -	char cru_name[CRYPTO_MAX_ALG_NAME];
> -	char cru_driver_name[CRYPTO_MAX_ALG_NAME];
> -	char cru_module_name[CRYPTO_MAX_ALG_NAME];
> +	char cru_name[CRYPTO_MAX_NAME];
> +	char cru_driver_name[CRYPTO_MAX_NAME];
> +	char cru_module_name[CRYPTO_MAX_NAME];
>  	__u32 cru_type;
>  	__u32 cru_mask;
>  	__u32 cru_refcnt;
> @@ -73,7 +73,7 @@ struct crypto_report_hash {
>  };
>  
>  struct crypto_report_cipher {
> -	char type[CRYPTO_MAX_ALG_NAME];
> +	char type[CRYPTO_MAX_NAME];
>  	unsigned int blocksize;
>  	unsigned int min_keysize;
>  	unsigned int max_keysize;
> 

-- 
Best regards,
Alexander Sverdlin.
