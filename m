From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 11/22] efx: convert to net_device_ops
Date: Sat, 22 Nov 2008 00:45:14 +0000
Message-ID: <20081122004513.GE32518@solarflare.com>
References: <20081121232138.343333942@vyatta.com> <20081121232239.826434876@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:44251 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753299AbYKVApU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:45:20 -0500
Content-Disposition: inline
In-Reply-To: <20081121232239.826434876@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Convert driver to new net_device_ops. Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Ben Hutchings <bhutchings@solarflare.com>

(But the driver name is sfc; "efx" is an historical reference.)

> --- a/drivers/net/sfc/efx.c	2008-11-21 13:57:58.000000000 -0800
> +++ b/drivers/net/sfc/efx.c	2008-11-21 14:09:48.000000000 -0800
> @@ -1433,12 +1433,28 @@ static void efx_set_multicast_list(struc
>  	falcon_set_multicast_hash(efx);
>  }
>  
> +static const struct net_device_ops efx_netdev_ops = {
> +	.ndo_open		= efx_net_open,
> +	.ndo_stop		= efx_net_stop,
> +	.ndo_get_stats		= efx_net_stats,
> +	.ndo_tx_timeout		= efx_watchdog,
> +	.ndo_start_xmit		= efx_hard_start_xmit,
> +	.ndo_validate_addr	= eth_validate_addr,
> +	.ndo_do_ioctl		= efx_ioctl,
> +	.ndo_change_mtu		= efx_change_mtu,
> +	.ndo_set_mac_address	= efx_set_mac_address,
> +	.ndo_set_multicast_list = efx_set_multicast_list,
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	.ndo_poll_controller = efx_netpoll,
> +#endif
> +};
> +
>  static int efx_netdev_event(struct notifier_block *this,
>  			    unsigned long event, void *ptr)
>  {
>  	struct net_device *net_dev = ptr;
>  
> -	if (net_dev->open == efx_net_open && event == NETDEV_CHANGENAME) {
> +	if (net_dev->netdev_ops == &efx_netdev_ops && event == NETDEV_CHANGENAME) {

Also, this line should be wrapped now.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
