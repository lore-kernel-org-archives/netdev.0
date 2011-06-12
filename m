From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about LRO/GRO and TCP acknowledgements
Date: Sun, 12 Jun 2011 16:57:37 +0200
Message-ID: <1307890657.2872.158.camel@edumazet-laptop>
References: <20110611215919.5fc29c27@konijn>
	 <1307850224.22348.626.camel@localhost> <20110612095131.6d924082@konijn>
	 <1307869632.2872.106.camel@edumazet-laptop>
	 <20110612113004.79f48f40@konijn>
	 <1307875698.2872.130.camel@edumazet-laptop>
	 <20110612132428.3e1a4593@konijn>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joris van Rantwijk <joris@jorisvr.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38004 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573Ab1FLO5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 10:57:45 -0400
Received: by wya21 with SMTP id 21so2723209wya.19
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2011 07:57:44 -0700 (PDT)
In-Reply-To: <20110612132428.3e1a4593@konijn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 12 juin 2011 =C3=A0 13:24 +0200, Joris van Rantwijk a =C3=A9=
crit :
> On 2011-06-12, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > So your concern is more a Sender side implementation missing this
> > recommendation, not GRO per se...
>=20
> Not really. The same RFC says:
>   Specifically, an ACK SHOULD be generated for at least every
>   second full-sized segment, ...
>=20

Well, SHOULD is not MUST.


> I can see how the world may have been a better place if every sender
> implemented Appropriate Byte Counting and TCP receivers were allowed =
to
> send fewer ACKs. However, current reality is that ABC is optional,
> disabled by default in Linux, and receivers are recommended to send o=
ne
> ACK per two segments.
>=20

ABC might be nice for stacks that use byte counters for cwnd. We use
segments.

> I suspect that GRO currently hurts throughput of isolated TCP
> connections. This is based on a purely theoretic argument. I may be
> wrong and I have absolutely no data to confirm my suspicion.
>=20
> If you can point out the flaw in my reasoning, I would be greatly
> relieved. Until then, I remain concerned that there may be something
> wrong with GRO and TCP ACKs.

Think of GRO being a receiver facility against stress/load, typically i=
n
datacenter.

Only when receiver is overloaded, GRO kicks in and can coalesce several
frames before being handled in TCP stack in one run.

If receiver is so loaded that more than 2 frames are coalesced in a NAP=
I
run, it certainly helps to not allow sender to increase its cwnd more
than one SMSS. We probably are right before packet drops anyway.



