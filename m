From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 0/4] Fix routing metrics
Date: Fri, 10 Feb 2012 09:44:25 +0100
Message-ID: <20120210084424.GM23142@secunet.com>
References: <20120210065031.GK23142@secunet.com>
 <20120210.023815.192069104397847238.davem@davemloft.net>
 <20120210075106.GL23142@secunet.com>
 <20120210.031211.2297215055759518521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51202 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753419Ab2BJIob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 03:44:31 -0500
Content-Disposition: inline
In-Reply-To: <20120210.031211.2297215055759518521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2012 at 03:12:11AM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Fri, 10 Feb 2012 08:51:07 +0100
> 
> > On Fri, Feb 10, 2012 at 02:38:15AM -0500, David Miller wrote:
> >> From: Steffen Klassert <steffen.klassert@secunet.com>
> >> > 
> >> > I fully agree with you here. But we check for the genid just in
> >> > rt_init_metrics() which is invoked only on route cache entry
> >> > creation. There is no check when the metrics are accessed,
> >> > because the metrics on the inetpeer are valid on every access.
> >> 
> >> Every routing cache entry we will use after the flush will be
> >> a newly created one!  All the old ones will be stop being used.
> > 
> > Yes, I know that. All inetpeer metrics are updated once with the
> > first new routing cache entry that binds that inetpeer to the route.
> 
> And after a routing cache flush, that will be all routing cache
> entries every used after that point.

Yes, the genid check happens once for every new routing cache entry
we recreate. After that, we'll find maching routes in the cache
and we don't do that check.

> 
> So since this happens, you don't need to check the inetpeer at every
> metric access.  The fact that all routing cache entries get recreated
> will do it for you.

So if rt_init_metrics() is not the right place to check for genid
changes, where would you suggest to do it?
