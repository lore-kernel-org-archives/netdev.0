From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC 1/2] udp: add non-linear uniform port allocation scheme option /proc/sys/net/ipv4/udp_port_randomization
Date: Thu, 17 Dec 2009 17:16:55 +0200
Message-ID: <200912171716.56066.opurdila@ixiacom.com>
References: <4B2933EF.9060606@ixiacom.com> <4B2A3B3B.3000308@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:11661 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965139AbZLQPUO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 10:20:14 -0500
In-Reply-To: <4B2A3B3B.3000308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 17 December 2009 16:07:55 you wrote:
> Le 16/12/2009 20:24, Lucian Adrian Grijincu a =E9crit :
> > When we allocate ports with a (really) high frequency, randomizatio=
n
> > does more harm as some values tend to repeat with a higher frequenc=
y
> > than they would if allocated uniformly, while others are selected m=
ore
> > rarely.
> >
> > This patch does not allocate ports linearly as older kernels used t=
o do,
> > but it allocates the port with an uniform frequency.
> >
> > For example: assuming UDP_HTABLE_SIZE=3D8, hint=3D3, low=3D0, high=3D=
32
> >
> > This leads to:
> >> first=3D3, last=3D3+8=3D11, rand=3D(1 | 1) * UDP_HTABLE_SIZE=3D8
> >
> > The port selection code is similar to:
> >> for first in [3..11):
> >>     snum =3D first
> >>     do if (!good(snum)) snum+=3D8 while(snum!=3Dfirst)
> >
> > Will give the following sequence for snum (skipping `modulo 32` for
> > brevity)
> >   3,  3+8,  3+8+8,  3+8+8+8,
> >   4,  4+8,  4+8+8,  4+8+8+8,
> >  ...
> >   9,  9+8,  9+8+8,  9+8+8+8,
> >  10, 10+8, 10+8+8, 10+8+8+8,
> >
> > This will generate all numbers in the [low..high) interval with the
> > same frequency. This leads to better performance when most ports ar=
e
> > already allocated.
> >
> > Randomization is still enabled by default for normal setups that wi=
ll
> > most likely not encounter such situations.
>=20
> I dont like this patch, I am not convinced at all by your example.
>=20
> Your example is flawed, since UDP_HTABLE_SIZE >=3D 128 (128 is the mi=
nimum
>  hash size)
>=20
> I cannot understand why chosing a "one" increment instead of a "rando=
m odd"
>  increment can give a more uniform allocation frequency.
>=20
> If port randomization is not good enough, please make it better, not
>  reverting to plain sequential old behavior... (your application can =
do its
>  own port allocation by the way)
>=20

Thanks for reviewing Eric. In this thread=20

http://kerneltrap.org/mailarchive/linux-netdev/2009/5/8/5667204 (ports =
being=20
reused too fast)

Stephen observed that port randomization effects on same port allocatio=
n=20
frequency are explained by the birthday paradox.=20

The RFC suggesting port randomization recognizes this issue and suggest=
 a way=20
to overcome it, but on a first glance it looks expensive.=20

Adding a sysctl to sequencial port allocation might not be the best opt=
ion,=20
but we thought of kicking the discussion about this issue with this pat=
ch.

> BTW, net-next-2.6 is not yet open, this is not the right time to subm=
it non
>  bug fixes patches.

Yes, we know that, but we are still learning the details. For instance,=
 should=20
we refrain from sending RFC patches (as in patches we are not sure that=
 are=20
right and want to get early feedback on) as well during the merge windo=
w?

