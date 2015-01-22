From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 3/3] stmmac: Add an optional device tree property "snps,burst_len"
Date: Thu, 22 Jan 2015 09:20:25 +0100
Message-ID: <54C0B2C9.9000907@st.com>
References: <1421909758-31359-1-git-send-email-sonic.adi@gmail.com> <1421909758-31359-3-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	<adi-buildroot-devel@lists.sourceforge.net>,
	Sonic Zhang <sonic.zhang@analog.com>
To: Sonic Zhang <sonic.adi@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:41045 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751401AbbAVIUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 03:20:44 -0500
In-Reply-To: <1421909758-31359-3-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/22/2015 7:55 AM, Sonic Zhang wrote:
> From: Sonic Zhang <sonic.zhang@analog.com>
>
> This property define the AXI bug lenth.

Hello

I can accept this patch for now. So thx :-)

FYI, I will send a set of patches to program the AXI Bus mode
register providing more parameters from DT.

Peppe

>
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> ---
>   Documentation/devicetree/bindings/net/stmmac.txt   |    1 +
>   .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    3 +++
>   2 files changed, 4 insertions(+)
>
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> index c41afd9..8ca65ce 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -43,6 +43,7 @@ Optional properties:
>     available this clock is used for programming the Timestamp Addend Register.
>     If not passed then the system clock will be used and this is fine on some
>     platforms.
> +- snps,burst_len: The AXI burst lenth value of the AXI BUS MODE register.
>
>   Examples:
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 3039de2..a20cf0d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -234,6 +234,9 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
>   			of_property_read_bool(np, "snps,fixed-burst");
>   		dma_cfg->mixed_burst =
>   			of_property_read_bool(np, "snps,mixed-burst");
> +		of_property_read_u32(np, "snps,burst_len", &dma_cfg->burst_len);
> +		if (dma_cfg->burst_len < 0 || dma_cfg->burst_len > 256)
> +			dma_cfg->burst_len = 0;
>   	}
>   	plat->force_thresh_dma_mode = of_property_read_bool(np, "snps,force_thresh_dma_mode");
>   	if (plat->force_thresh_dma_mode) {
>
