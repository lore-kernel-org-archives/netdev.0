From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Mon, 08 Nov 2010 16:06:25 +0100
Message-ID: <1289228785.2820.203.camel@edumazet-laptop>
References: <1288954189.28003.178.camel@firesoul.comx.local>
	 <1288988955.2665.297.camel@edumazet-laptop>
	 <1289213926.15004.19.camel@firesoul.comx.local>
	 <1289214289.2820.188.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39776 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754847Ab0KHPGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 10:06:31 -0500
Received: by wwb18 with SMTP id 18so11978wwb.1
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 07:06:30 -0800 (PST)
In-Reply-To: <1289214289.2820.188.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 novembre 2010 =C3=A0 12:04 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le lundi 08 novembre 2010 =C3=A0 11:58 +0100, Jesper Dangaard Brouer =
a
> =C3=A9crit :
> > On Fri, 2010-11-05 at 21:29 +0100, Eric Dumazet wrote:
> > > Le vendredi 05 novembre 2010 =C3=A0 11:49 +0100, Jesper Dangaard =
Brouer a
> > > =C3=A9crit :
> > > > Hi Eric,
> > > >=20
> > > > A colleague send me a link to someone who has done some quite e=
xtensive
> > > > performance measurements across different kernel versions.
> > > >=20
> > > > I noticed that the loopback performance has gotten quite bad:
> > > >=20
> > > > http://www.phoronix.com/scan.php?page=3Darticle&item=3Dlinux_26=
12_2637&num=3D6
> > > >=20
> > > > I though you might be interested in the link.
> > > >=20
> > > > See you around :-)
> > >=20
> > > Hi !
> > >=20
> > > Problem is : I have no idea what test they exactly use,
> > > do you have info about it ?
> >=20
> > Its called the Phoronix test-suite, their website is:
> > http://www.phoronix-test-suite.com/?k=3Dhome
> >=20
> > On my Ubuntu workstation their software comes as a software package=
:
> >  sudo aptitude install phoronix-test-suite
> >=20
> > They seem to be related to the test/review site:
> > http://www.phoronix.com/
> >=20
> >=20
> >=20
> > > This probably can be explained very fast.
> >=20
> > The loopback test seems to be the only real networking test they do=
=2E
> > It looks like they just copy a very big fil via loopback, and recor=
d the
> > time it took... quite simple.
> >=20
> > Their tests seems to be focused on CPU util/speed, graphics/games.
> >=20
> >=20
> > The thing that caught my attention, was that they seemed interested=
 in
> > doing performance regression testing on all kernel versions...
> >=20
> > So, I though, it would be great if someone else would do automated
> > performance regression testing for us :-),  Too bad they only have =
a
> > very simple network test.
> >=20
> >=20
>=20

>=20

CC netdev, if you dont mind.


Their network test is basically :

netcat -l 9999 >/dev/null &
time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat  127.0.0.1 9999

They say it takes 38 seconds on their "super fast" processor

On my dev machine, not super fast (E5540 @2.53GHz), I get 8 or 9
seconds, even if only one CPU is online, all others offline.

Go figure... maybe an artifact of the virtualization they use.

I suspect some problem with the ticket spinlocks and a call to
hypervisor to say 'I am spinning on a spinlock, see if you need to do
something useful', or maybe ACPI problem (going to/from idle)




