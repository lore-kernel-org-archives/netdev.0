From: David Miller <davem@davemloft.net>
Subject: Re: [NET] IPv6 oops bisected
Date: Sun, 07 Oct 2007 23:23:02 -0700 (PDT)
Message-ID: <20071007.232302.78733656.davem@davemloft.net>
References: <4708F387.1060602@garzik.org>
	<20071007.231608.104667710.davem@davemloft.net>
	<20071008061942.GA842@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, dlunev@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	den@openvz.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51742
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751489AbXJHGXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 02:23:03 -0400
In-Reply-To: <20071008061942.GA842@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 8 Oct 2007 14:19:42 +0800

> On Sun, Oct 07, 2007 at 11:16:08PM -0700, David Miller wrote:
> >
> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > index a7db84c..7109ad6 100644
> > --- a/net/ipv6/route.c
> > +++ b/net/ipv6/route.c
> > @@ -1188,7 +1188,7 @@ int ip6_route_add(struct fib6_config *cfg)
> >  	if ((cfg->fc_flags & RTF_REJECT) ||
> >  	    (dev && (dev->flags&IFF_LOOPBACK) && !(addr_type&IPV6_ADDR_LOOPBACK))) {
> >  		/* hold loopback dev/idev if we haven't done so. */
> > -		if (dev != dev->nd_net->loopback_dev) {
> > +		if (!dev || (dev != dev->nd_net->loopback_dev)) {
> >  			if (dev) {
> >  				dev_put(dev);
> >  				in6_dev_put(idev);
> 
> Unfortunately this'll still oops a few lines down when it tries
> to assign dev->nd_net->loopabck_dev to dev.  The issue here is
> which namespace are we in if dev is NULL.

Good catch.

I'm just going to revert my bogus fix and the original change
for now.  Denis can resubmit the original patch once this
is resolved.
