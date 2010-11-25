From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP_MAXSEG vs TCP/generic segmentation offload (tso/gso)
Date: Thu, 25 Nov 2010 17:44:45 +0100
Message-ID: <1290703485.2858.360.camel@edumazet-laptop>
References: <nny68hqzzn.fsf@stalhein.lysator.liu.se>
	 <1290695253.2858.336.camel@edumazet-laptop>
	 <nnaakxqw1u.fsf@stalhein.lysator.liu.se>
	 <1290698312.2858.341.camel@edumazet-laptop>
	 <nn1v69qsjd.fsf@stalhein.lysator.liu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Niels =?ISO-8859-1?Q?M=F6ller?= <nisse@lysator.liu.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <nn1v69qsjd.fsf@stalhein.lysator.liu.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 25 novembre 2010 =C3=A0 17:25 +0100, Niels M=C3=B6ller a =C3=A9=
crit :


>=20
> I was under the impression that TSO (and maybe GSO) implied more
> cleverness in the network card; that the network card more or less ge=
ts
> to decide by itself how to divide a tcp stream into segments. And for
> example in the atl1c driver which I looked a bit into, this was what =
the
> REG_MTU register was for. Seems I have gotten this totally wrong.
>=20

You were not totally wrong, but device does not use its own MTU to
perform the split : We give it the MSS of the flow.

You can have multiple flows in parallel, each with its own MSS, while
device has a single MTU.

> Maybe Documentation/networking/netdevices.txt could clarify how it
> works. Currently, it says
>=20
> : Segmentation Offload (GSO, TSO) is an exception to this rule.  The
> : upper layer protocol may pass a large socket buffer to the device
> : transmit routine, and the device will break that up into separate
> : packets based on the current MTU.


MTU means : maximum transmission unit. But each layer has its own :)

In this context, TCP protocol, so MSS should be taken into account.

By default, MSS derives from device MTU  (ipv4 without options case :
MSS =3D MTU - 40), but user can change it with TCP_MAXSEG.
