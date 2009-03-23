From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 17/77] irda: convert sir device to net_device_ops
Date: Mon, 23 Mar 2009 12:36:42 +0100
Message-ID: <20090323113642.GN8199@sortiz.org>
References: <20090321053527.316395697@vyatta.com> <20090321053713.827044480@vyatta.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:58749 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756042AbZCWLe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:34:29 -0400
Content-Disposition: inline
In-Reply-To: <20090321053713.827044480@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 10:35:44PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> 
> --- a/drivers/net/irda/sir_dev.c	2009-03-19 22:52:52.826089334 -0700
> +++ b/drivers/net/irda/sir_dev.c	2009-03-19 23:09:32.268774083 -0700
> @@ -865,6 +865,12 @@ out:
>  	return 0;
>  }
>  
> +static const struct net_device_ops sirdev_ops = {
> +	.ndo_start_xmit	= sirdev_hard_xmit,
> +	.ndo_open	= sirdev_open,
> +	.ndo_stop	= sirdev_close,
> +	.ndo_do_ioctl	= sirdev_ioctl,
> +};
>  /* ----------------------------------------------------------------------------- */
>  
>  struct sir_dev * sirdev_get_instance(const struct sir_driver *drv, const char *name)
> @@ -908,10 +914,7 @@ struct sir_dev * sirdev_get_instance(con
>  	dev->netdev = ndev;
>  
>  	/* Override the network functions we need to use */
> -	ndev->hard_start_xmit = sirdev_hard_xmit;
> -	ndev->open = sirdev_open;
> -	ndev->stop = sirdev_close;
> -	ndev->do_ioctl = sirdev_ioctl;
> +	ndev->netdev_ops = &sirdev_ops;
>  
>  	if (register_netdev(ndev)) {
>  		IRDA_ERROR("%s(), register_netdev() failed!\n", __func__);
> 
> -- 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
