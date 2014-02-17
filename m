From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: xilinx CAN controller support.
Date: Mon, 17 Feb 2014 10:42:46 +0100
Message-ID: <5301D996.6040704@pengutronix.de>
References: <93c7272e-d8bf-43af-b39b-aaa0e0b70b6f@TX2EHSMHS036.ehs.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="SQw0GDVe2fpDd3PnHnxv7f5e917nkH2o3"
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <93c7272e-d8bf-43af-b39b-aaa0e0b70b6f@TX2EHSMHS036.ehs.local>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--SQw0GDVe2fpDd3PnHnxv7f5e917nkH2o3
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/17/2014 10:23 AM, Kedareswara rao Appana wrote:
> +/**
> + * xcan_get_berr_counter - error counter routine
> + * @ndev:	Pointer to net_device structure
> + * @bec:	Pointer to can_berr_counter structure
> + *
> + * This is the driver error counter routine.
> + * Return: 0 always
> + */
> +static int xcan_get_berr_counter(const struct net_device *ndev,
> +					struct can_berr_counter *bec)
> +{
> +	struct xcan_priv *priv =3D netdev_priv(ndev);
> +	int ret;
> +
> +	ret =3D clk_prepare_enable(priv->devclk);
> +	if (ret)
> +		goto err;
> +
> +	ret =3D clk_prepare_enable(priv->aperclk);
> +	if (ret)
> +		goto err_clk;
> +
> +	bec->txerr =3D priv->read_reg(priv, XCAN_ECR_OFFSET) & XCAN_ECR_TEC_M=
ASK;
> +	bec->rxerr =3D ((priv->read_reg(priv, XCAN_ECR_OFFSET) &
> +			XCAN_ECR_REC_MASK) >> XCAN_ESR_REC_SHIFT);

You have to disable the clock when leaving this function. Otherwise the
clocks will be unbalanced.

> +	return 0;
> +
> +err_clk:
> +	clk_disable_unprepare(priv->devclk);
> +err:
> +	return ret;
> +}

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--SQw0GDVe2fpDd3PnHnxv7f5e917nkH2o3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMB2ZYACgkQjTAFq1RaXHO7nwCglMLlduskfM/vsZwt+24Hwg0Q
etkAmwQTAlnddknr1sRKfFVhAefKIfg9
=ZTwN
-----END PGP SIGNATURE-----

--SQw0GDVe2fpDd3PnHnxv7f5e917nkH2o3--
