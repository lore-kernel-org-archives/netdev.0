From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix mv643xx_eth.c lockdep violation
Date: Thu, 16 May 2013 14:57:06 -0700 (PDT)
Message-ID: <20130516.145706.1048942034798267653.davem@davemloft.net>
References: <20130516161313.GS18614@n2100.arm.linux.org.uk>
	<1368721294.3301.55.camel@edumazet-glaptop>
	<20130516163142.GT18614@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, buytenh@wantstofly.org,
	netdev@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868Ab3EPV5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 17:57:07 -0400
In-Reply-To: <20130516163142.GT18614@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Thu, 16 May 2013 17:31:42 +0100

> From: Russell King <rmk+kernel@arm.linux.org.uk>
> Subject: [PATCH] NET: mv643xx_eth: avoid lockdep dump on interface down
> 
> When the interface is shutdown, the mv643xx_eth driver hits the following
> lockdep dump:
 ...
> It seems that txq_reclaim() takes the netif tx lock:
> 
>         __netif_tx_lock(nq, smp_processor_id());
> 
> in a context outside of softirq context, and thus is susceptible to
> deadlock should an interrupt occur.
> 
> Use __netif_tx_lock_bh()/__netif_tx_unlock_bh() instead.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Applied, thanks.
