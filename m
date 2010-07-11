From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.35-rc3-git7] axnet_cs: use spin_lock_irqsave
 in ax_interrupt
Date: Sat, 10 Jul 2010 19:49:28 -0700 (PDT)
Message-ID: <20100710.194928.116377282.davem@davemloft.net>
References: <20100706202243.95319ab4.ken_kawasaki@spring.nifty.jp>
	<20100710201813.a3e5c79c.ken_kawasaki@spring.nifty.jp>
	<1278816388.6139.10.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ken_kawasaki@spring.nifty.jp, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33954
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753240Ab0GKCtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 22:49:15 -0400
In-Reply-To: <1278816388.6139.10.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sun, 11 Jul 2010 03:46:28 +0100

> On Sat, 2010-07-10 at 20:18 +0900, Ken Kawasaki wrote:
>> axnet_cs:
>>     use spin_lock_irqsave instead of spin_lock in ax_interrupt
> [...]
> 
> I assume this is because it's now called from ei_watchdog() and not only
> from interrupt context.  Perhaps you should explain that in the commit
> message.

No, interrupt handlers in general may not assume that interrupts
are off or on when they are invoked.

Therefore they must use irqflags saving/restoring.
