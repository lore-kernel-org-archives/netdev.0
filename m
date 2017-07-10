From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 3/3] net: stmmac: Make 'alloc_dma_[rt]x_desc_resources()'
 look even closer
Date: Mon, 10 Jul 2017 08:22:50 +0200
Message-ID: <68a04948-2a52-56d4-1875-d15540808eed@st.com>
References: <cover.1499499451.git.christophe.jaillet@wanadoo.fr>
 <ea4badb176e009c7485ea4ab83bbe29cd3750d90.1499499451.git.christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
        <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ea4badb176e009c7485ea4ab83bbe29cd3750d90.1499499451.git.christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/8/2017 9:46 AM, Christophe JAILLET wrote:
> 'alloc_dma_[rt]x_desc_resources()' functions look very close.
> Remove a useless initialization and use the same label name for error
> handling path in order to get them even closer.
>
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 12 ++++++------
>   1 file changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 07d486a70118..1853f7ff6657 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1449,7 +1449,7 @@ static void free_dma_rx_desc_resources(struct stmmac_priv *priv)
>   static void free_dma_tx_desc_resources(struct stmmac_priv *priv)
>   {
>   	u32 tx_count = priv->plat->tx_queues_to_use;
> -	u32 queue = 0;
> +	u32 queue;
>   
>   	/* Free TX queue resources */
>   	for (queue = 0; queue < tx_count; queue++) {
> @@ -1561,13 +1561,13 @@ static int alloc_dma_tx_desc_resources(struct stmmac_priv *priv)
>   						    sizeof(*tx_q->tx_skbuff_dma),
>   						    GFP_KERNEL);
>   		if (!tx_q->tx_skbuff_dma)
> -			goto err_dma_buffers;
> +			goto err_dma;
>   
>   		tx_q->tx_skbuff = kmalloc_array(DMA_TX_SIZE,
>   						sizeof(struct sk_buff *),
>   						GFP_KERNEL);
>   		if (!tx_q->tx_skbuff)
> -			goto err_dma_buffers;
> +			goto err_dma;
>   
>   		if (priv->extend_desc) {
>   			tx_q->dma_etx = dma_zalloc_coherent(priv->device,
> @@ -1577,7 +1577,7 @@ static int alloc_dma_tx_desc_resources(struct stmmac_priv *priv)
>   							    &tx_q->dma_tx_phy,
>   							    GFP_KERNEL);
>   			if (!tx_q->dma_etx)
> -				goto err_dma_buffers;
> +				goto err_dma;
>   		} else {
>   			tx_q->dma_tx = dma_zalloc_coherent(priv->device,
>   							   DMA_TX_SIZE *
> @@ -1586,13 +1586,13 @@ static int alloc_dma_tx_desc_resources(struct stmmac_priv *priv)
>   							   &tx_q->dma_tx_phy,
>   							   GFP_KERNEL);
>   			if (!tx_q->dma_tx)
> -				goto err_dma_buffers;
> +				goto err_dma;
>   		}
>   	}
>   
>   	return 0;
>   
> -err_dma_buffers:
> +err_dma:
>   	free_dma_tx_desc_resources(priv);
>   
>   	return ret;
