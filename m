From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [patch]: ipv6 tunnel for MIPv6
Date: Thu, 5 Jun 2003 15:40:53 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306051138260.30092-100000@rhea.tcs.hut.fi>
References: <20030605.004932.00042147.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Cc: lpetande@tml.hut.fi, <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>,
   <netdev@oss.sgi.com>, <ajtuomin@morphine.tml.hut.fi>,
   <lpetande@morphine.tml.hut.fi>, <jagana@us.ibm.com>, <kumarkr@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030605.004932.00042147.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 5 Jun 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> In article <3EDE0286.4000304@tml.hut.fi> (at Wed, 04 Jun 2003 17:30:30 +0300), Henrik Petander <lpetande@tml.hut.fi> says:
>
> > 2. Source address based routing
>
> I'm not sure why you need this (and tunnel) for MIP...
> Would you clearify for me?
> (IMHO, I believe we don't need this change if we use XFRM engine.)
>

A few comments about the tunnels:

Can you run link-scope protocols over an XFRM tunnel? The MIPv6 spec more
or less requires this feature if you are to support protocols like DHCPv6
and MLD. (See eg. sections 8.5, 10.4.3 and 10.4.4 in the MIPv6 draft 22).

The only way to get them to work is AFAICS that there is a virtual
net_device associated with every tunnel. Are XFRM tunnels like this?

At least they didn't seem to be, based on the xfrm6_tunnel patch sent to
netdev last week...

If the tunnels aren't separate devices I can straight away think of one
scenario where we run into trouble.

1. MN receives RA with M or O flags set from a router on the foreign
   link.

2. MN receives a MPA with M or O flags set from HA.

In the first case the DHCP queries should be sent to the current link the
MN is attached to, in the latter to the HA.

I dont see any way for the MN to separate these two cases while sending
the DHCP queries, _unless_ they are sent through different interfaces
(i.e. the physical vs the virtual tunnel interface).

On a more general note, the driver I sent aims to provide provide a
completely RFC 2473 compliant tunnel interface. :)

Things (at the moment) missing from the xfrm6_tunnel are at least:
- tunnel encapsulation limit destination sub-option support
- forwarding of ICMP errors to the original source of the packet
- transparent fragmentation of packets if MTU minus size of tunnel
  headers less than IPV6_MIN_MTU
- ability to configure things like traffic class and flowlabel of
  encapsulating ipv6 header

Perhaps we could make feature complete ip6ip6 tunnels if we combined
xfrm6_tunnel and ip6_tunnel? :)

Regards,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
