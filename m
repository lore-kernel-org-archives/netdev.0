From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH 1/3] bnx2x: remove TPA_ENABLE_FLAG
Date: Wed, 31 Aug 2011 18:16:30 +0300
Message-ID: <201108311816.30468.vladz@broadcom.com>
References: <1314802836-9862-1-git-send-email-mschmidt@redhat.com>
 <1314802836-9862-2-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"mirqus@gmail.com" <mirqus@gmail.com>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3285 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756288Ab1HaPRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 11:17:08 -0400
In-Reply-To: <1314802836-9862-2-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 31 August 2011 18:00:34 Michal Schmidt wrote:
>  	if (bnx2x_reload) {
> -		if (bp->recovery_state == BNX2X_RECOVERY_DONE)
> +		if (bp->recovery_state == BNX2X_RECOVERY_DONE) {
> +			/*
> +			 * Cheat! Normally dev->features will be set after we
> +			 * return, but that's too late. We need to know how to
> +			 * configure the NIC when reloading it, so update
> +			 * the features early.
> +			 */
> +			dev->features = features;
>  			return bnx2x_reload_if_running(dev);

NACK 

This is bogus - what if bnx2x_reload_if_running(dev) (bnx2x_nic_load()) 
failes? The original dev->features would be lost... Pls., see my latest 
response on your previouse patch series thread.

thanks,
vlad

> +		}
>  		/* else: bnx2x_nic_load() will be called at end of recovery */
>  	}
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c index e7b584b..fd32c04
> 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -9757,13 +9757,10 @@ static int __devinit bnx2x_init_bp(struct bnx2x
> *bp) bp->multi_mode = multi_mode;
> 
>  	/* Set TPA flags */
> -	if (disable_tpa) {
> -		bp->flags &= ~TPA_ENABLE_FLAG;
> +	if (disable_tpa)
>  		bp->dev->features &= ~NETIF_F_LRO;
> -	} else {
> -		bp->flags |= TPA_ENABLE_FLAG;
> +	else
>  		bp->dev->features |= NETIF_F_LRO;
> -	}
>  	bp->disable_tpa = disable_tpa;
> 
>  	if (CHIP_IS_E1(bp))
