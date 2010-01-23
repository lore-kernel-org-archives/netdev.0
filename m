From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: only process one
 ixgbe_watchdog_task at a time.
Date: Sat, 23 Jan 2010 02:19:41 -0800 (PST)
Message-ID: <20100123.021941.134608202.davem@davemloft.net>
References: <20100123101644.12479.40925.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	john.r.fastabend@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39774
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753972Ab0AWKT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 05:19:29 -0500
In-Reply-To: <20100123101644.12479.40925.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 23 Jan 2010 02:17:31 -0800

> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index 8d206f7..cbc62db 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -5013,7 +5013,8 @@ static void ixgbe_watchdog_task(struct work_struct *work)
>  	struct ixgbe_ring *tx_ring;
>  	int some_tx_pending = 0;
>  
> -	adapter->flags |= IXGBE_FLAG_IN_WATCHDOG_TASK;
> +	while (test_and_set_bit(__IXGBE_IN_WATCHDOG_TASK, &adapter->state))
> +		msleep(1);
>  

I think using a mutex() would better serve you here.
