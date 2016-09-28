From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] L2TP:Adjust intf MTU,factor underlay L3,overlay
 L2
Date: Wed, 28 Sep 2016 03:48:41 -0400 (EDT)
Message-ID: <20160928.034841.997752666320557327.davem@davemloft.net>
References: <alpine.DEB.2.11.1609221341500.6975@duvvury30.eng.vyatta.net>
        <20160927.033153.1066118008027608891.davem@davemloft.net>
        <alpine.DEB.2.11.1609271210350.25517@duvvury48.eng.vyatta.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kleptog@svana.org, jchapman@katalix.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, nprachan@brocade.com,
        rshearma@brocade.com, dfawcus@brocade.com,
        stephen@networkplumber.org, acme@redhat.com, lboccass@brocade.com
To: parameswaran.r7@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1609271210350.25517@duvvury48.eng.vyatta.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Date: Tue, 27 Sep 2016 12:17:21 -0700 (PDT)

> Later, in vxlan_dev_configure(), called from vxlan_dev_create(), it gets 
> adjusted to account for the headers:
> 
> vxlan_dev_configure():
> ...
>  if (!conf->mtu)
>                         dev->mtu = lowerdev->mtu - (use_ipv6 ? 
> VXLAN6_HEADROOM : VXLAN_HEADROOM);
> 
> 
> where VXLAN_HEADROOM is defined as follows: 
> 
> /* IP header + UDP + VXLAN + Ethernet header */
> #define VXLAN_HEADROOM (20 + 8 + 8 + 14)
> /* IPv6 header + UDP + VXLAN + Ethernet header */
> #define VXLAN6_HEADROOM (40 + 8 + 8 + 14)

Right but I don't see it going through the effort to make use of the
PMTU like you are.

I have another strong concern related to this.  There seems to be no
mechanism used to propagate any PMTU events into the device's MTU.

Because if there is a limiting nexthop in the route to the other end
of the UDP tunnel, you won't learn the PMTU until you (or some other
entity on the machine) actually starts sending traffic to the tunnel's
endpoint.

If the PMTU events aren't propagated into the tunnel's MTU or similar
I think this is an ad-hoc solution.

I would suggest that you either:

1) Do what VXLAN appears to do an ignore the PMTu

2) Add code to handle PMTU events that land on the UDP tunnel
   socket.

Thanks.
