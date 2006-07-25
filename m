From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: [PATCH] ip multicast route bug fix
Date: Tue, 25 Jul 2006 08:03:00 +0200
Message-ID: <1153807381.23563.2.camel@localhost.localdomain>
References: <20060719145716.4cb9e7e2@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-uvXq0V1BxKdczNbvQJdf"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailfront1.citynet.nu ([217.10.96.36]:49853 "EHLO
	mailfront1.citynet.nu") by vger.kernel.org with ESMTP
	id S1751400AbWGYGDf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 02:03:35 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060719145716.4cb9e7e2@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-uvXq0V1BxKdczNbvQJdf
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2006-07-19 at 14:57 -0700, Stephen Hemminger wrote:
> This should fix the problem reported in http://bugzilla.kernel.org/show_b=
ug.cgi?id=3D6186
> where the skb is used after freed. The code in IP multicast route.
>=20
> Code was reusing an skb which could lead to use after free or double free=
.

> +	=09
> +		iskb =3D alloc_skb(sizeof(struct iphdr), GFP_KERNEL);
> +		if (!iskb) {
> +			read_unlock(&mrt_lock);
> +			return -ENOMEM;
> +		}

GFP_KERNEL allocation under read_lock()?

--=20
/Martin

--=-uvXq0V1BxKdczNbvQJdf
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQBExbQUWm2vlfa207ERAtVyAJ92E9tpmFJpUNq439SubGwKyKQTaQCfYTs1
92Ghaxq+wXZ5lzUHXQdTNjM=
=EXPM
-----END PGP SIGNATURE-----

--=-uvXq0V1BxKdczNbvQJdf--

