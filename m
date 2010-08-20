From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] netfilter: save the hash of the tuple in the
 original direction for latter use
Date: Fri, 20 Aug 2010 17:29:23 +0200
Message-ID: <1282318163.2484.212.camel@edumazet-laptop>
References: <1282316003-2966-1-git-send-email-xiaosuo@gmail.com>
	 <1282317016.2484.173.camel@edumazet-laptop>
	 <AANLkTimj=6HBdZK0WiPBxhm9YPG_8zRXEZyP--E7Shj8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41141 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292Ab0HTP33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 11:29:29 -0400
In-Reply-To: <AANLkTimj=6HBdZK0WiPBxhm9YPG_8zRXEZyP--E7Shj8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 20 ao=C3=BBt 2010 =C3=A0 23:22 +0800, Changli Gao a =C3=A9c=
rit :

> I should keep the old way, but fix a race.
>=20
>         if (unlikely(!nf_conntrack_hash_rnd_initted)) {
>                 get_random_bytes(&nf_conntrack_hash_rnd,
>                                 sizeof(nf_conntrack_hash_rnd));
>                 nf_conntrack_hash_rnd_initted =3D 1;
>         }
>=20
> nf_conntrack_alloc() isn't called with in the nf_conntrack_lock. So
> the above code maybe executed more than once on different CPUs. It is
> easy to fix with the cmpxchg() trick.

Sure, please fix the race first.

But as I said, its not critical, if one or two conntracks are hashed on
wrong basis. They will eventually disappear after timeout.



