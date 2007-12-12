From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 4/4] sky2: rtnl_lock out of loop will be faster
Date: Wed, 12 Dec 2007 08:30:11 -0800
Message-ID: <20071212083011.731773b9@freepuppy.rosehill>
References: <475FA0C1.8000701@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Wang Chen <wangchen@cn.fujitsu.com>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58896 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752911AbXLLQbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 11:31:50 -0500
In-Reply-To: <475FA0C1.8000701@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2007 16:50:09 +0800
Wang Chen <wangchen@cn.fujitsu.com> wrote:

> [PATCH 4/4] [NETDEV] sky2: rtnl_lock out of loop will be faster
> 
> Before this patch, it gets and releases the lock at each
> iteration of the loop. Changing unregister_netdev to
> unregister_netdevice and locking outside of the loop will
> be faster for this approach.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
>  sky2.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletion(-)
> 
> --- linux-2.6.24.rc5.org/drivers/net/sky2.c	2007-12-12 10:19:43.000000000 +0800
> +++ linux-2.6.24.rc5/drivers/net/sky2.c	2007-12-12 15:23:37.000000000 +0800
> @@ -4270,8 +4270,10 @@ static void __devexit sky2_remove(struct
>  	del_timer_sync(&hw->watchdog_timer);
>  	cancel_work_sync(&hw->restart_work);
>  
> +	rtnl_lock();
>  	for (i = hw->ports-1; i >= 0; --i)
> -		unregister_netdev(hw->dev[i]);
> +		unregister_netdevice(hw->dev[i]);
> +	rtnl_unlock();
>  
>  	sky2_write32(hw, B0_IMSK, 0);
> 

Umm, okay but it doesn't matter really, there can only be 2 ports and
90+% of the boards only have one port.  So why bother??

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
