From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH v3 net-next] net: mvneta: implement .set_wol and .get_wol
Date: Mon, 23 Jan 2017 04:55:39 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15A5DCDF@cnshjmbx04>
References: <1485144678-11777-1-git-send-email-houjingj@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jszhang@marvell.com" <jszhang@marvell.com>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jingju Hou <houjingj@marvell.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:56393 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750733AbdAWEzx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 23:55:53 -0500
In-Reply-To: <1485144678-11777-1-git-send-email-houjingj@marvell.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Jingju Hou
> Sent: Monday, January 23, 2017 12:11 PM
> To: davem@davemloft.net
> Cc: jszhang@marvell.com; thomas.petazzoni@free-electrons.com;
> netdev@vger.kernel.org; Jingju Hou
> Subject: [PATCH v3 net-next] net: mvneta: implement .set_wol and .get_wol
> 
> The mvneta itself does not support WOL, but the PHY might.
> So pass the calls to the PHY
> 
> Signed-off-by: Jingju Hou <houjingj@marvell.com>
> ---
> Since v2:
> - it should be phydev member not phy_dev
> 
>  drivers/net/ethernet/marvell/mvneta.c | 21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
> 
> diff --git a/drivers/net/ethernet/marvell/mvneta.c
> b/drivers/net/ethernet/marvell/mvneta.c
> index e05e227..fea4968 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -3908,6 +3908,25 @@ static int mvneta_ethtool_get_rxfh(struct
> net_device *dev, u32 *indir, u8 *key,
>  	return 0;
>  }
> 
> +static void
> +mvneta_ethtool_get_wol(struct net_device *dev, struct ethtool_wolinfo
> *wol)
> +{
> +	wol->supported = 0;
> +	wol->wolopts = 0;
> +
> +	if (dev->phy_dev)
Not changed,
> +		return phy_ethtool_get_wol(dev->phydev, wol);
> +}
> +
> +static int
> +mvneta_ethtool_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
> +{
> +	if (!dev->phydev)
> +		return -EOPNOTSUPP;
> +
> +	return phy_ethtool_set_wol(dev->phydev, wol);
> +}
> +
>  static const struct net_device_ops mvneta_netdev_ops = {
>  	.ndo_open            = mvneta_open,
>  	.ndo_stop            = mvneta_stop,
> @@ -3937,6 +3956,8 @@ static int mvneta_ethtool_get_rxfh(struct
> net_device *dev, u32 *indir, u8 *key,
>  	.set_rxfh	= mvneta_ethtool_set_rxfh,
>  	.get_link_ksettings = phy_ethtool_get_link_ksettings,
>  	.set_link_ksettings = mvneta_ethtool_set_link_ksettings,
> +	.get_wol        = mvneta_ethtool_get_wol,
> +	.set_wol        = mvneta_ethtool_set_wol,
>  };
> 
>  /* Initialize hw */
> --
> 1.9.1
