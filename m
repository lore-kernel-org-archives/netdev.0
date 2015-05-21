From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH] net: macb: Disable half duplex gigabit on Zynq
Date: Thu, 21 May 2015 14:57:00 -0700
Message-ID: <20150521215700.GN18303@xsjsorenbubuntu>
References: <1432244845-29315-1-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nicolas.ferre@atmel.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Nathan Sullivan <nathan.sullivan@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1432244845-29315-1-git-send-email-nathan.sullivan@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-05-21 at 04:47PM -0500, Nathan Sullivan wrote:
> According to the Zynq TRM, gigabit half duplex is not supported.  Add=
 a
> new cap and compatible string so Zynq can avoid advertising that mode=
=2E
>=20
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
> ---
>  drivers/net/ethernet/cadence/macb.c |   12 ++++++++++++
>  drivers/net/ethernet/cadence/macb.h |    1 +
>  2 files changed, 13 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 61aa570..e7c0ef6 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -350,6 +350,9 @@ static int macb_mii_probe(struct net_device *dev)
>  	else
>  		phydev->supported &=3D PHY_BASIC_FEATURES;
> =20
> +	if (bp->caps & MACB_CAPS_NO_GIGABIT_HALF)
> +		phydev->supported &=3D ~SUPPORTED_1000baseT_Half;
> +
>  	phydev->advertising =3D phydev->supported;
> =20
>  	bp->link =3D 0;
> @@ -2693,6 +2696,14 @@ static const struct macb_config emac_config =3D=
 {
>  	.init =3D at91ether_init,
>  };
> =20
> +static const struct macb_config zynq_config =3D {
> +	.caps =3D MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE =
|
> +		MACB_CAPS_NO_GIGABIT_HALF,
> +	.dma_burst_length =3D 16,
> +	.clk_init =3D macb_clk_init,
> +	.init =3D macb_init,
> +};
> +
>  static const struct of_device_id macb_dt_ids[] =3D {
>  	{ .compatible =3D "cdns,at32ap7000-macb" },
>  	{ .compatible =3D "cdns,at91sam9260-macb", .data =3D &at91sam9260_c=
onfig },
> @@ -2703,6 +2714,7 @@ static const struct of_device_id macb_dt_ids[] =
=3D {
>  	{ .compatible =3D "atmel,sama5d4-gem", .data =3D &sama5d4_config },
>  	{ .compatible =3D "cdns,at91rm9200-emac", .data =3D &emac_config },
>  	{ .compatible =3D "cdns,emac", .data =3D &emac_config },
> +	{ .compatible =3D "cdns,zynq-gem", .data =3D &zynq_config },

I wanted to add something like that already to sort out the clocks in a
better way, but never got to it. So, ACK at least for this part, but it
needs to be documented in the binding documentation.

	S=C3=B6ren
