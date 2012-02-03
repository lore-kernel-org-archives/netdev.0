From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Fri, 03 Feb 2012 12:04:57 +0100
Message-ID: <1328267097.2157.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120201.162157.880976652659067010.davem@davemloft.net>
		 <4F2A87B0.6070900@profihost.ag>
		 <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
		 <20120202.143957.2251106530056768980.davem@davemloft.net>
		 <20120203004228.GA23429@kroah.com> <4F2B8348.3090305@profihost.ag>
	 <1328253972.2480.42.camel@edumazet-laptop> <4F2B963F.4020504@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>, jwboyer@gmail.com,
	hch@infradead.org, netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:51130 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755938Ab2BCLFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 06:05:01 -0500
In-Reply-To: <4F2B963F.4020504@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 f=C3=A9vrier 2012 =C3=A0 09:09 +0100, Stefan Priebe - Pr=
ofihost AG
a =C3=A9crit :
> Hi,
>=20
> attached you find the patch files applying cleanly to 3.0.X.

=46irst, thanks a lot for doing this work.

OK, lets try to provide a cumulative patch with a good Changelog ?

And please try a "allyesconfig" build, because it doesnt build right
now :

  CC [M]  net/decnet/dn_neigh.o
net/decnet/dn_route.c: In function 'dn_forward':
net/decnet/dn_route.c:757:31: error: 'struct dst_entry' has no member
named 'neighbour'
make[2]: *** [net/decnet/dn_route.o] Error 1
make[2]: *** Waiting for unfinished jobs....
net/decnet/dn_neigh.c: In function 'dn_long_output':
net/decnet/dn_neigh.c:230:31: error: 'struct dst_entry' has no member
named 'neighbour'
net/decnet/dn_neigh.c: In function 'dn_short_output':
net/decnet/dn_neigh.c:277:31: error: 'struct dst_entry' has no member
named 'neighbour'
net/decnet/dn_neigh.c: In function 'dn_phase3_output':
net/decnet/dn_neigh.c:321:31: error: 'struct dst_entry' has no member
named 'neighbour'
make[2]: *** [net/decnet/dn_neigh.o] Error 1
make[1]: *** [net/decnet] Error 2


So there is at least one patch missing ?

Once you believe its ok, please send a proper patch with changelog like
this :

[PATCH] net: hot fix for stable kernels

This cumulative patch fixes IP redirect NULL dereferences
added in commit f39925dbde77
(ipv4: Cache learned redirect information in inetpeer.)

Backport of [xx] upstream commits

9cbb7ecbcff85077bb12301aaf4c9b5a56c5993d
(ipv6: Get rid of rt6i_nexthop macro.)

69cce1d1404968f78b177a0314f5822d5afdbbfb
(net: Abstract dst->neighbour accesses behind helpers.)=20
=2E..

[Full list of xx commits with their ID in linux tree and their title,
to ease future maintenance]

Signed-off-by: [your email]
---
[diffstat -p1 -w70 of your patch]

[content of the patch]
