From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: stmmac: fixed enh_desc set always zero
Date: Fri, 28 Jun 2013 14:57:46 +0200
Message-ID: <51CD884A.4030509@st.com>
References: <015801ce73d2$12332070$36996150$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	=?EUC-KR?B?J7HosbnB+Cc=?= <kgene.kim@samsung.com>,
	davem@davemloft.net, cpgs@samsung.com
To: Byungho An <bh74.an@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:47576 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754506Ab3F1M6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 08:58:02 -0400
In-Reply-To: <015801ce73d2$12332070$36996150$%an@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/28/2013 9:35 AM, Byungho An wrote:
> 
> This patch fixed that enh_desc value is always zero.
> Due to calling order of stmmac_selec_desc_mode(), enh_desc value is always zero.
> Even though mac is set to use enhanced dma descriptor, if enh_desc is zero,
> functions related dma descriptor are not working correctly.
> Signed-off-by: Byungho An <bh74.an@samsung.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index e5e221e..40efd55 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2567,9 +2567,6 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
>   	/* Get and dump the chip ID */
>   	priv->synopsys_id = stmmac_get_synopsys_id(priv);
>   
> -	/* To use alternate (extended) or normal descriptor structures */
> -	stmmac_selec_desc_mode(priv);
> -
>   	/* To use the chained or ring mode */
>   	if (chain_mode) {
>   		priv->hw->chain = &chain_mode_ops;
> @@ -2604,6 +2601,9 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
>   	} else
>   		pr_info(" No HW DMA feature register supported");
>   
> +	/* To use alternate (extended) or normal descriptor structures */
> +	stmmac_selec_desc_mode(priv);
> +
>   	ret = priv->hw->mac->rx_ipc(priv->ioaddr);
>   	if (!ret) {
>   		pr_warn(" RX IPC Checksum Offload not configured.\n");
> 
