From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sch_red: fix red_change
Date: Thu, 01 Dec 2011 22:57:23 +0100
Message-ID: <1322776643.2750.45.camel@edumazet-laptop>
References: <1322684749.2602.3.camel@edumazet-laptop>
	 <20111130143642.7130aa2b@nehalam.linuxnetplumber.net>
	 <1322773594.2750.28.camel@edumazet-laptop>
	 <CAA93jw7wAL75pVrB-q+xGAcpQtiZz4iVW0Z2W9E8VGSyUFOo-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Thomas Graf <tgraf@infradead.org>,
	netdev <netdev@vger.kernel.org>, Jim Gettys <jg@freedesktop.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61620 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754144Ab1LAV52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 16:57:28 -0500
Received: by bkas6 with SMTP id s6so2990053bka.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 13:57:26 -0800 (PST)
In-Reply-To: <CAA93jw7wAL75pVrB-q+xGAcpQtiZz4iVW0Z2W9E8VGSyUFOo-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 d=C3=A9cembre 2011 =C3=A0 22:35 +0100, Dave Taht a =C3=A9cr=
it :
> On Thu, Dec 1, 2011 at 10:06 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le mercredi 30 novembre 2011 =C3=A0 14:36 -0800, Stephen Hemminger =
a =C3=A9crit :
> >
> >> (Almost) nobody uses RED because they can't figure it out.
> >> According to Wikipedia, VJ says that:
> >>  "there are not one, but two bugs in classic RED."
>=20
> Heh. "There were not two, but four bugs in Linux red".
>=20
> Now reduced to 2. :)
>=20

This story about VJ and bugs in classic RED is urban legend if you ask
me :)



> RED is useful for high throughput routers, I doubt many linux machine=
s
> > act as such devices.
>=20
> "High throughput" at the time red was designed was not much faster
> than a T1 line.
>=20
> RED appears to be used by default in both gargoyle's and openwrt's Qo=
S systems,
> underneath unholy combinations of HTB, HSFC, and SFQ
> so it's more widely used than you might think. Not that works well.
>=20
> RED doesn't work worth beans on variable bandwidth links (cable
> modems/wireless).
>=20

Adaptative RED is the answer

> Once you are simulating a fixed rate link (e.g with HTB), then it sor=
t of
> kinda maybe can apply.
>=20
> RED was also designed at a time when long distance traffic was fixed =
rate
> and bidirectional, so the 'average packet' parameter made sense.
> Modern day traffic is far more asymmetric.
>=20

The truth is : For RED be effective (with say 20 to 100 flows), you nee=
d
a reasonable amount of packets in queue, and low wq (high burst value i=
n
linux), depending on the RTT. And on consumer links (ADSL, cable
modem ...), RTT is quite big.

RED performance is best when the average queue size is estimated over a
small _multiple_ of round-trip times, not over a fraction of a single
round-trip time.

In this respect, your RED setups are pathological (minimum burst value,
meaning wq =3D 0.5 or so), so in a small fraction of RTT, avgqsz value =
is
completely changed, so flows have no chance to be able to react
smoothly.
