From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ks8851: Fix mutex deadlock in ks8851_net_stop()
Date: Sat, 21 Apr 2012 15:34:40 -0400 (EDT)
Message-ID: <20120421.153440.1754750876890229323.davem@davemloft.net>
References: <1334805958-29119-1-git-send-email-sboyd@codeaurora.org>
	<1334805958-29119-2-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tj@kernel.org, ben-linux@fluff.org
To: sboyd@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334805958-29119-2-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Boyd <sboyd@codeaurora.org>
Date: Wed, 18 Apr 2012 20:25:58 -0700

> There is a potential deadlock scenario when the ks8851 driver
> is removed. The interrupt handler schedules a workqueue which
> acquires a mutex that ks8851_net_stop() also acquires before
> flushing the workqueue. Previously lockdep wouldn't be able
> to find this problem but now that it has the support we can
> trigger this lockdep warning by rmmoding the driver after
> an ifconfig up.
> 
> Fix the possible deadlock by disabling the interrupts in 
> the chip and then release the lock across the workqueue
> flushing. The mutex is only there to proect the registers
> anyway so this should be ok.
 ...
> Cc: Ben Dooks <ben-linux@fluff.org>
> Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>

Applied.
