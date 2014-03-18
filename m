From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH] micrel: fix masking off LED bits
Date: Wed, 19 Mar 2014 00:27:41 +0100
Message-ID: <1643301.laIYkMizQV@avalon>
References: <201403190258.16812.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	ben.dooks@codethink.co.uk
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201403190258.16812.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

Thank you for the patch.

On Wednesday 19 March 2014 02:58:16 Sergei Shtylyov wrote:
> Commit 20d8435a1cff (phy: micrel: add of configuration for LED mode) made
> the obvious mistake when masking off  the LED mode bits: forgot to do a
> logical NOT to the mask with which it ANDs the register value, so that
> unrelated bits are cleared instead.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Good catch.

Acked-by: Laurent Pinchart <laurent.pinchart@ideasonboard.com>

> ---
> This patch is against DaveM's 'net-next.git' repo.
> 
>  drivers/net/phy/micrel.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: net-next/drivers/net/phy/micrel.c
> ===================================================================
> --- net-next.orig/drivers/net/phy/micrel.c
> +++ net-next/drivers/net/phy/micrel.c
> @@ -167,7 +167,7 @@ static int kszphy_setup_led(struct phy_d
>  	if (temp < 0)
>  		return temp;
> 
> -	temp &= 3 << shift;
> +	temp &= ~(3 << shift);
>  	temp |= val << shift;
>  	rc = phy_write(phydev, reg, temp);


-- 
Regards,

Laurent Pinchart

