From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 22/77] usbnet: convert catc device to net_device_ops
Date: Sat, 21 Mar 2009 02:01:14 -0700
Message-ID: <200903210201.15098.david-b@pacbell.net>
References: <20090321053527.316395697@vyatta.com> <20090321053714.207963951@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Vojtech Pavlik <vojtech@suse.cz>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp127.sbc.mail.sp1.yahoo.com ([69.147.65.186]:46380 "HELO
	smtp127.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752698AbZCUJZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 05:25:51 -0400
In-Reply-To: <20090321053714.207963951@vyatta.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 20 March 2009, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

OK by me, but I cc'd Vojtech who was the last maintainer of this code.


> --- a/drivers/net/usb/catc.c	2009-03-20 12:10:10.851651580 -0700
> +++ b/drivers/net/usb/catc.c	2009-03-20 12:10:23.060839265 -0700
> @@ -743,6 +743,18 @@ static int catc_stop(struct net_device *
>  	return 0;
>  }
>  
> +static const struct net_device_ops catc_netdev_ops = {
> +	.ndo_open		= catc_open,
> +	.ndo_stop		= catc_stop,
> +	.ndo_start_xmit		= catc_start_xmit,
> +
> +	.ndo_tx_timeout		= catc_tx_timeout,
> +	.ndo_set_multicast_list = catc_set_multicast_list,
> +	.ndo_change_mtu		= eth_change_mtu,
> +	.ndo_set_mac_address 	= eth_mac_addr,
> +	.ndo_validate_addr	= eth_validate_addr,
> +};
> +
>  /*
>   * USB probe, disconnect.
>   */
> @@ -767,12 +779,8 @@ static int catc_probe(struct usb_interfa
>  
>  	catc = netdev_priv(netdev);
>  
> -	netdev->open = catc_open;
> -	netdev->hard_start_xmit = catc_hard_start_xmit;
> -	netdev->stop = catc_stop;
> -	netdev->tx_timeout = catc_tx_timeout;
> +	netdev->netdev_ops = &catc_netdev_ops;
>  	netdev->watchdog_timeo = TX_TIMEOUT;
> -	netdev->set_multicast_list = catc_set_multicast_list;
>  	SET_ETHTOOL_OPS(netdev, &ops);
>  
>  	catc->usbdev = usbdev;
> 
> -- 
> 
> 


