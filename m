From: David Lamparter <equinox@diac24.net>
Subject: Re: Subnet router anycast for FE80/10 ?
Date: Wed, 2 Nov 2011 16:38:09 +0100
Message-ID: <20111102153809.GH297914@jupiter.n2.diac24.net>
References: <4EAF0391.80907@collax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andreas Hofmeister <andi@collax.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:36056 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753567Ab1KBPiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 11:38:15 -0400
Content-Disposition: inline
In-Reply-To: <4EAF0391.80907@collax.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2011 at 09:22:41PM +0100, Andreas Hofmeister wrote:
> I noticed that once forwarding has been enabled on an interface, there 
> is a "subnet router anycast address" for the link-local address prefix 
> FE80/10.

(Please note that it is fe80::/64 is used, not /10)

> This address seems not to be explicitly mentioned in any RFC, but RFC 
> 4291 says "All routers are required to support the Subnet-Router anycast 
> addresses for the subnets to which they have interfaces."

That this directly contradicts RFC 2526 which specifies the
subnet-router anycast address to be either ::ffff:ffff:ffff:ff80 or
::fcff:ffff:ffff:ff80 depending on the phase of the moon (well,
interface type actually, but same thing. Also, the /64 <> /10
distinction would matter here.)

For even more confusion, look at
http://www.iana.org/assignments/ipv6-anycast-addresses/ipv6-anycast-addresses.xml

but the only point why I'm mentioning this at all is that if someone
implemented this, they might've noticed the colliding specifications,
and there would be an Errata.

> In the sense that a Linux router actually has an address FE80/10 on each 
> ipv6 enabled interface, it seems to be correct to also have FE80:: as an 
> anycast address on all interfaces which have ipv6 and forwarding enabled.
> 
> But then, FE80/10 is not actually supposed to be routed at all and so a 
> router cannot not really be a router for that particular subnet ?

This question isn't really relevant, because...

> Or is "FE80::" just supposed to be the anycast equivalent for the "all 
> routers" multicast address ff02::2 ?

... it's actually fairly hard to implement this at all. The idea of
"Anycast" is that even if you have 1000 routers, only one router will
receive the packet. The network is supposed to magically take care of
that, but in reality this only works with Layer 3/IPv6 routing.

So, if you're /actually on/ the subnet yourself, the RFC
- either expects the ethernet switch to implement anycast (...)
- or implies the need for some anycast resolution protocol
  (which is possible of course, but there would first need to actually
  /be/ some such protocol; while some quick googling tells me such
  things exist, they certainly belong in the esoterics drawer).

... which turns this entire thing into a really bad joke.


I would recommend forgetting that these anycast addresses exist at all.
If you need to reach a local on-subnet router, just use ff02::2 and
randomly pick one that answers.


-David
