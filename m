From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: BUG: ping without route segfaults in dst_release
Date: Tue, 29 Mar 2011 02:00:35 +0200
Message-ID: <4D912123.2060604@pengutronix.de>
References: <4D911758.3010608@pengutronix.de> <20110328.165149.193711805.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC7A8FEE09A25B9E179B63003"
Cc: Netdev@vger.kernel.org, kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45059 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932411Ab1C2AAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 20:00:44 -0400
In-Reply-To: <20110328.165149.193711805.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC7A8FEE09A25B9E179B63003
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 03/29/2011 01:51 AM, David Miller wrote:
> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Tue, 29 Mar 2011 01:18:48 +0200
>=20
>> root@ptx:~ ping 130.75.1.32
>> PING 130.75.1.32 (130.75[   10.160000] Unable to handle kernel paging =
request at virtual address ffffffdb
>=20
> Well, that was easy enough :-)

=2E.just finished bisecting :)

FWIW:

b23dd4fe42b455af5c6e20966b7d6959fa8352ea is the first bad commit
commit b23dd4fe42b455af5c6e20966b7d6959fa8352ea
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Mar 2 14:31:35 2011 -0800

    ipv4: Make output route lookup return rtable directly.

    Instead of on the stack.

    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 a30b2e32bbbbed71fe97ba44b8e0ac4d8691232b 589f843359ccb53c7=
800e594ea5efa074413f22e M      drivers
:040000 040000 001c629e354ff875e8f2d3d7e4df2506f3396448 a55b417b1c10c3f23=
fafdf9fa5c6ab3c132d5223 M      include
:040000 040000 1a0100ddadb50d9e61b66d1f18f47f25a4866856 4e89411fcefcfb87f=
8973910a97b4776d7a3f7f1 M      net

>=20
> --------------------
> ipv4: Don't ip_rt_put() an error pointer in RAW sockets.
>=20
> Reported-by: Marc Kleine-Budde <mkl@pengutronix.de>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/raw.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
> index e837ffd..2d3c72e 100644
> --- a/net/ipv4/raw.c
> +++ b/net/ipv4/raw.c
> @@ -569,6 +569,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct s=
ock *sk, struct msghdr *msg,
>  		rt =3D ip_route_output_flow(sock_net(sk), &fl4, sk);
>  		if (IS_ERR(rt)) {
>  			err =3D PTR_ERR(rt);
> +			rt =3D NULL;

IIRC I saw another commit which looks the same, in a different file
though. Any chance there are more rt =3D NULL missing?
>  			goto done;
>  		}
>  	}

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigC7A8FEE09A25B9E179B63003
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2RIScACgkQjTAFq1RaXHOKLQCfd1I1R3rby6h70pCOcjLDMpMG
h3YAnA1CO6Tz+s1AjP2ak/GLMGFdaDkJ
=1qYd
-----END PGP SIGNATURE-----

--------------enigC7A8FEE09A25B9E179B63003--
