From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3 1/3] can: sja1000: of: add per-compatible init hook
Date: Wed, 13 Jan 2016 12:21:14 +0100
Message-ID: <5696332A.7000806@pengutronix.de>
References: <1452637880-9922-1-git-send-email-damien.riegel@savoirfairelinux.com>
 <1452637880-9922-2-git-send-email-damien.riegel@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="cu1WxPemPHpn1d3XokeNNgEICuPQOV6P9"
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	kernel@savoirfairelinux.com
To: Damien Riegel <damien.riegel@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1452637880-9922-2-git-send-email-damien.riegel@savoirfairelinux.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--cu1WxPemPHpn1d3XokeNNgEICuPQOV6P9
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/12/2016 11:31 PM, Damien Riegel wrote:
> This commit adds the capability to allocate and init private data
> embedded in the sja1000_priv structure on a per-compatible basis. The
> device node is passed as a parameter of the init callback to allow
> parsing of custom device tree properties.
>=20
> Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
> ---
>  drivers/net/can/sja1000/sja1000_platform.c | 28 +++++++++++++++++++++-=
------
>  1 file changed, 21 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/c=
an/sja1000/sja1000_platform.c
> index 0552ed4..ea4e18b 100644
> --- a/drivers/net/can/sja1000/sja1000_platform.c
> +++ b/drivers/net/can/sja1000/sja1000_platform.c
> @@ -40,6 +40,11 @@ MODULE_DESCRIPTION("Socket-CAN driver for SJA1000 on=
 the platform bus");
>  MODULE_ALIAS("platform:" DRV_NAME);
>  MODULE_LICENSE("GPL v2");
> =20
> +struct sja1000_of_data {
> +	size_t  priv_sz;
> +	int     (*init)(struct sja1000_priv *priv, struct device_node *of);
> +};
> +
>  static u8 sp_read_reg8(const struct sja1000_priv *priv, int reg)
>  {
>  	return ioread8(priv->reg_base + reg);
> @@ -154,6 +159,12 @@ static void sp_populate_of(struct sja1000_priv *pr=
iv, struct device_node *of)
>  		priv->cdr |=3D CDR_CBP; /* default */
>  }
> =20
> +static const struct of_device_id sp_of_table[] =3D {
> +	{.compatible =3D "nxp,sja1000"},
> +	{},
> +};
> +MODULE_DEVICE_TABLE(of, sp_of_table);
> +
>  static int sp_probe(struct platform_device *pdev)
>  {
>  	int err, irq =3D 0;
> @@ -163,6 +174,9 @@ static int sp_probe(struct platform_device *pdev)
>  	struct resource *res_mem, *res_irq =3D NULL;
>  	struct sja1000_platform_data *pdata;
>  	struct device_node *of =3D pdev->dev.of_node;
> +	const struct of_device_id *id =3D of_match_node(sp_of_table, of);

Have you tested this with of =3D=3D NULL? I think it should work as
__of_find_property returns NULL if np is NULL.

> +	const struct sja1000_of_data *of_data =3D id ? id->data : NULL;=20
> +	size_t priv_sz =3D of_data ? of_data->priv_sz : 0;=20

I've move the code a bit around to get rid of the ? operator. I'll send
a new series.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--cu1WxPemPHpn1d3XokeNNgEICuPQOV6P9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWljMqAAoJEP5prqPJtc/HEZAH/3i6awwRyDUPx2om9kPDWzJq
yFz6jvMVEYJutFEW/QGunn/U/P8C7XLw76BL70C5pk0FiEN6LkFW6MEA/7n+w/Y4
oC5WiXi7JNmtj+qaw/rSVnt3Fb9UPFRmuljoByFYYP7+2zV6f60v95CNbfuv7kQC
44KMzzvC7GheO31+MYTleWN4o1rfv/kCqclrwVzQU1XQ+oSXEOSNocan2WWqcU5a
wc/uOZUBhMuAX3ZH4QyHkM/XBrUJI+z9+pUClyteeIw6dhVhQeFJUVpKsdaNtYj3
4XCNBWPjVX31H6eYVzLl6ldbi86dM62ZVcRwyR0dRM3e/QdpIO7W6+mRBX8oPTA=
=sKDN
-----END PGP SIGNATURE-----

--cu1WxPemPHpn1d3XokeNNgEICuPQOV6P9--
