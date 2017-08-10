From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCHv2 1/2] drivers: net: davinci_mdio: remove busy loop on
 wait user access
Date: Thu, 10 Aug 2017 11:24:50 -0500
Message-ID: <d176da18-b608-9738-317c-6ca01cb937e9@ti.com>
References: <1502351267-23841-1-git-send-email-muvarov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>
To: Max Uvarov <muvarov@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx194.ext.ti.com ([198.47.27.80]:43089 "EHLO
        lelnx194.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752829AbdHJQYw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 12:24:52 -0400
In-Reply-To: <1502351267-23841-1-git-send-email-muvarov@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/10/2017 02:47 AM, Max Uvarov wrote:
> Polling 14 mdio devices on single mdio bus eats 30% of 1Ghz cpu time
> due to busy loop in wait(). Add small delay to relax cpu.
> 
> Signed-off-by: Max Uvarov <muvarov@gmail.com>

yep. cover letter is good to have.

Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>

> ---
>   v2: fix spelling in commit description.
> 
>   drivers/net/ethernet/ti/davinci_mdio.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> index 33df340..611e7cc 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> @@ -198,8 +198,10 @@ static inline int wait_for_user_access(struct davinci_mdio_data *data)
>   			return 0;
>   
>   		reg = __raw_readl(&regs->control);
> -		if ((reg & CONTROL_IDLE) == 0)
> +		if ((reg & CONTROL_IDLE) == 0) {
> +			usleep_range(100, 200);
>   			continue;
> +		}
>   
>   		/*
>   		 * An emac soft_reset may have clobbered the mdio controller's
> 

-- 
regards,
-grygorii
