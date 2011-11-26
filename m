From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [BUG] 3.2-rc2: BUG kmalloc-8: Redzone overwritten
Date: Sat, 26 Nov 2011 12:54:38 +0200
Message-ID: <1322304878.28191.1.camel@sasha>
References: <1321866845.3831.7.camel@lappy>
	 <1321870529.2552.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321870915.2552.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321870967.8173.1.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>,
 Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg
 <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>,  linux-kernel
 <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1321870967.8173.1.camel@lappy>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-11-21 at 12:22 +0200, Sasha Levin wrote:
> On Mon, 2011-11-21 at 11:21 +0100, Eric Dumazet wrote:
> > Le lundi 21 novembre 2011 =E0 11:15 +0100, Eric Dumazet a =E9crit :
> >=20
> > >=20
> > > Hmm, trinity tries to crash decnet ;)
> > >=20
> > > Maybe we should remove this decnet stuff for good instead of tracki=
ng
> > > all bugs just for the record. Is there anybody still using decnet ?
> > >=20
> > > For example dn_start_slow_timer() starts a timer without holding a
> > > reference on struct sock, this is highly suspect.
> > >=20
> > > [PATCH] decnet: proper socket refcounting
> > >=20
> > > Better use sk_reset_timer() / sk_stop_timer() helpers to make sure =
we
> > > dont access already freed/reused memory later.
> > >=20
> > > Reported-by: Sasha Levin <levinsasha928@gmail.com>
> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >=20
> > Hmm, I forgot to remove the sock_hold(sk) call from dn_slow_timer(),
> > here is V2 :
> >=20
> > [PATCH] decnet: proper socket refcounting
> >=20
> > Better use sk_reset_timer() / sk_stop_timer() helpers to make sure we
> > dont access already freed/reused memory later.
> >=20
> > Reported-by: Sasha Levin <levinsasha928@gmail.com>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
>=20
> [snip]
>=20
> Applied locally and running same tests as before, will update with
> results.
>=20

Looks ok after a couple days of testing.

	Tested-by: Sasha Levin <levinsasha928@gmail.com>

--=20

Sasha.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
