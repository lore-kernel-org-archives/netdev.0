From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Latency difference between fifo and pfifo_fast
Date: Tue, 06 Dec 2011 14:44:18 -0500 (EST)
Message-ID: <9bf91034-a860-4144-858b-c9000964ea1d@jasiiieee>
References: <CAA93jw4rRsp0t0g4E0YOB=_N-rvTXj9aY+2qfN5hGXvi6R0auw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:63865 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751529Ab1LFSoG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 13:44:06 -0500
In-Reply-To: <CAA93jw4rRsp0t0g4E0YOB=_N-rvTXj9aY+2qfN5hGXvi6R0auw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "Dave Taht" <dave.taht@gmail.com>
> To: "Rick Jones" <rick.jones2@hp.com>
> Cc: "John A. Sullivan III" <jsullivan@opensourcedevel.com>, "Eric Dum=
azet" <eric.dumazet@gmail.com>,
> netdev@vger.kernel.org
> Sent: Tuesday, December 6, 2011 1:39:13 PM
> Subject: Re: Latency difference between fifo and pfifo_fast
>=20
> On Tue, Dec 6, 2011 at 7:20 PM, Rick Jones <rick.jones2@hp.com>
> wrote:
> > On 12/06/2011 12:51 AM, Eric Dumazet wrote:
> >>
> >> Le mardi 06 d=C3=A9cembre 2011 =C3=A0 03:39 -0500, John A. Sulliva=
n III a
> >> =C3=A9crit :
> >>
> >>>> ifconfig eth2 txqueuelen 0
> >>>> tc qdisc add dev eth2 root pfifo
> >>>> tc qdisc del dev eth2 root
> >>>>
> >>>>
> >>>>
> >>>>
> >>> Really? I didn't know one could do that. =C2=A0Thanks. =C2=A0Howe=
ver, with
> >>> no
> >>> queue length, do I have a significant risk of dropping packets?
> >>> To
> >>> answer your other response's question, these are Intel quad port
> >>> e1000
> >>> cards. =C2=A0We are frequently pushing them to near line speed so
> >>> 1,000,000,000 / 1534 / 8 =3D 81,486 pps - John
> >>
> >>
> >> You can remove qdisc layer, since NIC itself has a TX ring queue
> >>
> >> (check exact value with ethtool -g ethX)
> >>
> >> # ethtool -g eth2
> >> Ring parameters for eth2:
> >> Pre-set maximums:
> >> RX: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 4078
> >> RX Mini: =C2=A0 =C2=A0 =C2=A0 =C2=A00
> >> RX Jumbo: =C2=A0 =C2=A0 =C2=A0 0
> >> TX: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 4078
> >> Current hardware settings:
> >> RX: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 254
> >> RX Mini: =C2=A0 =C2=A0 =C2=A0 =C2=A00
> >> RX Jumbo: =C2=A0 =C2=A0 =C2=A0 0
> >> TX: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 4078 =C2=A0 =C2=A0 =C2=
=A0---- HERE ----
> >
> >
> > And while you are down at the NIC, if every microsecond is precious
> > (no
> > matter how close to epsilon compared to the latencies of spinning
> > rust :)
> > you might consider disabling interrupt coalescing via ethtool -C.
> >
> > rick jones
>=20
> Ya know, me being me, and if latency is your real problem, I can't
> help
> but think you'd do better by reducing those tx queues enormously,
> applying QFQ and maybe something like RED on top, would balance
> out the differences between flows and result in a net benefit.
>=20
> I realize that you are struggling to achieve line rate in the first
> place...
>=20
> but from where I sit (with asbestos suit on), it would be an
> interesting
> experiment. (I have no data on how much cpu this stuff uses at these
> sort of speeds)
> <snip>
>=20
Interesting.  Would that still be true if all the traffic is the same, =
i.e., nothing but iSCSI packets on the network? Or would just dumping p=
ackets with minimal processing be fastest? Thanks - John
