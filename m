From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 31/77] usbnet: convert sms95xx driver to net_device_ops
Date: Sat, 21 Mar 2009 02:20:29 -0700
Message-ID: <200903210220.29900.david-b@pacbell.net>
References: <20090321053527.316395697@vyatta.com> <20090321053714.885523813@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp127.sbc.mail.sp1.yahoo.com ([69.147.65.186]:46430 "HELO
	smtp127.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754024AbZCUJZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 05:25:58 -0400
In-Reply-To: <20090321053714.885523813@vyatta.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 20 March 2009, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

cc driver maintainer


> --- a/drivers/net/usb/smsc95xx.c	2009-03-20 12:11:35.646901516 -0700
> +++ b/drivers/net/usb/smsc95xx.c	2009-03-20 12:16:51.582901740 -0700
> @@ -1008,6 +1008,18 @@ static int smsc95xx_reset(struct usbnet 
>  	return 0;
>  }
>  
> +static const struct net_device_ops smsc95xx_netdev_ops = {
> +	.ndo_open		= usbnet_open,
> +	.ndo_stop		= usbnet_stop,
> +	.ndo_start_xmit		= usbnet_start_xmit,
> +	.ndo_tx_timeout		= usbnet_tx_timeout,
> +	.ndo_change_mtu		= usbnet_change_mtu,
> +	.ndo_set_mac_address 	= eth_mac_addr,
> +	.ndo_validate_addr	= eth_validate_addr,
> +	.ndo_do_ioctl 		= smsc95xx_ioctl,
> +	.ndo_set_multicast_list = smsc95xx_set_multicast,
> +};
> +
>  static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
>  {
>  	struct smsc95xx_priv *pdata = NULL;
> @@ -1038,9 +1050,8 @@ static int smsc95xx_bind(struct usbnet *
>  	/* Init all registers */
>  	ret = smsc95xx_reset(dev);
>  
> -	dev->net->do_ioctl = smsc95xx_ioctl;
> +	dev->net->netdev_ops = &smsc95xx_netdev_ops;
>  	dev->net->ethtool_ops = &smsc95xx_ethtool_ops;
> -	dev->net->set_multicast_list = smsc95xx_set_multicast;
>  	dev->net->flags |= IFF_MULTICAST;
>  	dev->net->hard_header_len += SMSC95XX_TX_OVERHEAD;
>  	return 0;
> 
> -- 
> 
> 


