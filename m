From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange packet drops with heavy firewalling
Date: Thu, 15 Apr 2010 15:42:53 +0200
Message-ID: <1271338973.16881.2593.camel@edumazet-laptop>
References: <m339z50x1l.fsf@ursa.amorsen.dk>
	 <q2v40c9f5b21004120116p766df82dj88c6af4e4cad55f@mail.gmail.com>
	 <1271083479.2858.377.camel@ursa.amorsen.dk>
	 <p2x40c9f5b21004120833jd7a749cak6ea69cebd28f8352@mail.gmail.com>
	 <1271091990.2858.409.camel@ursa.amorsen.dk>
	 <u2y412e6f7f1004121618p6d6eff30q8a45a03faa59a912@mail.gmail.com>
	 <1271138186.16881.168.camel@edumazet-laptop>
	 <m3hbnfzsye.fsf@ursa.amorsen.dk>  <m3633szw61.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	zhigang gong <zhigang.gong@gmail.com>, netdev@vger.kernel.org
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:45535 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455Ab0DONnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 09:43:03 -0400
Received: by bwz25 with SMTP id 25so1608697bwz.28
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 06:43:01 -0700 (PDT)
In-Reply-To: <m3633szw61.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 15:23 +0200, Benny Amorsen a =C3=A9crit :
> Benny Amorsen <benny+usenet@amorsen.dk> writes:
>=20
> > I'll keep monitoring the server, and if it starts dropping packets =
again
> > or load increases I'll check whether irqbalanced does the right thi=
ng,
> > and if not I'll implement your suggestion.
>=20
> It did start dropping packets (although very few, a few packets dropp=
ed
> at once perhaps every ten minutes). Irqbalanced didn't move the
> interrupts.
>=20
> Doing
>=20
> echo 01 >/proc/irq/99/smp_affinity
> echo 02 >/proc/irq/100/smp_affinity
> echo 04 >/proc/irq/101/smp_affinity
>=20
> and so on like Erik Dumazet suggested seems to have helped, but not
> entirely solved the problem.
>=20
> The problem now manifests itself this way in ethtool -S:
>      rx_no_buffer_count: 270
>      rx_queue_drop_packet_count: 270
>=20
> I can't be sure that I'm not just getting hit by a 1Gbps traffic spik=
e,
> of course, but it is a bit strange that a machine which can do 200Mbp=
s
> at 92% idle can't handle subsecond peaks close to 1Gbps...
>=20

Even with multiqueue, its quite possible one queue gets more than one
packet per micro second. Time to process a packet might be greater then
1 us even on recent hardware. So bursts of 1000 small packets with same
flow information, hit one queue, one cpu, and fill rx ring.

Loosing these packets is OK, its very likely its an attack :)

> I wish ifstat could report errors so I could see what the traffic rat=
e
> was when the problem occurred...

yes, it could be added I guess.


