From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] Avoid multi-page allocs for large mtu datagram sends
Date: Thu, 13 Apr 2006 22:57:49 +1000
Message-ID: <20060413125749.GA25452@gondor.apana.org.au>
References: <20060405175102.GA28166@tetsuo.zabbo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58386 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964914AbWDMM5w
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 08:57:52 -0400
To: Zach Brown <zach.brown@oracle.com>
Content-Disposition: inline
In-Reply-To: <20060405175102.GA28166@tetsuo.zabbo.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Zach:

On Wed, Apr 05, 2006 at 05:51:02PM +0000, Zach Brown wrote:
>
> +			if ((rt->u.dst.dev->features&NETIF_F_SG) &&
> +			    (SKB_DATA_KMALLOC_BYTES(alloclen + datalen)
> +								> PAGE_SIZE)) {
> +				/*
> +				 * datalen is shrinking so there won't be a
> +				 * trailer, but alloclen already accounted for
> +				 * it.  use that space for payload but only if
> +				 * it wasn't the trailer_len itself that pushed
> +				 * the alloc beyond a single page.
> +				 */
> +				if (datalen - SKB_MAX_ORDER(alloclen, 0) >
> +				    rt->u.dst.trailer_len)
> +					alloclen -= rt->u.dst.trailer_len;

I think this should be done unconditionally.  First of all at this
time ESP doesn't know how to deal with this anyway so it's just going
to reallocate and linearise the whole thing.  However, when we do fix
it we can just get it to allocate the trailer in its own frag so we
don't need to worry about trailer_len at all.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
