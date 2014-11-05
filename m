From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V2 2/4] can: m_can: workaround for transmit data less
 than 4 bytes
Date: Wed, 05 Nov 2014 11:17:48 +0100
Message-ID: <5459F94C.1030506@pengutronix.de>
References: <1415174326-6623-1-git-send-email-b29396@freescale.com> <1415174326-6623-2-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="e0LjrM5Dx3cFj3uw6fqiW2j5xb6IrhK6B"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415174326-6623-2-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--e0LjrM5Dx3cFj3uw6fqiW2j5xb6IrhK6B
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/05/2014 08:58 AM, Dong Aisheng wrote:
> At least on the i.MX6SX with M_CAN IP version 3.0.x, an issue with

Can you add the imx mask revision, too and the exact m_can version (is
available).

> the Message RAM was discovered. Sending CAN frames with dlc less
> than 4 bytes will lead to bit errors, when the first 8 bytes of
> the Message RAM have not been initialized (i.e. written to).
> To work around this issue, the first 8 bytes are initialized in open()
> function.
>=20
> Without the workaround, we can easily see the following errors:
> root@imx6qdlsolo:~# ip link set can0 up type can bitrate 1000000
> [   66.882520] IPv6: ADDRCONF(NETDEV_CHANGE): can0: link becomes ready
> root@imx6qdlsolo:~# cansend can0 123#112233
> [   66.935640] m_can 20e8000.can can0: Bit Error Uncorrected
>=20
> Signed-off-by: Dong Aisheng <b29396@freescale.com>
> ---
> ChangeLog since v1:
>  * initialize the first 8 bytes of Tx Buffer of Message RAM in open()
>    to workaround the issue
> ---
>  drivers/net/can/m_can/m_can.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>=20
> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_ca=
n.c
> index 664fe30..f47c200 100644
> --- a/drivers/net/can/m_can/m_can.c
> +++ b/drivers/net/can/m_can/m_can.c
> @@ -902,6 +902,15 @@ static void m_can_chip_config(struct net_device *d=
ev)
>  	/* set bittiming params */
>  	m_can_set_bittiming(dev);
> =20
> +	/* At least on the i.MX6SX with M_CAN IP version 3.0.x, an issue with=

> +	 * the Message RAM was discovered. Sending CAN frames with dlc less
> +	 * than 4 bytes will lead to bit errors, when the first 8 bytes of
> +	 * the Message RAM have not been initialized (i.e. written to).
> +	 * To work around this issue, the first 8 bytes are initialized here.=

> +	 */
> +	m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), 0x0);
> +	m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), 0x0);
> +
>  	m_can_config_endisable(priv, false);
>  }
> =20
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--e0LjrM5Dx3cFj3uw6fqiW2j5xb6IrhK6B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUWflMAAoJECte4hHFiupUKlYQAJQ3rjPY+6SLHlRtDr3hetHd
WT0AQpcmSs0HGCxQXe5i7TlN2dR+tyiC6r8TSVDBzUwETV77fwufWzQTp2b8fy3L
KJiEHxVnQGaU5g3m+EAZO3rJHndvWeruW9Zpmzoy/FSvPlGpQO3uiTPj/hhtI2T0
DXBUdtgDf4pIbaPjOLQE7Gdd1DNdcyFZwZ2XZb6nUqusliBCwbO87Aat92WjbELX
+H0ukQggjVF5rddsKPWVNEl4H0CsdjkZHjDL21C1D++RYAZMOv9rmYiWNoDmZPel
d6RnnB72nEq4T0OIldmAvZnQa5Fkdvc9Nns2IQ/3wU8zBjKslLm8UgZG8eR11Xpw
q0fxn2o+/vOK7mpN0RhnXHffRacEQKpVBkPQP5+kvpsvT6LHgXBG9FqYIi4Xsa8h
tDIl7npJ8D6N35fJ32ekxYpTULaOKS58siRwkcB+5iG4FF8zYLIK4LFF/9B7reLU
Ih7POTLeKzIr+G4kQvNgLeSJEHj77xsJAi4dZKo1f4HBcDnjn6YIjgFcIIt0QqoL
ANTHT/Rv3yiUQowzOi3R3RqptT9ydelXNCD/6iN+lGI1YN8XrXrKQE+/uTbnlA07
K1ZyYEMwRqhGKyWINYdm0jFPLra1mnE9aMnK6bximLbi4wQrS5DSc7oZETfjR6wB
E6mcUBSdQRYcPHK1USiY
=WITG
-----END PGP SIGNATURE-----

--e0LjrM5Dx3cFj3uw6fqiW2j5xb6IrhK6B--
