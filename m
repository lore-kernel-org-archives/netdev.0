From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2 net-next] net: fec: fix spin_lock dead lock
Date: Thu, 07 Feb 2013 23:37:08 -0500 (EST)
Message-ID: <20130207.233708.2170335376726433338.davem@davemloft.net>
References: <1360198799-25173-1-git-send-email-Frank.Li@freescale.com>
	<1360198799-25173-2-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, shawn.guo@linaro.org, B38611@freescale.com,
	s.hauer@pengutronix.de
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759781Ab3BHEhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 23:37:10 -0500
In-Reply-To: <1360198799-25173-2-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Thu, 7 Feb 2013 08:59:59 +0800

> =========================================================
> [ INFO: possible irq lock inversion dependency detected ]
> 3.8.0-rc5+ #82 Not tainted
> ---------------------------------------------------------
> swapper/0/0 just changed the state of lock:
>  (&(&fep->hw_lock)->rlock){..-...}, at: [<8034e2f8>] fec_enet_start_xmit+0x48/0x                      2cc
> but this lock took another, SOFTIRQ-unsafe lock in the past:
> (prepare_lock){+.+.+.}
> 
> and interrupts could create inverse lock ordering between them.
> other info that might help us debug this:
> Possible interrupt unsafe locking scenario:
> 
> CPU0				CPU1
> ----				----
> lock(prepare_lock);
> 				local_irq_disable()
> 				lock(&(&fep->hw_lock)->rlock);
> 				lock(prepare_lock);
> <Interrupt>
> lock(&(&fep->hw_lock)->rlock);
> 
> *** DEADLOCK ***
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Applied.
