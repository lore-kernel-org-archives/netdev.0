From: Bill Fink <billfink@mindspring.com>
Subject: Re: tbf/htb qdisc limitations
Date: Fri, 15 Oct 2010 17:37:46 -0400
Message-ID: <20101015173746.12c7c40a.billfink@mindspring.com>
References: <AANLkTin_jPp+WEkyJkD_KZyrJ4WX_6dM5wtFNw_ixuzv@mail.gmail.com>
	<20101012101022.GA8578@ff.dom.local>
	<AANLkTikQkCcPXtRQGp=MQrjrWtae84VzbENn5x+1yC47@mail.gmail.com>
	<20101012215932.GA1945@del.dom.local>
	<4CB4DE6E.7030802@hp.com>
	<20101013062649.GA6915@ff.dom.local>
	<20101013233653.1e363692.billfink@mindspring.com>
	<20101014064404.GA6219@ff.dom.local>
	<20101014031354.e172d737.billfink@mindspring.com>
	<20101014080939.GA7710@ff.dom.local>
	<20101014085005.GA8349@ff.dom.local>
	<20101015023749.f085006b.billfink@mindspring.com>
	<1287125059.2659.1812.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:52431 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750838Ab0JOVyw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 17:54:52 -0400
In-Reply-To: <1287125059.2659.1812.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Oct 2010, Eric Dumazet wrote:

> Le vendredi 15 octobre 2010 =E0 02:37 -0400, Bill Fink a =E9crit :
> > On Thu, 14 Oct 2010, Jarek Poplawski wrote:
> >=20
> > > On Thu, Oct 14, 2010 at 08:09:39AM +0000, Jarek Poplawski wrote:
> > > > On Thu, Oct 14, 2010 at 03:13:54AM -0400, Bill Fink wrote:
> > > > > TSO/GSO was disabled and was using 9000-byte jumbo frames
> > > > > (and specified mtu 9000 to tc command).
> > > > >=20
> > > > > Here was one attempt I made using tbf:
> > > > >=20
> > > > > tc qdisc add dev eth2 root handle 1: prio
> > > > > tc qdisc add dev eth2 parent 1:1 handle 10: tbf rate 8900mbit=
 buffer 1112500 limit 10000 mtu 9000
> > > > > tc filter add dev eth2 protocol ip parent 1: prio 1 u32 match=
 ip dst 192.168.1.23 flowid 10:1
> > > > >=20
> > > > > I tried many variations of the above, all without success.
> > > >=20
> > > > The main problem are smaller packets. If you had (almost) only =
9000b
> > > > frames this probably could work. [...]
> > >=20
> > > On the other hand, e.g. the limit above seems too low wrt mtu & r=
ate.
> >=20
> > Actually, I discovered my commands above work just fine on
> > a 2.6.35 box:
> >=20
> > i7test7% nuttcp -T10 -i1 192.168.1.17
> >  1045.3125 MB /   1.00 sec =3D 8768.3573 Mbps     0 retrans
> >  1045.6875 MB /   1.00 sec =3D 8772.0292 Mbps     0 retrans
> >  1049.5625 MB /   1.00 sec =3D 8804.2627 Mbps     0 retrans
> >  1043.1875 MB /   1.00 sec =3D 8750.9960 Mbps     0 retrans
> >  1048.6875 MB /   1.00 sec =3D 8796.3246 Mbps     0 retrans
> >  1033.4375 MB /   1.00 sec =3D 8669.3188 Mbps     0 retrans
> >  1040.7500 MB /   1.00 sec =3D 8730.7057 Mbps     0 retrans
> >  1047.0000 MB /   1.00 sec =3D 8783.2063 Mbps     0 retrans
> >  1040.0000 MB /   1.00 sec =3D 8724.0564 Mbps     0 retrans
> >  1037.4375 MB /   1.00 sec =3D 8702.5434 Mbps     0 retrans
> >=20
> > 10431.5608 MB /  10.00 sec =3D 8749.7542 Mbps 25 %TX 35 %RX 0 retra=
ns 0.11 msRTT
> >=20
> > The problems I encountered were on a field system running
> > 2.6.30.10.  I will investigate upgrading the field system
> > to 2.6.35.
> >=20
>=20
> Yes, I noticed same thing for me on net-next-2.6=20
>=20
> Please report :
>=20
> tc -s -d qdisc

Not sure why you want this on the older 2.6.30.10 kernel,
but here it is:

i7test6% nuttcp -T10 -i1 192.168.1.14
 1169.1875 MB /   1.00 sec =3D 9807.2868 Mbps     0 retrans
 1181.1875 MB /   1.00 sec =3D 9908.9054 Mbps     0 retrans
 1181.1250 MB /   1.00 sec =3D 9907.9253 Mbps     0 retrans
 1181.1875 MB /   1.00 sec =3D 9908.4991 Mbps     0 retrans
 1180.6875 MB /   1.00 sec =3D 9904.3345 Mbps     0 retrans
 1181.1250 MB /   1.00 sec =3D 9908.0838 Mbps     0 retrans
 1181.1875 MB /   1.00 sec =3D 9908.4099 Mbps     0 retrans
 1181.0625 MB /   1.00 sec =3D 9907.3911 Mbps     0 retrans
 1181.3750 MB /   1.00 sec =3D 9910.2801 Mbps     0 retrans
 1181.1875 MB /   1.00 sec =3D 9908.2118 Mbps     0 retrans

11801.1382 MB /  10.04 sec =3D 9858.7159 Mbps 24 %TX 40 %RX 0 retrans 0=
=2E11 msRTT

i7test6% tc -s -d qdisc show dev eth2
qdisc prio 1: root refcnt 32 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1=
 1 1 1
 Sent 12448974085 bytes 1381173 pkt (dropped 266, overlimits 0 requeues=
 12)=20
 rate 0bit 0pps backlog 0b 0p requeues 12=20
qdisc tbf 10: parent 1:1 rate 8900Mbit burst 1111387b/64 mpu 0b lat 429=
5.0s=20
 Sent 12448974043 bytes 1381172 pkt (dropped 266, overlimits 0 requeues=
 0)=20
 rate 0bit 0pps backlog 0b 0p requeues 0=20

I'm guessing this is probably related to the schedulers
time resolution issue that Jarek mentioned.

And for completeness, here's the info for the working
2.6.35 case:

i7test7% nuttcp -T10 -i1 192.168.1.17
 1045.5625 MB /   1.00 sec =3D 8770.6210 Mbps     0 retrans
 1032.1875 MB /   1.00 sec =3D 8658.3825 Mbps     0 retrans
 1039.8125 MB /   1.00 sec =3D 8722.7801 Mbps     0 retrans
 1050.2500 MB /   1.00 sec =3D 8810.0739 Mbps     0 retrans
 1050.6875 MB /   1.00 sec =3D 8813.9378 Mbps     0 retrans
 1048.8125 MB /   1.00 sec =3D 8798.0857 Mbps     0 retrans
 1046.1875 MB /   1.00 sec =3D 8775.9954 Mbps     0 retrans
 1045.7500 MB /   1.00 sec =3D 8771.9307 Mbps     0 retrans
 1051.1250 MB /   1.00 sec =3D 8817.8900 Mbps     0 retrans
 1044.0625 MB /   1.00 sec =3D 8757.8019 Mbps     0 retrans

10454.7500 MB /  10.00 sec =3D 8769.2206 Mbps 26 %TX 35 %RX 0 retrans 0=
=2E11 msRTT

i7test7% tc -s -d qdisc show dev eth2
qdisc prio 1: root refcnt 33 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1=
 1 1 1
 Sent 11028687119 bytes 1223828 pkt (dropped 293, overlimits 0 requeues=
 0)=20
 backlog 0b 0p requeues 0=20
qdisc tbf 10: parent 1:1 rate 8900Mbit burst 1112500b/64 mpu 0b lat 429=
5.0s=20
 Sent 11028687077 bytes 1223827 pkt (dropped 293, overlimits 593 requeu=
es 0)=20
 backlog 0b 0p requeues 0=20

I'm not sure how you can have so many dropped but not have
any TCP retransmissions (or not show up as requeues).  But
there's probably something basic I just don't understand
about how all this stuff works.

					-Bill
