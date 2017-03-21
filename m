From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-stable] ipv4: keep skb->dst around in presence of IP
 options
Date: Tue, 21 Mar 2017 11:25:29 +0000
Message-ID: <1490095529.4770.12.camel@decadent.org.uk>
References: <CAC9A2PqFcJ2k5Nm8QyxbOrO6rQnfHxcPvsnkzPMGUuJ5hCXM1Q@mail.gmail.com>
         <1489987500.16816.19.camel@edumazet-glaptop3.roam.corp.google.com>
         <1490056423.4770.6.camel@decadent.org.uk>
         <1490056561.4770.7.camel@decadent.org.uk>
         <1490070228.16816.98.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-S6IZ/sap6Aw9nSOQp+Px"
Cc: Anarcheuz Fritz <anarcheuz@gmail.com>, davem@davemloft.net,
        security@kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40880 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756896AbdCULZx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 07:25:53 -0400
In-Reply-To: <1490070228.16816.98.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-S6IZ/sap6Aw9nSOQp+Px
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2017-03-20 at 21:23 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> Upstream commit 34b2cef20f19c87999fff3da4071e66937db9644
> ("ipv4: keep skb->dst around in presence of IP options") incorrectly
> root caused commit d826eb14ecef ("ipv4: PKTINFO doesnt need dst
> reference") as bug origin.
>=20
> This patch should fix the issue for 3.2.xx stable kernels, since IPv4
> options seem to get more traction these days, after years of oblivion
> ;)
>=20
> Fixes: f84af32cbca70 ("net: ip_queue_rcv_skb() helper"))
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Anarcheuz Fritz <anarcheuz@gmail.com>
> ---
>=20
> This is a backport for 3.2 kernels.

Added to the queue, thanks.

Ben.

> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index b3648bbef0da..a6e1eeb02267 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -1009,7 +1009,8 @@ e_inval:
> =C2=A0 */
> =C2=A0int ip_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
> =C2=A0{
> -	if (!(inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO))
> +	if (!(inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO) &&
> +	=C2=A0=C2=A0=C2=A0=C2=A0!IPCB(skb)->opt.optlen)
> =C2=A0		skb_dst_drop(skb);
> =C2=A0	return sock_queue_rcv_skb(sk, skb);
> =C2=A0}
>=20
>=20
--=20
Ben Hutchings
Power corrupts.=C2=A0=C2=A0Absolute power is kind of neat.
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0- John Lehman, Secretary of the US Navy
1981-1987


--=-S6IZ/sap6Aw9nSOQp+Px
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAljRDakACgkQ57/I7JWG
EQmzfRAAtQ5D1b1dQ9FokfyDs2qQMn4cWkeUHBFpabCX5HHPA6EuOyUKwQEmNGZK
q++YIVY3nmlfXGdnoAP/XiqY38cZ5pTOCJRVrSt9q7GmFxTxR6vqvJqId8bb0D3Y
H2G93FBOx/1DkY9W/Ht7bDrXhlZJmQtGnhHjenTcyAPEWAspRHpCQB/tVXFxkcAh
e1+F9pnlv6dnZAmkdZz/XjFFNv95RFOf5DdgirAyf7Ak5UZCaHdoa8zz4hCPDyqH
vpQAfbL/KaGXRTmH5Hh8FJrqZq1ZEpcPAAkEWaYZwvgDKgfw20Qz68TyAoUswru3
0rdRGejG1Cke3zJWw8DYMGwsnj/Z62my+qhGgW28vcGEW9yT5YxfNlbkNxO3l3OS
mUFY7oswQSjnZBqjodYNZEmFxpe/NjedocyIaJisnkeJP1xESULxghzL/Kw1x8Yv
kqqzl1fV9ap+baCxa8zQg/OY7eScegv90s+c2hqkaXn2B0dPWoiV0nHBYgPhp76Y
cWlnL9CIkPe/qEG23lMSfn51yn037jjWYt6D41+t3B6/HBipHnyv20Yt425kM/iC
vlH6qIGlCMLaac4Tmv7+YEEUOjEE7zx+y7Kc7ZDgLQlSBFGgIsMDb5V1VAhkx05y
+rxOCqJ4Fojt/+8MZ8CFBZnWHeNM6ERwJH+h7ZTUBWQ7c0gqBlg=
=88wL
-----END PGP SIGNATURE-----

--=-S6IZ/sap6Aw9nSOQp+Px--
