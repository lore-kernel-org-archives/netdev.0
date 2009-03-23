From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 13/77] irda: convert ali driver to net_device_ops
Date: Mon, 23 Mar 2009 12:35:36 +0100
Message-ID: <20090323113536.GJ8199@sortiz.org>
References: <20090321053527.316395697@vyatta.com> <20090321053713.525233490@vyatta.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:46496 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755532AbZCWLdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:33:24 -0400
Content-Disposition: inline
In-Reply-To: <20090321053713.525233490@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 10:35:40PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> ---
>  drivers/net/irda/ali-ircc.c |   23 +++++++++++++++++------
>  1 file changed, 17 insertions(+), 6 deletions(-)
> 
> --- a/drivers/net/irda/ali-ircc.c	2009-03-19 22:40:30.305965477 -0700
> +++ b/drivers/net/irda/ali-ircc.c	2009-03-19 22:42:49.992901415 -0700
> @@ -259,6 +259,20 @@ static void __exit ali_ircc_cleanup(void
>  	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __func__);
>  }
>  
> +static const struct net_device_ops ali_ircc_sir_ops = {
> +	.ndo_open       = ali_ircc_net_open,
> +	.ndo_stop       = ali_ircc_net_close,
> +	.ndo_start_xmit = ali_ircc_sir_hard_xmit,
> +	.ndo_do_ioctl   = ali_ircc_net_ioctl,
> +};
> +
> +static const struct net_device_ops ali_ircc_fir_ops = {
> +	.ndo_open       = ali_ircc_net_open,
> +	.ndo_stop       = ali_ircc_net_close,
> +	.ndo_start_xmit = ali_ircc_fir_hard_xmit,
> +	.ndo_do_ioctl   = ali_ircc_net_ioctl,
> +};
> +
>  /*
>   * Function ali_ircc_open (int i, chipio_t *inf)
>   *
> @@ -361,10 +375,7 @@ static int ali_ircc_open(int i, chipio_t
>  	self->tx_fifo.tail = self->tx_buff.head;
>  
>  	/* Override the network functions we need to use */
> -	dev->hard_start_xmit = ali_ircc_sir_hard_xmit;
> -	dev->open            = ali_ircc_net_open;
> -	dev->stop            = ali_ircc_net_close;
> -	dev->do_ioctl        = ali_ircc_net_ioctl;
> +	dev->netdev_ops = &ali_ircc_sir_ops;
>  
>  	err = register_netdev(dev);
>  	if (err) {
> @@ -974,7 +985,7 @@ static void ali_ircc_change_speed(struct
>  		ali_ircc_fir_change_speed(self, baud);			
>  		
>  		/* Install FIR xmit handler*/
> -		dev->hard_start_xmit = ali_ircc_fir_hard_xmit;		
> +		dev->netdev_ops = &ali_ircc_fir_ops;
>  				
>  		/* Enable Interuupt */
>  		self->ier = IER_EOM; // benjamin 2000/11/20 07:24PM					
> @@ -988,7 +999,7 @@ static void ali_ircc_change_speed(struct
>  		ali_ircc_sir_change_speed(self, baud);
>  				
>  		/* Install SIR xmit handler*/
> -		dev->hard_start_xmit = ali_ircc_sir_hard_xmit;
> +		dev->netdev_ops = &ali_ircc_sir_ops;
>  	}
>  	
>  		
> 
> -- 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
