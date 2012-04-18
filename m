From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: fix kernel crash when device probed for SPEAr
 with DT
Date: Wed, 18 Apr 2012 07:11:08 +0200
Message-ID: <4F8E4CEC.9050002@st.com>
References: <91ea900ce78bb2054d83e0575c16ac70f3f11511.1334654597.git.viresh.kumar@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: spear-devel@list.st.com, viresh.linux@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	Deepak SIKRI <deepak.sikri@st.com>
To: Viresh KUMAR <viresh.kumar@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:51837 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750792Ab2DRFNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 01:13:22 -0400
In-Reply-To: <91ea900ce78bb2054d83e0575c16ac70f3f11511.1334654597.git.viresh.kumar@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Viresh

On 4/17/2012 11:24 AM, Viresh KUMAR wrote:
> plat->dma_cfg is never allocated memory and is tried to be filled when we boot
> it for SPEAr SoCs with DT. And so get a kernel crash.
> 
> Fix it by allocating memory for dma_cfg.

The fix seems to be legal but I'd like to do a review of the code again.
I was reluctant to add the dma_cfg because it had a big impact on
several platforms etc (as discussed with SPEAr guys). I accepted it
because logically correct and tidied-up the code, indeed.
I hoped it was fully tested on SPEAr platforms. at any rate, I'll look
at you patch and perform some tests on my boards and then come-back to you.

Kind Regards
Peppe

> 
> Signed-off-by: Viresh Kumar <viresh.kumar@st.com>
> ---
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 12bd221..f124f60 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -110,6 +110,14 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
>  			goto out_unmap;
>  		}
>  
> +		plat_dat->dma_cfg = devm_kzalloc(&pdev->dev,
> +				sizeof(*plat_dat->dma_cfg), GFP_KERNEL);
> +		if (!plat_dat->dma_cfg) {
> +			pr_err("%s: ERROR: no memory for dma_cfg", __func__);
> +			ret = -ENOMEM;
> +			goto out_unmap;
> +		}
> +
>  		ret = stmmac_probe_config_dt(pdev, plat_dat, &mac);
>  		if (ret) {
>  			pr_err("%s: main dt probe failed", __func__);
