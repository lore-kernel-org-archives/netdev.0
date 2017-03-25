From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: stmmac: fix number of tx queues in
 stmmac_poll
Date: Sat, 25 Mar 2017 08:26:21 +0100
Message-ID: <20170325072621.GA20997@Red>
References: <cover.1490375512.git.jpinto@synopsys.com>
 <b6f44c16abea1693dcc1333517778bd7a3e0b0f5.1490375512.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, thierry.reding@gmail.com,
        sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35622 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752824AbdCYH02 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 03:26:28 -0400
Received: by mail-wm0-f66.google.com with SMTP id z133so1819751wmb.2
        for <netdev@vger.kernel.org>; Sat, 25 Mar 2017 00:26:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <b6f44c16abea1693dcc1333517778bd7a3e0b0f5.1490375512.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 24, 2017 at 05:16:45PM +0000, Joao Pinto wrote:
> For cores that have more than 1 TX queue configured, the kernel would crash,
> since only one TX queue is permitted by default.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 3827952..1eab084 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -3429,7 +3429,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
>  	struct stmmac_rx_queue *rx_q =
>  		container_of(napi, struct stmmac_rx_queue, napi);
>  	struct stmmac_priv *priv = rx_q->priv_data;
> -	u32 tx_count = priv->dma_cap.number_tx_queues;
> +	u32 tx_count = priv->plat->tx_queues_to_use;
>  	u32 chan = rx_q->queue_index;
>  	u32 work_done = 0;
>  	u32 queue = 0;
> -- 
> 2.9.3
> 

This patch fix the performance issue on dwmac-sun8i only.
The dwmac-sunxi is still broken.
