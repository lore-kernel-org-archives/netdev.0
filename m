From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 1/7] stmmac: review napi gro support
Date: Wed, 3 Apr 2013 17:01:53 +0100
Message-ID: <1365004913.2897.5.camel@bwh-desktop.uk.solarflarecom.com>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38260 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762165Ab3DCQB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 12:01:56 -0400
In-Reply-To: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-03 at 07:41 +0200, Giuseppe CAVALLARO wrote:
> This patch is to:
> o use napi_gro_flush() before calling __napi_complete()

napi_complete() already does that, and some other important things.  Why
do you think it makes sense to call __napi_complete() directly?

Ben.

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
>  	return work_done;
> @@ -2586,7 +2587,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>  
>  	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>  			    NETIF_F_RXCSUM;
> -	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
> +	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA | NETIF_F_GRO;
>  	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
>  #ifdef STMMAC_VLAN_TAG_USED
>  	/* Both mac100 and gmac support receive VLAN tag detection */

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
