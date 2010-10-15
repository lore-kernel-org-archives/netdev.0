From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tbf/htb qdisc limitations
Date: Fri, 15 Oct 2010 08:44:19 +0200
Message-ID: <1287125059.2659.1812.camel@edumazet-laptop>
References: <AANLkTin_jPp+WEkyJkD_KZyrJ4WX_6dM5wtFNw_ixuzv@mail.gmail.com>
	 <20101012101022.GA8578@ff.dom.local>
	 <AANLkTikQkCcPXtRQGp=MQrjrWtae84VzbENn5x+1yC47@mail.gmail.com>
	 <20101012215932.GA1945@del.dom.local> <4CB4DE6E.7030802@hp.com>
	 <20101013062649.GA6915@ff.dom.local>
	 <20101013233653.1e363692.billfink@mindspring.com>
	 <20101014064404.GA6219@ff.dom.local>
	 <20101014031354.e172d737.billfink@mindspring.com>
	 <20101014080939.GA7710@ff.dom.local> <20101014085005.GA8349@ff.dom.local>
	 <20101015023749.f085006b.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36333 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756086Ab0JOGpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 02:45:10 -0400
Received: by wyb28 with SMTP id 28so349222wyb.19
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 23:45:09 -0700 (PDT)
In-Reply-To: <20101015023749.f085006b.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 15 octobre 2010 =C3=A0 02:37 -0400, Bill Fink a =C3=A9crit =
:
> On Thu, 14 Oct 2010, Jarek Poplawski wrote:
>=20
> > On Thu, Oct 14, 2010 at 08:09:39AM +0000, Jarek Poplawski wrote:
> > > On Thu, Oct 14, 2010 at 03:13:54AM -0400, Bill Fink wrote:
> > > > TSO/GSO was disabled and was using 9000-byte jumbo frames
> > > > (and specified mtu 9000 to tc command).
> > > >=20
> > > > Here was one attempt I made using tbf:
> > > >=20
> > > > tc qdisc add dev eth2 root handle 1: prio
> > > > tc qdisc add dev eth2 parent 1:1 handle 10: tbf rate 8900mbit b=
uffer 1112500 limit 10000 mtu 9000
> > > > tc filter add dev eth2 protocol ip parent 1: prio 1 u32 match i=
p dst 192.168.1.23 flowid 10:1
> > > >=20
> > > > I tried many variations of the above, all without success.
> > >=20
> > > The main problem are smaller packets. If you had (almost) only 90=
00b
> > > frames this probably could work. [...]
> >=20
> > On the other hand, e.g. the limit above seems too low wrt mtu & rat=
e.
>=20
> Actually, I discovered my commands above work just fine on
> a 2.6.35 box:
>=20
> i7test7% nuttcp -T10 -i1 192.168.1.17
>  1045.3125 MB /   1.00 sec =3D 8768.3573 Mbps     0 retrans
>  1045.6875 MB /   1.00 sec =3D 8772.0292 Mbps     0 retrans
>  1049.5625 MB /   1.00 sec =3D 8804.2627 Mbps     0 retrans
>  1043.1875 MB /   1.00 sec =3D 8750.9960 Mbps     0 retrans
>  1048.6875 MB /   1.00 sec =3D 8796.3246 Mbps     0 retrans
>  1033.4375 MB /   1.00 sec =3D 8669.3188 Mbps     0 retrans
>  1040.7500 MB /   1.00 sec =3D 8730.7057 Mbps     0 retrans
>  1047.0000 MB /   1.00 sec =3D 8783.2063 Mbps     0 retrans
>  1040.0000 MB /   1.00 sec =3D 8724.0564 Mbps     0 retrans
>  1037.4375 MB /   1.00 sec =3D 8702.5434 Mbps     0 retrans
>=20
> 10431.5608 MB /  10.00 sec =3D 8749.7542 Mbps 25 %TX 35 %RX 0 retrans=
 0.11 msRTT
>=20
> The problems I encountered were on a field system running
> 2.6.30.10.  I will investigate upgrading the field system
> to 2.6.35.
>=20

Yes, I noticed same thing for me on net-next-2.6=20

Please report :

tc -s -d qdisc


