From: Mikko Perttunen <cyndis@kapsi.fi>
Subject: Re: [PATCH 4/7] net: stmmac: Parse FIFO sizes from feature registers
Date: Mon, 27 Feb 2017 11:51:25 +0200
Message-ID: <0b40b953-8fde-6351-a571-556943d78ecb@kapsi.fi>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
 <20170223172438.14770-5-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Alexandre Courbot <gnurou@gmail.com>,
        Jon Hunter <jonathanh@nvidia.com>, netdev@vger.kernel.org,
        linux-tegra@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thierry Reding <thierry.reding@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170223172438.14770-5-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23.02.2017 19:24, Thierry Reding wrote:
> From: Thierry Reding <treding@nvidia.com>
>
> New version of this core encode the FIFO sizes in one of the feature
> registers. Use these sizes as default, but still allow device tree to
> override them for backwards compatibility.
>
> Signed-off-by: Thierry Reding <treding@nvidia.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/common.h      | 3 +++
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c  | 2 ++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 3 +++
>  3 files changed, 8 insertions(+)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
> index 144fe84e8a53..6ac653845d82 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -324,6 +324,9 @@ struct dma_features {
>  	unsigned int number_tx_queues;
>  	/* Alternate (enhanced) DESC mode */
>  	unsigned int enh_desc;
> +	/* TX and RX FIFO sizes */
> +	unsigned int tx_fifo_size;
> +	unsigned int rx_fifo_size;
>  };
>
>  /* GMAC TX FIFO is 8K, Rx FIFO is 16K */
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> index 377d1b44d4f2..8d249f3b34c8 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> @@ -296,6 +296,8 @@ static void dwmac4_get_hw_feature(void __iomem *ioaddr,
>  	hw_cap = readl(ioaddr + GMAC_HW_FEATURE1);
>  	dma_cap->av = (hw_cap & GMAC_HW_FEAT_AVSEL) >> 20;
>  	dma_cap->tsoen = (hw_cap & GMAC_HW_TSOEN) >> 18;
> +	dma_cap->tx_fifo_size = 128 << ((hw_cap >> 6) & 0x1f);
> +	dma_cap->rx_fifo_size = 128 << ((hw_cap >> 0) & 0x1f);
>  	/* MAC HW feature2 */
>  	hw_cap = readl(ioaddr + GMAC_HW_FEATURE2);
>  	/* TX and RX number of channels */
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index d7387919bdb6..291e34f0ca94 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1281,6 +1281,9 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
>  {
>  	int rxfifosz = priv->plat->rx_fifo_size;
>
> +	if (rxfifosz == 0)
> +		rxfifosz = priv->dma_cap.rx_fifo_size;
> +
>  	if (priv->plat->force_thresh_dma_mode)
>  		priv->hw->dma->dma_mode(priv->ioaddr, tc, tc, rxfifosz);
>  	else if (priv->plat->force_sf_dma_mode || priv->plat->tx_coe) {
>

Reviewed-by: Mikko Perttunen <mperttunen@nvidia.com>
