From: Alexander Sverdlin <alexander.sverdlin@nokia.com>
Subject: Re: [PATCH 2/4] crypto: af_alg - Allow arbitrarily long algorithm
 names
Date: Thu, 6 Apr 2017 14:32:27 +0200
Message-ID: <32d123fa-5c5f-4db6-d333-24b71639b738@nokia.com>
References: <20170406081509.GB30557@gondor.apana.org.au>
 <E1cw2aP-00085S-Q4@gondobar>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        <linux-crypto@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0115.outbound.protection.outlook.com ([104.47.1.115]:22848
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757171AbdDFMdf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 08:33:35 -0400
In-Reply-To: <E1cw2aP-00085S-Q4@gondobar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On 06/04/17 10:16, Herbert Xu wrote:
> This patch removes the hard-coded 64-byte limit on the length
> of the algorithm name through bind(2).  The address length can
> now exceed that.  The user-space structure remains unchanged.
> In order to use a longer name simply extend the salg_name array
> beyond its defined 64 bytes length.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> 
>  crypto/af_alg.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/crypto/af_alg.c b/crypto/af_alg.c
> index 690deca..3556d8e 100644
> --- a/crypto/af_alg.c
> +++ b/crypto/af_alg.c
> @@ -160,11 +160,11 @@ static int alg_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>  	if (sock->state == SS_CONNECTED)
>  		return -EINVAL;
>  
> -	if (addr_len != sizeof(*sa))
> +	if (addr_len < sizeof(*sa))
>  		return -EINVAL;
>  
>  	sa->salg_type[sizeof(sa->salg_type) - 1] = 0;
> -	sa->salg_name[sizeof(sa->salg_name) - 1] = 0;
> +	sa->salg_name[sizeof(sa->salg_name) + addr_len - sizeof(*sa) - 1] = 0;
>  
>  	type = alg_get_type(sa->salg_type);
>  	if (IS_ERR(type) && PTR_ERR(type) == -ENOENT) {

Why should userspace ever extend the structure if salg_name is hardcoded to 64 in if_alg.h?
This patch doesn't change the behavior at all, or am I missing something?

-- 
Best regards,
Alexander Sverdlin.
