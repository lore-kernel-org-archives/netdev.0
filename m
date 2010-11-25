From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP_MAXSEG vs TCP/generic segmentation offload (tso/gso)
Date: Thu, 25 Nov 2010 15:27:33 +0100
Message-ID: <1290695253.2858.336.camel@edumazet-laptop>
References: <nny68hqzzn.fsf@stalhein.lysator.liu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Niels =?ISO-8859-1?Q?M=F6ller?= <nisse@lysator.liu.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <nny68hqzzn.fsf@stalhein.lysator.liu.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 25 novembre 2010 =C3=A0 14:44 +0100, Niels M=C3=B6ller a =C3=A9=
crit :
> [ This is a slightly updated repost of a an October 21 mail to the
>   linux-net list. Any hints or advice appreciated. /Niels ]
>=20

CC netdev

> I have been observing large ethernet packets when generating TCP traf=
fic
> over a local ethernet, up to a bit over 20000 bytes, even though the
> interface MTU is 1500 bytes.
>=20
> Furthermore, I tried to use setsockopt with TCP_MAXSEG to limit the T=
CP
> segment size further, to 1000 bytes, and that didn't have any effect.
>=20
> When bugreporting a related problem to the debian kernel maintainers,=
 I
> was told that the behaviour may be linked to the use of TCP segmentat=
ion
> offload (see http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D60028=
6).
>=20
> Disabling TSO and GSO using ethtool solves both problems: Generated
> packets now are limited in size by both the interface MTU and the
> segment size set with setsockopt. (Except the atl1c driver, where
> ethtool -K eth0 tso off only results in a "Cannot set device tcp
> segmentation offload settings: Operation not supported").
>=20
> Before I try to write proper bug reports on specific network drivers =
(I
> have seen problems with several network drivers on different machines=
,
> unfortunately using different linux versions), I would like to know:
>=20
> 1. Is TCP_MAXSEG supposed to work at all with network drivers that do
>    tcp segmentation offload?
>=20
> 2. If it is supposed to work, can someone give a rough sketch on how =
the
>    per-socket segment size, set with setsockopt(... TCP_MAXSEG,...), =
is
>    passed down to the driver and to the network hardware? I suspect i=
t
>    ought to be passed with each "pseudo-packet" to be transmitted.
>=20
> I have spent some time searching the documentation and the net for
> answers, without result, hence I'm posting to this list. I'm not
> subscribed, so please cc any replies.
>=20
> (Regarding packets larger than the interface MTU, that seems clearly
> buggy to me, and I think I already know enough to be able to file pro=
per
> bug reports. And in the atl1c driver, it appears to have been fixed
> between 1.0.0.1-NAPI and 1.0.1.0-NAPI).

GSO is a software technique. Same for GRO.

Physical frames are indeed 1500 bytes (on regular ethernet links)

tcpdump gives you the high level view, before segmentation done in lowe=
r
levels (by NIC itself or in linux stack) in Transmit path.

We also have GRO in receive path, able to coalesce several 1500 bytes
frames into a single one (if same tcp flow), so that overhead in stacks
is lowered (netfilter, IP stack, tcp stack, bridge, routing ...)

So... there is no 'bug', unless you trust too much tcpdump output.
