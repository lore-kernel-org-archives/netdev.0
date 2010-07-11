From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH kernel 2.6.35-rc3-git7] axnet_cs: use spin_lock_irqsave
 in ax_interrupt
Date: Sun, 11 Jul 2010 04:12:34 +0100
Message-ID: <1278817954.6139.24.camel@localhost>
References: <20100706202243.95319ab4.ken_kawasaki@spring.nifty.jp>
	 <20100710201813.a3e5c79c.ken_kawasaki@spring.nifty.jp>
	 <1278816388.6139.10.camel@localhost>
	 <20100710.194928.116377282.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ken_kawasaki@spring.nifty.jp, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:41366 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207Ab0GKDMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 23:12:39 -0400
In-Reply-To: <20100710.194928.116377282.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-07-10 at 19:49 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Sun, 11 Jul 2010 03:46:28 +0100
> 
> > On Sat, 2010-07-10 at 20:18 +0900, Ken Kawasaki wrote:
> >> axnet_cs:
> >>     use spin_lock_irqsave instead of spin_lock in ax_interrupt
> > [...]
> > 
> > I assume this is because it's now called from ei_watchdog() and not only
> > from interrupt context.  Perhaps you should explain that in the commit
> > message.
> 
> No, interrupt handlers in general may not assume that interrupts
> are off or on when they are invoked.
> 
> Therefore they must use irqflags saving/restoring.

But an interrupt handler will not be called recursively for the same
IRQ.  Since this device only uses one IRQ, surely it was OK to use
spin_lock() in this function so long as it was only called from the
interrupt handler.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

