From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v2 2/3] net: macb: Disable half duplex gigabit on Zynq
Date: Fri, 22 May 2015 16:56:28 +0200
Message-ID: <555F439C.1020703@atmel.com>
References: <1432304531-23682-1-git-send-email-nathan.sullivan@ni.com> <1432304531-23682-2-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Nathan Sullivan <nathan.sullivan@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432304531-23682-2-git-send-email-nathan.sullivan@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 22/05/2015 16:22, Nathan Sullivan a =E9crit :
> According to the Zynq TRM, gigabit half duplex is not supported.  Add=
 a
> new cap and compatible string so Zynq can avoid advertising that mode=
=2E
>=20
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

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
>  	{ /* sentinel */ }
>  };
>  MODULE_DEVICE_TABLE(of, macb_dt_ids);
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethern=
et/cadence/macb.h
> index eb7d76f..24b1d9b 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -393,6 +393,7 @@
>  #define MACB_CAPS_ISR_CLEAR_ON_WRITE		0x00000001
>  #define MACB_CAPS_USRIO_HAS_CLKEN		0x00000002
>  #define MACB_CAPS_USRIO_DEFAULT_IS_MII		0x00000004
> +#define MACB_CAPS_NO_GIGABIT_HALF		0x00000008
>  #define MACB_CAPS_FIFO_MODE			0x10000000
>  #define MACB_CAPS_GIGABIT_MODE_AVAILABLE	0x20000000
>  #define MACB_CAPS_SG_DISABLED			0x40000000
>=20


--=20
Nicolas Ferre
