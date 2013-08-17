From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH RESEND] can: mcp251x: Replace power callbacks with regulator
 API
Date: Sat, 17 Aug 2013 21:59:10 +0200
Message-ID: <520FD60E.4040709@pengutronix.de>
References: <1375963227-6468-1-git-send-email-shc_work@mail.ru> <52049C44.6030902@pengutronix.de> <520EDDA8.6050309@gmail.com> <20130817083014.a01144051b158c34ec7dd9d9@mail.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="iJRqkJtL8jged6X3GQQRLl8lAT9mFrD4x"
Cc: Haojian Zhuang <haojian.zhuang@gmail.com>,
	Eric Miao <eric.y.miao@gmail.com>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>,
	Russell King <linux@arm.linux.org.uk>,
	linux-arm-kernel@lists.infradead.org
To: Alexander Shiyan <shc_work@mail.ru>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20130817083014.a01144051b158c34ec7dd9d9@mail.ru>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--iJRqkJtL8jged6X3GQQRLl8lAT9mFrD4x
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 08/17/2013 06:30 AM, Alexander Shiyan wrote:
[...]
>> Since DT conversion isn't finished, I still accept the board files.
>> But this patch should be split into two parts. One is for pxa, and the=

>> other one is for net.
>=20
> Patch cannot be splitted because this can create hole which break git-b=
isect.
>=20
> In any case, I want to create a v2 with a more detailed description, an=
d I
> have a supplementary question for the CAN subsystem maintainers.
> "Transciever power" is not used by any of the boards, can we remove it
> completely? This will greatly simplify driver.

Do you mean the former transceiver_enable() callback?

>  struct mcp251x_platform_data {
>  	unsigned long oscillator_frequency;
>  	unsigned long irq_flags;
> -	int (*board_specific_setup)(struct spi_device *spi);
> -	int (*transceiver_enable)(int enable);
> -	int (*power_enable) (int enable);
>  };

Having a switchable transceiver is a quite common thing. So I'd like
that you keep it. The flexcan driver was just converted from a callback
to a regulator too. It already has device tree bindings and I'd like to
use these bindings as a standard for new drivers. From flexcan's dt
bindings:

> - xceiver-supply: Regulator that powers the CAN transceiver

which translates into:

> priv->reg_xceiver =3D devm_regulator_get(&pdev->dev, "xceiver");

Can you please use "xceiver" instead of "transceiver", so that future DT
binding will fit the scheme.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--iJRqkJtL8jged6X3GQQRLl8lAT9mFrD4x
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIP1g4ACgkQjTAFq1RaXHM1LwCeN3aRjAvOPOjt80BuESpAQOpn
QXYAniHBYknFe4bDxet9jD6bLhe4yXxq
=fJbh
-----END PGP SIGNATURE-----

--iJRqkJtL8jged6X3GQQRLl8lAT9mFrD4x--
