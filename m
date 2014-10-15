From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] net: fec: ptp: fix convergence issue to support
 LinuxPTP stack
Date: Wed, 15 Oct 2014 16:40:39 -0400 (EDT)
Message-ID: <20141015.164039.817474261624839292.davem@davemloft.net>
References: <1413365412-22072-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, b20596@freescale.com
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbaJOUmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 16:42:01 -0400
In-Reply-To: <1413365412-22072-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Wed, 15 Oct 2014 17:30:12 +0800

> iMX6SX IEEE 1588 module has one hw issue in capturing the ATVR register.
> The current SW flow is:
> 		ENET0->ATCR |= ENET_ATCR_CAPTURE_MASK;
> 		ts_counter_ns = ENET0->ATVR;
> The ATVR value is not expected value that cause LinuxPTP stack cannot be convergent.
> 
> ENET Block Guide/ Chapter for the iMX6SX (PELE) address the issue:
> After set ENET_ATCR[Capture], there need some time cycles before the counter
> value is capture in the register clock domain. The wait-time-cycles is at least
> 6 clock cycles of the slower clock between the register clock and the 1588 clock.
> So need something like:
> 		ENET0->ATCR |= ENET_ATCR_CAPTURE_MASK;
> 		wait();
> 		ts_counter_ns = ENET0->ATVR;
> 
> For iMX6SX, the 1588 ts_clk is fixed to 25Mhz, register clock is 66Mhz, so the
> wait-time-cycles must be greater than 240ns (40ns * 6). The patch add 1us delay
> before cpu read ATVR register.
> 
> Changes V2:
> Modify the commit/comments log to describe the issue clearly.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied, thanks.
