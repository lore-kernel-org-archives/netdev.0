From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: cpsw: fix hangs with interrupts
Date: Sun, 04 Jan 2015 22:19:23 -0500 (EST)
Message-ID: <20150104.221923.550321820468649239.davem@davemloft.net>
References: <1420236959-32444-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, yegorslists@googlemail.com,
	linux-omap@vger.kernel.org, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: balbi@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838AbbAEDTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 22:19:25 -0500
In-Reply-To: <1420236959-32444-1-git-send-email-balbi@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felipe Balbi <balbi@ti.com>
Date: Fri, 2 Jan 2015 16:15:59 -0600

> The CPSW IP implements pulse-signaled interrupts. Due to
> that we must write a correct, pre-defined value to the
> CPDMA_MACEOIVECTOR register so the controller generates
> a pulse on the correct IRQ line to signal the End Of
> Interrupt.
> 
> The way the driver is written today, all four IRQ lines
> are requested using the same IRQ handler and, because of
> that, we could fall into situations where a TX IRQ fires
> but we tell the controller that we ended an RX IRQ (or
> vice-versa). This situation triggers an IRQ storm on the
> reserved IRQ 127 of INTC which will in turn call ack_bad_irq()
> which will, then, print a ton of:
 ...
> Reported-by: Yegor Yefremov <yegorslists@googlemail.com>
> Fixes: 510a1e7 (drivers: net: davinci_cpdma: acknowledge interrupt properly)
> Cc: <stable@vger.kernel.org> # v3.9+
> Signed-off-by: Felipe Balbi <balbi@ti.com>

Applied, thanks.
