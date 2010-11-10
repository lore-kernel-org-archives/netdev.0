From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Routing over multiple interfaces
Date: Wed, 10 Nov 2010 14:50:54 +0000
Message-ID: <1289400654.2721.7.camel@macbook.infradead.org>
References: <1288645922.5977.41.camel@macbook.infradead.org>
	 <20101101.141638.116372747.davem@davemloft.net>
	 <1288647330.2660.116.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	uweber@astaro.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54903 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756325Ab0KJOvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 09:51:01 -0500
In-Reply-To: <1288647330.2660.116.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-11-01 at 22:35 +0100, Eric Dumazet wrote:
>=20
> David W. probably wants to use teql or some bonding ?
>=20
> # tc qdisc add dev ppp0 root teql0
> # tc qdisc add dev ppp1 root teql0
> # ip link set dev teql0 up
> # ip route add default src 90.155.92.214 dev teql0

That works; thanks. Or it should do... there's a slight complication
right now in that one of my lines is actually routed through a separate
ADSL<->Ethernet box, because one of the ports on my Solos card is a bit
shagged and syncs a lot slower than it should. So it's actually eth1 an=
d
ppp1 that I'm sharing. That should be fixed relatively soon as they're
sending me a new box.

There's a minor issue with this setup though =E2=80=94 ideally, any giv=
en TCP
connection would tend to use the *same* interface as much as possible,
and only 'overflow' onto the other interface if it's actually saturatin=
g
the uplink on the first. That would tend to reduce the amount of packet
re-ordering. At the moment it will split outbound packets over both
lines even when they're relatively idle, introducing packet re-ordering
where it wasn't really necessary.

That said, the world is supposed to cope with packet re-ordering, so I'=
m
not going to lose a lot of sleep over it. And I have a feeling the
downstream link from the ISP does it exactly the same.

--=20
dwmw2

