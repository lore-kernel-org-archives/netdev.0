From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH] IPv6: optionaly validate RAs on raw sockets
Date: Wed, 11 Jul 2007 15:44:43 +0300
Message-ID: <200707111544.43151.rdenis@simphalempin.com>
References: <200707102111.18824@auguste.remlab.net> <20070711.212916.36390936.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki /
	 =?utf-8?q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poy.chewa.net ([194.242.114.73]:1190 "EHLO poy.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756587AbXGKMot convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 08:44:49 -0400
In-Reply-To: <20070711.212916.36390936.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 11 July 2007 15:29:16 YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=
=E8=8B=B1=E6=98=8E wrote:
> In article <200707102111.18824@auguste.remlab.net> (at Tue, 10 Jul 20=
07=20
21:11:17 +0300), Remi Denis-Courmont <rdenis@simphalempin.com> says:
> > ICMPv6 Router Advertisements may now contain informations that is
> > mostly of interest to userland. This currently mostly consists of
> > recursive DNS server addresses (though one should expect other
> > stuff to come).
>
> I really do not want to have such non-standard API in kernel.

I can only think of a very limited set of ways to extract options from =
RAs=20
that the kernel currently ignores:

1) parse everything in kernel addrconf.c
2) validate RA in kernel, parse userland options in userland
3) parse everything in userland
4) do not support any option of interest to userland ever
5) userland and kernel do their own cooking separately

netdev folks already rejected (1) earlier. You just rejected (2) this i=
nstant.=20
(3) implies removing addrconf from the kernel completely, which does no=
t=20
sound good, besides being a big waste. (4) means Linux is unusable on I=
Pv6=20
networks. And it's already been pointed out (5) was not safe/secure (us=
erland=20
may end up accepting something when it should not).

I might be missing something because I am a notoriously arrogant moron =
but it=20
looks like Linux IPv6 is in a dead-end for the time being :-(

What do you propose then?

--=20
R=C3=A9mi Denis-Courmont
