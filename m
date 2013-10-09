From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] Stmmac: fix a bug when clk_csr == 0x0
Date: Wed, 9 Oct 2013 16:43:46 +0200
Message-ID: <52556BA2.1080004@st.com>
References: <CAKT61h8mcj1Gvp1i8xkM_NS2+fv1WhPtCQaFq7mi=i=JUqT4Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Wan ZongShun <mcuos.com@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:46406 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751959Ab3JIPQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 11:16:41 -0400
In-Reply-To: <CAKT61h8mcj1Gvp1i8xkM_NS2+fv1WhPtCQaFq7mi=i=JUqT4Uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello

On 10/9/2013 4:37 AM, Wan ZongShun wrote:
> Hi Giuseppe,
>
> According to spec, if csr clock freq is 60-100Mhz, we have to set CR[5:2] = 0000
> but when I set the 'plat_dat.clk_csr = 0',acctually, this value is not used
> since the driver code judge 'if (!priv->plat->clk_csr)' then go to dynamic tune
> the MDC clock. So I add other judge condition.

yes, and true in case of 60-100Mhz... I don't know if this was actually
tested on SPEAr long time ago.

Pls document the new platform field in the stmmac.txt or find a way
to reuse the clk_csr (maybe not the case)

peppe

>
> Signed-off-by: Wan Zongshun <mcuos.com@gmail.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>   include/linux/stmmac.h                            | 1 +
>   2 files changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 8d4ccd3..a849092c 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2741,7 +2741,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct
> device *device,
>        * set the MDC clock dynamically according to the csr actual
>        * clock input.
>        */
> -    if (!priv->plat->clk_csr)
> +    if (priv->plat->dynamic_mdc_clk_en)
>           stmmac_clk_csr_set(priv);
>       else
>           priv->clk_csr = priv->plat->clk_csr;
> diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
> index bb5deb0..e2552ce 100644
> --- a/include/linux/stmmac.h
> +++ b/include/linux/stmmac.h
> @@ -101,6 +101,7 @@ struct plat_stmmacenet_data {
>       struct stmmac_mdio_bus_data *mdio_bus_data;
>       struct stmmac_dma_cfg *dma_cfg;
>       int clk_csr;
> +    int dynamic_mdc_clk_en;
>       int has_gmac;
>       int enh_desc;
>       int tx_coe;
>
