From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: PROBLEM: null-ptr deref in ip_options_echo may lead to denial
 of service
Date: Tue, 21 Mar 2017 00:33:43 +0000
Message-ID: <1490056423.4770.6.camel@decadent.org.uk>
References: <CAC9A2PqFcJ2k5Nm8QyxbOrO6rQnfHxcPvsnkzPMGUuJ5hCXM1Q@mail.gmail.com>
         <1489987500.16816.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-wyeKUVrhXnH7wFGobtz2"
Cc: davem@davemloft.net, security@kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Anarcheuz Fritz <anarcheuz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37651 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932080AbdCUAeD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 20:34:03 -0400
In-Reply-To: <1489987500.16816.19.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wyeKUVrhXnH7wFGobtz2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2017-03-19 at 22:25 -0700, Eric Dumazet wrote:
> On Mon, 2017-03-20 at 12:59 +0800, Anarcheuz Fritz wrote:
> > Hi David,
> >=20
> >=20
> > While working on some legacy kernel I stumbled upon a null-ptr deref in
> > ip_options_echo. The bug has been verified on the latest version
> > 3.2.87 from the supported long-term branch.
> >=20
>=20
> Fixed in commit 34b2cef20f19c87999fff3da4071e66937db9644
> ("ipv4: keep skb->dst around in presence of IP options")
>=20
> For 3.2, since d826eb14ecef was not backported, following patch should
> do it.
>=20
> (Bug origin was f84af32cbca70 ("net: ip_queue_rcv_skb() helper"))

I see, I thought the vulnerability was introduced by d826eb14ecef.

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

Thanks to both of you; I'll queue this up for 3.2.

Ben.

--=20
Ben Hutchings
Power corrupts.=C2=A0=C2=A0Absolute power is kind of neat.
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0- John Lehman, Secretary of the US Navy
1981-1987

--=-wyeKUVrhXnH7wFGobtz2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAljQdOcACgkQ57/I7JWG
EQltMRAAoTqhAHP8llh+OkZonSzVdv5Aak0KYB5qAqn+GYmLzOu+WZha4WvgR/Cc
Ky6m/AdN3B9CtCrch42iAKNy3dGRzTMwYByJ+dqnyiDffC73o5Q6z1fiHvdLcbAD
J1HZ8Sl6Q1ev4OPxX/xNhmwXGgoRvn16310HCQ+lXYz19XINYm1mw+Ayetmksrs2
kZv4JgmhgCr6F5ylsBy/qdYgZSv8rFjBCk7sOqjBeF08Fkl/smOJhihHt604lRQD
+ThTbueU5tk7TG9Gb76M8PV4OSFJt1YCctcX2LKYv6W2c9vMPxiejChSIqX6Bk8t
b/7UcfESTSK0iGNQ+hKDdcnBidS4nm/VfXt9nTJm5zZ4vLxbWIFnZy+HSR80EEdS
5lQnP5aCSf2uujyY6oEm0rKR33BjR5nurVlsiFNy6ujTKQv6xE6ovBCy4gPc/i+R
IPhigW6A6Cxd8LWC5QNVgbHpEpfed78ZENxk9QwUX3CxawyXeRBzaawJ5Y0IrOW4
UF54M8ioJH5B4dJE+Bce8GyKZy+18MTuQayyDkMbS87C6yWBGT5jJyD6tSGwuAhL
AMj5gpeAm0aZVZq/ncNZPXr1QEgsAqBDuZ1kQSreLdun38WogslCSuBCYLrHLOke
f1+2ZZfh8SJdq/Tw0uhcaC/AlV1f2U8LycYrPhRPGSUhYTba7+s=
=PkWc
-----END PGP SIGNATURE-----

--=-wyeKUVrhXnH7wFGobtz2--
