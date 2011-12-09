From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] flexcan: Acknowledge all interrupt sources in the IRQ
 handler
Date: Fri, 09 Dec 2011 14:52:46 +0100
Message-ID: <4EE212AE.40005@pengutronix.de>
References: <1323438454-6816-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC0D3D5080627EE142F18E624"
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?B?TG90aGFyIFdhw59tYW5u?= <LW@KARO-electronics.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1323438454-6816-1-git-send-email-LW@KARO-electronics.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC0D3D5080627EE142F18E624
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/09/2011 02:47 PM, Lothar Wa=C3=9Fmann wrote:
> Otherwise the handler will get stuck in an endless IRQ loop when an
> interrupt condition occurs that is not being acked (e.g. TWRN)

On which CPU do you have this problem?

Seems that mx25/35 behave a bit different than mx28. But I had no time
to dig into this, yet. BTW Wolfgang is just reworking error handling,
can you please test his patches he recently posted on linux-can.

cheers, Marc


> Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> ---
>  drivers/net/can/flexcan.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> index e023379..ea8f04d 100644
> --- a/drivers/net/can/flexcan.c
> +++ b/drivers/net/can/flexcan.c
> @@ -577,7 +577,7 @@ static irqreturn_t flexcan_irq(int irq, void *dev_i=
d)
> =20
>  	reg_iflag1 =3D flexcan_read(&regs->iflag1);
>  	reg_esr =3D flexcan_read(&regs->esr);
> -	flexcan_write(FLEXCAN_ESR_ERR_INT, &regs->esr);	/* ACK err IRQ */
> +	flexcan_write(reg_esr, &regs->esr);	/* ACK all IRQs */
> =20
>  	/*
>  	 * schedule NAPI in case of:


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigC0D3D5080627EE142F18E624
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk7iErEACgkQjTAFq1RaXHM7lQCgi0ZYI8AzXbzM6UoZpixJilCW
3iwAn33/ewcUA1G74Ug8gpLrku3uiNBE
=OMmq
-----END PGP SIGNATURE-----

--------------enigC0D3D5080627EE142F18E624--
