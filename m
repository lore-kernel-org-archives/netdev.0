From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 07/77] irlan: convert to net_device_ops
Date: Mon, 23 Mar 2009 12:33:50 +0100
Message-ID: <20090323113350.GD8199@sortiz.org>
References: <20090321053527.316395697@vyatta.com> <20090321053713.084967137@vyatta.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:48059 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752595AbZCWLbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:31:37 -0400
Content-Disposition: inline
In-Reply-To: <20090321053713.084967137@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 10:35:34PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> ---
>  net/irda/irlan/irlan_eth.c |   19 +++++++++++++------
>  1 file changed, 13 insertions(+), 6 deletions(-)
> 
> --- a/net/irda/irlan/irlan_eth.c	2009-03-19 22:40:30.449963919 -0700
> +++ b/net/irda/irlan/irlan_eth.c	2009-03-19 22:42:45.749902310 -0700
> @@ -45,6 +45,16 @@ static int  irlan_eth_xmit(struct sk_buf
>  static void irlan_eth_set_multicast_list( struct net_device *dev);
>  static struct net_device_stats *irlan_eth_get_stats(struct net_device *dev);
>  
> +static const struct net_device_ops irlan_eth_netdev_ops = {
> +	.ndo_open               = irlan_eth_open,
> +	.ndo_stop               = irlan_eth_close,
> +	.ndo_start_xmit    	= irlan_eth_xmit,
> +	.ndo_get_stats	        = irlan_eth_get_stats,
> +	.ndo_set_multicast_list = irlan_eth_set_multicast_list,
> +	.ndo_change_mtu		= eth_change_mtu,
> +	.ndo_validate_addr	= eth_validate_addr,
> +};
> +
>  /*
>   * Function irlan_eth_setup (dev)
>   *
> @@ -53,14 +63,11 @@ static struct net_device_stats *irlan_et
>   */
>  static void irlan_eth_setup(struct net_device *dev)
>  {
> -	dev->open               = irlan_eth_open;
> -	dev->stop               = irlan_eth_close;
> -	dev->hard_start_xmit    = irlan_eth_xmit;
> -	dev->get_stats	        = irlan_eth_get_stats;
> -	dev->set_multicast_list = irlan_eth_set_multicast_list;
> +	ether_setup(dev);
> +
> +	dev->netdev_ops		= &irlan_eth_netdev_ops;
>  	dev->destructor		= free_netdev;
>  
> -	ether_setup(dev);
>  
>  	/*
>  	 * Lets do all queueing in IrTTP instead of this device driver.
> 
> -- 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
