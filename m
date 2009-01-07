From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH 24/42] tulip: convert devices to new API
Date: Wed, 7 Jan 2009 00:49:49 -0700
Message-ID: <20090107074949.GB23818@colo.lackof.org>
References: <20090107003316.784424362@vyatta.com> <20090107003348.110775064@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:60818 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751326AbZAGHuE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 02:50:04 -0500
Content-Disposition: inline
In-Reply-To: <20090107003348.110775064@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2009 at 04:33:40PM -0800, Stephen Hemminger wrote:
> Convert to net_device_ops and internal net_device_stats
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

thanks,
grant

> 
> ---
>  drivers/net/tulip/tulip_core.c |   27 +++++++++++++++++----------
>  1 file changed, 17 insertions(+), 10 deletions(-)
> 
> --- a/drivers/net/tulip/tulip_core.c	2009-01-06 16:22:22.016610626 -0800
> +++ b/drivers/net/tulip/tulip_core.c	2009-01-06 16:22:24.210112411 -0800
> @@ -1225,6 +1225,22 @@ static int tulip_uli_dm_quirk(struct pci
>  	return 0;
>  }
>  
> +static const struct net_device_ops tulip_netdev_ops = {
> +	.ndo_open		= tulip_open,
> +	.ndo_start_xmit		= tulip_start_xmit,
> +	.ndo_tx_timeout		= tulip_tx_timeout,
> +	.ndo_stop		= tulip_close,
> +	.ndo_get_stats		= tulip_get_stats,
> +	.ndo_do_ioctl 		= private_ioctl,
> +	.ndo_set_multicast_list = set_rx_mode,
> +	.ndo_change_mtu		= eth_change_mtu,
> +	.ndo_set_mac_address	= eth_mac_addr,
> +	.ndo_validate_addr	= eth_validate_addr,
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	.ndo_poll_controller	 = poll_tulip,
> +#endif
> +};
> +
>  static int __devinit tulip_init_one (struct pci_dev *pdev,
>  				     const struct pci_device_id *ent)
>  {
> @@ -1601,20 +1617,11 @@ static int __devinit tulip_init_one (str
>  	}
>  
>  	/* The Tulip-specific entries in the device structure. */
> -	dev->open = tulip_open;
> -	dev->hard_start_xmit = tulip_start_xmit;
> -	dev->tx_timeout = tulip_tx_timeout;
> +	dev->netdev_ops = &tulip_netdev_ops;
>  	dev->watchdog_timeo = TX_TIMEOUT;
>  #ifdef CONFIG_TULIP_NAPI
>  	netif_napi_add(dev, &tp->napi, tulip_poll, 16);
>  #endif
> -	dev->stop = tulip_close;
> -	dev->get_stats = tulip_get_stats;
> -	dev->do_ioctl = private_ioctl;
> -	dev->set_multicast_list = set_rx_mode;
> -#ifdef CONFIG_NET_POLL_CONTROLLER
> -	dev->poll_controller = &poll_tulip;
> -#endif
>  	SET_ETHTOOL_OPS(dev, &ops);
>  
>  	if (register_netdev(dev))
> 
> -- 
