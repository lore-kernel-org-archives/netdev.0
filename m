From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: arc_emac: switch to phy_start()/phy_stop()
Date: Wed, 19 Apr 2017 14:08:49 -0700
Message-ID: <5ed9e534-d134-2ba1-0276-0bc8bd949eb1@gmail.com>
References: <1492612195-16601-1-git-send-email-al.kochet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Alexander Kochetkov <al.kochet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Peter Chen <peter.chen@nxp.com>,
        Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f196.google.com ([209.85.213.196]:32942 "EHLO
        mail-yb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966847AbdDSVIw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 17:08:52 -0400
In-Reply-To: <1492612195-16601-1-git-send-email-al.kochet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2017 07:29 AM, Alexander Kochetkov wrote:
> The patch replace phy_start_aneg() with phy_start(). phy_start() call
> phy_start_aneg() as a part of startup sequence and allow recover from
> error (PHY_HALTED) state.
> 
> Also added call phy_stop() to arc_emac_remove() to stop PHY state machine
> when MAC is down.

This looks fine. If you wanted to go further, you could move the
phy_connect(), phy_disconnect() calls down to the arc_emac_open()
respectively arc_emac_stop() as this would also allow the PHY device to
be fully suspended when the interface is unused.

> 
> Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>
> ---
>  drivers/net/ethernet/arc/emac_main.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
> index abc9f2a..188676d 100644
> --- a/drivers/net/ethernet/arc/emac_main.c
> +++ b/drivers/net/ethernet/arc/emac_main.c
> @@ -434,7 +434,7 @@ static int arc_emac_open(struct net_device *ndev)
>  	/* Enable EMAC */
>  	arc_reg_or(priv, R_CTRL, EN_MASK);
>  
> -	phy_start_aneg(ndev->phydev);
> +	phy_start(ndev->phydev);
>  
>  	netif_start_queue(ndev);
>  
> @@ -556,6 +556,8 @@ static int arc_emac_stop(struct net_device *ndev)
>  	napi_disable(&priv->napi);
>  	netif_stop_queue(ndev);
>  
> +	phy_stop(ndev->phydev);
> +
>  	/* Disable interrupts */
>  	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | TXINT_MASK | ERR_MASK);
>  
> 


-- 
Florian
