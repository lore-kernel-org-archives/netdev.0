From: Henrik Petander <lpetande@morphine.tml.hut.fi>
Subject: Re: [patch]: ipv6 tunnel for MIPv6
Date: Wed, 4 Jun 2003 20:31:53 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.44.0306041941480.8428-100000@morphine.tml.hut.fi>
References: <20030605.004932.00042147.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <vnuorval@tcs.hut.fi>, <kuznet@ms2.inr.ac.ru>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>, <ajtuomin@morphine.tml.hut.fi>,
   Venkata Jagana <jagana@us.ibm.com>, <kumarkr@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030605.004932.00042147.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Yoshifuji,

On Thu, 5 Jun 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> In article <3EDE0286.4000304@tml.hut.fi> (at Wed, 04 Jun 2003 17:30:30 +0300), Henrik Petander <lpetande@tml.hut.fi> says:
>
> > 2. Source address based routing
>
> I'm not sure why you need this (and tunnel) for MIP...
> Would you clearify for me?
> (IMHO, I believe we don't need this change if we use XFRM engine.)

As far as I remember there  are three main reasons for this: (Ville
correct me if  forgot something)

1. Mobile node sends packets to correspondent node through the tunnel, if
they have home address as the IPv6 source address (not in home address
option). MIPv6 signalling packets are sent at the same time with the home
address option (i.e. care-of address as the source address in IPv6 header)
to the same destination, but they must not be sent through the tunnel.
If the xfrm engine works correctly (for IPSec) and does the lookup using
the home address as the source address, the flows appear the same based on
the addresses.

2. Home Agent delivers packets with its own address as source address to
mobile node using route optimization, i.e. routing header type 2, but
tunnels other traffic to MN. Again behaviour depends on the source
address.

3. Multihomed mobile hosts: Mobile nodes can have a cellular and WLAN
interface. Packets with address from one interface can be sent only
through that interface to avoid RPF dropping the traffic. With routing
based primarily on source addresses this is easy to achieve. Actually this
is more general than MIPv6, but multihoming is essential for
real-life mobility.

>
> BTW, source based routing (source address is major, destination is minor)
> is done by policy routing; It is NOT the task of CONFIG_IPV6_SUBTREE, IMHO.
> Yes, poeple want to have policy routing, but it is NOT (only) for MIP6.

IMO source address subtrees were useless as they were at least for doing
mobility and multihoming, whereas with source address as primary selector
routing for mobile and multihomed hosts is straightforward. Of course I
may miss something of the larger picture ;-) But so far I have heard of no
one using them for anything else. As long as Linux lacks "real" IPv6
policy routing, source based routing is the best we have got and works
both for mobility and multihoming. The main problem with it is IMO
the source address selection using the route as a selection basis. Just my
thoughts, though.

>
> > 3. API
>
> No, user daemon adds a XFRM policy for adding destination option
> (and/or routing header).  Stackable destination will do the real work.
> (So, we don't need socket options.)

Actually we do... Due to some interesting requirements in the MIPv6 spec.
the signalling packets are treated differently from data packets: home
address option is always present in binding update messages, but it can be
used with data packets only after sending a binding update. Routing
header type 2 is used in negative binding acks sometimes with addresses
which differ from the ones used with data packets.

The signalling packets need IPSec protection with final addresses as
selectors, so the MIPv6 extension headers can't be added to packets
created by a raw socket as the final addresses would be hidden in the
extension headers.

>
> > 5. MIPv6 extension header adding
> I still belive it is very natural to use XFRM to manage stackable
> destination.

If you have a concrete proposal how to do it, I would be eager to hear it
;-)

> Okay, anyway, please sent it to David, Alexey and me (at least).
> We can learn more from the code than documentation. ;-)

Sure, I'll send it tomorrow when i get back to work.

Regards,

Henrik

		----------------------------------
		Henrik Petander
		Helsinki University of Technology,
		GO/Core Project
		Henrik.Petander@hut.fi
		Office: +358 (0)9 451 5846
		GSM: +358 (0)40 741 5248
		----------------------------------
