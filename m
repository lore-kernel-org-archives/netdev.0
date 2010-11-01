From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Routing over multiple interfaces
Date: Mon, 01 Nov 2010 22:35:30 +0100
Message-ID: <1288647330.2660.116.camel@edumazet-laptop>
References: <1288645922.5977.41.camel@macbook.infradead.org>
	 <20101101.141638.116372747.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dwmw2@infradead.org, netdev@vger.kernel.org, uweber@astaro.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36022 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749Ab0KAVfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 17:35:38 -0400
Received: by wwe15 with SMTP id 15so6624306wwe.1
        for <netdev@vger.kernel.org>; Mon, 01 Nov 2010 14:35:37 -0700 (PDT)
In-Reply-To: <20101101.141638.116372747.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 01 novembre 2010 =C3=A0 14:16 -0700, David Miller a =C3=A9crit=
 :
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Mon, 01 Nov 2010 17:12:02 -0400
>=20
> > But when I do a large upload, I find that the kernel is only ever u=
sing
> > a *single* link at a time, rather than both. How can I make it use
> > *both* links? It's fine to confine each flow to a single link if it
> > doesn't saturate that link... but once the queue is full, it should
> > overflow onto the other device.
>=20
> Once a TCP socket gets a routing cache entry, that's what it uses
> for the rest of the life of the connection.
>=20
> The multi-pathing decision happens at the time the routing
> cache entry is created.
>=20
> What you want is multi-path routing support in the routing cache.
>=20
> We used to have that, but the guy who implemented it (after bugging
> me to integrate it for 4 months straight, non-stop) just did a code
> dump and then disappeared and fixed none of the serious fundamental
> problems which existed in his code.
>=20
> After a year of no action, I simply tore out all of his code.
>=20
> More recently Ulrich Weber gave a presentation at netfilter workshop
> on some uplink load balancing work he is doing, you might have
> a look at his talk and get in contact with him:
>=20
> http://people.astaro.com/uweber/uplink_balancing.pdf
> --

Astaro case is a bit different, since links have different IP addresses=
,
and a single upload uses a single link anyway because of hashing or
policy that selects one source IP address.

David W. probably wants to use teql or some bonding ?

# tc qdisc add dev ppp0 root teql0
# tc qdisc add dev ppp1 root teql0
# ip link set dev teql0 up
# ip route add default src 90.155.92.214 dev teql0




