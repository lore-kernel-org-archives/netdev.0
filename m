From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 1/1] sysctl configurable icmperror sourceaddress
Date: Thu, 9 Jun 2005 01:40:29 +0200
Message-ID: <20050608234029.GJ28207@xi.wantstofly.org>
References: <1118136384.10479.15.camel@jeroens.office.netland.nl> <20050608214540.GF28207@xi.wantstofly.org> <20050608.144941.26530856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050608.144941.26530856.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 08, 2005 at 02:49:41PM -0700, David S. Miller wrote:

> > Can this patch go in, pretty please?
> > 
> > Here's the patch again for reference:
> 
> We have a similar sysctl for ARP handling, why don't
> we make use of it?

Which one do you mean, the arp_{filter,announce,ignore} ones?  IMHO
this is a very different issue, this patch just selects which source
address we use when we reply to a packet with an ICMP.

In the case below, if all routers are linux routers, a traceroute
from source to dest will show something like this:
	1 10.0.0.254 x.xxx ms x.xxx ms x.xxx ms
	2 12.0.0.100 x.xxx ms x.xxx ms x.xxx ms
	3 12.0.0.1 x.xxx ms x.xxx ms x.xxx ms

Whereas we'd prefer seeing this, partly because it makes more sense,
partly because a very large fraction of networking hardware does it
this way too:
	1 10.0.0.254 x.xxx ms x.xxx ms x.xxx ms
	2 11.0.0.100 x.xxx ms x.xxx ms x.xxx ms   <===
	3 12.0.0.1 x.xxx ms x.xxx ms x.xxx ms

I used to work at an ISP and there are a number of practical cases
where the linux behavior is rather confusing.


cheers,
Lennert


	+------------+
	|   source   |
	|  10.0.0.1  |
	+-----+------+
	      |
	      V
	      |
	      |
	+-----+------+
	| 10.0.0.254 |
	|            |
	|   router1  +---------------------+
	|            |                     |
	| 11.0.0.254 |                     |
	+-----+------+                     |
	      |                            |
	      V                            ^ asymmetric route
	      |                            |  back to source
	      |                            |
	+-----+------+               +-----+------+
	| 11.0.0.100 |               | 13.0.0.13  |
	|            |               |            |
	|   router2  |               |   router3  |
	|            |               |            |
	| 12.0.0.100 |               | 12.0.0.101 |
	+-----+------+               +-----+------+
	      |                            |
	      +------------->--------------+
	      V
	      |
	+-----+------+
	|    dest    |
	|  12.0.0.1  |
	+------------+
