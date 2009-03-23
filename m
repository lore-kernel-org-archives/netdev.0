From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 20/77] irda: convert ks959 device to net_device_ops
Date: Mon, 23 Mar 2009 12:37:44 +0100
Message-ID: <20090323113744.GQ8199@sortiz.org>
References: <20090321053527.316395697@vyatta.com> <20090321053714.047172024@vyatta.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:40440 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753459AbZCWLfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:35:32 -0400
Content-Disposition: inline
In-Reply-To: <20090321053714.047172024@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 10:35:47PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> --- a/drivers/net/irda/ks959-sir.c	2009-03-19 23:10:00.793089980 -0700
> +++ b/drivers/net/irda/ks959-sir.c	2009-03-19 23:11:27.344651666 -0700
> @@ -668,6 +668,12 @@ static int ks959_net_ioctl(struct net_de
>  	return ret;
>  }
>  
> +static const struct net_device_ops ks959_ops = {
> +	.ndo_start_xmit	= ks959_hard_xmit,
> +	.ndo_open	= ks959_net_open,
> +	.ndo_stop	= ks959_net_close,
> +	.ndo_do_ioctl	= ks959_net_ioctl,
> +};
>  /*
>   * This routine is called by the USB subsystem for each new device
>   * in the system. We need to check if the device is ours, and in
> @@ -780,10 +786,7 @@ static int ks959_probe(struct usb_interf
>  	irda_qos_bits_to_value(&kingsun->qos);
>  
>  	/* Override the network functions we need to use */
> -	net->hard_start_xmit = ks959_hard_xmit;
> -	net->open = ks959_net_open;
> -	net->stop = ks959_net_close;
> -	net->do_ioctl = ks959_net_ioctl;
> +	net->netdev_ops = &ks959_ops;
>  
>  	ret = register_netdev(net);
>  	if (ret != 0)
> 
> -- 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
