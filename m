From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 net-next] net: mvneta: implement .set_wol and .get_wol
Date: Mon, 23 Jan 2017 19:10:34 +0100
Message-ID: <20170123181034.GN10895@lunn.ch>
References: <20170123065507.2557-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: thomas.petazzoni@free-electrons.com, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jingju Hou <houjingj@marvell.com>
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170123065507.2557-1-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 23, 2017 at 02:55:07PM +0800, Jisheng Zhang wrote:
> From: Jingju Hou <houjingj@marvell.com>
> 
> From: Jingju Hou <houjingj@marvell.com>
> 
> The mvneta itself does not support WOL, but the PHY might.
> So pass the calls to the PHY
> 
> Signed-off-by: Jingju Hou <houjingj@marvell.com>
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
> ---
> since v3:
>  - really fix the build error

Keep trying....

But maybe tomorrow, after you have taken the pause Dave said you
should take, and maybe ask Jingju to really review it, in detail.

> 
> since v2,v1:
>  - using phy_dev member in struct net_device
>  - add commit msg
> 
>  drivers/net/ethernet/marvell/mvneta.c | 21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
> 
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index 6dcc951af0ff..02611fa1c3b8 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -3929,6 +3929,25 @@ static int mvneta_ethtool_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
>  	return 0;
>  }
>  
> +static void mvneta_ethtool_get_wol(struct net_device *dev,
> +				   struct ethtool_wolinfo *wol)
> +{
> +	wol->supported = 0;
> +	wol->wolopts = 0;
> +
> +	if (dev->phydev)
> +		return phy_ethtool_get_wol(dev->phydev, wol);

This is a void function.  And you are returning a value.  And
phy_ethtool_get_wol() is also a void function, so does not actually
return anything.

0-day was telling you this. Please read what is said.

     Andrew
