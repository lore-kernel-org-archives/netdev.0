From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 0/4] Fix routing metrics
Date: Fri, 10 Feb 2012 07:50:31 +0100
Message-ID: <20120210065031.GK23142@secunet.com>
References: <20120208073037.GI23142@secunet.com>
 <20120208.151837.75403230557283008.davem@davemloft.net>
 <20120209124411.GJ23142@secunet.com>
 <20120209.134010.832064360325335834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50065 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751810Ab2BJGuf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 01:50:35 -0500
Content-Disposition: inline
In-Reply-To: <20120209.134010.832064360325335834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 09, 2012 at 01:40:10PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> > 
> > Hm, I still don't get your point. Could you specify this please?
> > 
> > When a route cache entry is created and the peer_genid does not match
> > the genid on the inetpeer, fresh inetpeer metrics are allocated  and
> > then published. After that, the new metrics are in proper state and
> > ready to use.
> 
> Right, which is exactly what you want to happen.
> 
> Checking on every metric access is therefore pointless and needless.
> 
> The peer_genid only increments when the routing cache is flushed,
> therefore every subsequent access to the metrics will go through the
> route cache entry creation path first, and therefore that will make
> sure fresh inetpeer metrics will be allocated since the peer_genid
> does not match.

I fully agree with you here. But we check for the genid just in
rt_init_metrics() which is invoked only on route cache entry
creation. There is no check when the metrics are accessed,
because the metrics on the inetpeer are valid on every access.
