From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 2/3] net: stmmac: Fix error handling path in
 'alloc_dma_tx_desc_resources()'
Date: Mon, 10 Jul 2017 08:22:06 +0200
Message-ID: <ad14c503-684d-b4dc-6a9b-53e5c5a92688@st.com>
References: <cover.1499499451.git.christophe.jaillet@wanadoo.fr>
 <41bce9018e1acec009ed184ba238f495a678297e.1499499451.git.christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
        <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:52537 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752276AbdGJGWO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 02:22:14 -0400
In-Reply-To: <41bce9018e1acec009ed184ba238f495a678297e.1499499451.git.christophe.jaillet@wanadoo.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/8/2017 9:46 AM, Christophe JAILLET wrote:
> If the first 'kmalloc_array' within the loop fails, we should free what
> as already been allocated, as done in all other error handling path.
>
> Fixes: ce736788e8a9 ("net: stmmac: adding multiple buffers for TX")
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 4322fa4a13e8..07d486a70118 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1561,7 +1561,7 @@ static int alloc_dma_tx_desc_resources(struct stmmac_priv *priv)
>   						    sizeof(*tx_q->tx_skbuff_dma),
>   						    GFP_KERNEL);
>   		if (!tx_q->tx_skbuff_dma)
> -			return -ENOMEM;
> +			goto err_dma_buffers;
>   
>   		tx_q->tx_skbuff = kmalloc_array(DMA_TX_SIZE,
>   						sizeof(struct sk_buff *),
