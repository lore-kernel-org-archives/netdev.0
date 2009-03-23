From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 16/77] irda: convert via-ircc to net_device_ops
Date: Mon, 23 Mar 2009 12:36:13 +0100
Message-ID: <20090323113613.GM8199@sortiz.org>
References: <20090321053527.316395697@vyatta.com> <20090321053713.753305795@vyatta.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:45743 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754941AbZCWLeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:34:00 -0400
Content-Disposition: inline
In-Reply-To: <20090321053713.753305795@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 10:35:43PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> 
> ---
>  drivers/net/irda/via-ircc.c |   22 ++++++++++++++++------
>  1 file changed, 16 insertions(+), 6 deletions(-)
> 
> --- a/drivers/net/irda/via-ircc.c	2009-03-19 22:44:21.282901713 -0700
> +++ b/drivers/net/irda/via-ircc.c	2009-03-19 22:46:36.823964988 -0700
> @@ -310,6 +310,19 @@ static void __exit via_ircc_cleanup(void
>  	pci_unregister_driver (&via_driver); 
>  }
>  
> +static const struct net_device_ops via_ircc_sir_ops = {
> +	.ndo_start_xmit = via_ircc_hard_xmit_sir,
> +	.ndo_open = via_ircc_net_open,
> +	.ndo_stop = via_ircc_net_close,
> +	.ndo_do_ioctl = via_ircc_net_ioctl,
> +};
> +static const struct net_device_ops via_ircc_fir_ops = {
> +	.ndo_start_xmit = via_ircc_hard_xmit_fir,
> +	.ndo_open = via_ircc_net_open,
> +	.ndo_stop = via_ircc_net_close,
> +	.ndo_do_ioctl = via_ircc_net_ioctl,
> +};
> +
>  /*
>   * Function via_ircc_open (iobase, irq)
>   *
> @@ -428,10 +441,7 @@ static __devinit int via_ircc_open(int i
>  	self->tx_fifo.tail = self->tx_buff.head;
>  
>  	/* Override the network functions we need to use */
> -	dev->hard_start_xmit = via_ircc_hard_xmit_sir;
> -	dev->open = via_ircc_net_open;
> -	dev->stop = via_ircc_net_close;
> -	dev->do_ioctl = via_ircc_net_ioctl;
> +	dev->netdev_ops = &via_ircc_sir_ops;
>  
>  	err = register_netdev(dev);
>  	if (err)
> @@ -798,11 +808,11 @@ static void via_ircc_change_speed(struct
>  
>  	if (speed > 115200) {
>  		/* Install FIR xmit handler */
> -		dev->hard_start_xmit = via_ircc_hard_xmit_fir;
> +		dev->netdev_ops = &via_ircc_fir_ops;
>  		via_ircc_dma_receive(self);
>  	} else {
>  		/* Install SIR xmit handler */
> -		dev->hard_start_xmit = via_ircc_hard_xmit_sir;
> +		dev->netdev_ops = &via_ircc_sir_ops;
>  	}
>  	netif_wake_queue(dev);
>  }
> 
> -- 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
