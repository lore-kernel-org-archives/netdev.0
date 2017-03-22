From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v3 net-next] net: stmmac: fix dma operation mode config
 for older versions
Date: Wed, 22 Mar 2017 13:37:21 +0100
Message-ID: <20170322123721.GA24523@Red>
References: <3b8aeab69d2987db68c74f48a3ac13c7241e1542.1490183441.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, thierry.reding@gmail.com,
        sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36289 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750952AbdCVMh1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 08:37:27 -0400
Received: by mail-wr0-f194.google.com with SMTP id l37so26482724wrc.3
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 05:37:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <3b8aeab69d2987db68c74f48a3ac13c7241e1542.1490183441.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 22, 2017 at 11:56:05AM +0000, Joao Pinto wrote:
> The dma operation mode configuration routine was wrongly moved to a
> function (stmmac_mtl_configuration) that is only executed if the
> core version is >= 4.00.
> 
> Fixes: 6deee2221e11 ("net: stmmac: prepare dma op mode config for multiple queues")
> Reported-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> Reviewed-by: Thierry Reding <thierry.reding@gmail.com>
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
> changes v2->v3:
> - Commit ID and title should be under a 'Fixes' tag
> changes v1->v2:
> - commit id did not have 12 digits
> 
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index d3a2151..225a3a3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1945,9 +1945,6 @@ static void stmmac_mtl_configuration(struct stmmac_priv *priv)
>  	/* Enable MAC RX Queues */
>  	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_enable)
>  		stmmac_mac_enable_rx_queues(priv);
> -
> -	/* Set the HW DMA mode and the COE */
> -	stmmac_dma_operation_mode(priv);
>  }
>  
>  /**
> @@ -2014,6 +2011,9 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
>  	else
>  		stmmac_set_mac(priv->ioaddr, true);
>  
> +	/* Set the HW DMA mode and the COE */
> +	stmmac_dma_operation_mode(priv);
> +
>  	stmmac_mmc_setup(priv);
>  
>  	if (init_ptp) {
> -- 
> 2.9.3
> 

Tested-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Fix one of the reported problem on dwmac-sunxi and dwmac-sun8i
Regards
