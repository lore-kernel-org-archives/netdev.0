From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/4][upstream] powerpc/p1010: Rearrange header file for
 FlexCAN
Date: Mon, 08 Aug 2011 17:08:12 +0200
Message-ID: <4E3FFBDC.3090600@pengutronix.de>
References: <1312815586-25756-1-git-send-email-bhaskar.upadhaya@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE989F71E5D271E2C5FBEA10B"
Cc: netdev@vger.kernel.org, holt@sgi.com, wg@grandegger.com,
	davem@davemloft.net, linuxppc-release@linux.freescale.net,
	b22300@freescale.com, socketcan-core@lists.berlios.de
To: Bhaskar Upadhaya <bhaskar.upadhaya@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39965 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361Ab1HHPIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 11:08:18 -0400
In-Reply-To: <1312815586-25756-1-git-send-email-bhaskar.upadhaya@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE989F71E5D271E2C5FBEA10B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/08/2011 04:59 PM, Bhaskar Upadhaya wrote:
> - Rearrange header file so that it can be used by both of_ type
>   and platform_ type architecture.
> - Provide a common read and write interface for of_ type and platform_
>   type architecture for accessing h/w registers.
> Signed-off-by: Bhaskar Upadhaya <bhaskar.upadhaya@freescale.com>

NACK - please have a look at Robin's patches. They are in a much better
shape.

cheers, Marc
> ---
>  Based on http://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next=
-2.6.git
>  Branch master
>=20
>  include/linux/can/platform/flexcan.h |   65 ++++++++++++++++++++++++++=
++++++++
>  1 files changed, 65 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/can/platform/flexcan.h b/include/linux/can/p=
latform/flexcan.h
> index 72b713a..8458a87 100644
> --- a/include/linux/can/platform/flexcan.h
> +++ b/include/linux/can/platform/flexcan.h
> @@ -1,5 +1,6 @@
>  /*
>   * Copyright (C) 2010 Marc Kleine-Budde <kernel@pengutronix.de>
> + * Copyright 2011 Freescale Semiconductor, Inc.
>   *
>   * This file is released under the GPLv2
>   *
> @@ -8,6 +9,27 @@
>  #ifndef __CAN_PLATFORM_FLEXCAN_H
>  #define __CAN_PLATFORM_FLEXCAN_H
> =20
> +#include <linux/clk.h>
> +#include <linux/can/dev.h>
> +#include <linux/io.h>
> +
> +#ifdef CONFIG_OF
> +#include<linux/of_platform.h>
> +#else
> +#include <linux/platform_device.h>
> +#include <mach/clock.h>
> +#endif
> +
> +#define DRV_NAME "flexcan"
> +
> +#ifdef __BIG_ENDIAN
> +#define flexcan_read(x)	in_be32(x)
> +#define flexcan_write(x, y) out_be32(y, x)
> +#else
> +#define flexcan_read(x)	readl(x)
> +#define flexcan_write(x, y) writel(x, y)
> +#endif
> +
>  /**
>   * struct flexcan_platform_data - flex CAN controller platform data
>   * @transceiver_enable:         - called to power on/off the transceiv=
er
> @@ -17,4 +39,47 @@ struct flexcan_platform_data {
>  	void (*transceiver_switch)(int enable);
>  };
> =20
> +struct flexcan_interface {
> +	int (*clk_enable) (struct clk *clk);
> +	void (*clk_disable) (struct clk *clk);
> +	void (*clk_put) (struct clk *clk);
> +	unsigned long (*clk_get_rate) (struct clk *clk);
> +	struct clk *(*clk_get) (struct device *dev, const char *id);
> +};
> +
> +struct flexcan_resource {
> +	u32 irq;
> +	u64 addr;
> +	u64 size;
> +	const char *drv_name;
> +};
> +
> +#ifdef CONFIG_OF
> +struct clk {
> +	unsigned long		rate;
> +	void			*data;
> +};
> +#endif
> +
> +struct flexcan_priv {
> +	struct can_priv can;
> +	struct net_device *dev;
> +	struct napi_struct napi;
> +
> +	void __iomem *base;
> +	u32 reg_esr;
> +	u32 reg_ctrl_default;
> +
> +	struct clk *clk;
> +	struct flexcan_interface *flexcan_ops;
> +	struct flexcan_platform_data *pdata;
> +};
> +
> +int flexcan_dev_init(struct device *pdev, struct flexcan_resource
> +			flexcan_res, struct flexcan_interface *flexcan_ops);
> +
> +void __devexit unregister_flexcandev(struct net_device *dev);
> +
> +void flexcan_reg_dump(struct net_device *dev);
> +
>  #endif /* __CAN_PLATFORM_FLEXCAN_H */


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigE989F71E5D271E2C5FBEA10B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk4/+98ACgkQjTAFq1RaXHPERACcD7rljOm2lM6+iQMe0mwqj0cL
5ocAniCyzVjgeMRHGqED08fyZoJmgwMv
=TRCs
-----END PGP SIGNATURE-----

--------------enigE989F71E5D271E2C5FBEA10B--
