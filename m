From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCHv2 net-next] net: mvneta: implement .set_wol and .get_wol
Date: Mon, 23 Jan 2017 10:52:23 +0800
Message-ID: <20170123105223.3535751b@xhacker>
References: <1485139447-11067-1-git-send-email-houjingj@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <thomas.petazzoni@free-electrons.com>,
        <netdev@vger.kernel.org>
To: Jingju Hou <houjingj@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:59969 "EHLO
        mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750708AbdAWC5B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 21:57:01 -0500
In-Reply-To: <1485139447-11067-1-git-send-email-houjingj@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Jan 2017 10:44:07 +0800
Jingju Hou <houjingj@marvell.com> wrote:

> The mvneta itself does not support WOL, but the PHY might.
> So pass the calls to the PHY
> 
> Signed-off-by: Jingju Hou <houjingj@marvell.com>

Reviewed-by: Jisheng Zhang <jszhang@marvell.com>

> ---
> Since v1:
> - using phy_dev member in struct net_device
> 
>  drivers/net/ethernet/marvell/mvneta.c | 21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
> 
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index e05e227..78869fa 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -3908,6 +3908,25 @@ static int mvneta_ethtool_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
>  	return 0;
>  }
>  
> +static void
> +mvneta_ethtool_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
> +{
> +	wol->supported = 0;
> +	wol->wolopts = 0;
> +
> +	if (dev->phy_dev)
> +		return phy_ethtool_get_wol(dev->phy_dev, wol);
> +}
> +
> +static int
> +mvneta_ethtool_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
> +{
> +	if (!dev->phy_dev)
> +		return -EOPNOTSUPP;
> +
> +	return phy_ethtool_set_wol(dev->phy_dev, wol);
> +}
> +
>  static const struct net_device_ops mvneta_netdev_ops = {
>  	.ndo_open            = mvneta_open,
>  	.ndo_stop            = mvneta_stop,
> @@ -3937,6 +3956,8 @@ static int mvneta_ethtool_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
>  	.set_rxfh	= mvneta_ethtool_set_rxfh,
>  	.get_link_ksettings = phy_ethtool_get_link_ksettings,
>  	.set_link_ksettings = mvneta_ethtool_set_link_ksettings,
> +	.get_wol        = mvneta_ethtool_get_wol,
> +	.set_wol        = mvneta_ethtool_set_wol,
>  };
>  
>  /* Initialize hw */
