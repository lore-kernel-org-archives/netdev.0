From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH] net: ethernet: ti: davinci_cpdma: fix fixed prio cpdma
 ctlr configuration
Date: Wed, 9 Nov 2016 15:09:22 -0600
Message-ID: <a20ab87c-4f9d-0eaa-e486-156d9f359866@ti.com>
References: <1478610656-24634-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        <mugunthanvnm@ti.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478610656-24634-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/08/2016 07:10 AM, Ivan Khoronzhuk wrote:
> The dma ctlr is reseted to 0 while cpdma start, thus cpdma ctlr

I assume this is because cpdma_ctlr_start() does soft reset. Is it correct?

> cannot be configured after cpdma is stopped. So, restore content
> of cpdma ctlr while off/on procedure.
> 
> Based on net-next/master

^ remove it

> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> ---
>  drivers/net/ethernet/ti/cpsw.c          |   6 +-
>  drivers/net/ethernet/ti/davinci_cpdma.c | 103 +++++++++++++++++---------------
>  drivers/net/ethernet/ti/davinci_cpdma.h |   2 +
>  3 files changed, 58 insertions(+), 53 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index b1ddf89..4d04b8e 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1376,10 +1376,6 @@ static int cpsw_ndo_open(struct net_device *ndev)
>  				  ALE_ALL_PORTS, ALE_ALL_PORTS, 0, 0);
>  
>  	if (!cpsw_common_res_usage_state(cpsw)) {
> -		/* setup tx dma to fixed prio and zero offset */
> -		cpdma_control_set(cpsw->dma, CPDMA_TX_PRIO_FIXED, 1);
> -		cpdma_control_set(cpsw->dma, CPDMA_RX_BUFFER_OFFSET, 0);
> -
>  		/* disable priority elevation */
>  		__raw_writel(0, &cpsw->regs->ptype);
>  
> @@ -2710,6 +2706,8 @@ static int cpsw_probe(struct platform_device *pdev)
>  	dma_params.desc_align		= 16;
>  	dma_params.has_ext_regs		= true;
>  	dma_params.desc_hw_addr         = dma_params.desc_mem_phys;
> +	dma_params.rxbuf_offset		= 0;
> +	dma_params.fixed_prio		= 1;

Do we really need this new parameters? Do you have plans to use other values?


-- 
regards,
-grygorii
