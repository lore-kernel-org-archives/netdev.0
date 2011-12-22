From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Thu, 22 Dec 2011 11:25:26 +0100
Message-ID: <20111222102526.GT6348@secunet.com>
References: <20111220071843.GL6348@secunet.com>
 <20111220.133542.2144336048061483258.davem@davemloft.net>
 <20111221085616.GO6348@secunet.com>
 <20111221.155615.990885397853981125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:59930 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753524Ab1LVKZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Dec 2011 05:25:29 -0500
Content-Disposition: inline
In-Reply-To: <20111221.155615.990885397853981125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2011 at 03:56:15PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Wed, 21 Dec 2011 09:56:16 +0100
> 
> > My decscription was a bit missleading, sorry. This seems to be not
> > even related to pmtu handling. It's just that we don't use the
> > user configured metrics on the fib entry if we find an inetpeer
> > with metrics that are not in INETPEER_METRICS_NEW state when we
> > initialize the routing metrics in rt_init_metrics(). I tried to add
> > a route with a hoplimit, this has also no effect if the metrics on
> > the inetpeer are not new.
> 
> Ok, so what you're saying is that we need a way to invalidate inetpeer
> entries, or at least invalidate their cached metrics and set
> INETPEER_METRICS_NEW once more.

Yes, we probaply need to invalidate whenever the fib changes.
We would have to invalidate at least the cached metrics and
all the pmtu related stuff we have on the inetpeer now.
Not sure if it is better to just invalidate some pieces
or the whole inetpeer entries.

Actually, I'm getting some doubts on the concept of caching
the metrics on the inetpeer. How should we handle the case when
we have multiple routes with different metrics to the same
destination? As it is, we can cache just one of them on the
inetpeer.
