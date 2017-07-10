From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 1/3] net: stmmac: Fix error handling path in
 'alloc_dma_rx_desc_resources()'
Date: Mon, 10 Jul 2017 08:21:50 +0200
Message-ID: <fce9a8f9-437b-2c14-a733-d8ec956f66c8@st.com>
References: <cover.1499499451.git.christophe.jaillet@wanadoo.fr>
 <12c5a0a87b6ef1ae40e35e247703082a671f2934.1499499451.git.christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
        <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <12c5a0a87b6ef1ae40e35e247703082a671f2934.1499499451.git.christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/8/2017 9:46 AM, Christophe JAILLET wrote:
> If the first 'kmalloc_array' within the loop fails, we should free what
> as already been allocated, as done in all other error handling path.
>
> Fixes: 54139cf3bb33 ("net: stmmac: adding multiple buffers for rx")
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 19bba6281dab..4322fa4a13e8 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1498,7 +1498,7 @@ static int alloc_dma_rx_desc_resources(struct stmmac_priv *priv)
>   						    sizeof(dma_addr_t),
>   						    GFP_KERNEL);
>   		if (!rx_q->rx_skbuff_dma)
> -			return -ENOMEM;
> +			goto err_dma;
>   
>   		rx_q->rx_skbuff = kmalloc_array(DMA_RX_SIZE,
>   						sizeof(struct sk_buff *),
