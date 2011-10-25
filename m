From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [RFC PATCH 11/17] sh_eth: Don't unnecessarily reset the PHY
Date: Tue, 25 Oct 2011 20:11:46 +0900
Message-ID: <4EA69972.4090004@renesas.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
 <1319144425-15547-12-git-send-email-Kyle.D.Moffett@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Kuninori Morimoto <morimoto.kuninori@renesas.com>
To: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1319144425-15547-12-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

2011/10/21 6:00, Kyle Moffett wrote:
> The PHY is already reset during driver probing, and this manual reset
> afterwards will wipe out board-specific PHY fixups and driver-specific
> phy->drv->config_init() register tweaks.

Thank you for your patch. I think so.
However, the patch cannot work correctly on my environment.

> Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
> ---
>  drivers/net/sh_eth.c |   19 +------------------
>  1 files changed, 1 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
> index 1c1666e..7ef4378 100644
> --- a/drivers/net/sh_eth.c
> +++ b/drivers/net/sh_eth.c
> @@ -1235,23 +1235,6 @@ static int sh_eth_phy_init(struct net_device *ndev)
>  	return 0;
>  }
>  
> -/* PHY control start function */
> -static int sh_eth_phy_start(struct net_device *ndev)
> -{
> -	struct sh_eth_private *mdp = netdev_priv(ndev);
> -	int ret;
> -
> -	ret = sh_eth_phy_init(ndev);
> -	if (ret)
> -		return ret;
> -
> -	/* reset phy - this also wakes it from PDOWN */
> -	phy_write(mdp->phydev, MII_BMCR, BMCR_RESET);
> -	phy_start(mdp->phydev);

I think that the driver needs the phy_start().
So, I removed the phy_write() only. Then, the driver could work correctly.

Therefore, I would to remove the following code only.
Do you think about this?

> -	/* reset phy - this also wakes it from PDOWN */
> -	phy_write(mdp->phydev, MII_BMCR, BMCR_RESET);

Thanks,
Yoshihiro Shimoda
