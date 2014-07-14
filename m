From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH 1/2] net: cadence: macb: add support for the WOL
Date: Mon, 14 Jul 2014 15:45:21 +0530
Message-ID: <53C3ADB9.4010309@gmail.com>
References: <1405328538-29153-1-git-send-email-neidhard.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
To: Jongsung Kim <neidhard.kim@lge.com>, nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405328538-29153-1-git-send-email-neidhard.kim@lge.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/14/2014 02:32 PM, Jongsung Kim wrote:
> This patch enables the ethtool utility to control the WOL function
> of the PHY connected to the GEM/MACB. (if supported)
>
> Signed-off-by: Jongsung Kim <neidhard.kim@lge.com>
> ---
>   drivers/net/ethernet/cadence/macb.c |   26 ++++++++++++++++++++++++++
>   1 files changed, 26 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index e9daa07..7ad8909 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1742,11 +1742,37 @@ static void macb_get_regs(struct net_device *dev, struct ethtool_regs *regs,
>   	}
>   }
>   
> +static void macb_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
> +{
> +	struct macb *bp = netdev_priv(netdev);
> +	struct phy_device *phydev = bp->phy_dev;
> +
> +	wol->supported = 0;
> +	wol->wolopts = 0;
> +
> +	if (phydev)
> +		phy_ethtool_get_wol(phydev, wol);
> +}
> +
> +static int macb_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
> +{
> +	struct macb *bp = netdev_priv(netdev);
> +	struct phy_device *phydev = bp->phy_dev;
> +	int err = -ENODEV;
> +
> +	if (phydev)
> +		err = phy_ethtool_set_wol(phydev, wol);
> +
> +	return err;
> +}
> +

I think we can do in this way:

if (phydev)
	return phy_ethtool_set_wol(phydev, wol);
else
	return -ENODEV;


we can save err. What do you say ...?

>   const struct ethtool_ops macb_ethtool_ops = {
>   	.get_settings		= macb_get_settings,
>   	.set_settings		= macb_set_settings,
>   	.get_regs_len		= macb_get_regs_len,
>   	.get_regs		= macb_get_regs,
> +	.get_wol		= macb_get_wol,
> +	.set_wol		= macb_set_wol,
>   	.get_link		= ethtool_op_get_link,
>   	.get_ts_info		= ethtool_op_get_ts_info,
>   };


-- 
Regards,
Varka Bhadram.
