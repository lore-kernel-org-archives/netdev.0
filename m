From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 28/77] usbnet: convert asix driver to net_device_ops
Date: Sat, 21 Mar 2009 02:12:36 -0700
Message-ID: <200903210212.36526.david-b@pacbell.net>
References: <20090321053527.316395697@vyatta.com> <20090321053714.666551962@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	David Hollis <dhollis@davehollis.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp127.sbc.mail.sp1.yahoo.com ([69.147.65.186]:46413 "HELO
	smtp127.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753606AbZCUJZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 05:25:56 -0400
In-Reply-To: <20090321053714.666551962@vyatta.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 20 March 2009, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

cc'd driver maintainer


> 
> --- a/drivers/net/usb/asix.c	2009-03-20 12:11:35.724901593 -0700
> +++ b/drivers/net/usb/asix.c	2009-03-20 12:15:35.937027165 -0700
> @@ -807,6 +807,18 @@ static int ax88172_link_reset(struct usb
>  	return 0;
>  }
>  
> +static const struct net_device_ops ax88172_netdev_ops = {
> +	.ndo_open		= usbnet_open,
> +	.ndo_stop		= usbnet_stop,
> +	.ndo_start_xmit		= usbnet_start_xmit,
> +	.ndo_tx_timeout		= usbnet_tx_timeout,
> +	.ndo_change_mtu		= usbnet_change_mtu,
> +	.ndo_set_mac_address 	= eth_mac_addr,
> +	.ndo_validate_addr	= eth_validate_addr,
> +	.ndo_do_ioctl		= asix_ioctl,
> +	.ndo_set_multicast_list = ax88172_set_multicast,
> +};
> +
>  static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
>  {
>  	int ret = 0;
> @@ -846,9 +858,8 @@ static int ax88172_bind(struct usbnet *d
>  	dev->mii.phy_id_mask = 0x3f;
>  	dev->mii.reg_num_mask = 0x1f;
>  	dev->mii.phy_id = asix_get_phy_addr(dev);
> -	dev->net->do_ioctl = asix_ioctl;
>  
> -	dev->net->set_multicast_list = ax88172_set_multicast;
> +	dev->net->netdev_ops = &ax88172_netdev_ops;
>  	dev->net->ethtool_ops = &ax88172_ethtool_ops;
>  
>  	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
> @@ -898,6 +909,18 @@ static int ax88772_link_reset(struct usb
>  	return 0;
>  }
>  
> +static const struct net_device_ops ax88772_netdev_ops = {
> +	.ndo_open		= usbnet_open,
> +	.ndo_stop		= usbnet_stop,
> +	.ndo_start_xmit		= usbnet_start_xmit,
> +	.ndo_tx_timeout		= usbnet_tx_timeout,
> +	.ndo_change_mtu		= usbnet_change_mtu,
> +	.ndo_set_mac_address 	= eth_mac_addr,
> +	.ndo_validate_addr	= eth_validate_addr,
> +	.ndo_do_ioctl		= asix_ioctl,
> +	.ndo_set_multicast_list = asix_set_multicast,
> +};
> +
>  static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
>  {
>  	int ret, embd_phy;
> @@ -962,7 +985,6 @@ static int ax88772_bind(struct usbnet *d
>  	dev->mii.mdio_write = asix_mdio_write;
>  	dev->mii.phy_id_mask = 0x1f;
>  	dev->mii.reg_num_mask = 0x1f;
> -	dev->net->do_ioctl = asix_ioctl;
>  	dev->mii.phy_id = asix_get_phy_addr(dev);
>  
>  	phyid = asix_get_phyid(dev);
> @@ -978,7 +1000,7 @@ static int ax88772_bind(struct usbnet *d
>  
>  	msleep(150);
>  
> -	dev->net->set_multicast_list = asix_set_multicast;
> +	dev->net->netdev_ops = &ax88772_netdev_ops;
>  	dev->net->ethtool_ops = &ax88772_ethtool_ops;
>  
>  	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
> @@ -1181,6 +1203,18 @@ static int ax88178_change_mtu(struct net
>  	return 0;
>  }
>  
> +static const struct net_device_ops ax88178_netdev_ops = {
> +	.ndo_open		= usbnet_open,
> +	.ndo_stop		= usbnet_stop,
> +	.ndo_start_xmit		= usbnet_start_xmit,
> +	.ndo_tx_timeout		= usbnet_tx_timeout,
> +	.ndo_set_mac_address 	= eth_mac_addr,
> +	.ndo_validate_addr	= eth_validate_addr,
> +	.ndo_set_multicast_list = asix_set_multicast,
> +	.ndo_do_ioctl 		= asix_ioctl,
> +	.ndo_change_mtu 	= ax88178_change_mtu,
> +};
> +
>  static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
>  {
>  	struct asix_data *data = (struct asix_data *)&dev->data;
> @@ -1247,11 +1281,10 @@ static int ax88178_bind(struct usbnet *d
>  	dev->mii.phy_id_mask = 0x1f;
>  	dev->mii.reg_num_mask = 0xff;
>  	dev->mii.supports_gmii = 1;
> -	dev->net->do_ioctl = asix_ioctl;
>  	dev->mii.phy_id = asix_get_phy_addr(dev);
> -	dev->net->set_multicast_list = asix_set_multicast;
> +
> +	dev->net->netdev_ops = &ax88178_netdev_ops;
>  	dev->net->ethtool_ops = &ax88178_ethtool_ops;
> -	dev->net->change_mtu = &ax88178_change_mtu;
>  
>  	phyid = asix_get_phyid(dev);
>  	dbg("PHYID=0x%08x", phyid);
> 
> -- 
> 
> 


