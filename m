From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 18/77] irda: convert kignsun device to net_device_ops
Date: Mon, 23 Mar 2009 12:37:16 +0100
Message-ID: <20090323113716.GO8199@sortiz.org>
References: <20090321053527.316395697@vyatta.com> <20090321053713.897498717@vyatta.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:47416 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756022AbZCWLfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:35:04 -0400
Content-Disposition: inline
In-Reply-To: <20090321053713.897498717@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 10:35:45PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> --- a/drivers/net/irda/kingsun-sir.c	2009-03-19 22:49:39.434901885 -0700
> +++ b/drivers/net/irda/kingsun-sir.c	2009-03-19 22:52:44.909902552 -0700
> @@ -418,6 +418,12 @@ static int kingsun_net_ioctl(struct net_
>  	return ret;
>  }
>  
> +static const struct net_device_ops kingsun_ops = {
> +	.ndo_start_xmit = kingsun_hard_xmit,
> +	.ndo_open            = kingsun_net_open,
> +	.ndo_stop            = kingsun_net_close,
> +	.ndo_do_ioctl        = kingsun_net_ioctl,
> +};
>  
>  /*
>   * This routine is called by the USB subsystem for each new device
> @@ -520,10 +526,7 @@ static int kingsun_probe(struct usb_inte
>  	irda_qos_bits_to_value(&kingsun->qos);
>  
>  	/* Override the network functions we need to use */
> -	net->hard_start_xmit = kingsun_hard_xmit;
> -	net->open            = kingsun_net_open;
> -	net->stop            = kingsun_net_close;
> -	net->do_ioctl        = kingsun_net_ioctl;
> +	net->netdev_ops = &kingsun_ops;
>  
>  	ret = register_netdev(net);
>  	if (ret != 0)
> 
> -- 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
