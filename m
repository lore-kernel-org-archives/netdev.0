From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 27/41]bnx2x: smp_mb and not just smp_rmb
Date: Thu, 12 Feb 2009 19:21:49 +0000
Message-ID: <1234466509.3583.22.camel@achroite>
References: <1234463845.1863.159.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:34723 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757623AbZBLTWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 14:22:00 -0500
In-Reply-To: <1234463845.1863.159.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-02-12 at 20:37 +0200, Eilon Greenstein wrote:
> Subject: [PATCH 27/41]bnx2x: smp_mb and not just smp_rmb

This could do with some more explanation (and comments in the code).

> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  drivers/net/bnx2x_main.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index 6bd9219..2e95799 100644
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c
> @@ -7173,7 +7173,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
>  		struct bnx2x_fastpath *fp = &bp->fp[i];
>  
>  		cnt = 1000;
> -		smp_rmb();
> +		smp_mb();
>  		while (bnx2x_has_tx_work_unload(fp)) {
>  
>  			bnx2x_tx_int(fp, 1000);
> @@ -7189,7 +7189,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
>  			}
>  			cnt--;
>  			msleep(1);
> -			smp_rmb();
> +			smp_mb();

I suspect that smp_*mb() is redundant after a schedule().

>  		}
>  	}
>  	/* Give HW time to discard old tx messages */

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

