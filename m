From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 12/77] irda: convert nsc_ircc driver to net_device_ops
Date: Mon, 23 Mar 2009 12:35:21 +0100
Message-ID: <20090323113520.GI8199@sortiz.org>
References: <20090321053527.316395697@vyatta.com> <20090321053713.447008113@vyatta.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:47521 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756947AbZCWLdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:33:08 -0400
Content-Disposition: inline
In-Reply-To: <20090321053713.447008113@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 10:35:39PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> --- a/drivers/net/irda/nsc-ircc.c	2009-03-19 22:40:30.326964540 -0700
> +++ b/drivers/net/irda/nsc-ircc.c	2009-03-19 22:42:49.228901973 -0700
> @@ -331,6 +331,20 @@ static void __exit nsc_ircc_cleanup(void
>  	pnp_registered = 0;
>  }
>  
> +static const struct net_device_ops nsc_ircc_sir_ops = {
> +	.ndo_open       = nsc_ircc_net_open,
> +	.ndo_stop       = nsc_ircc_net_close,
> +	.ndo_start_xmit = nsc_ircc_hard_xmit_sir,
> +	.ndo_do_ioctl   = nsc_ircc_net_ioctl,
> +};
> +
> +static const struct net_device_ops nsc_ircc_fir_ops = {
> +	.ndo_open       = nsc_ircc_net_open,
> +	.ndo_stop       = nsc_ircc_net_close,
> +	.ndo_start_xmit = nsc_ircc_hard_xmit_fir,
> +	.ndo_do_ioctl   = nsc_ircc_net_ioctl,
> +};
> +
>  /*
>   * Function nsc_ircc_open (iobase, irq)
>   *
> @@ -441,10 +455,7 @@ static int __init nsc_ircc_open(chipio_t
>  	self->tx_fifo.tail = self->tx_buff.head;
>  
>  	/* Override the network functions we need to use */
> -	dev->hard_start_xmit = nsc_ircc_hard_xmit_sir;
> -	dev->open            = nsc_ircc_net_open;
> -	dev->stop            = nsc_ircc_net_close;
> -	dev->do_ioctl        = nsc_ircc_net_ioctl;
> +	dev->netdev_ops = &nsc_ircc_sir_ops;
>  
>  	err = register_netdev(dev);
>  	if (err) {
> @@ -1320,12 +1331,12 @@ static __u8 nsc_ircc_change_speed(struct
>  	switch_bank(iobase, BANK0); 
>  	if (speed > 115200) {
>  		/* Install FIR xmit handler */
> -		dev->hard_start_xmit = nsc_ircc_hard_xmit_fir;
> +		dev->netdev_ops = &nsc_ircc_fir_ops;
>  		ier = IER_SFIF_IE;
>  		nsc_ircc_dma_receive(self);
>  	} else {
>  		/* Install SIR xmit handler */
> -		dev->hard_start_xmit = nsc_ircc_hard_xmit_sir;
> +		dev->netdev_ops = &nsc_ircc_sir_ops;
>  		ier = IER_RXHDL_IE;
>  	}
>  	/* Set our current interrupt mask */
> 
> -- 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
