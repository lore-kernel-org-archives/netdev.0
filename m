From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/11] net: stmmac: dma channel init prepared for
 multiple queues
Date: Mon, 13 Mar 2017 17:18:57 -0700 (PDT)
Message-ID: <20170313.171857.406760790328158776.davem@davemloft.net>
References: <cover.1489419356.git.jpinto@synopsys.com>
        <cover.1489419356.git.jpinto@synopsys.com>
        <c5de4f9e818a5e84e880d0ab16bfc6bb59470a27.1489419357.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60270 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752001AbdCNAS6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 20:18:58 -0400
In-Reply-To: <c5de4f9e818a5e84e880d0ab16bfc6bb59470a27.1489419357.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Mon, 13 Mar 2017 16:12:40 +0000

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index e60e077..44db2e3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1732,6 +1732,10 @@ static void stmmac_check_ether_addr(struct stmmac_priv *priv)
>   */
>  static int stmmac_init_dma_engine(struct stmmac_priv *priv)
>  {
> +	u32 rx_channels_count = priv->plat->rx_queues_to_use;
> +	u32 tx_channels_count = priv->plat->tx_queues_to_use;
> +	u32 dummy_dma_rx_phy, dummy_dma_tx_phy = 0;
> +	u32 chan = 0;
>  	int atds = 0;
>  	int ret = 0;
>  

dummy_dma_rx_phy is declared, but not initialized:

> @@ -1749,19 +1753,43 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
>  		return ret;
>  	}
>  
> -	priv->hw->dma->init(priv->ioaddr, priv->plat->dma_cfg,
> -			    priv->dma_tx_phy, priv->dma_rx_phy, atds);
> -
>  	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
> -		priv->rx_tail_addr = priv->dma_rx_phy +
> -			    (DMA_RX_SIZE * sizeof(struct dma_desc));
> -		priv->hw->dma->set_rx_tail_ptr(priv->ioaddr, priv->rx_tail_addr,
> -					       STMMAC_CHAN0);
> +		/* DMA Configuration */
> +		priv->hw->dma->init(priv->ioaddr, priv->plat->dma_cfg,
> +				    dummy_dma_tx_phy, dummy_dma_rx_phy, atds);
> +

Yet it is used here, still uninitialized.

The compiler even warns about this.
