From: Sven Schuster <schuster.sven@gmx.de>
Subject: Re: [patch] tg3 ring buffer allocation error handling
Date: Wed, 14 Apr 2004 22:59:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040414205959.GA22051@zion.homelinux.com>
References: <20040414184642.GZ1175@waste.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PNTmBPCT7hxwcZjr"
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
Content-Disposition: inline
In-Reply-To: <20040414184642.GZ1175@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 14, 2004 at 01:46:42PM -0500, Matt Mackall told us:
>  	if (tp->tg3_flags & TG3_FLAG_JUMBO_ENABLE) {
>  		for (i =3D 0; i < tp->rx_jumbo_pending; i++) {
>  			if (tg3_alloc_rx_skb(tp, RXD_OPAQUE_RING_JUMBO,
> -					     -1, i) < 0)
> -				break;
> +					     -1, i) < 0) {
> +				printk("tg3_alloc_rx_skb %d failed\n", i);
> +				return -ENOMEM;

Please correct me if I'm wrong, but shouldn't the buffers from the=20
irst allocation (RXD_OPAQUE_RING_STD) be freed (maybe via=20
tg3_free_rings??) when we get an error here??


Sven

> +			}
>  		}
>  	}
> +
> +	return 0;
>  }
> =20

--=20
Linux zion 2.6.5 #1 Sun Apr 4 19:56:55 CEST 2004 i686 athlon i386 GNU/Linux
 22:53:42  up 9 days, 23:37,  2 users,  load average: 0.00, 0.00, 0.00

--PNTmBPCT7hxwcZjr
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD4DBQFAfaZPo4FAdB2PneQRAg/vAJY271NoGQ+BQIq4LQaoLttZkXoHAJ4o+CkG
N2Ni5uzqICLb1U9OZPmMEg==
=i0cp
-----END PGP SIGNATURE-----

--PNTmBPCT7hxwcZjr--
