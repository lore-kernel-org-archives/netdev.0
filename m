From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: Fix bug in suspend/resume
Date: Thu, 13 Nov 2014 11:15:53 +0100
Message-ID: <546484D9.4030005@pengutronix.de>
References: <a44efc1fb0144cca9d0c4851cc51db25@BL2FFO11FD024.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="uqLsaDjP18VDNT8tK35mx9f0IL97xFwaK"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, grant.likely@linaro.org,
	robh+dt@kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <a44efc1fb0144cca9d0c4851cc51db25@BL2FFO11FD024.protection.gbl>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--uqLsaDjP18VDNT8tK35mx9f0IL97xFwaK
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/13/2014 07:58 AM, Kedareswara rao Appana wrote:
> When accessing the priv structure use container_of instead of dev_get_d=
rvdata.

Why?

> Enable the clocks in the suspend before accessing the registers of the =
CAN.
>=20
> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> ---
>  drivers/net/can/xilinx_can.c |   20 ++++++++++++++++++--
>  1 files changed, 18 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.=
c
> index 5e8b560..63ef645 100644
> --- a/drivers/net/can/xilinx_can.c
> +++ b/drivers/net/can/xilinx_can.c
> @@ -972,15 +972,30 @@ static const struct net_device_ops xcan_netdev_op=
s =3D {
>   */
>  static int __maybe_unused xcan_suspend(struct device *dev)
>  {
> -	struct platform_device *pdev =3D dev_get_drvdata(dev);
> +	struct platform_device *pdev =3D container_of(dev,
> +			struct platform_device, dev);
>  	struct net_device *ndev =3D platform_get_drvdata(pdev);
>  	struct xcan_priv *priv =3D netdev_priv(ndev);
> +	int ret;
> =20
>  	if (netif_running(ndev)) {
>  		netif_stop_queue(ndev);
>  		netif_device_detach(ndev);
>  	}
> =20
> +	ret =3D clk_prepare_enable(priv->can_clk);
> +	if (ret) {
> +		dev_err(dev, "unable to enable device clock\n");
> +		return ret;
> +	}
> +
> +	ret =3D clk_prepare_enable(priv->bus_clk);
> +	if (ret) {
> +		dev_err(dev, "unable to enable bus clock\n");
> +		clk_disable_unprepare(priv->can_clk);
> +		return ret;
> +	}

Now you have clock imbalance. Per suspend/resume cycle the clocks are
enabled twice, but disabled only once.

> +
>  	priv->write_reg(priv, XCAN_MSR_OFFSET, XCAN_MSR_SLEEP_MASK);
>  	priv->can.state =3D CAN_STATE_SLEEPING;
> =20
> @@ -999,7 +1014,8 @@ static int __maybe_unused xcan_suspend(struct devi=
ce *dev)
>   */
>  static int __maybe_unused xcan_resume(struct device *dev)
>  {
> -	struct platform_device *pdev =3D dev_get_drvdata(dev);
> +	struct platform_device *pdev =3D container_of(dev,
> +			struct platform_device, dev);
>  	struct net_device *ndev =3D platform_get_drvdata(pdev);
>  	struct xcan_priv *priv =3D netdev_priv(ndev);
>  	int ret;
>=20

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--uqLsaDjP18VDNT8tK35mx9f0IL97xFwaK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZITZAAoJECte4hHFiupUgTYP/3DFIdl1XXBiCTcyHmjjDHvK
QLXY1+am7O77NzvuMbjLYwNUc20/JGhwaOLeqs72+dC98+vZwOUu3ImgXEVXfqkJ
w0ebpxJruM5OhiSYMkc8qHisbQl3GegMfp5kQuwWDJGNTZxU8Zt+tZepzCIx9Voe
5SmE9/eZSJlS9cYyH0gM9R5QYeo8ro2AR71NvcG1tdT53nYW3bPxGwVMK7wUXkPO
vfC+RFa+n16KdS/bVWOeZabmBaUzwOi3soX7PtqsKZibWhZdLyctUbUosT2mO8vC
ICFcJR/v+huZljKoWcUsrKKAnv28WWXEZic0sSzW8hoeM2A4UrzFsl2rvFGX5I4u
2I7rA3PqRYTG3CwUOFjh2T2FEMWQai8NyQUwnBqkDKH3hPKU34xsJ9OgTiGYmqVW
njHpI1HFulNl0VxoqmGD22B3nlvU9nZULKNYocH9uVLWEFiwQVfa7UHA8Lzeb63P
gKQVYIoRPnyBQcU46r2jUOj1Z/IW0xIdpMMytKyZMpmJF0POSuuuFFg/ycjeyV1O
UKYv4UUxt/vCsZHbzD2B1V40ufEYxVU1a0d9oHoNwHYo4J/Pzfu+9IR87AjF5DMH
Nk/Zmm6pW/z3/RKyBWBEE+NPha5wBpHFTMKAtyAgP2IZPx99r3YZgJqTnkpZ7iS6
4+Ub1xiF4LcZ1JhV9m85
=nlfw
-----END PGP SIGNATURE-----

--uqLsaDjP18VDNT8tK35mx9f0IL97xFwaK--
