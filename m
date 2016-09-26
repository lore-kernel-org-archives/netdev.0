From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net-next 3/3] net: bcmgenet: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 26 Sep 2016 11:07:40 -0700
Message-ID: <d396ba92-7808-5530-099c-25836140e682@gmail.com>
References: <1474820967-1130-1-git-send-email-tremyfr@gmail.com>
 <1474820967-1130-4-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, jaedon.shin@gmail.com,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474820967-1130-4-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/25/2016 09:29 AM, Philippe Reynes wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c |   24 ++++++++++--------------
>  1 files changed, 10 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index 47d0a2b..2c5d9d3 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -450,32 +450,28 @@ static inline void bcmgenet_rdma_ring_writel(struct bcmgenet_priv *priv,
>  			genet_dma_ring_regs[r]);
>  }
>  
> -static int bcmgenet_get_settings(struct net_device *dev,
> -				 struct ethtool_cmd *cmd)
> +static int bcmgenet_get_link_ksettings(struct net_device *dev,
> +				       struct ethtool_link_ksettings *cmd)
>  {
> -	struct bcmgenet_priv *priv = netdev_priv(dev);
> -
>  	if (!netif_running(dev))
>  		return -EINVAL;
>  
> -	if (!priv->phydev)
> +	if (!dev->phydev)
>  		return -ENODEV;
>  
> -	return phy_ethtool_gset(priv->phydev, cmd);
> +	return phy_ethtool_ksettings_get(dev->phydev, cmd);

Can't we just use priv->phydev now instead of dev->phydev? This should
really be identical in terms of phydev lifecycle, but it just feels more
consistent to use it.
-- 
Florian
