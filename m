From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net: mvneta: implement .set_wol and
 .get_wol
Date: Sun, 22 Jan 2017 23:29:36 -0500 (EST)
Message-ID: <20170122.232936.1713221615026642410.davem@davemloft.net>
References: <1485144678-11777-1-git-send-email-houjingj@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jszhang@marvell.com, thomas.petazzoni@free-electrons.com,
        netdev@vger.kernel.org
To: houjingj@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750736AbdAWE3h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 23:29:37 -0500
In-Reply-To: <1485144678-11777-1-git-send-email-houjingj@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingju Hou <houjingj@marvell.com>
Date: Mon, 23 Jan 2017 12:11:18 +0800

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
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index e05e227..fea4968 100644
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

You are not testing the build of this patch, you are still using
phy_dev here.  Either that or your commit message is not accurate.

Either way this patch or it's commit message is wrong.

I think you need to stop, take a deep breath, and take your time
fixing this.

Right now you are spitting out a new patch just minutes after
a previous submission, and these patches still have the same
bugs.
