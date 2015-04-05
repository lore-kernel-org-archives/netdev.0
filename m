From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool 3/5] ethtool: Return bad status when send_ioctl
 fails
Date: Sun, 05 Apr 2015 02:48:56 +0100
Message-ID: <1428198536.11260.128.camel@decadent.org.uk>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
	 <1422193883-30504-4-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KQydM7yMZHttamnlLqHX"
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Eyal Grossman <eyalgr@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58703 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750762AbbDEBtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 21:49:13 -0400
In-Reply-To: <1422193883-30504-4-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KQydM7yMZHttamnlLqHX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-01-25 at 15:51 +0200, Amir Vadai wrote:
> From: Eyal Grossman <eyalgr@mellanox.com>
>=20
> Added to ethtool return code(rc !=3D 0) when an error occurs after send_i=
octl has fails.
>=20
> Signed-off-by: Eyal Grossman <eyalgr@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

I wish we could do this, but it's been returning 0 on failure for as
long as git history lasts (10 years) and I would expect this change to
break some scripts.

Maybe we could provide some way to opt-in to this behaviour?

[..]
> @@ -2654,17 +2661,20 @@ static int do_sset(struct cmd_context *ctx)
>  		err =3D send_ioctl(ctx, &edata);
>  		if (err < 0) {
>  			perror("Cannot get msglvl");
> +			status +=3D err;
>  		} else {
>  			edata.cmd =3D ETHTOOL_SMSGLVL;
>  			edata.data =3D ((edata.data & ~msglvl_mask) |
>  				      msglvl_wanted);
>  			err =3D send_ioctl(ctx, &edata);
> -			if (err < 0)
> +			if (err < 0) {
>  				perror("Cannot set new msglvl");
> +				status +=3D err;
> +			}
>  		}
>  	}
> =20
> -	return 0;
> +	return status;

This is going to be a negative number on error, which is not a valid
exit code.  We should generally return 1 on error.

Ben.

>  }
> =20
>  static int do_gregs(struct cmd_context *ctx)

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-KQydM7yMZHttamnlLqHX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVSCUkue/yOyVhhEJAQoxkg/9G3oLXWruylw8BejFgGkG4RoOZunk9DZZ
owQAkuHRcT2bQ85eC/L9aiYauhGj+uEMXTa+wtjrAzQKCqMYGm09pZnK7QhxhN79
Y1m2rQ2SEDSLWIXEtHgjTySBtUTG/BOJe34IzXyL4L3ZBNEiElysIIHjtwM8hGmd
GuBg3R92UbPi/jqoccWIBUjwf6gAuykmgvfqA/ppVAb0Iyt/sl8PVYaja9r6yn9A
YnuXkhxJCERndNwfNp4GmWSUydC/4wp90MX89S+EHjAMG5mw291gGAVYMW5OK8UJ
TZ3ndXtCyn/seUg4/DAa1yZp0FZAih9MhjwwSVhKf4zLAYk+colBdXxgKLCGE/3u
w+9sCvjWgTugWplv/KATF6FOatR0olZuowBROyOxuyAdrqPSOpAD/FB3vhROHfzr
urLfcYsUwjba1vXgnoiHUm+howgJ3eOo8uUo/R7hHYMjZ8C7xV+K1miCn/GldjQi
jNHb/NFY/iwt1Cqe138QG6z6TPrwzWhtFdfu0vFYqsSdktA4yMcdFRnT+ZV3CNJ8
H7AI8bE+AcByVmVpi0xLzYJoCYcwou1RclyAq+wsgBeYBw7PAPuZijXaYEJTQZLU
JX60Sum5nU8bndHUthHFjJD7pKK/UcYNxbVRXzGBKiCfHYykeVgt3AtQ1eWcj9ZD
Xqhg6ZoFEeQ=
=VfgA
-----END PGP SIGNATURE-----

--=-KQydM7yMZHttamnlLqHX--
