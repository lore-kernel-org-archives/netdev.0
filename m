From: =?utf-8?Q?Lothar_Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: Re: [PATCH v2 1/1 net-next] NET: FEC: dynamtic check DMA desc buff type
Date: Fri, 28 Dec 2012 15:45:32 +0100
Message-ID: <20701.45196.361432.80622@ipc1.ka-ro>
References: <1356676164-10910-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <lznuaa@gmail.com>, <davem@davemloft.net>,
	<s.hauer@pengutronix.de>, netdev@vger.kernel.org,
	shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:60604 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753689Ab2L1Op4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 09:45:56 -0500
In-Reply-To: <1356676164-10910-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rank Li writes:
> MX6 and mx28 support enhanced DMA descript buff to support 1588
> ptp. But MX25, MX3x, MX5x can't support enhanced DMA descript buff.
> Check fec type and choose correct DAM descript buff type.
                                    ^^^
s/DAM/DMA/
s/descript/descriptor/g

[...]
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ether=
net/freescale/fec.c
> index 0704bca..290f91c 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -76,6 +76,8 @@
>  #define FEC_QUIRK_USE_GASKET		(1 << 2)
>  /* Controller has GBIT support */
>  #define FEC_QUIRK_HAS_GBIT		(1 << 3)
> +/* Controller has extend desc buffer */
> +#define FEC_QUICK_HAS_BUFDESC_EX	(1 << 4)
               ^^^^^
As Sascha has already pointed out, this should be 'QUIRK' rather than
'QUICK' (like in the preceeding lines)!

>  static struct platform_device_id fec_devtype[] =3D {
>  	{
> @@ -93,7 +95,8 @@ static struct platform_device_id fec_devtype[] =3D =
{
>  		.driver_data =3D FEC_QUIRK_ENET_MAC | FEC_QUIRK_SWAP_FRAME,
>  	}, {
>  		.name =3D "imx6q-fec",
> -		.driver_data =3D FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT,
> +		.driver_data =3D FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
> +				FEC_QUICK_HAS_BUFDESC_EX,
                                    ^^^^^
same as above.

[...]
> @@ -1574,6 +1617,8 @@ fec_probe(struct platform_device *pdev)
>  	fep->pdev =3D pdev;
>  	fep->dev_id =3D dev_id++;
> =20
> +	fep->bufdesc_ex =3D 0;
> +
>  	if (!fep->hwp) {
>  		ret =3D -ENOMEM;
>  		goto failed_ioremap;
> @@ -1628,19 +1673,19 @@ fec_probe(struct platform_device *pdev)
>  		goto failed_clk;
>  	}
> =20
> -#ifdef CONFIG_FEC_PTP
>  	fep->clk_ptp =3D devm_clk_get(&pdev->dev, "ptp");
> +	fep->bufdesc_ex =3D
> +		pdev->id_entry->driver_data & FEC_QUICK_HAS_BUFDESC_EX;
                                                  ^^^^^
same as above.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
