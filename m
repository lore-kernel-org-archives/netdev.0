From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: fix wrong return from bnx2x_trylock_hw_lock
Date: Fri, 27 Aug 2010 07:54:44 +0300
Message-ID: <1282884884.14181.1.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1282880943.2501.13.camel@edumazet-laptop>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2654 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753228Ab0H0Ey7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Aug 2010 00:54:59 -0400
In-Reply-To: <1282880943.2501.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-08-26 at 20:49 -0700, Eric Dumazet wrote:
> bnx2x_trylock_hw_lock() returns a bool :
> 
> true if succeeded to acquire the lock.
> false in case of error.
> 
> -EINVAL is not an acceptable value, since its promoted to true.

Indeed - thanks Eric!

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Eilon Greenstein <eilong@broadcom.com>

> ---
> Cosmetic patch, since compiler probably omits the code anyway.
> 
> diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
> index f8c3f08..86cc4b0 100644
> --- a/drivers/net/bnx2x/bnx2x_main.c
> +++ b/drivers/net/bnx2x/bnx2x_main.c
> @@ -781,7 +781,7 @@ static bool bnx2x_trylock_hw_lock(struct bnx2x *bp, u32 resource)
>  		DP(NETIF_MSG_HW,
>  		   "resource(0x%x) > HW_LOCK_MAX_RESOURCE_VALUE(0x%x)\n",
>  		   resource, HW_LOCK_MAX_RESOURCE_VALUE);
> -		return -EINVAL;
> +		return false;
>  	}
>  
>  	if (func <= 5)
> 
> 
> 



