From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Ensure that initialization is done prior to
 request_irq()
Date: Thu, 21 Feb 2013 15:27:24 -0500 (EST)
Message-ID: <20130221.152724.6508078801736235.davem@davemloft.net>
References: <1361474510-14286-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Frank.Li@freescale.com, s.hauer@pengutronix.de,
	jim_baxter@mentor.com, netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34759 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755876Ab3BUU10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 15:27:26 -0500
In-Reply-To: <1361474510-14286-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Thu, 21 Feb 2013 16:21:50 -0300

> Currently request_irq() is called prior to fec_enet_init() and fec_ptp_init(), 
> which causes the following crash on a mx53qsb:
> 
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
> Ensure that such initialization functions are called prior to requesting the 
> interrupts, so that all necessary the data structures are in place when the 
> irqs occur. 
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Looks good, did you test this yourself or should we wait for others to
test it out?
