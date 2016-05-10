From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phylib: fix interrupts re-enablement in phy_start
Date: Tue, 10 May 2016 11:25:22 -0700
Message-ID: <57322792.4060008@gmail.com>
References: <1462873346-46457-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Shaohui Xie <Shaohui.Xie@nxp.com>, Andrew Lunn <andrew@lunn.ch>
To: shh.xie@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35087 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbcEJSZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 14:25:25 -0400
Received: by mail-pf0-f171.google.com with SMTP id 77so8525603pfv.2
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 11:25:25 -0700 (PDT)
In-Reply-To: <1462873346-46457-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2016 02:42 AM, shh.xie@gmail.com wrote:
> From: Shaohui Xie <Shaohui.Xie@nxp.com>
> 
> If phy was suspended and is starting, current driver always enable
> phy's interrupts, if phy works in polling, phy can raise unexpected
> interrupt which will not be handled, the interrupt will block system
> enter suspend again. So interrupts should only be re-enabled if phy
> works in interrupt.

Your explanation makes sense. The commit message could you use some
improvements like s/phy/PHY/ and "works in interrupt mode", but that is
not a huge thing.

> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@nxp.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/phy.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 6f221c8..baa5ecb 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -871,9 +871,11 @@ void phy_start(struct phy_device *phydev)
>  		break;
>  	case PHY_HALTED:
>  		/* make sure interrupts are re-enabled for the PHY */
> -		err = phy_enable_interrupts(phydev);
> -		if (err < 0)
> -			break;
> +		if (phydev->irq != PHY_POLL) {
> +			err = phy_enable_interrupts(phydev);
> +			if (err < 0)
> +				break;
> +		}
>  
>  		phydev->state = PHY_RESUMING;
>  		do_resume = true;
> 


-- 
Florian
