From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 08/77] irda: convert irda_usb to net_device_ops
Date: Mon, 23 Mar 2009 12:34:03 +0100
Message-ID: <20090323113403.GE8199@sortiz.org>
References: <20090321053527.316395697@vyatta.com> <20090321053713.155535463@vyatta.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:45788 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753764AbZCWLbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:31:49 -0400
Content-Disposition: inline
In-Reply-To: <20090321053713.155535463@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 10:35:35PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> 
> ---
>  drivers/net/irda/irda-usb.c |   18 ++++++++++--------
>  1 file changed, 10 insertions(+), 8 deletions(-)
> 
> --- a/drivers/net/irda/irda-usb.c	2009-03-19 22:40:30.429651929 -0700
> +++ b/drivers/net/irda/irda-usb.c	2009-03-19 22:42:46.433089198 -0700
> @@ -1401,6 +1401,14 @@ static inline void irda_usb_init_qos(str
>  }
>  
>  /*------------------------------------------------------------------*/
> +static const struct net_device_ops irda_usb_netdev_ops = {
> +	.ndo_open       = irda_usb_net_open,
> +	.ndo_stop       = irda_usb_net_close,
> +	.ndo_do_ioctl   = irda_usb_net_ioctl,
> +	.ndo_start_xmit = irda_usb_hard_xmit,
> +	.ndo_tx_timeout	= irda_usb_net_timeout,
> +};
> +
>  /*
>   * Initialise the network side of the irda-usb instance
>   * Called when a new USB instance is registered in irda_usb_probe()
> @@ -1411,15 +1419,9 @@ static inline int irda_usb_open(struct i
>  
>  	IRDA_DEBUG(1, "%s()\n", __func__);
>  
> -	irda_usb_init_qos(self);
> +	netdev->netdev_ops = &irda_usb_netdev_ops;
>  
> -	/* Override the network functions we need to use */
> -	netdev->hard_start_xmit = irda_usb_hard_xmit;
> -	netdev->tx_timeout	= irda_usb_net_timeout;
> -	netdev->watchdog_timeo  = 250*HZ/1000;	/* 250 ms > USB timeout */
> -	netdev->open            = irda_usb_net_open;
> -	netdev->stop            = irda_usb_net_close;
> -	netdev->do_ioctl        = irda_usb_net_ioctl;
> +	irda_usb_init_qos(self);
>  
>  	return register_netdev(netdev);
>  }
> 
> -- 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
