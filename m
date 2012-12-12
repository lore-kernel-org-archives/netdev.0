From: "voncken" <cedric.voncken@acksys.fr>
Subject: RE: Gianfar driver issue
Date: Wed, 12 Dec 2012 09:46:57 +0100
Message-ID: <029701cdd845$3ed5e280$bc81a780$@acksys.fr>
References: <773DB8A82AB6A046AE0195C68612A31901412124@sbs2003.acksys.local> <50C744CE.7040109@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "'Claudiu Manoil'" <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp07.msg.oleane.net ([62.161.4.7]:52194 "EHLO
	smtp07.msg.oleane.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927Ab2LLIrB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 03:47:01 -0500
In-Reply-To: <50C744CE.7040109@freescale.com>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Thanks claudiu,=20

	I will reformat my patch and resend it.

	Regards.

Cedric Voncken=20

-----Message d'origine-----
De=A0: Claudiu Manoil [mailto:claudiu.manoil@freescale.com]=20
Envoy=E9=A0: mardi 11 d=E9cembre 2012 15:36
=C0=A0: Cedric VONCKEN
Cc=A0: netdev@vger.kernel.org
Objet=A0: Re: Gianfar driver issue

On 12/11/2012 11:59 AM, Cedric VONCKEN wrote:
> 	Hi all,
>
> 	I think he have an issue in Gianfar driver.
>
> 	When the Netdev tx queue timeout occurred, the function
> gfar_timeout(..) is called. This function calls indirectly the
> gfar_init_mac(..) function.
>
> 	In this function, the rctrl register is set to a default value.
>
> 	If the Promiscuous is enable on the net dev ( flag IFF_PROMISC is=20
> set), the gfar_init_function does not reactivate it.
>
> 	The Promiscuous mode is used for example when the netdev is bridged.
> =09
> 	I apply this patch to fix it.
>
> 	--- a/drivers/net/ethernet/freescale/gianfar.c.	2012-06-01
> 09:16:13.000000000 +0200
> 	+++ b/drivers/net/ethernet/freescale/gianfar.c	2012-12-11
> 10:38:23.000000000 +0100
> 	@@ -356,6 +356,11 @@
>   	/* Configure the coalescing support */
>   	gfar_configure_coalescing(priv, 0xFF, 0xFF);
>
> +	if (ndev->flags & IFF_PROMISC) {
> +		/* Set RCTRL to PROM */
> +		rctrl |=3D RCTRL_PROM;
> +	}
> +
>   	if (priv->rx_filer_enable) {
>   		rctrl |=3D RCTRL_FILREN;
>   		/* Program the RIR0 reg with the required distribution */

Hello,

I don't see any issue with this code change, and there are other driver=
s too
reconfiguring the promiscuous mode upon tx timeout.
A valid (formatted) patch needs to be sent however.

Thanks,
Claudiu
