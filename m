From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 2/3] bnx2x: assure we release PHY lock only when is
 taken
Date: Wed, 6 May 2009 15:04:32 +0300
Message-ID: <1241611472.30581.10.camel@lb-tlvb-eliezer>
References: <20090506112207.4d3ae9c4@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Stanislaw Gruszka" <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2358 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752580AbZEFMHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 08:07:50 -0400
In-Reply-To: <20090506112207.4d3ae9c4@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-05-06 at 02:22 -0700, Stanislaw Gruszka wrote:
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> ---
>  drivers/net/bnx2x_main.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index ff2d9f6..5bd42db 100644
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c
> @@ -2585,10 +2585,11 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
>  	REG_WR(bp, hc_addr, asserted);
>  
>  	/* now set back the mask */
> -	if (asserted & ATTN_NIG_FOR_FUNC) {
> -		REG_WR(bp, nig_int_mask_addr, nig_mask);
> -		bnx2x_release_phy_lock(bp);
> -	}
> +	if (asserted & ATTN_HARD_WIRED_MASK)
> +		if (asserted & ATTN_NIG_FOR_FUNC) {
Here are the constants values:
#define ATTN_HARD_WIRED_MASK		0xff00
#define ATTN_NIG_FOR_FUNC		(1L << 8)
So as you can see, there is no need for the extra "if".

Thanks for the patch - but we should not apply it.

> +			REG_WR(bp, nig_int_mask_addr, nig_mask);
> +			bnx2x_release_phy_lock(bp);
> +		}
>  }
>  
>  static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)


