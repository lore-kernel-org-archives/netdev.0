From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH] stmmac: hardware TX COE doesn't work when
 force_thresh_dma_mode is set
Date: Mon, 16 May 2016 19:47:44 +0200
Message-ID: <CAGhQ9Vzuer6WkZNUmoEmDYgK1wuw3z_8a5jeMSL76xX6VuTk8g@mail.gmail.com>
References: <1463413267-19543-1-git-send-email-ezequiel@vanguardiasur.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"peppe.cavallaro" <peppe.cavallaro@st.com>,
	alexandre.torgue@st.com, David Miller <davem@davemloft.net>
To: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32897 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754419AbcEPRrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 13:47:45 -0400
Received: by mail-io0-f195.google.com with SMTP id x35so27653660ioi.0
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 10:47:44 -0700 (PDT)
In-Reply-To: <1463413267-19543-1-git-send-email-ezequiel@vanguardiasur.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ezequiel,

On 16 May 2016 at 17:41, Ezequiel Garcia <ezequiel@vanguardiasur.com.ar> wrote:
> Commit f748be531d70 ("stmmac: support new GMAC4") reverted a previous fix
> by mistake. This commit re-applies said fix:
>
>   commit dec2165ff38a99f937fe61875d102c6c8596c815
>   Author: Sonic Zhang <sonic.zhang@analog.com>
>   Date:   Thu Jan 22 14:55:57 2015 +0800
>   stmmac: hardware TX COE doesn't work when force_thresh_dma_mode is set
>
>   Clear the TX COE bit when force_thresh_dma_mode is set even hardware
>   dma capability says support.
>
>   Tested on BF609.
>
>   Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>   Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>   Signed-off-by: David S. Miller <davem@davemloft.net>
>
> Tested on LPC4350 Hitex board.
>
> Fixes: f748be531d70 ("stmmac: support new GMAC4")
> Signed-off-by: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index fd5ab7bfdb76..eac45d0c75e2 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -3131,7 +3131,12 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
>                 priv->plat->enh_desc = priv->dma_cap.enh_desc;
>                 priv->plat->pmt = priv->dma_cap.pmt_remote_wake_up;
>
> -               priv->plat->tx_coe = priv->dma_cap.tx_coe;
> +               /* TXCOE doesn't work in thresh DMA mode */
> +               if (priv->plat->force_thresh_dma_mode)
> +                       priv->plat->tx_coe = 0;
> +               else
> +                       priv->plat->tx_coe = priv->dma_cap.tx_coe;
> +
>                 /* In case of GMAC4 rx_coe is from HW cap register. */
>                 priv->plat->rx_coe = priv->dma_cap.rx_coe;

Works for me on EA4357 board together with another patch to fix the DT
properties for DWMAC on lpc18xx.

Tested-by: Joachim Eastwood <manabian@gmail.com>


regards,
Joachim Eastwood
