From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: implement basic garbage collection for bundles
Date: Sat, 20 Mar 2010 20:32:48 +0800
Message-ID: <20100320123247.GB1930@gondor.apana.org.au>
References: <1269087341-7009-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47540 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751824Ab0CTMcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 08:32:51 -0400
Content-Disposition: inline
In-Reply-To: <1269087341-7009-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 20, 2010 at 02:15:41PM +0200, Timo Teras wrote:
> The dst core calls garbage collection only from dst_alloc when
> the dst entry threshold is exceeded. Xfrm core currently checks
> bundles only on NETDEV_DOWN event.
> 
> Previously this has not been a big problem since xfrm gc threshold
> was small, and they were generated all the time due to another bug.
> 
> Since after a33bc5c15154c835aae26f16e6a3a7d9ad4acb45
> ("xfrm: select sane defaults for xfrm[4|6] gc_thresh") we can have
> large gc threshold sizes (>200000 on machines with normal amount
> of memory) the garbage collection does not get triggered under
> normal circumstances. This can result in enormous amount of stale
> bundles. Further more, each of these stale bundles keep a reference
> to ipv4/ipv6 rtable entries which are already gargage collected and
> put to dst core "destroy free'd dst's" list. Now this list can grow
> to be very large, and the dst core periodic job can bring even a fast
> machine to it's knees.

So why do we need this larger threshold in the first place? Neil?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
