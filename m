From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: stmmac: Fix null-function call in ISR on stmmac1000
Date: Mon, 27 Jun 2016 07:50:30 +0200
Message-ID: <a5e5b8ed-9022-7de5-689b-6ea6e8f7a2e4@st.com>
References: <E5152E61-5896-46FD-BF4A-16CDFB3796F6@bluematt.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
	<netdev@vger.kernel.org>, <martin.blumenstingl@googlemail.com>
To: Matt Corallo <linux@bluematt.me>,
	<linux-amlogic@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:63298 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751644AbcF0FvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 01:51:04 -0400
In-Reply-To: <E5152E61-5896-46FD-BF4A-16CDFB3796F6@bluematt.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Matt for the fix

On 6/25/2016 9:35 PM, Matt Corallo wrote:
> At least on Meson GXBB, the CORE_IRQ_MTL_RX_OVERFLOW interrupt is thrown
> with the stmmac1000 driver, which does not support set_rx_tail_ptr. With
> this patch and the clock fixes, 1G ethernet works on ODROID-C2.
>
> Signed-off-by: Matt Corallo <git@bluematt.me>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index a473c18..e407126 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2804,7 +2804,7 @@ static irqreturn_t stmmac_interrupt(int irq, void
> *dev_id)
>  				priv->tx_path_in_lpi_mode = true;
>  			if (status & CORE_IRQ_TX_PATH_EXIT_LPI_MODE)
>  				priv->tx_path_in_lpi_mode = false;
> -			if (status & CORE_IRQ_MTL_RX_OVERFLOW)
> +			if (status & CORE_IRQ_MTL_RX_OVERFLOW && priv->hw->dma->set_rx_tail_ptr)
>  				priv->hw->dma->set_rx_tail_ptr(priv->ioaddr,
>  							priv->rx_tail_addr,
>  							STMMAC_CHAN0);
>
