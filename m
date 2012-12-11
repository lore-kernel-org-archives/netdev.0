From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: Gianfar driver issue
Date: Tue, 11 Dec 2012 16:35:58 +0200
Message-ID: <50C744CE.7040109@freescale.com>
References: <773DB8A82AB6A046AE0195C68612A31901412124@sbs2003.acksys.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Cedric VONCKEN <cedric.voncken@acksys.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:26024
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753043Ab2LKOgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 09:36:10 -0500
In-Reply-To: <773DB8A82AB6A046AE0195C68612A31901412124@sbs2003.acksys.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
> 	If the Promiscuous is enable on the net dev ( flag IFF_PROMISC
> is set), the gfar_init_function does not reactivate it.
>
> 	The Promiscuous mode is used for example when the netdev is
> bridged.
> 	
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
> +		rctrl |= RCTRL_PROM;
> +	}
> +
>   	if (priv->rx_filer_enable) {
>   		rctrl |= RCTRL_FILREN;
>   		/* Program the RIR0 reg with the required distribution
> */

Hello,

I don't see any issue with this code change, and there are other drivers 
too reconfiguring the promiscuous mode upon tx timeout.
A valid (formatted) patch needs to be sent however.

Thanks,
Claudiu
