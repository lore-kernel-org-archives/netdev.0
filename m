From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH 2/3] net: stmmac: Restore DT backwards-compatibility
Date: Wed, 22 Mar 2017 13:38:38 +0100
Message-ID: <20170322123838.GB24523@Red>
References: <20170321151211.31841-1-thierry.reding@gmail.com>
 <20170321151211.31841-2-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Thierry Reding <thierry.reding@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34767 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752391AbdCVMin (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 08:38:43 -0400
Content-Disposition: inline
In-Reply-To: <20170321151211.31841-2-thierry.reding@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 21, 2017 at 04:12:10PM +0100, Thierry Reding wrote:
> From: Thierry Reding <treding@nvidia.com>
> 
> Recent changes to support multiple queues in the device tree bindings
> resulted in the number of RX and TX queues to be initialized to zero for
> device trees not adhering to the new bindings.
> 
> Restore backwards-compatibility with those device trees by falling back
> to a single RX and TX queues each.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 37f550ae76a5..74b0aff79b25 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -143,6 +143,13 @@ static void stmmac_mtl_setup(struct platform_device *pdev,
>  	struct device_node *tx_node;
>  	u8 queue = 0;
>  
> +	/* For backwards-compatibility with device trees that don't have any
> +	 * snps,mtl-rx-config or snps,mtl-tx-config properties, we fall back
> +	 * to one RX and TX queues each.
> +	 */
> +	plat->rx_queues_to_use = 1;
> +	plat->tx_queues_to_use = 1;
> +
>  	rx_node = of_parse_phandle(pdev->dev.of_node, "snps,mtl-rx-config", 0);
>  	if (!rx_node)
>  		return;
> -- 
> 2.12.0
> 

Tested-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Fix one of the reported problem on dwmac-sunxi and dwmac-sun8i
Regards
