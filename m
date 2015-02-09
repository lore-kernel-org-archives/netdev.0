From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 3/3] stmmac: Add AXI burst length support to platform
 device.
Date: Mon, 9 Feb 2015 12:04:43 +0000
Message-ID: <20150209120443.GF4250@leverpostej>
References: <1423285636-8623-1-git-send-email-cbz@baozis.org>
 <1423285636-8623-4-git-send-email-cbz@baozis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chen Baozi <cbz@baozis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1423285636-8623-4-git-send-email-cbz@baozis.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 07, 2015 at 05:07:16AM +0000, Chen Baozi wrote:
> The AXI Bus Mode Register controls the AXI master behavior. It is mainly
> used to control the burst splitting and the number of outstanding requests.
> This register is present and valid only in GMAC-AXI configuration. The old
> driver only supports this feature on PCI devices. This patch adds an
> 'snps,apl' properties in DT to enable it on platform devices.
> 
> Signed-off-by: Chen Baozi <chenbaozi@kylinos.com.cn>
> ---
>  Documentation/devicetree/bindings/net/stmmac.txt      | 1 +
>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> index c41afd9..8f3c834 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -43,6 +43,7 @@ Optional properties:
>    available this clock is used for programming the Timestamp Addend Register.
>    If not passed then the system clock will be used and this is fine on some
>    platforms.
> +- snps,abl: AXI Burst Length

This is not a good name (though I see it follows "snps,pbl", which is
also not a good name)...

Why does this need to be in the DT? Is this required for correctness? Or
performance?

Thanks,
Mark.

>  
>  Examples:
>  
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 3039de2..abbc897 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -230,6 +230,7 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
>  			return -ENOMEM;
>  		plat->dma_cfg = dma_cfg;
>  		of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl);
> +		of_property_read_u32(np, "snps,abl", &dma_cfg->burst_len);
>  		dma_cfg->fixed_burst =
>  			of_property_read_bool(np, "snps,fixed-burst");
>  		dma_cfg->mixed_burst =
> -- 
> 2.1.4
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 
