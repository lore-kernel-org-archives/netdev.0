From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH 1/3] net: stmmac: Always enable MAC RX queues
Date: Tue, 21 Mar 2017 15:18:20 +0000
Message-ID: <970fc0aa-33f9-3eca-45e7-36df38d16e84@synopsys.com>
References: <20170321151211.31841-1-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        "LABBE Corentin" <clabbe.montjoie@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Thierry Reding <thierry.reding@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:51184 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757421AbdCUPTG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 11:19:06 -0400
In-Reply-To: <20170321151211.31841-1-thierry.reding@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 3:12 PM de 3/21/2017, Thierry Reding escreveu:
> From: Thierry Reding <treding@nvidia.com>
> 
> The MAC RX queues always need to be enabled in order to receive network
> packets. Remove the condition that this only needs to be done for multi-
> queue configurations.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index d3a21519e4c0..298956032098 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1943,7 +1943,7 @@ static void stmmac_mtl_configuration(struct stmmac_priv *priv)
>  		stmmac_rx_queue_dma_chan_map(priv);
>  
>  	/* Enable MAC RX Queues */
> -	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_enable)
> +	if (priv->hw->mac->rx_queue_enable)
>  		stmmac_mac_enable_rx_queues(priv);
>  
>  	/* Set the HW DMA mode and the COE */
> 

This text is from the Databook:

"In multiple Rx queues configuration, all the queues are disabled by default.
Enable the Rx queue by programming the corresponding field in this register."

So by theory, only multiple queue configured cores needs the enable operation.

>>> But came to my attention a setup that has 1 RX queue and 2 TX queues, which
enables multiple queues mechanism inside the core (even with 1 RX) and so RX
needs to be enabled. Because of that I agree with this patch.

Acked-By: Joao Pinto <jpinto@synopsys.com>
