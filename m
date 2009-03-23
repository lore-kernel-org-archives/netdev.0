From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 14/77] irda: convert vlsi driver to net_device_ops
Date: Mon, 23 Mar 2009 12:35:53 +0100
Message-ID: <20090323113553.GK8199@sortiz.org>
References: <20090321053527.316395697@vyatta.com> <20090321053713.605552151@vyatta.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:42373 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755621AbZCWLdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:33:42 -0400
Content-Disposition: inline
In-Reply-To: <20090321053713.605552151@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 10:35:41PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> 
> ---
>  drivers/net/irda/vlsi_ir.c |   14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)
> 
> --- a/drivers/net/irda/vlsi_ir.c	2009-03-19 22:40:30.270902366 -0700
> +++ b/drivers/net/irda/vlsi_ir.c	2009-03-19 22:42:50.764027628 -0700
> @@ -1573,6 +1573,14 @@ static int vlsi_close(struct net_device 
>  	return 0;
>  }
>  
> +static const struct net_device_ops vlsi_netdev_ops = {
> +	.ndo_open       = vlsi_open,
> +	.ndo_stop       = vlsi_close,
> +	.ndo_start_xmit = vlsi_hard_start_xmit,
> +	.ndo_do_ioctl   = vlsi_ioctl,
> +	.ndo_tx_timeout = vlsi_tx_timeout,
> +};
> +
>  static int vlsi_irda_init(struct net_device *ndev)
>  {
>  	vlsi_irda_dev_t *idev = netdev_priv(ndev);
> @@ -1608,11 +1616,7 @@ static int vlsi_irda_init(struct net_dev
>  	ndev->flags |= IFF_PORTSEL | IFF_AUTOMEDIA;
>  	ndev->if_port = IF_PORT_UNKNOWN;
>   
> -	ndev->open	      = vlsi_open;
> -	ndev->stop	      = vlsi_close;
> -	ndev->hard_start_xmit = vlsi_hard_start_xmit;
> -	ndev->do_ioctl	      = vlsi_ioctl;
> -	ndev->tx_timeout      = vlsi_tx_timeout;
> +	ndev->netdev_ops = &vlsi_netdev_ops;
>  	ndev->watchdog_timeo  = 500*HZ/1000;	/* max. allowed turn time for IrLAP */
>  
>  	SET_NETDEV_DEV(ndev, &pdev->dev);
> 
> -- 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
