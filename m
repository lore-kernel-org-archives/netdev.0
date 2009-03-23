From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 10/77] stir4200: convert to net_device_ops
Date: Mon, 23 Mar 2009 12:34:48 +0100
Message-ID: <20090323113448.GG8199@sortiz.org>
References: <20090321053527.316395697@vyatta.com> <20090321053713.305126852@vyatta.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:37246 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754125AbZCWLci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:32:38 -0400
Content-Disposition: inline
In-Reply-To: <20090321053713.305126852@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 10:35:37PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> --- a/drivers/net/irda/stir4200.c	2009-03-19 22:40:30.388964511 -0700
> +++ b/drivers/net/irda/stir4200.c	2009-03-19 22:42:47.828091113 -0700
> @@ -1007,6 +1007,13 @@ static int stir_net_ioctl(struct net_dev
>  	return ret;
>  }
>  
> +static const struct net_device_ops stir_netdev_ops = {
> +	.ndo_open       = stir_net_open,
> +	.ndo_stop       = stir_net_close,
> +	.ndo_start_xmit = stir_hard_xmit,
> +	.ndo_do_ioctl   = stir_net_ioctl,
> +};
> +
>  /*
>   * This routine is called by the USB subsystem for each new device
>   * in the system. We need to check if the device is ours, and in
> @@ -1054,10 +1061,7 @@ static int stir_probe(struct usb_interfa
>  	irda_qos_bits_to_value(&stir->qos);
>  
>  	/* Override the network functions we need to use */
> -	net->hard_start_xmit = stir_hard_xmit;
> -	net->open            = stir_net_open;
> -	net->stop            = stir_net_close;
> -	net->do_ioctl        = stir_net_ioctl;
> +	net->netdev_ops = &stir_netdev_ops;
>  
>  	ret = register_netdev(net);
>  	if (ret != 0)
> 
> -- 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
