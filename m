From: Kozlov Dmitry <xeb@mail.ru>
Subject: Re: [net-next,v3] GRE over IPv6
Date: Mon, 30 Jul 2012 15:52:46 +0400
Message-ID: <4682082.2P7rpuTCdd@dima>
References: <1368610.TAsHNfv2Eb@comp1> <20120730143806.41f759fd@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.mail.ru ([94.100.176.130]:55488 "EHLO smtp2.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752456Ab2G3Lwy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2012 07:52:54 -0400
In-Reply-To: <20120730143806.41f759fd@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 30 July 2012 14:38:06 Timo Teras wrote:
> On Sat, 28 Jul 2012 22:12:42 -0000 xeb@mail.ru wrote:
> > GRE over IPv6 implementation.
> > 
> > Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
> > 
> > ---
> > Changes:
> > Initialize nt->dev before calling ip6gre_tnl_link_config in
> > ip6gre_newlink.
> > Add missing ip6gre.c
> > 
> >  include/linux/if_arp.h     |    1 +
> >  include/linux/if_tunnel.h  |    3 +
> >  include/linux/ip6_tunnel.h |   18 +
> >  include/net/ip6_tunnel.h   |   40 +-
> >  include/net/ipv6.h         |    1 +
> >  net/ipv6/Kconfig           |   16 +
> >  net/ipv6/Makefile          |    1 +
> >  net/ipv6/ip6_gre.c         | 1817
> > 
> > ++++++++++++++++++++++++++++++++++++++++++++
> > net/ipv6/ip6_tunnel.c      |   86 ++- 9 files changed, 1958
> > insertions(+), 25 deletions(-)
> 
> Would it be possible and/or feasible to instead modify ip_gre to support
> also ipv6 as outer protocol?
> 
> It already has ipv6 stuff in it for the inner protocol support. And it
> would avoid duplicating most of the code.
> 
> And I would especially love that approach, since I could then on
> per-target basis say if it should be contacted with IPv4 or IPv6. As in:
> 
>   ip addr add 10.0.0.1/24 dev gre1
>   ip neigh add 10.0.0.2 lladdr 192.168.x.x dev gre1 nud permanent
>   ip neigh add 10.0.0.3 lladdr fe80::xxxx:xxxx:xxxx:xxxx/64 dev gre1 nud
> permanent

Sounds good, but it involves too many if/else because there are much ipv4 and ipv6 specifics and code will be unreadable.
I see only shared part is tunnel initialization and managing code.
Tunnel lookup, receive and transmit parts are mostly different.
