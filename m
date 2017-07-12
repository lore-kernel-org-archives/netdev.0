From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/4] net-next: mediatek: add platform data to
 adapt into various hardware
Date: Tue, 11 Jul 2017 21:19:49 -0700
Message-ID: <2ab410a6-bf08-79bc-28ca-e05eb8b67cf5@gmail.com>
References: <cover.1499829241.git.sean.wang@mediatek.com>
 <401e9fa04ea4759c936fa5af11bb2b5c97ef14f0.1499829241.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org
To: sean.wang@mediatek.com, john@phrozen.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <401e9fa04ea4759c936fa5af11bb2b5c97ef14f0.1499829241.git.sean.wang@mediatek.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/11/2017 08:37 PM, sean.wang@mediatek.com wrote:
> From: Sean Wang <sean.wang@mediatek.com>
> 
> This patch is the preparation patch in order to adapt into various
> hardware through adding platform data which holds specific characteristics
> among MediaTek SoCs and introducing the unified clock handler for those
> distinct clock requirements depending on different features such as
> TRGMII and SGMII getting support on the target SoC. And finally, add
> enhancement with given the generic description for Kconfig and remove the
> unnecessary machine type dependency in Makefile.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> ---

>  	if (dev->phydev->link)
> @@ -1837,6 +1838,39 @@ static void ethsys_reset(struct mtk_eth *eth, u32 reset_bits)
>  	mdelay(10);
>  }
>  
> +static void mtk_clk_disable(struct mtk_eth *eth)
> +{
> +	int clk;
> +
> +	for (clk = MTK_CLK_MAX - 1; clk >= 0; clk--) {
> +		if (eth->clks[clk])
> +			clk_disable_unprepare(eth->clks[clk]);
> +	}

The clock framework works just fine with NULL clk references, no need to
check that.

> +}

There are now (or will be soon in clk-next) bulk accessors that you may
consider using for this.

> +
> +static int mtk_clk_enable(struct mtk_eth *eth)
> +{
> +	int clk, ret;
> +
> +	for (clk = 0; clk < MTK_CLK_MAX ; clk++) {
> +		if (eth->clks[clk]) {
> +			ret = clk_prepare_enable(eth->clks[clk]);
> +			if (ret)
> +				goto err_disable_clks;
> +		}
> +	}

Same here.
-- 
Florian
