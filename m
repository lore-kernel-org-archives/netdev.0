From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: reset_task is crashing the kernel. Fixing it.
Date: Wed, 16 Dec 2009 11:15:09 -0800
Message-ID: <1260990909.31045.84.camel@nseg_linux_HP1.broadcom.com>
References: <1260988830.31045.79.camel@nseg_linux_HP1.broadcom.com>
 <1260990759-16236-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3020 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763177AbZLPTZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2009 14:25:28 -0500
In-Reply-To: <1260990759-16236-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2009-12-16 at 11:12 -0800, leitao@linux.vnet.ibm.com wrote:
> If bnx2 schedules a reset via the reset_task, e.g., due to a TX
> timeout, it's possible for the NIC to be disabled with packets
> pending for transmit.  In this case, napi_disable will loop forever,
> eventually crashing the kernel.  This patch moves the disable of
> the device to after the napi_disable call.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Acked-by: Michael Chan <mchan@broadcom.com>

> ---
>  drivers/net/bnx2.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index f81f082..65df1de 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -653,7 +653,6 @@ static void
>  bnx2_netif_stop(struct bnx2 *bp)
>  {
>  	bnx2_cnic_stop(bp);
> -	bnx2_disable_int_sync(bp);
>  	if (netif_running(bp->dev)) {
>  		int i;
>  
> @@ -667,6 +666,7 @@ bnx2_netif_stop(struct bnx2 *bp)
>  			txq->trans_start = jiffies;
>  		}
>  	}
> +	bnx2_disable_int_sync(bp);
>  }
>  
>  static void


