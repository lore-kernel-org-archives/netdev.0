From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Tue, 05 Jul 2011 06:14:18 +0200
Message-ID: <1309839258.2720.17.camel@edumazet-laptop>
References: <bug-38102-10286@https.bugzilla.kernel.org/>
	 <20110629145135.5179fb0c.akpm@linux-foundation.org>
	 <BANLkTi=PxH8V58k-VycsM=1ZiE9hPqCN4Q@mail.gmail.com>
	 <CAB9v_DHXB6n07sEY_=HZ8S4zMO01Vs8B78dGyEWrm-hyRP82XA@mail.gmail.com>
	 <1309707971.2523.20.camel@edumazet-laptop>
	 <CAB9v_DG7e8vDE+4PDwuOR2DYG1FEvUM1fxa+e4a=swwTYGJ9nQ@mail.gmail.com>
	 <20110704130531.37cf876e@Nokia-N900>
	 <1309787822.2247.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110704162726.4072e715@maggie> <20110704164351.338dc12e@maggie>
	 <1309792323.2247.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAB9v_DHHmeFtQ4jrtVRSGWBvB=W_=QBHCvMi-u25e0nPBQ1jAA@mail.gmail.com>
	 <CAB9v_DFFX6cHAFBSOGDJRniehJ6pYD7Z5XG6ygTGHy8j=z+U0g@mail.gmail.com>
	 <1309837443.2720.8.camel@edumazet-laptop>
	 <CAB9v_DFYGyYiXGfMCXn_WDeGTKz8BZPYBCuaDj_a+5VAG3Jn=g@mail.gmail.com>
	 <1309839068.2720.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53582 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab1GEEOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 00:14:23 -0400
Received: by wwe5 with SMTP id 5so5537462wwe.1
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 21:14:22 -0700 (PDT)
In-Reply-To: <1309839068.2720.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 06:11 +0200, Eric Dumazet a =C3=A9crit =
:
> Le mardi 05 juillet 2011 =C3=A0 07:56 +0400, Alexey Zaytsev a =C3=A9c=
rit :
> > On Tue, Jul 5, 2011 at 07:44, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > >
> > > I dont care about duplicate acks at this point.
> > >
> > > Thats a separate issue (TCP layer)
> > >
> >=20
> > Maybe some tx packets are just sent out more then once? Or a single
> > packet is sent out instead of some other packets?
> > The delays between two dups is short, and they come in bursts, up t=
o a
> > few hundreds of duplicate packets at a time.
> >=20
>=20
> Thats a completely different problem. SSH is very expensive for your
> receiver (your dump1 file has small packets (560 bytes)), and it cann=
ot
> cope with the stress.
>=20
> You're filling the b44 rx ring, and b44 driver has no choice to zap 2=
00
> packets at once. This sure is a problem for tcp, as it stalls the thi=
ng.
>=20
> You could avoid this by doing this at b44 machine (the receiver)
>=20
> echo "4096 32768 87380" >/proc/sys/net/ipv4/tcp_rmem
>=20
> So that sender wont be able to push so many packets

You can also try using more packets in rx ring : (default is 200
packets, limit ~511)

ethtool -G eth0 rx 400



