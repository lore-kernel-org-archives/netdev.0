From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next patch 1/12] bnx2x: Add support for external LB
Date: Wed, 13 Jun 2012 19:17:49 +0100
Message-ID: <1339611469.2612.14.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
	 <1339591464-10554-2-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <eilong@broadcom.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Merav Sicron <meravs@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:28400 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754507Ab2FMSRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 14:17:53 -0400
In-Reply-To: <1339591464-10554-2-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-13 at 15:44 +0300, Merav Sicron wrote:
> This change enables to do self-test with external loopback via ethtool.
> 
> Signed-off-by: Merav Sicron <meravs@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

The ethtool bits look right.

[...]
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -2124,7 +2124,12 @@ u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
>  			}
>  		}
>  
> -		rc = bnx2x_phy_init(&bp->link_params, &bp->link_vars);
> +	if (load_mode == LOAD_LOOPBACK_EXT) {
> +		struct link_params *lp = &bp->link_params;
> +		lp->loopback_mode = LOOPBACK_EXT;
> +	}
> +
> +	rc = bnx2x_phy_init(&bp->link_params, &bp->link_vars);
>  
>  		bnx2x_release_phy_lock(bp);

Indentation is wrong here, though.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
