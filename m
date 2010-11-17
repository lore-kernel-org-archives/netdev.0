From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ping -I eth1 ....
Date: Wed, 17 Nov 2010 11:23:32 +0100
Message-ID: <1289989412.2687.18.camel@edumazet-laptop>
References: <OF339BCA8A.B674D6AE-ONC12577D2.00481B5E-C12577D2.0048B214@transmode.se>
	 <1288964206.2882.402.camel@edumazet-laptop>
	 <OF22F5901E.A7276220-ONC12577D2.004C79CB-C12577D2.004D1571@transmode.se>
	 <20101105142510.GA14986@canuck.infradead.org>
	 <1288967665.2882.522.camel@edumazet-laptop>
	 <OF6C6C2970.245A64ED-ONC12577D2.00518CF6-C12577D2.00522AAD@transmode.se>
	 <1288969614.2882.590.camel@edumazet-laptop>
	 <OFAA7963DE.C3F04675-ONC12577D2.0056F55C-C12577D2.00575EC2@transmode.se>
	 <20101105203150.GA12118@canuck.infradead.org>
	 <OF921B3329.67FE598A-ONC12577D3.0033387A-C12577D3.00355AC4@LocalDomain>
	 <OFC0986D69.B0E22D17-ONC12577D6.006B4A38-C12577D6.006B72F9@LocalDomain>
	 <OFDE99BE0E.BC2CFBA0-ONC12577DE.00341E5C-C12577DE.00342E2E@transmode.se>
	 <1289987467.2687.15.camel@edumazet-laptop>
	 <OF76197EA2.D5EFE8B7-ONC12577DE.0036FE30-C12577DE.0037C54E@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@infradead.org>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34941 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932541Ab0KQKXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 05:23:38 -0500
Received: by wyb28 with SMTP id 28so1789956wyb.19
        for <netdev@vger.kernel.org>; Wed, 17 Nov 2010 02:23:37 -0800 (PST)
In-Reply-To: <OF76197EA2.D5EFE8B7-ONC12577DE.0036FE30-C12577DE.0037C54E@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 novembre 2010 =C3=A0 11:09 +0100, Joakim Tjernlund a =C3=
=A9crit :
> Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/11/17 10:51:07:
> >
> > Le mercredi 17 novembre 2010 =C3=A0 10:29 +0100, Joakim Tjernlund a=
 =C3=A9crit :
> > > Joakim Tjernlund/Transmode wrote on 2010/11/09 20:33:37:
> > > >
> > > > Joakim Tjernlund/Transmode wrote on 2010/11/06 10:42:46:
> > > > > Thomas Graf <tgr@infradead.org> wrote on 2010/11/05 21:31:50:
> > > > > >
> > > > > > On Fri, Nov 05, 2010 at 04:54:18PM +0100, Joakim Tjernlund =
wrote:
> > > > > > > Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/11/05=
 16:06:54:
> > > > > > > >
> > > > > > > > > Hopefully most of that is legacy or just plain wrong?=
 Unless
> > > > > > > > > someone can say why only test IFF_UP one should consi=
der changing them.
> > > > > > > > >
> > > > > > > >
> > > > > > > > Most of the places are hot path.
> > > > > > > >
> > > > > > > > You dont want to replace one test by four tests.
> > > > > > > >
> > > > > > > > _This_ would be wrong :)
> > > > > > >
> > > > > > > Wrong is wrong, even if it is in the hot path :)
> > > > > > > Perhaps it is time define and internal IFF_OPERATIONAL fl=
ag
> > > > > > > which is the sum of IFF_UP, IFF_RUNNING etc.? Tht
> > > > > > > way you still get one test in the hot path and can abstra=
ct
> > > > > > > what defines an operational link.
> > > > > >
> > > > > > You definitely don't want to have your send() call fail sim=
ply because
> > > > > > the carrier was off for a few msec or the routing daemon ha=
s put a link
> > > > > > down temporarly. Also, the outgoing interface looked up at =
routing
> > > > > > decision is not necessarly the interface used for sending i=
n the end.
> > > > > > The packet may get mangled and rerouted by netfilter or tc =
on the way.
> > > > >
> > > > > But do you handle the case when the link is non operational f=
or a long time?
> > > > >
> > > > > >
> > > > > > Personally I'm even ok with the current behaviour of sendto=
() while the
> > > > > > socket is bound to an interface but if we choose to return =
an error
> > > > > > if the interface is down we might as well do so based on th=
e operational
> > > > > > status.
> > >
> > > > > Perhaps there is a better way. This all started when pppd hun=
g because
> > > > > of ping -I <ppp interface>, then someone pulled the cable for=
 the on the link.
> > > > >
> > > > > This is a strace where we have two ping -I,
> > > > > ping -I p1-2-1-2-2 .. and ping -I p1-2-3-2-4 ..
> > > > > Notice how pppd hangs for a long time in PPPIOCDETACH
> > > > > As far as I can tell this is due to ping -I has claimed the p=
pp interfaces
> > > > > and doesn't noticed that the link is down. Ideally ping shoul=
d receive
> > > > > a ENODEV as soon as pppd calls PPPIOCDETACH.
> > > > >
> > > > >    0.000908 write(0, "Connection terminated.\n", 23) =3D 23
> > > > >      0.000481 gettimeofday({1288952770, 566048}, NULL) =3D 0
> > > > >      0.001553 ioctl(7, PPPIOCDETACH
> > > > > Message from syslogd@Brazil at Fri Nov  5 11:26:20 2010 ...
> > > > > Brazil kernel: unregister_netdevice: waiting for p1-2-1-2-2 t=
o become free. Usage count =3D 3
> > > > > Message from syslogd@Brazil at Fri Nov  5 11:26:20 2010 ...
> > > > > Brazil kernel: unregister_netdevice: waiting for p1-2-3-2-4 t=
o become free. Usage count =3D 3
> > > > > Message from syslogd@Brazil at Fri Nov  5 11:26:51 2010 ...
> > > > > Brazil last message repeated 3 times
> > > > > , 0xbfbc3398) =3D 0
> > > > >     66.559216 connect(9, {sa_family=3DAF_PPPOX, sa_data=3D"\0=
\0\0\0\0\0\0\252\273\314\335\356hd"}, 30) =3D 0
> > > > >      0.000693 close(10)                 =3D 0
> > > > >      0.000449 close(7)                  =3D 0
> > > > >      0.009801 close(9)                  =3D 0
> > > >
> > > > Any comment on this last strace? It is expected that ping -I sh=
ould
> > > > hold pppd hostage?
> > > >
> > >
> > > Ping?
> > >
> >
> > I thought I posted a patch, is there something else ?
>=20
> yes, I wondered about the above strace and if it is expected that pin=
g -I
> should hold pppd hostage? Should not ping receive a ENODEV as soon as
> pppd detaches an interface?
>=20
> >
> > Could you please test with latest net-next-2.6 and following patch =
?
>=20
> I tested the first patch you sent and that one worked well. I can try
> again on 2.6.35( our boards takes a while to move forward)?

Well, in this case, apply commit :=20

332dd96f7ac15e937088fe11f15cfe0210e8edd1

(net/dst: dst_dev_event() called after other notifiers)

http://git2.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3D332dd96f7ac15e937088fe11f15cfe0210e8edd1



