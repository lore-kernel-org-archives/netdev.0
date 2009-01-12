From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: Remove redundant NAPI functions
Date: Mon, 12 Jan 2009 07:13:17 +0000
Message-ID: <20090112071317.GA4212@ff.dom.local>
References: <1231446610.3893.17.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>, shemminger@vyatta.com,
	netdev@vger.kernel.org,
	Krzysztof =?iso-8859-2?Q?Ha=B3asa?= <khc@pm.waw.pl>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:49451 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbZALHNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 02:13:25 -0500
Received: by ewy10 with SMTP id 10so11341729ewy.13
        for <netdev@vger.kernel.org>; Sun, 11 Jan 2009 23:13:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1231446610.3893.17.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2009 at 08:30:10PM +0000, Ben Hutchings wrote:
> Following the removal of the unused struct net_device * parameter from
> the NAPI functions named *netif_rx_* in commit 908a7a1, they are
> exactly equivalent to the corresponding *napi_* functions and are
> therefore redundant.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
...

Alas I wasn't able to send this earlier, but here is some issue
(I see Krzysztof tried to patch this too):

> diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
> index 2dc2416..9ea167b 100644
> --- a/drivers/net/wan/ixp4xx_hss.c
> +++ b/drivers/net/wan/ixp4xx_hss.c
> @@ -622,7 +622,7 @@ static void hss_hdlc_rx_irq(void *pdev)
>  	printk(KERN_DEBUG "%s: hss_hdlc_rx_irq\n", dev->name);
>  #endif
>  	qmgr_disable_irq(queue_ids[port->id].rx);
> -	netif_rx_schedule(dev, &port->napi);
> +	napi_schedule(dev, &port->napi);
>  }
>  
>  static int hss_hdlc_poll(struct napi_struct *napi, int budget)
> @@ -649,15 +649,15 @@ static int hss_hdlc_poll(struct napi_struct *napi, int budget)
>  		if ((n = queue_get_desc(rxq, port, 0)) < 0) {
>  #if DEBUG_RX
>  			printk(KERN_DEBUG "%s: hss_hdlc_poll"
> -			       " netif_rx_complete\n", dev->name);
> +			       " napi_complete\n", dev->name);
>  #endif
> -			netif_rx_complete(dev, napi);
> +			napi_complete(dev, napi);
>  			qmgr_enable_irq(rxq);
>  			if (!qmgr_stat_empty(rxq) &&
> -			    netif_rx_reschedule(napi)) {
> +			    napi_reschedule(napi)) {
>  #if DEBUG_RX
>  				printk(KERN_DEBUG "%s: hss_hdlc_poll"
> -				       " netif_rx_reschedule succeeded\n",
> +				       " napi_reschedule succeeded\n",
>  				       dev->name);
>  #endif
>  				qmgr_disable_irq(rxq);
> @@ -1069,7 +1069,7 @@ static int hss_hdlc_open(struct net_device *dev)
>  	hss_start_hdlc(port);
>  
>  	/* we may already have RX data, enables IRQ */
> -	netif_rx_schedule(dev, &port->napi);
> +	napi_schedule(dev, &port->napi);
>  	return 0;
>  
>  err_unlock:
...

Plus a missing chunk for: drivers/staging/benet/be_int.c.

Jarek P.
