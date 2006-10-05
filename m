From: Jean-Philippe Andriot <jean-philippe.andriot@6WIND.com>
Subject: Re: !! SPAM Suspect : SPAM-URL-DBL !!  Re: [RFC] Disable addrconf on ~multicast interfaces?
Date: Thu, 5 Oct 2006 11:54:33 +0200
Message-ID: <20061005095433.GD2933@palpatine.dev.6wind.com>
References: <Pine.LNX.4.64.0610050907160.22625@netcore.fi> <E1GVMph-0005Do-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Savola <pekkas@netcore.fi>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:50949 "EHLO
	proxy.6wind.com") by vger.kernel.org with ESMTP id S1751575AbWJEJye
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 05:54:34 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1GVMph-0005Do-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch will break multicast forwarding using the pim6 daemon.
This daemon creates an interface called pim6reg which is not MULTICAST
enabled but needs to be configred by addrconf to get ff00::/8 and
fe80::/64 routes. This is required since the route lookup process has
been enforced to strictly match input interfaces for linklocal and
multicast packets.

Regards,
JP


On Thu, Oct 05, 2006 at 04:35:49PM +1000, Herbert Xu wrote:
> Pekka Savola <pekkas@netcore.fi> wrote:
> > On Thu, 5 Oct 2006, Herbert Xu wrote:
> >> Are there any non-multicast interfaces that require addrconf?
> >> In other words, what does the following patch break :)
> > 
> > Point-to-point (or NOARP) interfaces such as tunnels.   I'm not sure 
> > what are the right flags to check..
> 
> Tunnels shouldn't even get into that function so they aren't
> affected.  Are there any Ethernet-like interfaces which do not
> set IFF_MULTICAST yet still require addrconf?
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
