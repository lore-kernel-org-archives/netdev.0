From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc3-mm2] 3c59x: support more ethtool_ops
Date: Tue, 05 Oct 2004 10:17:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4162ACED.10303@pobox.com>
References: <20041005134143.GA4829@gareth.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>, akpm@osdl.org
In-Reply-To: <20041005134143.GA4829@gareth.mathematik.tu-chemnitz.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Steffen Klassert wrote:
> +static int vortex_nway_reset(struct net_device *dev)
> +{
> +	struct vortex_private *vp = netdev_priv(dev);
> +	long ioaddr = dev->base_addr;
> +	EL3WINDOW(4);
> +	return mii_nway_restart(&vp->mii);
> +}
> +
> +static u32 vortex_get_link(struct net_device *dev)
> +{
> +	struct vortex_private *vp = netdev_priv(dev);
> +	long ioaddr = dev->base_addr;
> +	EL3WINDOW(4);
> +	return mii_link_ok(&vp->mii);
> +}

3c59x should properly use netif_carrier_{on,off}, at which point you can 
eliminate vortex_get_link in favor of generic ethtool_op_get_link


> +static int vortex_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
> +{
> +	struct vortex_private *vp = netdev_priv(dev);
> +	long ioaddr = dev->base_addr;
> +	EL3WINDOW(4);
> +	return mii_ethtool_gset(&vp->mii, cmd);
> +}
> +
> +static int vortex_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
> +{
> +	struct vortex_private *vp = netdev_priv(dev);
> +	long ioaddr = dev->base_addr;
> +	EL3WINDOW(4);
> +	return mii_ethtool_sset(&vp->mii, cmd);
> +}

I think that this and the other MII patch should do some amount of 
locking, like the other drivers.

	Jeff
