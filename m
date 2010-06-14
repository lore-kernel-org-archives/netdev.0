From: Simon Horman <horms@verge.net.au>
Subject: Re: [net-next PATCH] bnx2x: Fix link problem with some DACs
Date: Mon, 14 Jun 2010 17:49:56 +0900
Message-ID: <20100614084956.GC25374@verge.net.au>
References: <1276511188.13056.26.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Yaniv Rosner <yanivr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:46813 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755124Ab0FNIt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jun 2010 04:49:59 -0400
Content-Disposition: inline
In-Reply-To: <1276511188.13056.26.camel@lb-tlvb-yanivr.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 14, 2010 at 01:26:28PM +0300, Yaniv Rosner wrote:
> Change 2wire transfer rate of SFP+ module EEPROM from 400Khz to 100Khz since some DACs(direct attached cables) do not work at 400Khz.
> 
> Reported-by: Krzysztof Oldzki <ole@ans.pl>
> Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
> diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
> index ff70be8..600bc44 100644
> --- a/drivers/net/bnx2x_link.c
> +++ b/drivers/net/bnx2x_link.c
> @@ -4266,14 +4266,15 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
>  					       MDIO_PMA_REG_10G_CTRL2, 0x0008);
>  			}
>  
> -			/* Set 2-wire transfer rate to 400Khz since 100Khz
> -			is not operational */

Doesn't the above comment indicate there is some HW where 100Khz doesn't work?

> +			/* Set 2-wire transfer rate of SFP+ module EEPROM
> +			to 100Khz since some DACs(direct attached cables) do
> +			not work at 400Khz.*/
>  			bnx2x_cl45_write(bp, params->port,
>  				       ext_phy_type,
>  				       ext_phy_addr,
>  				       MDIO_PMA_DEVAD,
>  				       MDIO_PMA_REG_8727_TWO_WIRE_SLAVE_ADDR,
> -				       0xa101);
> +				       0xa001);
>  
>  			/* Set TX PreEmphasis if needed */
>  			if ((params->feature_config_flags &
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
