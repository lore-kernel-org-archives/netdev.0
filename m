From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/4]: sunlance: Convert to net_device_ops.
Date: Mon, 23 Mar 2009 14:03:03 -0700
Message-ID: <20090323140303.0eeb3844@nehalam>
References: <20090323.134719.234362924.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37291 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753756AbZCWVDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 17:03:10 -0400
In-Reply-To: <20090323.134719.234362924.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Mar 2009 13:47:19 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/sunlance.c |   14 +++++++++-----
>  1 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
> index 16c528d..3a2bb96 100644
> --- a/drivers/net/sunlance.c
> +++ b/drivers/net/sunlance.c
> @@ -1311,6 +1311,14 @@ static const struct ethtool_ops sparc_lance_ethtool_ops = {
>  	.get_link		= sparc_lance_get_link,
>  };
>  
> +static const struct net_device_ops sparc_lance_ops = {
> +	.ndo_open		= lance_open,
> +	.ndo_stop		= lance_close,
> +	.ndo_start_xmit		= lance_start_xmit,
> +	.ndo_set_multicast_list	= lance_set_multicast,
> +	.ndo_tx_timeout		= lance_tx_timeout,

You need to add the three entries that ether_setup() was doing
in the old code:
	.ndo_change_mtu		= eth_change_mtu,
	.ndo_set_mac_address	= eth_mac_addr,
	.ndo_validate_addr	= eth_validate_addr,



> +};
> +
>  static int __devinit sparc_lance_probe_one(struct of_device *op,
>  					   struct of_device *ledma,
>  					   struct of_device *lebuffer)
> @@ -1462,13 +1470,9 @@ no_link_test:
>  
>  	lp->dev = dev;
>  	SET_NETDEV_DEV(dev, &op->dev);
> -	dev->open = &lance_open;
> -	dev->stop = &lance_close;
> -	dev->hard_start_xmit = &lance_start_xmit;
> -	dev->tx_timeout = &lance_tx_timeout;
>  	dev->watchdog_timeo = 5*HZ;
> -	dev->set_multicast_list = &lance_set_multicast;
>  	dev->ethtool_ops = &sparc_lance_ethtool_ops;
> +	dev->netdev_ops = &sparc_lance_ops;
>  
>  	dev->irq = op->irqs[0];
>  
