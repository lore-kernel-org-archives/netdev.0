From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] GRE: Use IS_ERR_OR_NULL in gre_gso_segment
Date: Fri, 26 Apr 2013 11:38:33 +0800
Message-ID: <20130426033833.GA1782@gondor.apana.org.au>
References: <20130423075042.GA25776@verge.net.au>
 <CAEP_g=93aAXPk+A2u7LzAzEk6Fr33y7HiEMmXBCEkD8+B90kZQ@mail.gmail.com>
 <20130425084617.GA27463@gondor.apana.org.au>
 <20130425.050157.1080837692941670798.davem@davemloft.net>
 <20130425090346.GA27618@gondor.apana.org.au>
 <20130425091151.GA27681@gondor.apana.org.au>
 <1366898314.8964.135.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jesse@nicira.com,
	horms@verge.net.au, netdev@vger.kernel.org, xeb@mail.ru
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:45834 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759855Ab3DZDio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 23:38:44 -0400
Content-Disposition: inline
In-Reply-To: <1366898314.8964.135.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 25, 2013 at 06:58:34AM -0700, Eric Dumazet wrote:
> On Thu, 2013-04-25 at 17:11 +0800, Herbert Xu wrote:
> 
> > In any case, returning an error in this case makes little sense
> > because when we return NULL it is precisely because the packet is
> > well-formed and ready for direct processing by the hardware which
> > will perform GSO instead of us.
> > 
> > The reason this dichotomy exists is because we've reused the
> > normal software GSO path to do header verification for hardware
> > GSO.
> > 
> 
> OK, then current code is fine. Comments will save future 'cleanups'.

Looks good to me.  Either this or add a wrapper so that the comments
don't get out-of-sync since this construct is used in multiple
places.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
