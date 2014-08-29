From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: Add support for pause
 frames
Date: Fri, 29 Aug 2014 16:53:22 +0400
Message-ID: <540077C2.2020403@cogentembedded.com>
References: <1409302581-25290-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:56861 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795AbaH2MxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 08:53:25 -0400
Received: by mail-lb0-f170.google.com with SMTP id w7so2573895lbi.29
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 05:53:24 -0700 (PDT)
In-Reply-To: <1409302581-25290-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/29/2014 12:56 PM, Mugunthan V N wrote:

> CPSW supports both rx and tx pause frames for flow control.

> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
>   drivers/net/ethernet/ti/cpsw.c | 37 +++++++++++++++++++++++++++++++++++++
>   1 file changed, 37 insertions(+)

> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 999fb72..81325d4 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -397,6 +397,8 @@ struct cpsw_priv {
>   	struct cpdma_ctlr		*dma;
>   	struct cpdma_chan		*txch, *rxch;
>   	struct cpsw_ale			*ale;
> +	bool				rx_pause;
> +	bool				tx_pause;
>   	/* snapshot of IRQ numbers */
>   	u32 irqs_table[4];
>   	u32 num_irqs;
[...]
> @@ -1784,6 +1795,30 @@ static int cpsw_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
>   		return -EOPNOTSUPP;
>   }
>
> +static void cpsw_get_pauseparam(struct net_device *ndev,
> +				struct ethtool_pauseparam *pause)
> +{
> +	struct cpsw_priv *priv = netdev_priv(ndev);
> +
> +	pause->autoneg = AUTONEG_DISABLE;
> +	pause->rx_pause = (priv->rx_pause) ? true : false;
> +	pause->tx_pause = (priv->tx_pause) ? true : false;

    Aren't 'priv->[rt]x_queue' already *bool*? And the parens are not needed 
anyway.

> +}
> +
> +static int cpsw_set_pauseparam(struct net_device *ndev,
> +			       struct ethtool_pauseparam *pause)
> +{
> +	struct cpsw_priv *priv = netdev_priv(ndev);
> +	bool link;
> +
> +	priv->rx_pause = (pause->rx_pause) ? true : false;
> +	priv->tx_pause = (pause->tx_pause) ? true : false;

    Same here...

WBR, Sergei
