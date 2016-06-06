From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Subject: Re: [PATCH] net: stmmac: dwmac-rk: keep PHY up for WoL
Date: Mon, 06 Jun 2016 22:45:11 +0200
Message-ID: <1922621.IgQfJVQxEA@diego>
References: <1464974960-26672-1-git-send-email-vpalatin@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexandre Torgue <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: Vincent Palatin <vpalatin@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464974960-26672-1-git-send-email-vpalatin@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Am Freitag, 3. Juni 2016, 10:29:20 schrieb Vincent Palatin:
> Do not shutdown the PHY if Wake-on-Lan is enabled, else it cannot wake
> us up.
> 
> Signed-off-by: Vincent Palatin <vpalatin@chromium.org>
> ---
>  drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
> b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c index 0cd3ecf..2e45e75
> 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
> @@ -534,6 +534,10 @@ static int rk_gmac_init(struct platform_device *pdev,
> void *priv) struct rk_priv_data *bsp_priv = priv;
>  	int ret;
> 
> +	/* Keep the PHY up if we use Wake-on-Lan. */
> +	if (device_may_wakeup(&pdev->dev))
> +		return 0;
> +

Hmm, this looks like it would also block the initial setup of clocks and phy?
platform_device + device struct are created before probe gets called, so 
something could set the wakeup flag before the driver initially probes?


Confused,
Heiko
