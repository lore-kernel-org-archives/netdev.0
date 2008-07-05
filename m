From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] xfrm: Fix inter family IPsec tunnel handling again
Date: Sat, 5 Jul 2008 19:56:55 +0800
Message-ID: <20080705115654.GA18290@gondor.apana.org.au>
References: <20080705071950.GA26532@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48777 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751170AbYGEL5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2008 07:57:09 -0400
Content-Disposition: inline
In-Reply-To: <20080705071950.GA26532@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 05, 2008 at 09:19:50AM +0200, Steffen Klassert wrote:
> Move the selector family initialization behind the check for AF_UNSPEC
> and call xfrm_ip2inner_mode() in any case. So the selector family is
> intitalized and we can choose for the right inner_mode.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/xfrm/xfrm_input.c |   19 ++++---------------
>  net/xfrm/xfrm_state.c |    2 ++
>  net/xfrm/xfrm_user.c  |    4 ----
>  3 files changed, 6 insertions(+), 19 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
> index 7527940..d220ecf 100644
> --- a/net/xfrm/xfrm_input.c
> +++ b/net/xfrm/xfrm_input.c
> @@ -91,11 +91,9 @@ int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb)
>  	if (err)
>  		return err;
>  
> -	if (x->sel.family == AF_UNSPEC) {
> -		inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
> -		if (inner_mode == NULL)
> -			return -EAFNOSUPPORT;
> -	}
> +	inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
> +	if (inner_mode == NULL)
> +		return -EAFNOSUPPORT;

If sel.family is specified, inner_mode should already be set, no?
Overriding it would seem insecure.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
