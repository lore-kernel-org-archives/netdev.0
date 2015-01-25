From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] bnx2x: fix napi poll return value for repoll
Date: Sun, 25 Jan 2015 08:05:13 -0800
Message-ID: <1422201913.29618.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422182363-10932-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ariel.elior@qlogic.com, edumazet@google.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:44790 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770AbbAYQFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 11:05:16 -0500
Received: by mail-pa0-f49.google.com with SMTP id fa1so7035434pad.8
        for <netdev@vger.kernel.org>; Sun, 25 Jan 2015 08:05:16 -0800 (PST)
In-Reply-To: <1422182363-10932-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-01-25 at 16:09 +0530, Govindarajulu Varadarajan wrote:
> With the commit d75b1ade567ffab ("net: less interrupt masking in NAPI") napi
> repoll is done only when work_done == budget. When in busy_poll is we return 0
> in napi_poll. We should return budget.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
> v2:
> Remove unnecessary change for work_done >= budget return value.
> 
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index 1d1147c..e468ed3 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -3175,7 +3175,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
>  		}
>  #endif
>  		if (!bnx2x_fp_lock_napi(fp))
> -			return work_done;
> +			return budget;
>  
>  		for_each_cos_in_tx_queue(fp, cos)
>  			if (bnx2x_tx_queue_has_work(fp->txdata_ptr[cos]))

Thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
