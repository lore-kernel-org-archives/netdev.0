From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: stmmac: dwmac-rk: keep PHY up for WoL
Date: Tue, 7 Jun 2016 09:23:09 +0200
Message-ID: <f543c3e1-fa55-a6fd-c916-cf043e562ec2@st.com>
References: <1464974960-26672-1-git-send-email-vpalatin@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	Alexandre Torgue <alexandre.torgue@st.com>,
	=?UTF-8?Q?Heiko_St=c3=bcbner?= <heiko@sntech.de>
To: Vincent Palatin <vpalatin@chromium.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464974960-26672-1-git-send-email-vpalatin@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

On 6/3/2016 7:29 PM, Vincent Palatin wrote:
> Do not shutdown the PHY if Wake-on-Lan is enabled, else it cannot wake
> us up.
>

I do not understand why you need that.
This is done inside the PHY layer and it is tested on our platforms
he idea is: If the parent wants to Wake the system then the PHY should
not power-down.

Peppe

> Signed-off-by: Vincent Palatin <vpalatin@chromium.org>
> ---
>  drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
> index 0cd3ecf..2e45e75 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
> @@ -534,6 +534,10 @@ static int rk_gmac_init(struct platform_device *pdev, void *priv)
>  	struct rk_priv_data *bsp_priv = priv;
>  	int ret;
>
> +	/* Keep the PHY up if we use Wake-on-Lan. */
> +	if (device_may_wakeup(&pdev->dev))
> +		return 0;
> +
>  	ret = phy_power_on(bsp_priv, true);
>  	if (ret)
>  		return ret;
> @@ -549,6 +553,10 @@ static void rk_gmac_exit(struct platform_device *pdev, void *priv)
>  {
>  	struct rk_priv_data *gmac = priv;
>
> +	/* The PHY was up for Wake-on-Lan. */
> +	if (device_may_wakeup(&pdev->dev))
> +		return;
> +
>  	phy_power_on(gmac, false);
>  	gmac_clk_enable(gmac, false);
>  }
>
