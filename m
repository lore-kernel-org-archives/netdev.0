From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] GRO: fix merging a paged skb after non-paged skbs
Date: Tue, 8 Feb 2011 19:49:28 +1100
Message-ID: <20110208084928.GA27505@gondor.apana.org.au>
References: <20110124184752.1d0947dd@delilah> <1295918675.4105.5.camel@localhost> <1297111160.4077.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Schmidt <mschmidt@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:56401 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438Ab1BHIth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 03:49:37 -0500
Content-Disposition: inline
In-Reply-To: <1297111160.4077.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 07, 2011 at 08:39:20PM +0000, Ben Hutchings wrote:
> 
> That is indeed the case; commit da3bc07171dff957906cbe2ad5abb443eccf57c4
> made the following deletions:
> 
> -       /* Both our generic-LRO and SFC-SSR support skb and page based
> -        * allocation, but neither support switching from one to the
> -        * other on the fly. If we spot that the allocation mode has
> -        * changed, then flush the LRO state.
> -        */
> -       if (unlikely(channel->rx_alloc_pop_pages != (rx_buf->page != NULL))) {
> -               efx_flush_lro(channel);
> -               channel->rx_alloc_pop_pages = (rx_buf->page != NULL);
> -       }

Oops, sorry about that.

How about changing skb_gro_receive to detect such switches and
simply return an error, which should have the same effect as
flushing that flow?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
