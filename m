From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH 2/7] net: stmmac: Balance PTP reference clock
 enable/disable
Date: Thu, 2 Mar 2017 14:47:15 +0000
Message-ID: <72ef0b76-0b36-0849-dc54-6efa6ffcda53@synopsys.com>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
 <20170223172438.14770-3-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        "Alexandre Courbot" <gnurou@gmail.com>,
        Jon Hunter <jonathanh@nvidia.com>, <netdev@vger.kernel.org>,
        <linux-tegra@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Thierry Reding <thierry.reding@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170223172438.14770-3-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Às 5:24 PM de 2/23/2017, Thierry Reding escreveu:
> From: Thierry Reding <treding@nvidia.com>
> 
> clk_prepare_enable() and clk_disable_unprepare() for this clock aren't
> properly balanced, which can trigger a WARN_ON() in the common clock
> framework.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 4 ++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 -
>  2 files changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 3cbe09682afe..6b7a5ce19589 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1711,6 +1711,10 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
>  	stmmac_mmc_setup(priv);
>  
>  	if (init_ptp) {
> +		ret = clk_prepare_enable(priv->plat->clk_ptp_ref);
> +		if (ret < 0)
> +			netdev_warn(priv->dev, "failed to enable PTP reference clock: %d\n", ret);
> +
>  		ret = stmmac_init_ptp(priv);
>  		if (ret == -EOPNOTSUPP)
>  			netdev_warn(priv->dev, "PTP not supported by HW\n");
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 5b18355c0d2b..d285d6cfbd0d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -365,7 +365,6 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
>  		plat->clk_ptp_ref = NULL;
>  		dev_warn(&pdev->dev, "PTP uses main clock\n");
>  	} else {
> -		clk_prepare_enable(plat->clk_ptp_ref);
>  		plat->clk_ptp_rate = clk_get_rate(plat->clk_ptp_ref);
>  		dev_dbg(&pdev->dev, "PTP rate %d\n", plat->clk_ptp_rate);
>  	}
> 

Reviewed-By: Joao Pinto <jpinto@synopsys.com>
