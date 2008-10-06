From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Sun, 5 Oct 2008 20:52:34 -0400
Message-ID: <20081006005234.GA5382@localhost.localdomain>
References: <20080929191254.GA20074@hmsreliant.think-freely.org> <E1KmK7b-00036t-LM@gondolin.me.apana.org.au> <20081005032047.GA11997@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56871 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186AbYJFAyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 20:54:47 -0400
Content-Disposition: inline
In-Reply-To: <20081005032047.GA11997@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 05, 2008 at 11:20:47AM +0800, Herbert Xu wrote:
> On Sun, Oct 05, 2008 at 11:17:27AM +0800, Herbert Xu wrote:
> > Neil Horman <nhorman@tuxdriver.com> wrote:
> > >        We currently have the ability to disable our route cache secret interval
> > > rebuild timer (by setting it to zero), but if we do that its possible for an
> > > attacker (if they guess our route cache hash secret, to fill our system with
> > > routes that all hash to the same bucket, destroying our performance.  This patch
> > 
> > This is completely bogus.  We never allow any chain to grow beyond
> > the elasticity.  So in the worst case we just bypass the route cache.
> 
> OK we don't actually enforce that as it stands, but perhaps we
> should have a maximum chain length that is enforced.
> 
Thank you :).  I was just about to respond with a note asking you for a
reference to your previous assertion.  We definately don't enforce that now.

I agree we should have a maximum chain legth that we enforce.  Unfortunately
according to eric, the gc_elasticity value can't be it, because we very
routinely in nominal systems have a limited number of chains that violate the
elasticity, and that should be expected.  Thats why my latest patch tries to
cover that by computing the standard deviation of the set of chains and allowing
chains within avg+4*SD to exist.  With that allowance, we should be able to
remove the periodic rehash entirely.

Best
Neil

> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 
