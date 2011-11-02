From: David Lamparter <equinox@diac24.net>
Subject: Re: Subnet router anycast for FE80/10 ?
Date: Wed, 2 Nov 2011 22:53:59 +0100
Message-ID: <20111102215359.GJ297914@jupiter.n2.diac24.net>
References: <4EAF0391.80907@collax.com>
 <20111102153809.GH297914@jupiter.n2.diac24.net>
 <OFCBEF5360.F10E7D75-ON8825793C.00613C5C-8825793C.00623B8A@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	Andreas Hofmeister <andi@collax.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:53351 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751023Ab1KBVyM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 17:54:12 -0400
Content-Disposition: inline
In-Reply-To: <OFCBEF5360.F10E7D75-ON8825793C.00613C5C-8825793C.00623B8A@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 02, 2011 at 10:52:57AM -0700, David Stevens wrote:
> > > This address seems not to be explicitly mentioned in any RFC, but RFC 
> > > 4291 says "All routers are required to support the Subnet-Router 
> anycast 
> > > addresses for the subnets to which they have interfaces."
> > 
> > That this directly contradicts RFC 2526 which specifies the
> > subnet-router anycast address to be either ::ffff:ffff:ffff:ff80 or
> > ::fcff:ffff:ffff:ff80 depending on the phase of the moon (well,
> > interface type actually, but same thing. Also, the /64 <> /10
> > distinction would matter here.)
>
>         The subnet-router anycast address is defined in section 2.6.1 of 
> RFC 4291 to be "all 0's" for the prefix. The definition above is for
> reserved anycast addresses. RFC 2526 says "IPv6 defines a required
> Subnet-Router anycast address [3] for all routers within a subnet prefix,
> and allows additional anycast addresses to be taken from the unicast
> address space. This document defines an additional set of reserved
> anycast addresses...".

Argh. I got thoroughly confused. Please ignore everything I said.

> > [...] only one router will receive the packet [...]
> 
>         The host implementation is very straightforward. Not every host
> on a segment has to use the *same* host for an anycast address (it's
> kind of the point that it won't, in fact). A host simply needs to
> do a solicitation for the anycast address and keep the first one that
> answers (by definition, the "closest").

Right. Sorry. I was half-asleep when I wrote my previous mail and
clearly didn't think through the entire problem. I should probably stop
writing mails when not at least 80% awake :).

Neighbor Discovery can indeed select one of the anycast hosts and talk
to it using its lower-layer address, and no other host should
receive/process the packet.

Going back to Andreas's original question about Subnet-Router Anycast
for fe80::/64 (or /10), RFC 4291 says
   +------------------------------------------------+----------------+
   |                   subnet prefix                | 00000000000000 |
   +------------------------------------------------+----------------+

   The "subnet prefix" in an anycast address is the prefix that
   identifies a specific link.

But fe80::/64 does not identify a specific link, as it is link-local and
would specify all links but not one specifically. So, fe80:: is not a
Subnet-Router anycast address, I'd say.


Hoping I was awake enough this time...


-David
