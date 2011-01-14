From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] ARM: mxs: pass fec device name via platform data
Date: Fri, 14 Jan 2011 09:38:52 +0100
Message-ID: <20110114083852.GE24920@pengutronix.de>
References: <20110113150622.GV24920@pengutronix.de>
 <1294988000-20232-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, gerg@snapgear.com, baruch@tkos.co.il,
	eric@eukrea.com, bryan.wu@canonical.com, r64343@freescale.com,
	B32542@freescale.com, lw@karo-electronics.de,
	w.sang@pengutronix.de, s.hauer@pengutronix.de, jamie@jamieiles.com,
	jamie@shareable.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42264 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046Ab1ANIjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 03:39:07 -0500
Content-Disposition: inline
In-Reply-To: <1294988000-20232-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 14, 2011 at 02:53:20PM +0800, Shawn Guo wrote:
> Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
Acked-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

> ---
>  arch/arm/mach-mxs/devices/platform-fec.c        |   11 ++++++-----
>  arch/arm/mach-mxs/include/mach/devices-common.h |    1 +
>  2 files changed, 7 insertions(+), 5 deletions(-)
>=20
> diff --git a/arch/arm/mach-mxs/devices/platform-fec.c b/arch/arm/mach=
-mxs/devices/platform-fec.c
> index c42dff7..75eb26b 100644
> --- a/arch/arm/mach-mxs/devices/platform-fec.c
> +++ b/arch/arm/mach-mxs/devices/platform-fec.c
> @@ -10,20 +10,21 @@
>  #include <mach/mx28.h>
>  #include <mach/devices-common.h>
> =20
> -#define mxs_fec_data_entry_single(soc, _id)				\
> +#define mxs_fec_data_entry_single(soc, _devid, _id)			\
>  	{								\
> +		.devid =3D _devid,					\
>  		.id =3D _id,						\
>  		.iobase =3D soc ## _ENET_MAC ## _id ## _BASE_ADDR,	\
>  		.irq =3D soc ## _INT_ENET_MAC ## _id,			\
>  	}
> =20
> -#define mxs_fec_data_entry(soc, _id)					\
> -	[_id] =3D mxs_fec_data_entry_single(soc, _id)
> +#define mxs_fec_data_entry(soc, _devid, _id)				\
> +	[_id] =3D mxs_fec_data_entry_single(soc, _devid, _id)
> =20
>  #ifdef CONFIG_SOC_IMX28
>  const struct mxs_fec_data mx28_fec_data[] __initconst =3D {
>  #define mx28_fec_data_entry(_id)					\
> -	mxs_fec_data_entry(MX28, _id)
> +	mxs_fec_data_entry(MX28, "imx28-fec", _id)
>  	mx28_fec_data_entry(0),
>  	mx28_fec_data_entry(1),
>  };
> @@ -45,6 +46,6 @@ struct platform_device *__init mxs_add_fec(
>  		},
>  	};
> =20
> -	return mxs_add_platform_device("imx28-fec", data->id,
> +	return mxs_add_platform_device(data->devid, data->id,
>  			res, ARRAY_SIZE(res), pdata, sizeof(*pdata));
>  }
> diff --git a/arch/arm/mach-mxs/include/mach/devices-common.h b/arch/a=
rm/mach-mxs/include/mach/devices-common.h
> index 6c3d1a1..10fbcfd 100644
> --- a/arch/arm/mach-mxs/include/mach/devices-common.h
> +++ b/arch/arm/mach-mxs/include/mach/devices-common.h
> @@ -33,6 +33,7 @@ int __init mxs_add_duart(const struct amba_device *=
dev);
>  /* fec */
>  #include <linux/fec.h>
>  struct mxs_fec_data {
> +	const char *devid;
>  	int id;
>  	resource_size_t iobase;
>  	resource_size_t iosize;
> --=20
> 1.7.1
>=20
>=20
>=20
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>=20

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
