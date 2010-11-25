From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP_MAXSEG vs TCP/generic segmentation offload (tso/gso)
Date: Thu, 25 Nov 2010 16:18:31 +0100
Message-ID: <1290698312.2858.341.camel@edumazet-laptop>
References: <nny68hqzzn.fsf@stalhein.lysator.liu.se>
	 <1290695253.2858.336.camel@edumazet-laptop>
	 <nnaakxqw1u.fsf@stalhein.lysator.liu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Niels =?ISO-8859-1?Q?M=F6ller?= <nisse@lysator.liu.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <nnaakxqw1u.fsf@stalhein.lysator.liu.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 25 novembre 2010 =C3=A0 16:09 +0100, Niels M=C3=B6ller a =C3=A9=
crit :
> Eric Dumazet <eric.dumazet@gmail.com> writes:
>=20
> > So... there is no 'bug', unless you trust too much tcpdump output.
>=20
> I really expected tcpdump -e to display the actual values in the link
> layer header, including the correct frame size. It's more than a bit
> confusing if that is not the case...
>=20
> In the future, I will try to remember to always run tcpdump on a netw=
ork
> node which (i) is different from the sending one, and (ii) has GRO
> disabled (and hence will discard packets if it has trouble processing
> them all, rather than coalesce them).
>=20

Just disable GSO and TSO on sending machine, then tcpdump will show you
individual frames.


> What about the TCP_MAXSEG socket option, should that work? From a qui=
ck
> look at driver source code, I could only see the handling of the
> per-interface MTU, no per-socket segment size.

TCP_MAXSEG is certainly not handled in driver layer, but TCP layer.

/* If user gave his TCP_MAXSEG, record it to clamp */
if (tp->rx_opt.user_mss)
	tp->rx_opt.mss_clamp =3D tp->rx_opt.user_mss;

I believe TCP_MAXSEG is working fine, but GRO/GSO dont care at all :
They coalesce frames whatever their size is.
