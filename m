From: Art -kwaak- van Breemen <ard@telegraafnet.nl>
Subject: Re: gretap+vlan+bridge==Oops (2.6.29)
Date: Fri, 17 Apr 2009 18:51:59 +0200
Message-ID: <20090417165159.GA5098@telegraafnet.nl>
References: <20090417143732.GA8564@telegraafnet.nl> <49E89725.3090305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49E89725.3090305@trash.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, Apr 17, 2009 at 04:50:13PM +0200, Patrick McHardy wrote:
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 70d3ef4..748d567 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -387,7 +387,8 @@ static int macvlan_ethtool_get_settings(struct net_device *dev,
>  	const struct macvlan_dev *vlan = netdev_priv(dev);
>  	struct net_device *lowerdev = vlan->lowerdev;
>  
> -	if (!lowerdev->ethtool_ops->get_settings)
> +	if (!lowerdev->ethtool_ops ||
> +	    !lowerdev->ethtool_ops->get_settings)
>  		return -EOPNOTSUPP;
>  
>  	return lowerdev->ethtool_ops->get_settings(lowerdev, cmd);
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index 1b34135..6b09213 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -668,7 +668,8 @@ static int vlan_ethtool_get_settings(struct net_device *dev,
>  	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
>  	struct net_device *real_dev = vlan->real_dev;
>  
> -	if (!real_dev->ethtool_ops->get_settings)
> +	if (!real_dev->ethtool_ops ||
> +	    !real_dev->ethtool_ops->get_settings)
>  		return -EOPNOTSUPP;
>  
>  	return real_dev->ethtool_ops->get_settings(real_dev, cmd);

Too lazy to save the patch, so I just typed it :-).
Anyway: it works now as suspected.

On a side note: I was just trying to test gretap since it seems
not fragment packets and somebody else noticed that when adding
.1Q it suddenly fragmented ;-).

On to the next test.

Regards,
Ard

-- 
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?
A: Top-posting.
Q: What is the most annoying thing in email?
