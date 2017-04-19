From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: arc_emac: switch to phy_start()/phy_stop()
Date: Wed, 19 Apr 2017 21:22:26 +0300
Message-ID: <af660812-20f9-76fc-ee04-38a6714faabe@cogentembedded.com>
References: <1492612195-16601-1-git-send-email-al.kochet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Kochetkov <al.kochet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Peter Chen <peter.chen@nxp.com>,
        Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:32811 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1765973AbdDSSWa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 14:22:30 -0400
Received: by mail-lf0-f54.google.com with SMTP id 88so16992847lfr.0
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 11:22:30 -0700 (PDT)
In-Reply-To: <1492612195-16601-1-git-send-email-al.kochet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2017 05:29 PM, Alexander Kochetkov wrote:

> The patch replace phy_start_aneg() with phy_start(). phy_start() call

    Replaces.

> phy_start_aneg() as a part of startup sequence and allow recover from
> error (PHY_HALTED) state.
>
> Also added call phy_stop() to arc_emac_remove() to stop PHY state machine

    To arc_emac_stop() maybe?

> when MAC is down.

> Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>
> ---
>  drivers/net/ethernet/arc/emac_main.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
> index abc9f2a..188676d 100644
> --- a/drivers/net/ethernet/arc/emac_main.c
> +++ b/drivers/net/ethernet/arc/emac_main.c
[...]
> @@ -556,6 +556,8 @@ static int arc_emac_stop(struct net_device *ndev)
>  	napi_disable(&priv->napi);
>  	netif_stop_queue(ndev);
>
> +	phy_stop(ndev->phydev);
> +
>  	/* Disable interrupts */
>  	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | TXINT_MASK | ERR_MASK);
>

MBR, Sergei
