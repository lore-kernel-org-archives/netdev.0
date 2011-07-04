From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Mon, 04 Jul 2011 15:57:02 +0200
Message-ID: <1309787822.2247.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <bug-38102-10286@https.bugzilla.kernel.org/>
	 <20110629145135.5179fb0c.akpm@linux-foundation.org>
	 <BANLkTi=PxH8V58k-VycsM=1ZiE9hPqCN4Q@mail.gmail.com>
	 <CAB9v_DHXB6n07sEY_=HZ8S4zMO01Vs8B78dGyEWrm-hyRP82XA@mail.gmail.com>
	 <1309707971.2523.20.camel@edumazet-laptop>
	 <CAB9v_DG7e8vDE+4PDwuOR2DYG1FEvUM1fxa+e4a=swwTYGJ9nQ@mail.gmail.com>
	 <20110704130531.37cf876e@Nokia-N900>
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
To: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44976 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081Ab1GDN5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 09:57:17 -0400
Received: by wwe5 with SMTP id 5so5106494wwe.1
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 06:57:16 -0700 (PDT)
In-Reply-To: <20110704130531.37cf876e@Nokia-N900>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 04 juillet 2011 =C3=A0 13:05 +0000, Michael B=C3=BCsch a =C3=A9=
crit :
> On Mon, 4 Jul 2011 15:48:31 +0400
> Alexey Zaytsev <alexey.zaytsev@gmail.com> wrote:
> > The skb is reinserted into the ring before its data is copied, it
> > seems. But this can't be the cause of my problem, as it would lead =
to
> > data corruption at most, not a write-after-free.
>=20
> Recycling the skb does not imply that the device can reuse it immedia=
tely. The device is told at the very end of the RX function (after the =
loop) that it's now safe to put stuff into the recyceled/new buffers.
>=20
> > And an other question. Why so we have the logic to work-around the =
1Gb
> > DMA limit instead of just setting the dma mask?
>=20
> Because the DMA mask does not work correctly on all arches for masks =
smaller than 4G.
>=20
> And btw, I dont understand what that wmb() patch is supposed to fix. =
There may be a wmb() missing, but rather after the ctrl _and_ the addre=
ss assignment to the descriptor.
> But I don't think this can cause this use-after-free anyway.
>=20

I dont have the b44 specs, but :

=46or sure, addr should be set before ctl, just in case ctl allows chip=
 to
start a dma transfert (to previous packet), because a OWN bit is unset
for example...

A second wmb() is not necessary.
It will be done eventually at next packet (we have a ring of 200
packets)



