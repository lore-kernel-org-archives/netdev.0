From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: micrel: don't do clock-mode-select if we got
 NULL clock
Date: Thu, 23 Apr 2015 11:41:31 -0400 (EDT)
Message-ID: <20150423.114131.1358383687413246843.davem@davemloft.net>
References: <1429796231-8542-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, johan@kernel.org, niklass@axis.com
To: niklas.cassel@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429796231-8542-1-git-send-email-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Thu, 23 Apr 2015 15:37:11 +0200

> Signed-off-by: Niklas Cassel <niklass@axis.com>
> ---
>  drivers/net/phy/micrel.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 1190fd8..a422036 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -548,7 +548,7 @@ static int kszphy_probe(struct phy_device *phydev)
>  	}
>  
>  	clk = devm_clk_get(&phydev->dev, "rmii-ref");
> -	if (!IS_ERR(clk)) {
> +	if (!IS_ERR_OR_NULL(clk)) {
>  		unsigned long rate = clk_get_rate(clk);
>  		bool rmii_ref_clk_sel_25_mhz;
>  

I do not see anyone in any other networking driver checking for a NULL
return from devm_clk_get().

So either everyone else is wrong, or your change is.  I want to find
out which before applying anything.
