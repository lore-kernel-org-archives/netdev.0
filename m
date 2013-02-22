From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Fix division by zero
Date: Fri, 22 Feb 2013 15:14:29 -0500 (EST)
Message-ID: <20130222.151429.1706601343859875638.davem@davemloft.net>
References: <1361551245-11021-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Frank.Li@freescale.com, s.hauer@pengutronix.de,
	jim_baxter@mentor.com, netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757276Ab3BVUOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 15:14:31 -0500
In-Reply-To: <1361551245-11021-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Fri, 22 Feb 2013 13:40:45 -0300

> commit 7f7d6c282 (net: fec: Ensure that initialization is done prior to 
> request_irq()) placed fec_ptp_init() into a point that ptp clock was not 
> available, which causes a division by zero in fec_ptp_start_cyclecounter():
> 
> [   17.895723] Division by zero in kernel.
> [   17.899571] Backtrace:
> [   17.902094] [<80012564>] (dump_backtrace+0x0/0x10c) from [<8056deec>]
> (dump_stack+0x18/0x1c)
> [   17.910539]  r6:bfba8500 r5:8075c950 r4:bfba8000 r3:bfbd0000
> [   17.916284] [<8056ded4>] (dump_stack+0x0/0x1c) from [<80012688>]
> (__div0+0x18/0x20)
> [   17.923968] [<80012670>] (__div0+0x0/0x20) from [<802829c4>] (Ldiv0+0x8/0x10)
> [   17.931140] [<80398534>] (fec_ptp_start_cyclecounter+0x0/0x110) from
> [<80394f64>] (fec_restart+0x6c8/0x754)
> [   17.940898] [<8039489c>] (fec_restart+0x0/0x754) from [<803969a0>]
> (fec_enet_adjust_link+0xdc/0x108)
> [   17.950046] [<803968c4>] (fec_enet_adjust_link+0x0/0x108) from [<80390bc4>]
> (phy_state_machine+0x178/0x534)
> ...
> 
> Fix this by rearraging the code so that fec_ptp_init() is called only after
> the clocks have been properly acquired.
> 
> Tested on both mx53 and mx6 platforms.
> 
> Reported-by: Jim Baxter <jim_baxter@mentor.com>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
