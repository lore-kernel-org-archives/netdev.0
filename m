From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: ethernet: ti/cpsw: do not crash on single-MAC machines
 during resume
Date: Thu, 14 Nov 2013 18:15:54 +0530
Message-ID: <5284C602.8000103@ti.com>
References: <1384347180-3490-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: Daniel Mack <zonque@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:38740 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753818Ab3KNMp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 07:45:59 -0500
In-Reply-To: <1384347180-3490-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 13 November 2013 06:23 PM, Daniel Mack wrote:
> To prevent Oopses, cpsw_suspend() should only soft-reset sliver 1
> on dual MAC enabled machines.
>
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> ---
>  drivers/net/ethernet/ti/cpsw.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index edd3e79..702b063 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -2173,8 +2173,11 @@ static int cpsw_suspend(struct device *dev)
>  
>  	if (netif_running(ndev))
>  		cpsw_ndo_stop(ndev);
> +
>  	soft_reset("sliver 0", &priv->slaves[0].sliver->soft_reset);
> -	soft_reset("sliver 1", &priv->slaves[1].sliver->soft_reset);
> +	if (priv->data.dual_emac)
> +		soft_reset("sliver 1", &priv->slaves[1].sliver->soft_reset);

Is this tested on a system with both ports in switch mode?
I don't think this will not work with both ports in switch mode.

Regards
Mugunthan V N
