From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] pcnet: fix sparse triviality
Date: Mon, 29 Oct 2007 06:04:53 -0400
Message-ID: <4725B045.80705@garzik.org>
References: <20071026221132.1913.24518.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pcnet32@verizon.net, netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46737 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752223AbXJ2KE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 06:04:56 -0400
In-Reply-To: <20071026221132.1913.24518.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Since data can never exceed u32, it can't even be larger than LONG_MAX/HZ.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: pcnet32@verizon.net
> ---
> 
>  drivers/net/pcnet32.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
> index ff92aca..3573e77 100644
> --- a/drivers/net/pcnet32.c
> +++ b/drivers/net/pcnet32.c
> @@ -1101,9 +1101,8 @@ static int pcnet32_phys_id(struct net_device *dev, u32 data)
>  	mod_timer(&lp->blink_timer, jiffies);
>  	set_current_state(TASK_INTERRUPTIBLE);
>  
> -	/* AV: the limit here makes no sense whatsoever */
> -	if ((!data) || (data > (u32) (MAX_SCHEDULE_TIMEOUT / HZ)))
> -		data = (u32) (MAX_SCHEDULE_TIMEOUT / HZ);
> +	if (!data)
> +		data = INT_MAX;
>  
>  	msleep_interruptible(data * 1000);
>  	del_timer_sync(&lp->blink_timer);

Two comments:

1) I would prefer to pick a sane limit, like "1 day".  The unit of 
'data' is seconds, so IMO we should not allow stupid timeouts, much less 
INT_MAX ones :)  But hey, then again, maybe we should permit root to 
hang themselves with own rope...

2) [tangent] someone really should add the obvious ssleep_interruptible()

