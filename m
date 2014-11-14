From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 3/8] net: can: c_can: Add RAMINIT register information
 to driver data
Date: Fri, 14 Nov 2014 18:55:30 +0100
Message-ID: <54664212.8080206@pengutronix.de>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-4-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="ub8ulLvilUfPbnqmGk77AvWG8K6NX3WWp"
Cc: wsa@the-dreams.de, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1415371762-29885-4-git-send-email-rogerq@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ub8ulLvilUfPbnqmGk77AvWG8K6NX3WWp
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/07/2014 03:49 PM, Roger Quadros wrote:
> Some platforms (e.g. TI) need special RAMINIT register handling.
> Provide a way to store RAMINIT register description in driver data.
>=20
> Signed-off-by: Roger Quadros <rogerq@ti.com>
> ---
>  drivers/net/can/c_can/c_can.h          | 6 ++++++
>  drivers/net/can/c_can/c_can_platform.c | 1 +
>  2 files changed, 7 insertions(+)
>=20
> diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_ca=
n.h
> index 26c975d..3c305a1 100644
> --- a/drivers/net/can/c_can/c_can.h
> +++ b/drivers/net/can/c_can/c_can.h
> @@ -171,6 +171,12 @@ enum c_can_dev_id {
> =20
>  struct c_can_driver_data {
>  	enum c_can_dev_id id;
> +
> +	/* RAMINIT register description. Optional. */
> +	u8 num_can;		/* Number of CAN instances on the SoC */
> +	u8 *raminit_start_bits;	/* Array of START bit positions */
> +	u8 *raminit_done_bits;	/* Array of DONE bit positions */

What do you think about making this a struct:

+struct raminit_bits {
+       u8 start;
+       u8 done;
+};

 struct c_can_driver_data {
        enum c_can_dev_id id;
+
+       /* RAMINIT register description. Optional. */
+       const struct raminit_bits *raminit_bits; /* Array of START/DONE b=
it positions */
+       u8 raminit_num;         /* Number of CAN instances on the SoC */
+       bool raminit_pulse;     /* If set, sets and clears START bit (pul=
se) */
 };

The driver data looks like this:

+static const struct raminit_bits dra7_raminit_bits[] =3D {
+       [0] =3D { .start =3D 3, .done =3D 1, },
+       [1] =3D { .start =3D 5, .done =3D 2, },
+};
+
+static const struct c_can_driver_data dra7_dcan_drvdata =3D {
+       .id =3D BOSCH_D_CAN,
+       .raminit_num =3D ARRAY_SIZE(dra7_raminit_bits),
+       .raminit_bits =3D dra7_raminit_bits,
+       .raminit_pulse =3D true,
+};

I'll send an updated series.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--ub8ulLvilUfPbnqmGk77AvWG8K6NX3WWp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZkISAAoJECte4hHFiupUeZoQAJIc5VIEoRwFAkPnG9wdV5Pw
X2ccOjItaQzTfE07WuyLjNhparwtLKJ6IfU1VRpDAgoUbeqq3UZHoK/X/kPCBUiH
mFKAGrY6z8tPiXPJ7hEmQMuX/tREqWc7iV1LaMUATd6zhQZbmUyDZWluGuos+vsS
l23rxv7gVRMadw4AjXgxvAc5hwabxti0hFEGZtsHT6YZgLrT3bd4ahZBn1R4hgds
U9+owpMB52H7RgR7NpJ1lanOqGI99USZU+Jjn1Neloe3/RHZyXEvxDU6rVy6Cu64
2qTt9IXOgfZ02htATS4v4bGDSbG9K/ZBTs7elQlUWI5YooYxLEyOxud/hv0yOoHu
2ucGIzEgG0b7lnQ9fKbyTQ/jF7jKcHZV29kh7xNrJMvTwPc0MfbUIvIbXBYIwgd3
asnLbYTdfaFNORVuQVwGDbgHUuDLG5bxiXHMqtPw/3E8hqLUiqgpnYM6IKSAsd71
bl961PWfOTp1viwA39gfUT59n9SLAuPdLGf5CgrBpRa1hI6Lel8MVxcDFeLMJ9lm
tvXU/u3an3qq2UwexPGPF/yPJNMeFkbQ7xP5UiBm6jeNi+sh15z2QJdvyZPru9bI
xCcpfbhIzXx2FaaJk6ly6NdeDNaJW7CVx7b0XstOAlV/BMkltuemGKJV0T5arqij
OC3n5HflP25rvSvlqySw
=aVHL
-----END PGP SIGNATURE-----

--ub8ulLvilUfPbnqmGk77AvWG8K6NX3WWp--
