From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: add more ethtool information
Date: Fri, 4 Dec 2009 10:32:23 +1030
Message-ID: <200912041032.23865.rusty@rustcorp.com.au>
References: <20091203063225.926337440@vyatta.com> <20091203063311.902077645@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alex Williamson <alex.williamson@hp.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:59754 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751794AbZLDACY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 19:02:24 -0500
In-Reply-To: <20091203063311.902077645@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Dec 2009 05:02:26 pm Stephen Hemminger wrote:
> It is useful for some tools (as well as bonding, and bridging)
> for virtio network interface provide more ethtool information.

Hi Stephen,

    Can't see any harm.  Some minor questions below:

> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/drivers/net/virtio_net.c	2009-12-01 14:24:14.766450584 -0800
> +++ b/drivers/net/virtio_net.c	2009-12-01 16:49:18.295535415 -0800
> @@ -763,7 +763,36 @@ static void virtnet_vlan_rx_kill_vid(str
>  		dev_warn(&dev->dev, "Failed to kill VLAN ID %d.\n", vid);
>  }
>  
> +static void virtnet_get_drvinfo(struct net_device *dev,
> +				struct ethtool_drvinfo *info)
> +{
> +	struct virtnet_info *vi = netdev_priv(dev);
> +
> +	strcpy(info->driver, "virtnet");
> +	strcpy(info->version, "0.1");
> +	strcpy(info->fw_version, "N/A");
> +	strcpy(info->bus_info, dev_driver_string(&vi->vdev->dev));

0.1 as a version is weird.  If we need a number, "0" seems best.

> +	cmd->speed = SPEED_1000;

Why 1000?  Because it's commong?  How about a SPEED_UNLIMITED?

Thanks,
Rusty.
