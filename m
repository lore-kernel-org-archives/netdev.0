From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] bridge: 64bit rx/tx counters
Date: Thu, 12 Aug 2010 14:16:15 +0200
Message-ID: <1281615375.2494.20.camel@edumazet-laptop>
References: <1276531162.2478.121.camel@edumazet-laptop>
	 <20100614.231412.39191304.davem@davemloft.net>
	 <1276596856.2541.84.camel@edumazet-laptop>
	 <1276598376.2541.93.camel@edumazet-laptop>
	 <20100809214740.c5d186d2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	Nick Piggin <npiggin@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51532 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753680Ab0HLMQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 08:16:21 -0400
Received: by wwj40 with SMTP id 40so1467884wwj.1
        for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 05:16:20 -0700 (PDT)
In-Reply-To: <20100809214740.c5d186d2.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 09 ao=C3=BBt 2010 =C3=A0 21:47 -0700, Andrew Morton a =C3=A9cr=
it :

> Oh for fuck's sake.  Will you guys just stop adding generic kernel
> infrastructure behind everyone's backs?
>=20
> Had I actually been aware that this stuff was going into the tree I'd
> have pointed out that the u64_stats_* api needs renaming.=20
> s/stats/counter/ because it has no business assuming that the counter
> is being used for statistics.
>=20
>=20

Sure. Someone suggested to change the name, considering values could
also be signed (s64 instead of u64_...)

> And all this open-coded per-cpu counter stuff added all over the plac=
e.
> Were percpu_counters tested or reviewed and found inadequate and unfi=
xable?
> If so, please do tell.
>=20

percpu_counters tries hard to maintain a view of the current value of
the (global) counter. This adds a cost because of a shared cache line
and locking. (__percpu_counter_sum() is not very scalable on big hosts,
it locks the percpu_counter lock for a possibly long iteration)


=46or network stats we dont want to maintain this central value, we do =
the
folding only when necessary. And this folding has zero effect on
concurrent writers (counter updates)

=46or network stack, we also need to update two values, a packet counte=
r
and a bytes counter. percpu_counter is not very good for the 'bytes
counter', since we would have to use a arbitrary big bias value.
Using several percpu_counter would also probably use more cache lines.

Also please note this stuff is only needed for 32bit arches.=20

Using percpu_counter would slow down network stack on modern arches.


I am very well aware of the percpu_counter stuff, I believe I tried to
optimize it a bit in the past.

Thanks


