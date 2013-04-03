From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next.git 1/7] stmmac: review napi gro support
Date: Wed, 03 Apr 2013 00:05:15 -0700
Message-ID: <1364972715.5113.197.camel@edumazet-glaptop>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:45728 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762262Ab3DCHFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 03:05:18 -0400
Received: by mail-pb0-f41.google.com with SMTP id mc17so695036pbc.14
        for <netdev@vger.kernel.org>; Wed, 03 Apr 2013 00:05:18 -0700 (PDT)
In-Reply-To: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-03 at 07:41 +0200, Giuseppe CAVALLARO wrote:
> This patch is to:
> o use napi_gro_flush() before calling __napi_complete()
> o turn on NETIF_F_GRO by default
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 6b26d31..8b69e3b 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2046,7 +2046,8 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
>  
>  	work_done = stmmac_rx(priv, budget);
>  	if (work_done < budget) {
> -		napi_complete(napi);
> +		napi_gro_flush(napi, false);
> +		__napi_complete(napi);
>  		stmmac_enable_dma_irq(priv);
>  	}

Why are you doing this ?

This adds a (fatal) race.
