From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH 2/3] net: stmmac: Always use the number of configured TX
 queues
Date: Tue, 28 Mar 2017 16:10:43 +0200
Message-ID: <ee068d94-9a4e-404e-1348-c8e412c58ec9@axis.com>
References: <71d841cd-b07b-2635-c2cf-f7af5f5ed2c9@axis.com>
 <20170328135706.7605-1-thierry.reding@gmail.com>
 <20170328135706.7605-2-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Joao Pinto <Joao.Pinto@synopsys.com>,
        David Miller <davem@davemloft.net>,
        <clabbe.montjoie@gmail.com>, <peppe.cavallaro@st.com>,
        <alexandre.torgue@st.com>, <sergei.shtylyov@cogentembedded.com>,
        <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
To: Thierry Reding <thierry.reding@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:52174 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751936AbdC1OK6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:10:58 -0400
In-Reply-To: <20170328135706.7605-2-thierry.reding@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/28/2017 03:57 PM, Thierry Reding wrote:
> From: Thierry Reding <treding@nvidia.com>
> 
> Even if hardware supports multiple queues, software can choose to only
> use a subset of them. Make sure we never try to access uninitialized
> queues.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 106ace3781b3..ec5bba85c529 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -3423,7 +3423,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
>  	struct stmmac_rx_queue *rx_q =
>  		container_of(napi, struct stmmac_rx_queue, napi);
>  	struct stmmac_priv *priv = rx_q->priv_data;
> -	u32 tx_count = priv->dma_cap.number_tx_queues;
> +	u32 tx_count = priv->plat->tx_queues_to_use;
>  	u32 chan = rx_q->queue_index;
>  	u32 work_done = 0;
>  	u32 queue = 0;
> 

Thanks Thierry,
but this look like an equivalent patch to Joao's
"net: stmmac: fix number of tx queues in stmmac_poll"
which I already used during bisecting to avoid random
crashes in stmmac_tx_clean.

Have you noticed random RX brokenness after boot in
recent linux-next tags?

It feels like it might trigger more often after a
cold boot, but that could just be my brain seeing
patterns that aren't really there :)
