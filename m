From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] neigh: speedup neigh_resolve_output()
Date: Mon, 11 Oct 2010 21:46:01 +0200
Message-ID: <1286826361.3218.14.camel@edumazet-laptop>
References: <1286456008.2912.171.camel@edumazet-laptop>
	 <1286484247.3745.91.camel@edumazet-laptop>
	 <20101011.121609.246536311.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46575 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755986Ab0JKTqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 15:46:07 -0400
Received: by wye20 with SMTP id 20so749860wye.19
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 12:46:06 -0700 (PDT)
In-Reply-To: <20101011.121609.246536311.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 octobre 2010 =C3=A0 12:16 -0700, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 07 Oct 2010 22:44:07 +0200
>=20
> > Le jeudi 07 octobre 2010 =C3=A0 14:53 +0200, Eric Dumazet a =C3=A9c=
rit :
> >=20
> >> Further improvements would need to use a seqlock instead of an rwl=
ock to
> >> protect neigh->ha[], to not dirty neigh too often and remove two a=
tomic
> >> ops.
> >>=20
> >=20
> > I implemented this idea in following patch, on top on previous one.
> >=20
> > [PATCH net-next] neigh: speedup neigh_resolve_output()
>=20
> So Eric do you think this is more efficient than the idea I
> proposed, which is to "cmpxchg 'hh' and RCU"?
>=20
> If you think this seqlock thing is faster or more desirable
> for some reason, I'll add it.
>=20
> Thanks!

Hmm, we would need a neigh->ha pointer to some struct, with rcu
protection. It adds a dereference in hot path. I believe this seqlock
(only for pathological cases, where dst are used for few packets) shoul=
d
be fine.

Note: After this patch, I have a "struct neighbour" small field reorg
pending, not yet submitted.

Thanks


