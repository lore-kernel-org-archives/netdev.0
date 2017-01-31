From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 15/17] net: stmmac: remove dead code in stmmac_tx_clean
Date: Tue, 31 Jan 2017 11:21:51 +0100
Message-ID: <e134b132-f6e7-17c9-453b-acffec785241@st.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
 <20170131091152.13842-16-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:45409 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750998AbdAaKjJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 05:39:09 -0500
In-Reply-To: <20170131091152.13842-16-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/31/2017 10:11 AM, Corentin Labbe wrote:
> Since commit cf32deec16e4 ("stmmac: add tx_skbuff_dma to save descriptors used by PTP"),
> the struct dma_desc *p in stmmac_tx_clean was not used at all.
>
> This patch remove this dead code.
>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 7 -------
>  1 file changed, 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 3d52b8c..b494bc2 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1124,13 +1124,6 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
>  	int i;
>
>  	for (i = 0; i < DMA_TX_SIZE; i++) {
> -		struct dma_desc *p;
> -
> -		if (priv->extend_desc)
> -			p = &((priv->dma_etx + i)->basic);
> -		else
> -			p = priv->dma_tx + i;
> -
>  		if (priv->tx_skbuff_dma[i].buf) {
>  			if (priv->tx_skbuff_dma[i].map_as_page)
>  				dma_unmap_page(priv->device,
>
