From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] ipv6: fix two typos in a comment in xfrm6_init()
Date: Fri, 9 Nov 2012 08:57:26 +0100
Message-ID: <20121109075726.GD22290@secunet.com>
References: <1352363888-14068-1-git-send-email-roy.qing.li@gmail.com>
 <20121108141936.GC22290@secunet.com>
 <20121108.145939.2274479010583117059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57696 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750711Ab2KIH5d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2012 02:57:33 -0500
Content-Disposition: inline
In-Reply-To: <20121108.145939.2274479010583117059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 08, 2012 at 02:59:39PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> > 
> > The routing cache is removed, so this comment is obsolete. But it reminds
> > me that we set the gc threshold to ip_rt_max_size/2 in ipv4. With the
> > routing cache removal patch, ip_rt_max_size was set to INT_MAX. So the gc
> > starts to remove entries when a threshold of INT_MAX/2 is reached.
> > 
> > cat /proc/sys/net/ipv4/xfrm4_gc_thresh
> > 1073741823
> > 
> > I guess this was not intentional.
> 
> Do you mean for IPSEC routes?  For non-IPSEC routes on ipv4 there
> is nothing to garbage collect.

Yes, I mean IPsec routes. We still cache them at the flow cache
and at sockets, so we should do some garbage collecting.

We could either go back to a static threshold, as it was before

git commit a33bc5c15154c835aae26f16e6a3a7d9ad4acb45
xfrm: select sane defaults for xfrm[4|6] gc_thresh

or do the same as ipv6 does. I'll take care of this.

Btw. it seems to me that the flow cache has similar limitations
as the routing cache had. At least I was able to fill the flow
cache with a nmap scan from a remote entity. In practice, it's
hard to DOS the flow cache because we use a Jenkins hash with
a random initialization value, but this was the same with the
routing cache.
