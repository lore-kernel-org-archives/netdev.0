From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 5/5] stmmac: replace if (netif_msg_type) by their
 netif_xxx counterpart
Date: Thu, 10 Sep 2015 09:24:44 -0700
Message-ID: <1441902284.17219.165.camel@perches.com>
References: <1441888653-30535-1-git-send-email-clabbe.montjoie@gmail.com>
	 <1441888653-30535-6-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: LABBE Corentin <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441888653-30535-6-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-09-10 at 14:37 +0200, LABBE Corentin wrote:
> replace all
> if (netif_msg_type(priv)) dev_xxx(priv->devices, ...)
> by the simplier macro netif_xxx(priv, hw, priv->dev, ...)

Thanks.  Trivia:

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
[]
> @@ -733,10 +735,9 @@ static void stmmac_adjust_link(struct net_device *dev)
>  				stmmac_hw_fix_mac_speed(priv);
>  				break;
>  			default:
> -				if (netif_msg_link(priv))
> -					netdev_warn(priv->dev,
> -						    "%s: Speed (%d) not 10/100\n",
> -						    dev->name, phydev->speed);
> +				netif_warn(priv, link, priv->dev,
> +					   "%s: Speed (%d) not 10/100\n",
> +					   dev->name, phydev->speed);

Maybe add another patch removing dev->name where used
in logging as it's likely redundant.

> @@ -1038,18 +1039,15 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
>  
>  	priv->dma_buf_sz = bfsize;
>  
> -	if (netif_msg_probe(priv))
> -		netdev_dbg(priv->dev, "%s: txsize %d, rxsize %d, bfsize %d\n",
> -			   __func__, txsize, rxsize, bfsize);
> +	netif_dbg(priv, probe, priv->dev, "%s: txsize %d, rxsize %d, bfsize %d\n",
> +		  __func__, txsize, rxsize, bfsize);

And another removing __func__ from the _dbg uses as
it's relatively low value and dynamic debug can add it.
