From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH] net: mvneta: implement ->ndo_do_ioctl() to support PHY
 ioctls
Date: Wed, 04 Sep 2013 18:45:02 +0200
Message-ID: <5227638E.1070905@free-electrons.com>
References: <1378304812-21390-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:34241 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762470Ab3IDQpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 12:45:11 -0400
In-Reply-To: <1378304812-21390-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2013 16:26, Thomas Petazzoni wrote:
> This commit implements the ->ndo_do_ioctl() operation so that the
> PHY-related ioctl() calls can work from userspace, which allows
> applications like mii-tool or mii-diag to do their job.
> 

I tested it successfully with mii-diag for the Armada 370 on Mirabox
and for the Armada XP on Open Blocks AX3-4

Tested-by: Gregory CLEMENT <gregory.clement@free-electrons.com>


> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index 90ab292..389a854 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -2451,6 +2451,21 @@ static int mvneta_stop(struct net_device *dev)
>  	return 0;
>  }
>  
> +static int mvneta_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
> +{
> +	struct mvneta_port *pp = netdev_priv(dev);
> +	int ret;
> +
> +	if (!pp->phy_dev)
> +		return -ENOTSUPP;
> +
> +	ret = phy_mii_ioctl(pp->phy_dev, ifr, cmd);
> +	if (!ret)
> +		mvneta_adjust_link(dev);
> +
> +	return ret;
> +}
> +
>  /* Ethtool methods */
>  
>  /* Get settings (phy address, speed) for ethtools */
> @@ -2569,6 +2584,7 @@ static const struct net_device_ops mvneta_netdev_ops = {
>  	.ndo_change_mtu      = mvneta_change_mtu,
>  	.ndo_tx_timeout      = mvneta_tx_timeout,
>  	.ndo_get_stats64     = mvneta_get_stats64,
> +	.ndo_do_ioctl        = mvneta_ioctl,
>  };
>  
>  const struct ethtool_ops mvneta_eth_tool_ops = {
> 


-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
