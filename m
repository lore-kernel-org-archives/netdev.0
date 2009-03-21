From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 24/77] usbnet: convert rtl driver to net_device_ops
Date: Sat, 21 Mar 2009 02:03:42 -0700
Message-ID: <200903210203.43124.david-b@pacbell.net>
References: <20090321053527.316395697@vyatta.com> <20090321053714.361988448@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Petko Manolov <petkan@users.sourceforge.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp127.sbc.mail.sp1.yahoo.com ([69.147.65.186]:46396 "HELO
	smtp127.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752977AbZCUJZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 05:25:53 -0400
In-Reply-To: <20090321053714.361988448@vyatta.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 20 March 2009, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

cc'd the maintainer ... by the way, note that
"usbnet" != "everything in drivers/net/usb" ...


> --- a/drivers/net/usb/rtl8150.c	2009-03-20 12:12:47.085715442 -0700
> +++ b/drivers/net/usb/rtl8150.c	2009-03-20 12:13:41.757841762 -0700
> @@ -891,6 +891,19 @@ static int rtl8150_ioctl(struct net_devi
>  	return res;
>  }
>  
> +static const struct net_device_ops rtl8150_netdev_ops = {
> +	.ndo_open		= rtl8150_open,
> +	.ndo_stop		= rtl8150_close,
> +	.ndo_do_ioctl		= rtl8150_ioctl,
> +	.ndo_start_xmit		= rtl8150_start_xmit,
> +	.ndo_tx_timeout 	= rtl8150_tx_timeout,
> +	.ndo_set_multicast_list = rtl8150_set_multicast,
> +	.ndo_set_mac_address	= rtl8150_set_mac_address,
> +
> +	.ndo_change_mtu		= eth_change_mtu,
> +	.ndo_validate_addr	= eth_validate_addr,
> +};
> +
>  static int rtl8150_probe(struct usb_interface *intf,
>  			 const struct usb_device_id *id)
>  {
> @@ -917,15 +930,8 @@ static int rtl8150_probe(struct usb_inte
>  	
>  	dev->udev = udev;
>  	dev->netdev = netdev;
> -	netdev->open = rtl8150_open;
> -	netdev->stop = rtl8150_close;
> -	netdev->do_ioctl = rtl8150_ioctl;
> +	netdev->netdev_ops = &rtl8150_netdev_ops;
>  	netdev->watchdog_timeo = RTL8150_TX_TIMEOUT;
> -	netdev->tx_timeout = rtl8150_tx_timeout;
> -	netdev->hard_start_xmit = rtl8150_start_xmit;
> -	netdev->set_multicast_list = rtl8150_set_multicast;
> -	netdev->set_mac_address = rtl8150_set_mac_address;
> -
>  	SET_ETHTOOL_OPS(netdev, &ops);
>  	dev->intr_interval = 100;	/* 100ms */
>  
> 
> -- 
> 
> 


