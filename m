From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: FW: [PATCH] bnx2x: make bnx2x_close() static again
Date: Thu, 16 Feb 2012 15:35:40 +0200
Message-ID: <1329399341.16698.33.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1329395928-998-1-git-send-email-mschmidt@redhat.com>
 <D4345541C14421439B1167B74C9F383537EEF3@SJEXCHMB05.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eilong@broadcom.com
To: netdev@vger.kernel.org, mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1505 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751487Ab2BPNfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Feb 2012 08:35:50 -0500
In-Reply-To: <D4345541C14421439B1167B74C9F383537EEF3@SJEXCHMB05.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [PATCH] bnx2x: make bnx2x_close() static again
> 
> Commit 8304859a "bnx2x: add fan failure event handling" made the function
> bnx2x_close() non-static unnecessarily. The function is not called from
> other sources. Make it static again.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    2 --
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    4 +++-
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> index 7d184fb..5d7e4bc 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> @@ -2074,8 +2074,6 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
>  #define BNX2X_VPD_LEN			128
>  #define VENDOR_ID_LEN			4
>  
> -int bnx2x_close(struct net_device *dev);
> -
>  /* Congestion management fairness mode */
>  #define CMNG_FNS_NONE		0
>  #define CMNG_FNS_MINMAX		1
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index ff19c3c..80cae51 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -8719,6 +8719,8 @@ static void bnx2x_parity_recover(struct bnx2x *bp)
>  	}
>  }
>  
> +static int bnx2x_close(struct net_device *dev);
> +
>  /* bnx2x_nic_unload() flushes the bnx2x_wq, thus reset task is
>   * scheduled on a general queue in order to prevent a dead lock.
>   */
> @@ -10291,7 +10293,7 @@ static int bnx2x_open(struct net_device *dev)
>  }
>  
>  /* called with rtnl_lock */
> -int bnx2x_close(struct net_device *dev)
> +static int bnx2x_close(struct net_device *dev)
>  {
>  	struct bnx2x *bp = netdev_priv(dev);
>  
Acked-by: Yuval Mintz <yuvalmin@broadcom.com>

Thanks Michal.
