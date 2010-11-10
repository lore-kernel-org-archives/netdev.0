From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Routing over multiple interfaces
Date: Wed, 10 Nov 2010 16:08:24 +0100
Message-ID: <1289401704.2860.182.camel@edumazet-laptop>
References: <1288645922.5977.41.camel@macbook.infradead.org>
	 <20101101.141638.116372747.davem@davemloft.net>
	 <1288647330.2660.116.camel@edumazet-laptop>
	 <1289400654.2721.7.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	uweber@astaro.com
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44373 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756475Ab0KJPIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 10:08:31 -0500
Received: by eye27 with SMTP id 27so339770eye.19
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 07:08:30 -0800 (PST)
In-Reply-To: <1289400654.2721.7.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 10 novembre 2010 =C3=A0 14:50 +0000, David Woodhouse a =C3=A9=
crit :
> On Mon, 2010-11-01 at 22:35 +0100, Eric Dumazet wrote:
> >=20
> > David W. probably wants to use teql or some bonding ?
> >=20
> > # tc qdisc add dev ppp0 root teql0
> > # tc qdisc add dev ppp1 root teql0
> > # ip link set dev teql0 up
> > # ip route add default src 90.155.92.214 dev teql0
>=20
> That works; thanks. Or it should do... there's a slight complication
> right now in that one of my lines is actually routed through a separa=
te
> ADSL<->Ethernet box, because one of the ports on my Solos card is a b=
it
> shagged and syncs a lot slower than it should. So it's actually eth1 =
and
> ppp1 that I'm sharing. That should be fixed relatively soon as they'r=
e
> sending me a new box.
>=20
> There's a minor issue with this setup though =E2=80=94 ideally, any g=
iven TCP
> connection would tend to use the *same* interface as much as possible=
,
> and only 'overflow' onto the other interface if it's actually saturat=
ing
> the uplink on the first. That would tend to reduce the amount of pack=
et
> re-ordering. At the moment it will split outbound packets over both
> lines even when they're relatively idle, introducing packet re-orderi=
ng
> where it wasn't really necessary.
>=20
> That said, the world is supposed to cope with packet re-ordering, so =
I'm
> not going to lose a lot of sleep over it. And I have a feeling the
> downstream link from the ISP does it exactly the same.
>=20

Its a bit problematic, as you said you want to use both links to do one
upload ;)

Maybe it is possible to instruct teql to try to not change links unless
one link is full...



