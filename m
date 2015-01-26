From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net: macb: allow deffered probe of the driver
Date: Mon, 26 Jan 2015 15:37:00 +0100
Message-ID: <54C6510C.8050002@atmel.com>
References: <1421947441.717.4.camel@uti.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Nicolae Rosia <nicolae.rosia@certsign.ro>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:1726 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754296AbbAZOhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 09:37:21 -0500
In-Reply-To: <1421947441.717.4.camel@uti.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/01/2015 18:31, Nicolae Rosia a =C3=A9crit :
> The driver is trying to acquire clocks which maybe
> are not available yet. Allow the driver to request
> deffered probe by providing a probe function and
> registering it with module_platform_driver. [1]
> This patch is based on 3.19-rc5.

Do you have a use case for this need?

> [1] https://lkml.org/lkml/2013/9/23/118
>=20
> Signed-off-by: Nicolae Rosia <nicolae.rosia@certsign.ro>

But anyway, it's not harmful:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  drivers/net/ethernet/cadence/macb.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c
> b/drivers/net/ethernet/cadence/macb.c
> index 3767271..4dfcd66 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2148,7 +2148,7 @@ static void macb_probe_queues(void __iomem *mem=
,
>  			(*num_queues)++;
>  }
> =20
> -static int __init macb_probe(struct platform_device *pdev)
> +static int macb_probe(struct platform_device *pdev)
>  {
>  	struct macb_platform_data *pdata;
>  	struct resource *regs;
> @@ -2386,7 +2386,7 @@ err_out:
>  	return err;
>  }
> =20
> -static int __exit macb_remove(struct platform_device *pdev)
> +static int macb_remove(struct platform_device *pdev)
>  {
>  	struct net_device *dev;
>  	struct macb *bp;
> @@ -2449,7 +2449,8 @@ static int macb_resume(struct device *dev)
>  static SIMPLE_DEV_PM_OPS(macb_pm_ops, macb_suspend, macb_resume);
> =20
>  static struct platform_driver macb_driver =3D {
> -	.remove		=3D __exit_p(macb_remove),
> +	.probe		=3D macb_probe,
> +	.remove		=3D macb_remove,
>  	.driver		=3D {
>  		.name		=3D "macb",
>  		.of_match_table	=3D of_match_ptr(macb_dt_ids),
> @@ -2457,7 +2458,7 @@ static struct platform_driver macb_driver =3D {
>  	},
>  };
> =20
> -module_platform_driver_probe(macb_driver, macb_probe);
> +module_platform_driver(macb_driver);
> =20
>  MODULE_LICENSE("GPL");
>  MODULE_DESCRIPTION("Cadence MACB/GEM Ethernet driver");
>=20


--=20
Nicolas Ferre
