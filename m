From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 30/77] usbnet: convert msc7830 driver to net_device_ops
Date: Sat, 21 Mar 2009 02:19:17 -0700
Message-ID: <200903210219.17593.david-b@pacbell.net>
References: <20090321053527.316395697@vyatta.com> <20090321053714.808098082@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp127.sbc.mail.sp1.yahoo.com ([69.147.65.186]:46424 "HELO
	smtp127.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753938AbZCUJZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 05:25:57 -0400
In-Reply-To: <20090321053714.808098082@vyatta.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 20 March 2009, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

cc'd driver maintainer


> 
> --- a/drivers/net/usb/mcs7830.c	2009-03-20 12:11:35.680902515 -0700
> +++ b/drivers/net/usb/mcs7830.c	2009-03-20 12:16:27.334776706 -0700
> @@ -486,6 +486,18 @@ static int mcs7830_set_mac_address(struc
>  	return 0;
>  }
>  
> +static const struct net_device_ops mcs7830_netdev_ops = {
> +	.ndo_open		= usbnet_open,
> +	.ndo_stop		= usbnet_stop,
> +	.ndo_start_xmit		= usbnet_start_xmit,
> +	.ndo_tx_timeout		= usbnet_tx_timeout,
> +	.ndo_change_mtu		= usbnet_change_mtu,
> +	.ndo_validate_addr	= eth_validate_addr,
> +	.ndo_do_ioctl 		= mcs7830_ioctl,
> +	.ndo_set_multicast_list = mcs7830_set_multicast,
> +	.ndo_set_mac_address	 = mcs7830_set_mac_address,
> +};
> +
>  static int mcs7830_bind(struct usbnet *dev, struct usb_interface *udev)
>  {
>  	struct net_device *net = dev->net;
> @@ -495,11 +507,9 @@ static int mcs7830_bind(struct usbnet *d
>  	if (ret)
>  		goto out;
>  
> -	net->do_ioctl = mcs7830_ioctl;
>  	net->ethtool_ops = &mcs7830_ethtool_ops;
> -	net->set_multicast_list = mcs7830_set_multicast;
> +	net->netdev_ops = &mcs7830_netdev_ops;
>  	mcs7830_set_multicast(net);
> -	net->set_mac_address = mcs7830_set_mac_address;
>  
>  	/* reserve space for the status byte on rx */
>  	dev->rx_urb_size = ETH_FRAME_LEN + 1;
> 
> -- 
> 
> 


