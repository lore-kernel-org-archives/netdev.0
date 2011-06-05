From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 3.0-rc1] smc91c92_cs: set smc->base to NULL
 before iounmap
Date: Sun, 05 Jun 2011 14:38:34 -0700 (PDT)
Message-ID: <20110605.143834.1866501392102519766.davem@davemloft.net>
References: <20110131061616.05b2fa6f.ken_kawasaki@spring.nifty.jp>
	<20110221000720.e93225c1.ken_kawasaki@spring.nifty.jp>
	<20110605082016.5a26f61a.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756114Ab1FEVii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 17:38:38 -0400
In-Reply-To: <20110605082016.5a26f61a.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Sun, 5 Jun 2011 08:20:16 +0900

> 
> smc91c92_cs:
>     set smc->base to NULL before iounmap
>     to avoid writing to smc->base in smc_interrupt.
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

The device should be completely made quiet and all interrupts
synchronized before unmapping chip registers.  Using NULL checks
is merely a workaround for the real problem, even though you take
great pains to assign NULL before the iounmap() call.

Perhaps putting the pcmcia_disable_device() call before the iounmap()
will be sufficient to fix this bug.  Or perhaps that, plus a call to
synchronize_irq() or similar.

