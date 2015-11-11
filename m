From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/1] can: sja1000: clear interrupts on start
Date: Wed, 11 Nov 2015 09:04:53 +0100
Message-ID: <5642F6A5.5070301@pengutronix.de>
References: <1447163974-24514-1-git-send-email-mirza.krak@hostmobility.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="ULHt5o2hAqNJOUKwPdN0E7TFP1g9p5H2F"
Cc: andri.yngvason@marel.com, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mirza Krak <mirza.krak@hostmobility.com>, wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1447163974-24514-1-git-send-email-mirza.krak@hostmobility.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ULHt5o2hAqNJOUKwPdN0E7TFP1g9p5H2F
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/10/2015 02:59 PM, Mirza Krak wrote:
> From: Mirza Krak <mirza.krak@hostmobility.com>
>=20
> According to SJA1000 data sheet error-warning (EI) interrupt is not
> cleared by setting the controller in to reset-mode.
>=20
> Then if we have the following case:
> - system is suspended (echo mem > /sys/power/state) and SJA1000 is left=

> in operating state

This problem occurs only an hardware, where the SJA1000 is powered
during system suspend?

> - A bus error condition occurs which activates EI interrupt, system is
> still suspended which means EI interrupt will be not be handled nor
> cleared.
>=20
> If the above two events occur, on resume there is no way to return the
> SJA1000 to operating state, except to cycle power to it.
>=20
> By simply reading the IR register on start we will clear any previous
> conditions that could be present.

Doesn't the SJA1000 trigger an interrupt that is detected after
resuming? You add the fix to the open() function, which is triggered
during $(ifconfig up), how is related to suspend/resume? Does the
network layer call $(ifconfig down) during shutdown?

There isn't any suspend/resume code in the sja1000 driver, for me it
seems that we should add resume code that handles this problem.

>=20
> Signed-off-by: Mirza Krak <mirza.krak@hostmobility.com>
> ---
>  drivers/net/can/sja1000/sja1000.c | 3 +++
>  1 file changed, 3 insertions(+)
>=20
> diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja100=
0/sja1000.c
> index 7b92e911a616..f10834be48a5 100644
> --- a/drivers/net/can/sja1000/sja1000.c
> +++ b/drivers/net/can/sja1000/sja1000.c
> @@ -218,6 +218,9 @@ static void sja1000_start(struct net_device *dev)
>  	priv->write_reg(priv, SJA1000_RXERR, 0x0);
>  	priv->read_reg(priv, SJA1000_ECC);
> =20
> +	/* clear interrupt flags */
> +	priv->read_reg(priv, SJA1000_IR);
> +
>  	/* leave reset mode */
>  	set_normal_mode(dev);
>  }
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--ULHt5o2hAqNJOUKwPdN0E7TFP1g9p5H2F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWQvamAAoJEP5prqPJtc/HnmwH/2KKU0NdmoAaGYN4EEgfXPd7
UXQzPVijRO0tYhJ6Yt8j21Zi9kQ+GE2dTw3ax1clLAkJ9R/HjwqZwKSb0/wKk5n5
a7oGDKJkzhRiVCwPf7/LbNakW8XLC6yrrKIn4Svy4+Dj1Ufv02/8wBVHHXPKQ2Zt
1guWmREojZJte6TPR5b7Xw+DzjCkEAjuOwgVPDzpMH8I2BEvcELQrjwipycwUUMI
KEWUXvt5GZFGyIYyFegRYrOtNW7ZsCa0xADhiirFKib13PaAllKqGrGC7OcMvso9
cz7J9olfSE16sC8vBHwiZW/vEm5J7px1uywAmwquMICWGrc6GGDQ10aZl+cSStk=
=vUt4
-----END PGP SIGNATURE-----

--ULHt5o2hAqNJOUKwPdN0E7TFP1g9p5H2F--
