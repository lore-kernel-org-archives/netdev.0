From: Vincent Bernat <bernat@luffy.cx>
Subject: Re: [RFC PATCH net-next v2 0/1] Add support of ECMPv6
Date: Fri, 14 Sep 2012 11:40:07 +0200
Message-ID: <87392l7xjc.fsf@guybrush.luffy.cx>
References: <505058F5.9020707@linux-ipv6.org>
	<1347609548-14494-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:34395 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753250Ab2INJkL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 05:40:11 -0400
In-Reply-To: <1347609548-14494-1-git-send-email-nicolas.dichtel@6wind.com>
	(Nicolas Dichtel's message of "Fri\, 14 Sep 2012 09\:59\:07 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 14 septembre 2012 09:59 CEST, Nicolas Dichtel <nicolas.dicht=
el@6wind.com>=C2=A0:

> Here is an example of a command to add an ECMP route:
> $ ip -6 route add 3ffe:304:124:2306::/64 \
> 	nexthop via fe80::230:1bff:feb4:e05c dev eth0 weight 1 \
> 	nexthop via fe80::230:1bff:feb4:dd4f dev eth0 weight 1

When displaying ECMP routes, the display is different than for IPv4: we
get two distinct routes instead of an ECMP route (with nexthop
keyword).

With IPv4:

193.252.X.X/26  proto zebra  metric 20=20
	nexthop via 193.252.X.X  dev bae1 weight 1
	nexthop via 193.252.X.X  dev bae2 weight 1

With IPv6:

2a01:c9c0:X:X::/64 via fe80::215:17ff:fe85:76b9 dev bae1 metric 11=20
2a01:c9c0:X:X::/64 via fe80::222:91ff:fe4e:b000 dev bae2 metric 11

If I capture the netlink message from the add command, put it in a file
and use "ip monitor file ...", I see this:

2a01:c9c0:X:X::/64
	nexthop via fe80::215:17ff:fe85:76b9  dev if12 weight 1
	nexthop via fe80::222:91ff:fe4e:b000  dev if11 weight 1

Therefore, the problem is not in iproute2 which knows how to display
those ECMP routes. I fear that this difference make support in routing
daemons more difficult.
--=20
Make the coupling between modules visible.
            - The Elements of Programming Style (Kernighan & Plauger)
