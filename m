From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bnx2x: Restore a call to config_init
Date: Fri, 06 Sep 2013 06:08:29 -0700
Message-ID: <1378472909.31445.22.camel@edumazet-glaptop>
References: <1378461302.15758.2.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Dave Jones <davej@redhat.com>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:53703 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199Ab3IFNIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 09:08:31 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz10so3322961pad.16
        for <netdev@vger.kernel.org>; Fri, 06 Sep 2013 06:08:30 -0700 (PDT)
In-Reply-To: <1378461302.15758.2.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-06 at 12:55 +0300, Eilon Greenstein wrote:
> Commit c0a77ec74f295013d7ba3204dd3ed25fccf83cb4 'bnx2x: Add missing braces in
> bnx2x:bnx2x_link_initialize' identified indentation problem, but resolved it
> by adding braces instead of fixing the indentation. The braces now prevents a
> config_init call in some cases, though it should be called regardless of that
> condition. This patch removes the braces and fix the confusing indentation
> that caused this mess.
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> CC: Dave Jones <davej@redhat.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> index 6645684..d60a2ea 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
> @@ -6501,13 +6501,10 @@ static int bnx2x_link_initialize(struct link_params *params,
>  		struct bnx2x_phy *phy = &params->phy[INT_PHY];
>  		if (vars->line_speed == SPEED_AUTO_NEG &&
>  		    (CHIP_IS_E1x(bp) ||
> -		     CHIP_IS_E2(bp))) {
> +		     CHIP_IS_E2(bp)))
>  			bnx2x_set_parallel_detection(phy, params);
> -			if (params->phy[INT_PHY].config_init)
> -				params->phy[INT_PHY].config_init(phy,
> -								 params,
> -								 vars);
> -		}
> +		if (params->phy[INT_PHY].config_init)
> +			params->phy[INT_PHY].config_init(phy, params, vars);
>  	}
>  
>  	/* Init external phy*/

Thanks 

I wish people, including Dave Jones, clearly states that a patch was not
actually tested on real hardware.

Tested-by: Eric Dumazet <edumazet@google.com>
