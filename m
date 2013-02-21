From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: fec: fix crash at mx53 qsb board
Date: Thu, 21 Feb 2013 13:04:49 -0500 (EST)
Message-ID: <20130221.130449.868185028543115848.davem@davemloft.net>
References: <1361408848-14118-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, shawn.guo@linaro.org, B38611@freescale.com,
	s.hauer@pengutronix.de, festevam@gmail.com
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756200Ab3BUSEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 13:04:52 -0500
In-Reply-To: <1361408848-14118-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Thu, 21 Feb 2013 09:07:28 +0800

> Unable to handle kernel NULL pointer dereference at virtual address 00000002
> pgd = 80004000
> [00000002] *pgd=00000000
> Internal error: Oops: 5 [#1] SMP ARM
> Modules linked in:
> CPU: 0    Not tainted  (3.8.0-rc7-next-20130215+ #346)
> PC is at fec_enet_interrupt+0xd0/0x348
> LR is at fec_enet_interrupt+0xb8/0x348
> pc : [<80372b7c>]    lr : [<80372b64>]    psr: 60000193
> sp : df855c20  ip : df855c20  fp : df855c74
> r10: 00000516  r9 : 1c000000  r8 : 00000000
> r7 : 00000000  r6 : 00000000  r5 : 00000000  r4 : df9b7800
> r3 : df9b7df4  r2 : 00000000  r1 : 00000000  r0 : df9b7d34
> 
> It is possible that issue a irq between request_irq and fec_enet_init.
> Irq handle will be called but driver data structure is not ready yet.
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

You must fix this by making sure all of the necessary software
datastructures are initialized fully before request_irq() is
invoked.

You absolutely cannot control pending interrupts the chip is already
signalling and which have been queued up in the interrupt controller
already, which will be emitted precisely when you request_irq()
regardless of how you program the chip during this time.

I'm not applying this, fix the bug correctly, thanks.
