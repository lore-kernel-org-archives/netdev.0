From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 11/77] irda: convert w83977af_ir to net_device_ops
Date: Mon, 23 Mar 2009 12:35:06 +0100
Message-ID: <20090323113506.GH8199@sortiz.org>
References: <20090321053527.316395697@vyatta.com> <20090321053713.376037045@vyatta.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:55620 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755001AbZCWLcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:32:53 -0400
Content-Disposition: inline
In-Reply-To: <20090321053713.376037045@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 10:35:38PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> --- a/drivers/net/irda/w83977af_ir.c	2009-03-19 22:40:30.367964328 -0700
> +++ b/drivers/net/irda/w83977af_ir.c	2009-03-19 22:42:48.582901908 -0700
> @@ -140,6 +140,13 @@ static void __exit w83977af_cleanup(void
>  	}
>  }
>  
> +static const struct net_device_ops w83977_netdev_ops = {
> +	.ndo_open       = w83977af_net_open,
> +	.ndo_stop       = w83977af_net_close,
> +	.ndo_start_xmit = w83977af_hard_xmit,
> +	.ndo_do_ioctl   = w83977af_net_ioctl,
> +};
> +
>  /*
>   * Function w83977af_open (iobase, irq)
>   *
> @@ -231,11 +238,7 @@ static int w83977af_open(int i, unsigned
>  	self->rx_buff.data = self->rx_buff.head;
>  	self->netdev = dev;
>  
> -	/* Override the network functions we need to use */
> -	dev->hard_start_xmit = w83977af_hard_xmit;
> -	dev->open            = w83977af_net_open;
> -	dev->stop            = w83977af_net_close;
> -	dev->do_ioctl        = w83977af_net_ioctl;
> +	dev->netdev_ops	= &w83977_netdev_ops;
>  
>  	err = register_netdev(dev);
>  	if (err) {
> 
> -- 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
