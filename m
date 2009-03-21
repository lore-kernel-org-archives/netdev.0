From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 29/77] usbnet: convert dms9601 driver to net_device_ops
Date: Sat, 21 Mar 2009 02:14:56 -0700
Message-ID: <200903210214.56236.david-b@pacbell.net>
References: <20090321053527.316395697@vyatta.com> <20090321053714.737716531@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jacmet@sunsite.dk
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp127.sbc.mail.sp1.yahoo.com ([69.147.65.186]:46419 "HELO
	smtp127.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753651AbZCUJZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 05:25:56 -0400
In-Reply-To: <20090321053714.737716531@vyatta.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 20 March 2009, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

cc'd maintainer



> 
> --- a/drivers/net/usb/dm9601.c	2009-03-20 12:11:35.703901588 -0700
> +++ b/drivers/net/usb/dm9601.c	2009-03-20 12:16:05.744902076 -0700
> @@ -419,6 +419,18 @@ static int dm9601_set_mac_address(struct
>  	return 0;
>  }
>  
> +static const struct net_device_ops dm9601_netdev_ops = {
> +	.ndo_open		= usbnet_open,
> +	.ndo_stop		= usbnet_stop,
> +	.ndo_start_xmit		= usbnet_start_xmit,
> +	.ndo_tx_timeout		= usbnet_tx_timeout,
> +	.ndo_change_mtu		= usbnet_change_mtu,
> +	.ndo_validate_addr	= eth_validate_addr,
> +	.ndo_do_ioctl 		= dm9601_ioctl,
> +	.ndo_set_multicast_list = dm9601_set_multicast,
> +	.ndo_set_mac_address	= dm9601_set_mac_address,
> +};
> +
>  static int dm9601_bind(struct usbnet *dev, struct usb_interface *intf)
>  {
>  	int ret;
> @@ -428,9 +440,7 @@ static int dm9601_bind(struct usbnet *de
>  	if (ret)
>  		goto out;
>  
> -	dev->net->do_ioctl = dm9601_ioctl;
> -	dev->net->set_multicast_list = dm9601_set_multicast;
> -	dev->net->set_mac_address = dm9601_set_mac_address;
> +	dev->net->netdev_ops = &dm9601_netdev_ops;
>  	dev->net->ethtool_ops = &dm9601_ethtool_ops;
>  	dev->net->hard_header_len += DM_TX_OVERHEAD;
>  	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
> 
> -- 
> 
> 


