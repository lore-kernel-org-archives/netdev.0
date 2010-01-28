From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 0% cpu usasge after fresh boot or net restart but 10% CPU if
 kernel flush route cache
Date: Thu, 28 Jan 2010 22:16:27 +0100
Message-ID: <1264713387.3380.17.camel@edumazet-laptop>
References: <41ac0f9e1001260858o7d2a6a6dgb37ecfba5c325932@mail.gmail.com>
	 <1264605976.3197.8.camel@edumazet-laptop>
	 <41ac0f9e1001271153u333a5e2aq6f473ccc6e6d1e23@mail.gmail.com>
	 <1264627088.2892.7.camel@edumazet-laptop>
	 <41ac0f9e1001280114x17951046oda3fddcae4b8b9d3@mail.gmail.com>
	 <1264694957.2930.15.camel@edumazet-laptop>
	 <41ac0f9e1001280826j1a4e6caar47ccfd357b6feb37@mail.gmail.com>
	 <1264698380.2930.20.camel@edumazet-laptop>
	 <41ac0f9e1001281049g119d5b1bgbc47f78150cac6ee@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: cold cold <nedkonedev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:45387 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744Ab0A1VQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 16:16:31 -0500
Received: by bwz27 with SMTP id 27so961457bwz.21
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 13:16:29 -0800 (PST)
In-Reply-To: <41ac0f9e1001281049g119d5b1bgbc47f78150cac6ee@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 28 janvier 2010 =C3=A0 20:49 +0200, cold cold a =C3=A9crit :
> what you mean drop packets ?
>=20
> i test 2 different things and shearing results with you
> first test with high CPU is with garbage collection function
> second results represent CPU usage with totally disabled  garbage col=
lection

ell, you didnt describe your benchmark method.

1) your results were on different rx/tx workload, and describing your
workload is very important to be able to compare results. Then it shoul=
d
be exactly same workload.

=46or example, when tx/tx load is high enough, less cpu overhead is spe=
nt
on irq processing, since each IRQ delivers more packets per round.

2) you didnt sent "perf top" results for the second/last one.

  But the first "perf top" results showed less than 1% of cpu time was
used by cache cleanup. I guess you dont want to focus on this, since
its already very good.



Usually, when we want to bench a router, we study how it deals with DDO=
S
workload. Feeding lot of packets to the device and study what percentag=
e
of them are actually transmitted. Goal being 100% of legit packets of
course.

Route cache settings matter in DDOS situations, and the flush operation
can have a big impact on dropped frames because of cpu/ram congestion.

Because of 600 seconds oscillations, its pretty hard to study exact cpu
use of a router, unless taking samples on long periods.



