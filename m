From: Jim Westfall <jwestfall@surrealistic.net>
Subject: Re: ipv6 secondary ips and default ipv6 ip for new outbound
	connections
Date: Mon, 21 Mar 2011 17:15:08 -0700
Message-ID: <20110322001508.GA13831@surrealistic.net>
References: <20110318230312.GX13831@surrealistic.net> <4D8413BE.5000305@hp.com> <20110319033507.GY13831@surrealistic.net> <m2k4fvbks6.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: Andreas Schwab <schwab@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from whipper.surrealistic.net ([75.151.103.193]:43940 "EHLO
	whipper.surrealistic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755293Ab1CVAPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 20:15:12 -0400
Content-Disposition: inline
In-Reply-To: <m2k4fvbks6.fsf@igel.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Schwab <schwab@linux-m68k.org> wrote [03.19.11]:
> Jim Westfall <jwestfall@surrealistic.net> writes:
> 
> > Your patch fixes it for me.
> >
> > # ip addr add 2600:c00:0:1::1101/64 dev eth0
> > ~# traceroute6 www.kame.net | head -0
> > traceroute to orange.kame.net (2001:200:dff:fff1:216:3eff:feb1:44d7) from 2600:c00:0:1::1101, 30 hops max, 16 byte packets
> >
> > ~# ip addr add 2600:c00:0:1::1102/64 dev eth0
> > ~# traceroute6 www.kame.net | head -0
> > traceroute to orange.kame.net (2001:200:dff:fff1:216:3eff:feb1:44d7) from 2600:c00:0:1::1101, 30 hops max, 16 byte packets
> >
> > ~# ip addr add 2600:c00:0:1::1103/64 dev eth0
> > ~# traceroute6 www.kame.net | head -0
> > traceroute to orange.kame.net (2001:200:dff:fff1:216:3eff:feb1:44d7) from 2600:c00:0:1::1101, 30 hops max, 16 byte packets
> 
> Does this also affect the selected address if use_tempaddr=2?
> 
> Andreas.
> 

I am new to using temp addresses, but it appears to be working as 
expected.

With the interface down I set use_tempaddr=2, brought the interface up 
and added my 2 static ipv6 ips, then ran rdisc6 on the interface.

This resulted in the following 

13: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN
    link/ether 00:10:18:17:a0:e6 brd ff:ff:ff:ff:ff:ff
    inet6 2600:c00:1002:2::101/64 scope global
       valid_lft forever preferred_lft forever
    inet6 2600:c00:1002:2::102/64 scope global
       valid_lft forever preferred_lft forever
    inet6 2600:c00:1002:2:210:18ff:fe17:a0e6/64 scope global dynamic
       valid_lft 2591996sec preferred_lft 604796sec
    inet6 2600:c00:1002:2:ccd2:cf82:efb0:8dc5/64 scope global temporary dynamic
       valid_lft 604796sec preferred_lft 85796sec
    inet6 fe80::210:18ff:fe17:a0e6/64 scope link
       valid_lft forever preferred_lft forever

~# traceroute6 www.kame.net
traceroute to orange.kame.net (2001:200:dff:fff1:216:3eff:feb1:44d7) from 2600:c00:1002:2:ccd2:cf82:efb0:8dc5, 30 hops max, 16 byte packets

It correctly sourced from 2600:c00:1002:2:ccd2:cf82:efb0:8dc5.

I repeated the same steps but reset use_tempaddr=1

~# traceroute6 www.kame.net
traceroute to orange.kame.net (2001:200:dff:fff1:216:3eff:feb1:44d7) from 2600:c00:1002:2::101, 30 hops max, 16 byte packets

For which 2600:c00:1002:2::101 was my first added static ip.

In testing the above I observed that downing the interface resulted in 
all ipv6 addressing being removed.  Is this expected?  I can see 
removing the dynamic/temp addresses, but seems weird for the statics I 
added.

thanks
Jim
