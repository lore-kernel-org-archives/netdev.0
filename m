From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/am2150: fix nmclan_cs.c shared interrupt
 handling
Date: Fri, 21 Nov 2014 15:17:35 -0500 (EST)
Message-ID: <20141121.151735.1432199551923486515.davem@davemloft.net>
References: <4353896.15JnC91eLO@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	rpao@paonet.org, linux-kernel@vger.kernel.org,
	linux-pcmcia@lists.infradead.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbaKUURi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:17:38 -0500
In-Reply-To: <4353896.15JnC91eLO@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 20 Nov 2014 16:11:14 +0100

> A recent patch tried to work around a valid warning for the use of a
> deprecated interface by blindly changing from the old
> pcmcia_request_exclusive_irq() interface to pcmcia_request_irq().
> 
> This driver has an interrupt handler that is not currently aware
> of shared interrupts, but can be easily converted to be.
> At the moment, the driver reads the interrupt status register
> repeatedly until it contains only zeroes in the interesting bits,
> and handles each bit individually.
> 
> This patch adds the missing part of returning IRQ_NONE in case none
> of the bits are set to start with, so we can move on to the next
> interrupt source.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 5f5316fcd08ef7 ("am2150: Update nmclan_cs.c to use update PCMCIA API")
> ---
> I had this patch in my queue of things to submit and noticed that
> the warning had gone away upstream but my patch was still there.
> 
> For all I can tell, the driver is broken without this, although it
> would rarely be a problem.

I'm happy for this to go alongside patch #2 via another tree:

Acked-by: David S. Miller <davem@davemloft.net>
