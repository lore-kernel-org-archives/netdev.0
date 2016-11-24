From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [patch] fsl/fman: fix a leak in tgec_free()
Date: Thu, 24 Nov 2016 12:01:22 +0000
Message-ID: <AM4PR04MB1604B06C5FB986CCF241D411ECB60@AM4PR04MB1604.eurprd04.prod.outlook.com>
References: <20161124111931.GK17225@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0051.outbound.protection.outlook.com ([104.47.2.51]:62953
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933453AbcKXMRk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 07:17:40 -0500
In-Reply-To: <20161124111931.GK17225@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> Sent: Thursday, November 24, 2016 1:21 PM
> To: Madalin-Cristian Bucur <madalin.bucur@nxp.com>; Igal Liberman
> <igal.liberman@freescale.com>
> Cc: netdev@vger.kernel.org; kernel-janitors@vger.kernel.org
> Subject: [patch] fsl/fman: fix a leak in tgec_free()
>=20
> We set "tgec->cfg" to NULL before passing it to kfree().  There is no
> need to set it to NULL at all.  Let's just delete it.

Agree, thanks.

=20
> Fixes: 57ba4c9b56d8 ("fsl/fman: Add FMan MAC support")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> I haven't tested this.  It occurs to me that this code might be
> something to paper over a use after free bug by changing it to a leak
> instead.
>=20
> It applies to net-master.
>=20
> diff --git a/drivers/net/ethernet/freescale/fman/fman_tgec.c
> b/drivers/net/ethernet/freescale/fman/fman_tgec.c
> index efabb04..4b0f3a5 100644
> --- a/drivers/net/ethernet/freescale/fman/fman_tgec.c
> +++ b/drivers/net/ethernet/freescale/fman/fman_tgec.c
> @@ -722,9 +722,6 @@ int tgec_free(struct fman_mac *tgec)
>  {
>  	free_init_resources(tgec);
>=20
> -	if (tgec->cfg)
> -		tgec->cfg =3D NULL;
> -
>  	kfree(tgec->cfg);
>  	kfree(tgec);
>=20
