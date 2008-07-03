From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Fix possible error pointer dereference
Date: Thu, 3 Jul 2008 17:04:03 +0800
Message-ID: <20080703090403.GA27923@gondor.apana.org.au>
References: <20080703084836.GI9549@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58972 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760555AbYGCNzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 09:55:10 -0400
Content-Disposition: inline
In-Reply-To: <20080703084836.GI9549@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 03, 2008 at 10:48:36AM +0200, Steffen Klassert wrote:
> Check for error befor dereferencing xdst in xfrm_bundle_create.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/xfrm/xfrm_policy.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index cae9fd8..9fab591 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -1384,6 +1384,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
>  	struct net_device *dev;
>  	struct dst_entry *dst_prev = NULL;
>  	struct dst_entry *dst0 = NULL;
> +	struct dst_entry *dst1 = NULL;
>  	int i = 0;
>  	int err;
>  	int header_len = 0;
> @@ -1404,7 +1405,6 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
>  
>  	for (; i < nx; i++) {
>  		struct xfrm_dst *xdst = xfrm_alloc_dst(family);
> -		struct dst_entry *dst1 = &xdst->u.dst;

Please check again, we're not dereferencing it here.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
