From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Have af-specific init_tempsel() initialize family
	field of temporary selector
Date: Tue, 4 Nov 2008 19:24:24 +0800
Message-ID: <20081104112424.GB11049@gondor.apana.org.au>
References: <87hc6npz4c.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andreas Steffen <andreas.steffen@strongswan.org>,
	Martin Willi <martin@strongswan.org>,
	Kazunori MIYAZAWA <kazunori@miyazawa.org>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51609 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753170AbYKDLYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 06:24:33 -0500
Content-Disposition: inline
In-Reply-To: <87hc6npz4c.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 04, 2008 at 11:24:51AM +0100, Arnaud Ebalard wrote:
> Hi,
> 
> While adding MIGRATE support to strongSwan, Andreas Steffen noticed that
> the selectors provided in XFRM_MSG_ACQUIRE have their family field
> uninitialized (those in MIGRATE do have their family set).
> 
> Looking at the code, this is because the af-specific init_tempsel()
> (called via afinfo->init_tempsel() in xfrm_init_tempsel()) do not set
> the value.
> 
> Even if current apps probably do not rely on it, is there any argument
> for not doing it or is it just an omission?
> 
> The patch below is more for discussion than anything else.

We should ask the MIP6 folks since this may affect them.

> Reported-by: Andreas Steffen <andreas.steffen@strongswan.org>
> Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
> ---
>  net/ipv4/xfrm4_state.c |    1 +
>  net/ipv6/xfrm6_state.c |    1 +
>  2 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
> index 07735ed..55dc6be 100644
> --- a/net/ipv4/xfrm4_state.c
> +++ b/net/ipv4/xfrm4_state.c
> @@ -33,6 +33,7 @@ __xfrm4_init_tempsel(struct xfrm_state *x, struct flowi *fl,
>  	x->sel.dport_mask = htons(0xffff);
>  	x->sel.sport = xfrm_flowi_sport(fl);
>  	x->sel.sport_mask = htons(0xffff);
> +	x->sel.family = AF_INET;
>  	x->sel.prefixlen_d = 32;
>  	x->sel.prefixlen_s = 32;
>  	x->sel.proto = fl->proto;
> diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
> index 89884a4..60c78cf 100644
> --- a/net/ipv6/xfrm6_state.c
> +++ b/net/ipv6/xfrm6_state.c
> @@ -34,6 +34,7 @@ __xfrm6_init_tempsel(struct xfrm_state *x, struct flowi *fl,
>  	x->sel.dport_mask = htons(0xffff);
>  	x->sel.sport = xfrm_flowi_sport(fl);
>  	x->sel.sport_mask = htons(0xffff);
> +	x->sel.family = AF_INET6;
>  	x->sel.prefixlen_d = 128;
>  	x->sel.prefixlen_s = 128;
>  	x->sel.proto = fl->proto;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
