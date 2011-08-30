From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH 5/7] bnx2x: do not set TPA flags and features in
 bnx2x_init_bp
Date: Tue, 30 Aug 2011 19:21:22 +0300
Message-ID: <201108301921.22838.vladz@broadcom.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
 <1314714646-3642-6-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2105 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755758Ab1H3QV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 12:21:56 -0400
In-Reply-To: <1314714646-3642-6-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 30 August 2011 17:30:44 Michal Schmidt wrote:
> The .ndo_{set,fix}_features callbacks are sufficient.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    9 ---------
>  1 files changed, 0 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c index 64314f7..617a072
> 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -9752,15 +9752,6 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
>  					"must load devices in order!\n");
> 
>  	bp->multi_mode = multi_mode;
> -
> -	/* Set TPA flags */
> -	if (disable_tpa) {
> -		bp->flags &= ~TPA_ENABLE_FLAG;
> -		bp->dev->features &= ~NETIF_F_LRO;
> -	} else {
> -		bp->flags |= TPA_ENABLE_FLAG;
> -		bp->dev->features |= NETIF_F_LRO;
> -	}
>  	bp->disable_tpa = disable_tpa;
> 
>  	if (CHIP_IS_E1(bp))

NACK

This patch will cause the bnx2x to initialize HW with LRO disabled on the 
first ifup because our code considers the TPA_ENABLE_FLAG when desiding on 
whether LRO is enabled or not. ethtool would still report the LRO on though!

thanks,
vlad
