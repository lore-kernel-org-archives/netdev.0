From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH 3/4] net/fec: set phy_speed to the optimal frequency 2.5
 MHz
Date: Mon, 19 Sep 2011 15:39:30 -0700
Message-ID: <4E77C4A2.1060802@boundarydevices.com>
References: <1316346852-17090-1-git-send-email-shawn.guo@linaro.org> <1316346852-17090-4-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, patches@linaro.org
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy8-pub.bluehost.com ([69.89.22.20]:42987 "HELO
	oproxy8-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750714Ab1ISWje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 18:39:34 -0400
In-Reply-To: <1316346852-17090-4-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/18/2011 4:54 AM, Shawn Guo wrote:
> With the unnecessary 1 bit left-shift on fep->phy_speed during the
> calculation, the phy_speed always runs at the half frequency of the
> optimal one 2.5 MHz.
>
> The patch removes that 1 bit left-shift to get the optimal phy_speed.
>
> Signed-off-by: Shawn Guo<shawn.guo@linaro.org>
> ---
>   drivers/net/fec.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 5ef0e34..04206e4 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -1007,7 +1007,7 @@ static int fec_enet_mii_init(struct platform_device *pdev)
>   	/*
>   	 * Set MII speed to 2.5 MHz (= clk_get_rate() / 2 * phy_speed)
>   	 */
> -	fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk), 5000000)<<  1;
> +	fep->phy_speed = DIV_ROUND_UP(clk_get_rate(fep->clk), 5000000);
>   	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
>
>   	fep->mii_bus = mdiobus_alloc();
Do you need to round up to an even value? Is the hardware documentation 
wrong?
Does this need a quirk? What boards has this been verified to fix?

Thanks
Troy
