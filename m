From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [patch]  Gianfar : Enable promiscous mode after queue time out
Date: Wed, 23 Jan 2013 11:58:54 +0200
Message-ID: <50FFB45E.6030201@freescale.com>
References: <773DB8A82AB6A046AE0195C68612A319014B7309@sbs2003.acksys.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Cedric VONCKEN <cedric.voncken@acksys.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [65.55.88.13] ([65.55.88.13]:38034 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754312Ab3AWKAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 05:00:23 -0500
In-Reply-To: <773DB8A82AB6A046AE0195C68612A319014B7309@sbs2003.acksys.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/21/2013 6:24 PM, Cedric VONCKEN wrote:
> 	Hi all,
>
> 	When the Netdev tx queue timeout occurred, the function
> gfar_timeout(..) is called. This function calls indirectly the
> gfar_init_mac(..) function.
>
>   	In this function, the rctrl register is set to a default value.
>
>   	If the Promiscuous is enable on the net dev ( flag IFF_PROMISC
> is  set), the gfar_init_function does not reactivate it.
>
>   	The Promiscuous mode is used for example when the netdev is
> bridged.
>   	
>   	I apply this patch on the kernel 3.8-rc4 to fix it.
>
> 	Signed-off-by : Voncken C Acksys <cedric.voncken@acksys.fr>
>
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -349,6 +349,11 @@ static void gfar_init_mac(struct net_dev
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
>
>
>
>
>

Hello Cedric,

I'll take care of this code change and I'll send a properly formatted 
patch for it.
Besides, gfar_init_mac() may be called for numerous other reasons than 
tx timeout, like changing MTU, changing ring params, restoring the 
interface etc. (any reset condition), so I'll rephrase the patch comment 
too.

Thanks,
Claudiu
