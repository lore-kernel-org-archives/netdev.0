From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Mon, 4 Jul 2011 16:51:37 +0200
Message-ID: <20110704165137.1332c44f@maggie>
References: <bug-38102-10286@https.bugzilla.kernel.org/>
	<20110629145135.5179fb0c.akpm@linux-foundation.org>
	<BANLkTi=PxH8V58k-VycsM=1ZiE9hPqCN4Q@mail.gmail.com>
	<CAB9v_DHXB6n07sEY_=HZ8S4zMO01Vs8B78dGyEWrm-hyRP82XA@mail.gmail.com>
	<1309707971.2523.20.camel@edumazet-laptop>
	<CAB9v_DG7e8vDE+4PDwuOR2DYG1FEvUM1fxa+e4a=swwTYGJ9nQ@mail.gmail.com>
	<1309788049.2247.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20110704163134.7f2180b2@maggie>
	<1309790705.2247.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:51716 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755628Ab1GDOvr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 10:51:47 -0400
In-Reply-To: <1309790705.2247.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 04 Jul 2011 16:45:05 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 04 juillet 2011 =C3=A0 16:31 +0200, Michael B=C3=BCsch a =C3=
=A9crit :
> > On Mon, 04 Jul 2011 16:00:49 +0200
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > > And an other question. Why so we have the logic to work-around =
the 1Gb
> > > > DMA limit instead of just setting the dma mask?
> > >=20
> > > Your problem is in RX side : NIC actually writes to a buffer that=
 is
> > > supposedly not its property.
> >=20
> > The problem is on both sides, because some Linux architectures simp=
ly
> > do not support any DMA mask less than 32. This applied to i386 (IA3=
2) last
> > time I looked.
> > The b44 DMA engine can only address 30-bits.
>=20
>=20
> Michael, traces provided by Alexey are in the RX path.
>=20
> NIC does a DMA  (Receives an UDP frame) into a 2048 bytes buffers tha=
t
> was freed.

Yeah sure. That's obvious from the logs.
By "the problem" I meant "the 30bit limitation".
