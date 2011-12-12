From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: flexcan: fix irq flooding by clearing all interrupt
 sources
Date: Mon, 12 Dec 2011 16:31:09 +0100
Message-ID: <4EE61E3D.2090303@pengutronix.de>
References: <4EE61928.10608@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE0EEA662F0C4CC718B2F1371"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Reuben Dowle <Reuben.Dowle@navico.com>,
	=?ISO-8859-1?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4EE61928.10608@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE0EEA662F0C4CC718B2F1371
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/12/2011 04:09 PM, Wolfgang Grandegger wrote:
> As pointed out by Reuben Dowle and Lothar Wa=DFmann, the TWRN_INT,
> RWRN_INT, BOFF_INT interrupt sources need to be cleared as well
> to avoid interrupt flooding, at least for the Flexcan on i.MX28
> SOCs. Furthermore, the interrupts are only cleared, if really one
> of those interrupt sources are pending (which is not the case for
> rx and tx done).
>=20
> CC: Reuben Dowle <Reuben.Dowle@navico.com>
> CC: Lothar Wa=DFmann <LW@KARO-electronics.de>
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

Have you tested on mx25/mx35, does it have any negative side effects?
My schedule is full until Friday, sorry cannot test here.

Marc

> ---
>  drivers/net/can/flexcan.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> index 165a4c7..111f154 100644
> --- a/drivers/net/can/flexcan.c
> +++ b/drivers/net/can/flexcan.c
> @@ -118,6 +118,9 @@
>  	(FLEXCAN_ESR_TWRN_INT | FLEXCAN_ESR_RWRN_INT | FLEXCAN_ESR_BOFF_INT)
>  #define FLEXCAN_ESR_ERR_ALL \
>  	(FLEXCAN_ESR_ERR_BUS | FLEXCAN_ESR_ERR_STATE)
> +#define FLEXCAN_ESR_ALL_INT \
> +	(FLEXCAN_ESR_TWRN_INT | FLEXCAN_ESR_RWRN_INT | \
> +	 FLEXCAN_ESR_BOFF_INT | FLEXCAN_ESR_ERR_INT)
> =20
>  /* FLEXCAN interrupt flag register (IFLAG) bits */
>  #define FLEXCAN_TX_BUF_ID		8
> @@ -577,7 +580,9 @@ static irqreturn_t flexcan_irq(int irq, void *dev_i=
d)
> =20
>  	reg_iflag1 =3D flexcan_read(&regs->iflag1);
>  	reg_esr =3D flexcan_read(&regs->esr);
> -	flexcan_write(FLEXCAN_ESR_ERR_INT, &regs->esr);	/* ACK err IRQ */
> +	/* ACK all bus error and state change IRQ sources */
> +	if (reg_esr & FLEXCAN_ESR_ALL_INT)
> +		flexcan_write(reg_esr & FLEXCAN_ESR_ALL_INT, &regs->esr);
> =20
>  	/*
>  	 * schedule NAPI in case of:


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigE0EEA662F0C4CC718B2F1371
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk7mHkIACgkQjTAFq1RaXHN3YQCeIKLHit+MXDOrZU7J0hZIN6ha
ANkAoJk8FkJEFliJEJ2yf2QN++PXM2uW
=UBQ9
-----END PGP SIGNATURE-----

--------------enigE0EEA662F0C4CC718B2F1371--
