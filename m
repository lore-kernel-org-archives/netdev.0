From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: addrconf: refcnt with  IPV6_PRIVACY enabled
Date: Tue, 23 Nov 2010 16:53:31 +0200
Message-ID: <20101123145331.GA4102@swordfish.minsk.epam.com>
References: <20101123134003.GB4142@swordfish.minsk.epam.com>
 <1290522803.3046.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zhXaljGHf11kAtnf"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1290522803.3046.11.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Eric,

On (11/23/10 15:33), Eric Dumazet wrote:
> Sergey, I dont think your patches (V1 or V2) are correct.
>=20
> You leak a refcount if (idev->dead) is true
>
Hm, that's true. Thank you.

=20
> ipv6_regen_rndid() is the timer handler function, it must call
> in6_dev_put() at the end, unless we rearm the timer.
>=20
> So this code is correct.
>=20
>=20
> if (!mod_timer(&idev->regen_timer, expires))
> 	in6_dev_hold(idev);
> ...
> in6_dev_put(idev);
>

Even if in6_dev_hold hasn't been called from ipv6_regen_rndid?


>=20
> And we must call in6_dev_hold() before calling the handler, either
> directly from ipv6_add_dev() [Where your first patch tried to remove the
> dev_hold() call], or when arming the timer.
>=20
> Are you sure the problem you try to solve is not already solved in
> commit 88b2a9a3d98a19496d64aadda7158c0ad51cbe7d in net-2.6 tree ?
>=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcommitd=
iff;h=3D88b2a9a3d98a19496d64aadda7158c0ad51cbe7d
>=20

Oh, haven't seen this one. I'll try, thank you.


	Sergey

--zhXaljGHf11kAtnf
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iJwEAQECAAYFAkzr1WsACgkQfKHnntdSXjQEnAQAp/LJK1o+K9YrGGvWMpdiz3Mw
UkGFURAhzQnvIEjD1tlF2Ot9jAUxVg/EDgO5Qptrmjqjec43ZUNq6IAuHObfa1rV
V4f3opy3ZXm3Oe6NAAJyOScvfdVYTTDQBYCAzCxyzpdNo4yTsvZkS4QdzhwUlgk4
LGLFczvkrnsm5pxarro=
=wXzi
-----END PGP SIGNATURE-----

--zhXaljGHf11kAtnf--
