From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH 3/6] net: davinci_emac: Free clock after checking the
 frequency
Date: Tue, 13 Jan 2015 13:48:24 -0600
Message-ID: <54B57688.6000908@amd.com>
References: <1421177368-19756-1-git-send-email-tony@atomide.com>
 <1421177368-19756-4-git-send-email-tony@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	Brian Hutchinson <b.hutchman@gmail.com>,
	Felipe Balbi <balbi@ti.com>
To: Tony Lindgren <tony@atomide.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1421177368-19756-4-git-send-email-tony@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/13/2015 01:29 PM, Tony Lindgren wrote:
> We only use clk_get() to get the frequency, the rest is done by
> the runtime PM calls. Let's free the clock too.
>
> Cc: Brian Hutchinson <b.hutchman@gmail.com>
> Cc: Felipe Balbi <balbi@ti.com>
> Signed-off-by: Tony Lindgren <tony@atomide.com>
> ---
>   drivers/net/ethernet/ti/davinci_emac.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
> index deb43b3..e9efc74 100644
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
> @@ -1881,6 +1881,7 @@ static int davinci_emac_probe(struct platform_device *pdev)
>   		return -EBUSY;
>   	}
>   	emac_bus_frequency = clk_get_rate(emac_clk);
> +	clk_put(emac_clk);

The devm_clk_get call is used to get the clock so either a devm_clk_put
needs to be used here or just let the devm_ call do its thing and
automatically do the put when the module is unloaded.

Thanks,
Tom

>
>   	/* TODO: Probe PHY here if possible */
>
>
