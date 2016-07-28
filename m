From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: [PATCH 14/15] ethernet: stmicro: stmmac: stmmac_platform: add
 missing of_node_put after calling of_parse_phandle
Date: Thu, 28 Jul 2016 09:39:41 +0200
Message-ID: <5799B6BD.6010304@st.com>
References: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
 <1469586048-15697-15-git-send-email-peter.chen@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <vbridger@opensource.altera.com>,
	<isubramanian@apm.com>, <kchudgar@apm.com>,
	<yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
	<thomas.petazzoni@free-electrons.com>,
	<sergei.shtylyov@cogentembedded.com>, <peppe.cavallaro@st.com>,
	<mugunthanvnm@ti.com>, <tremyfr@gmail.com>, <wxt@rock-chips.com>,
	<arnd@arndb.de>, <david.daney@cavium.com>,
	<huangdaode@hisilicon.com>, <jszhang@marvell.com>
To: Peter Chen <peter.chen@nxp.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:35354 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932760AbcG1Hkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 03:40:47 -0400
In-Reply-To: <1469586048-15697-15-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 07/27/2016 04:20 AM, Peter Chen wrote:
> of_node_put needs to be called when the device node which is got
> from of_parse_phandle has finished using.
>
> Signed-off-by: Peter Chen <peter.chen@nxp.com>
> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index f7dfc0a..8d88782 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -113,8 +113,10 @@ static struct stmmac_axi *stmmac_axi_setup(struct platform_device *pdev)
>   		return NULL;
>
>   	axi = kzalloc(sizeof(*axi), GFP_KERNEL);
> -	if (!axi)
> +	if (!axi) {
> +		of_node_put(np);
>   		return ERR_PTR(-ENOMEM);
> +	}
>
>   	axi->axi_lpi_en = of_property_read_bool(np, "snps,lpi_en");
>   	axi->axi_xit_frm = of_property_read_bool(np, "snps,xit_frm");
> @@ -127,6 +129,7 @@ static struct stmmac_axi *stmmac_axi_setup(struct platform_device *pdev)
>   	of_property_read_u32(np, "snps,wr_osr_lmt", &axi->axi_wr_osr_lmt);
>   	of_property_read_u32(np, "snps,rd_osr_lmt", &axi->axi_rd_osr_lmt);
>   	of_property_read_u32_array(np, "snps,blen", axi->axi_blen, AXI_BLEN);
> +	of_node_put(np);
>
>   	return axi;
>   }
>

I agree with the modification inside stmmac_axi. I just have a question 
about np = pdev->dev.of_node inside stmmac_probe_config_dt (same file). 
We could add a "of_node_put(np)" just before "return plat" ?

Regards

alex
