From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Fri, 23 Dec 2011 09:47:37 +0100
Message-ID: <20111223084737.GU6348@secunet.com>
References: <20111221085616.GO6348@secunet.com>
 <20111221.155615.990885397853981125.davem@davemloft.net>
 <20111222102526.GT6348@secunet.com>
 <20111222.135127.1577166695312077920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39773 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752068Ab1LWIrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Dec 2011 03:47:40 -0500
Content-Disposition: inline
In-Reply-To: <20111222.135127.1577166695312077920.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 22, 2011 at 01:51:27PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Thu, 22 Dec 2011 11:25:26 +0100
> 
> > Actually, I'm getting some doubts on the concept of caching
> > the metrics on the inetpeer. How should we handle the case when
> > we have multiple routes with different metrics to the same
> > destination? As it is, we can cache just one of them on the
> > inetpeer.
> 
> In such cases the metrics won't be perfect.
> 
> Actually, we have two kinds of metrics and it might be best in the
> long term to seperate them out explicitly.
> 
> We have "loose" metrics (such as all the TCP measurements) which,
> if incorrect, will lead to suboptimal performance but will not
> dramatically effect connectivity.
> 
> Then we have "strict" metrics like PMTU information and redirects,
> which could have more fatal consequences if wrong.
> 
> The core issue is I want to keep these things tied only to destination
> address, it is the only sane way to get the routing cache removed.
> 
> Sockets and the packet forwarding path in the future will be using
> routes that cover whole subnets, or even the default route.  There
> will be no "rt->rt_dst" and there will also be not attached inetpeer.
> 
> The inetpeer, or something like it, will be managed seperately.
> Therefore metrics will need to be calculated using both objects (rt
> and inetpeer).
> 
> This is one of the longer term design issues we face in the routing
> cache removal and for which I don't have exact plans for yet.  I'm
> still concentrating on "ref-less" neighbour entries, so once I finish
> that work I can think more seriously about metrics in a world without
> the routing cache.

Ok, so let's try to keep the things working as good as possible at this
intermediate stage and see how it evolves. I know that you want to remove
the routing cache, but I did not care too much in the beginning. So I
missed the reason why you want to do that. Could you please give a short
explaination or point me to where I can find this informations?
