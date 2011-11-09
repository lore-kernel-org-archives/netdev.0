From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH] net: fsl_pq_mdio: fix oops when using uninitialized mutex
Date: Wed, 9 Nov 2011 14:10:49 -0600
Message-ID: <CAKWjMd5WCx8pSJiL5U_WkD6XA5dSZLgLZkvMA6sjAKNuAz7PKg@mail.gmail.com>
References: <59b050a97a9b5382918b66f2850a80c86e52f409.1320736936.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Andy Fleming <afleming@freescale.com>
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:34776 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab1KIUKt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 15:10:49 -0500
Received: by ggnb2 with SMTP id b2so2110598ggn.19
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 12:10:49 -0800 (PST)
In-Reply-To: <59b050a97a9b5382918b66f2850a80c86e52f409.1320736936.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Fix this by moving the of_mdiobus_register() call earlier.
>
> Cc: Andy Fleming <afleming@freescale.com>
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> ---
> =A0drivers/net/ethernet/freescale/fsl_pq_mdio.c | =A0 14 +++++++-----=
--
> =A01 files changed, 7 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/n=
et/ethernet/freescale/fsl_pq_mdio.c
> index 52f4e8a..e17fd2f 100644
> --- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
> +++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
> @@ -385,6 +385,13 @@ static int fsl_pq_mdio_probe(struct platform_dev=
ice *ofdev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tbiaddr =3D *prop;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 err =3D of_mdiobus_register(new_bus, np);
> + =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk (KERN_ERR "%s: Cannot register a=
s MDIO bus\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_bus=
->name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_free_irqs;
> + =A0 =A0 =A0 }
> +


This fix totally breaks the point of setting tbipa beforehand.
mdiobus_register will cause the bus to be scanned, and if any of the
PHYs are at the default address for tbipa, they won't be found. I have
a different fix which I will (re)submit today.


> =A0 =A0 =A0 =A0if (tbiaddr =3D=3D -1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0out_be32(tbipa, 0);


Andy
