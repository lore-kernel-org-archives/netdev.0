From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: skb_split in tcp_retransmit_skb question
Date: Thu, 27 Jan 2011 20:33:28 +0200
Message-ID: <20110127183327.GB4153@swordfish.minsk.epam.com>
References: <20110127152057.GA4153@swordfish.minsk.epam.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VrqPEDrXMn8OVzN4"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110127152057.GA4153@swordfish.minsk.epam.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--VrqPEDrXMn8OVzN4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On (01/27/11 17:20), Sergey Senozhatsky wrote:
> Hello,
>=20
> Suppose we have the following scenario:
>=20
> tcp_write_timer ->
>  tcp_retransmit_skb
>=20
> in tcp_retransmit_skb we have `if (skb->len > cur_mss)' evaluted to true,=
 which leads
> to tcp_fragment(sk, skb, cur_mss, cur_mss) call. tcp_fragment calls skb_s=
plit(skb, buff, len)
> which, in turn, calls skb_split_no_header(skb, skb1, len, pos), where we =
have
> `skb_shinfo(skb)->nr_frags++' while in `for (i =3D 0; i < nfrags; i++)' l=
oop.

Sorry for the noise. Alexey has pointed out that we have=20
skb_shinfo(skb)->nr_frags =3D 0 in skb_split_no_header. Have no idea how di=
d I miss it.=20

Thanks,

	Sergey

--VrqPEDrXMn8OVzN4
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iJwEAQECAAYFAk1BuncACgkQfKHnntdSXjRytwP/Wdjy9/P8mmMfzIknxb7s3jrO
bFmBB4QcETA/j0ZndGhjU/PGngFMnloh+Oh1kPZ9FQplewyqoDiBj+Bk19uVB9bm
273Rs5pjH99plbxFeWGPqRAGvvBrOvl6RvXHXPezlU8lynZgls/XgG+yPW1gkMKo
tLhNmaWUky+Ts0sxVd0=
=v8rH
-----END PGP SIGNATURE-----

--VrqPEDrXMn8OVzN4--
