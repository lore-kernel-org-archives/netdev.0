From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 27212] New: Warning kmemcheck: Caught 64-bit
 read from uninitialized memory in netlink_broadcast_filtered
Date: Mon, 14 Feb 2011 11:43:18 -0800 (PST)
Message-ID: <20110214.114318.112601812.davem@davemloft.net>
References: <1295556085.2613.22.camel@edumazet-laptop>
	<4D393A99.9060104@kernel.org>
	<1297704922.2996.60.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: penberg@kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	xiaosuo@gmail.com, vegardno@ifi.uio.no,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1297704922.2996.60.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Feb 2011 18:35:22 +0100

> Le vendredi 21 janvier 2011 =E0 09:49 +0200, Pekka Enberg a =E9crit :
>=20
>> It actually looks like a bug in SLUB+kmemcheck. The=20
>> kmemcheck_slab_alloc() call in slab_post_alloc_hook() should use ksi=
ze()=20
>> instead of s->objsize. SLAB seems to do the right thing already. Any=
one=20
>> care to send a patch my way?
>>=20
>=20
> Hmm, what do you think of following patch ?
>=20
> Thanks, and sorry for the delay.
>=20
> [PATCH] slub: fix kmemcheck calls to match ksize() hints
>=20
> Recent use of ksize() in network stack (commit ca44ac38 : net: don't
> reallocate skb->head unless the current one hasn't the needed extra s=
ize
> or is shared) triggers kmemcheck warnings, because ksize() can return
> more space than kmemcheck is aware of.
>=20
> Pekka Enberg noticed SLAB+kmemcheck is doing the right thing, while S=
LUB
> +kmemcheck doesnt.
>=20
> Bugzilla reference #27212
>=20
> Reported-by: Christian Casteyde <casteyde.christian@free.fr>
> Suggested-by: Pekka Enberg <penberg@kernel.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: David S. Miller <davem@davemloft.net>
