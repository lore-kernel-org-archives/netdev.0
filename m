From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH 2/3] net: stmmac: Restore DT backwards-compatibility
Date: Tue, 21 Mar 2017 15:14:19 +0000
Message-ID: <50db4ab4-ff7b-ca01-c266-d37ee02ac8f0@synopsys.com>
References: <20170321151211.31841-1-thierry.reding@gmail.com>
 <20170321151211.31841-2-thierry.reding@gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170321151211.31841-2-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Às 3:12 PM de 3/21/2017, Thierry Reding escreveu:
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
> 

Acked-By: Joao Pinto <jpinto@synopsys.com>
