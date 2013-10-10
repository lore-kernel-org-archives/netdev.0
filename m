From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v2] Stmmac: fix a bug when the clk_csr is euqal to 0x0
Date: Thu, 10 Oct 2013 14:05:41 +0200
Message-ID: <52569815.8020708@st.com>
References: <CAKT61h8=HGL8TvX2LZamXntR4QhM_s8UVdHRhs--kVT2RQ-wDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Wan ZongShun <mcuos.com@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:56267 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752080Ab3JJMFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 08:05:52 -0400
In-Reply-To: <CAKT61h8=HGL8TvX2LZamXntR4QhM_s8UVdHRhs--kVT2RQ-wDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2013 6:40 AM, Wan ZongShun wrote:
> Hi Giuseppe,
>
> According to your advice, I add this new field comments in stmmac.txt.
> And I only make one patch for fix this issue and field comments.

thanks Wan but pls re-send the patch where the comment only reports
what the patch actually does and the fix you are providing.

Put me on CC and remove "Hi Giuseppe"

many thanks
Peppe

>
> Signed-off-by: Wan Zongshun <mcuos.com@gmail.com>
>
> ---
>   Documentation/networking/stmmac.txt               | 3 +++
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>   include/linux/stmmac.h                            | 1 +
>   3 files changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/Documentation/networking/stmmac.txt
> b/Documentation/networking/stmmac.txt
> index 457b8bb..3ed0ea9 100644
> --- a/Documentation/networking/stmmac.txt
> +++ b/Documentation/networking/stmmac.txt
> @@ -116,6 +116,7 @@ struct plat_stmmacenet_data {
>       struct stmmac_mdio_bus_data *mdio_bus_data;
>       struct stmmac_dma_cfg *dma_cfg;
>       int clk_csr;
> +    unsigned int dynamic_mdc_clk_en;
>       int has_gmac;
>       int enh_desc;
>       int tx_coe;
> @@ -148,6 +149,8 @@ Where:
>          GMAC also enables the 4xPBL by default.
>      o fixed_burst/mixed_burst/burst_len
>    o clk_csr: fixed CSR Clock range selection.
> + o dynamic_mdc_clk_en: If it is set to >=1 MDC clk will be selected
> dynamically,
> +               or else you must set a fixed CSR Clock range to clk_src.
>    o has_gmac: uses the GMAC core.
>    o enh_desc: if sets the MAC will use the enhanced descriptor structure.
>    o tx_coe: core is able to perform the tx csum in HW.
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 8d4ccd3..93fc6bc 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2741,7 +2741,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct
> device *device,
>        * set the MDC clock dynamically according to the csr actual
>        * clock input.
>        */
> -    if (!priv->plat->clk_csr)
> +    if (!!priv->plat->dynamic_mdc_clk_en)
>           stmmac_clk_csr_set(priv);
>       else
>           priv->clk_csr = priv->plat->clk_csr;
> diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
> index bb5deb0..1b9f0b5 100644
> --- a/include/linux/stmmac.h
> +++ b/include/linux/stmmac.h
> @@ -101,6 +101,7 @@ struct plat_stmmacenet_data {
>       struct stmmac_mdio_bus_data *mdio_bus_data;
>       struct stmmac_dma_cfg *dma_cfg;
>       int clk_csr;
> +    unsigned int dynamic_mdc_clk_en;
>       int has_gmac;
>       int enh_desc;
>       int tx_coe;
>
