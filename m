From: David Miller <davem@davemloft.net>
Subject: Re: [patch sungem] improved locking
Date: Mon, 11 Dec 2006 17:43:51 -0800 (PST)
Message-ID: <20061211.174351.104064300.davem@davemloft.net>
References: <5cac192f0611141354l3a4aa130ve741c9d6a7a49d0a@mail.gmail.com>
	<20061128.144911.55733883.davem@davemloft.net>
	<5cac192f0611290256l7067ce21r39881486f6e21289@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59753
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750847AbWLLBnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 20:43:52 -0500
To: eric.lemoine@gmail.com
In-Reply-To: <5cac192f0611290256l7067ce21r39881486f6e21289@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric Lemoine" <eric.lemoine@gmail.com>
Date: Wed, 29 Nov 2006 11:56:30 +0100

> I don't understand why we'd need all this.
> 
> I think the following code for gem_interrupt should do the trick:
...
> The important thing is: we __netif_rx_schedule even if gem_status is 0
> (shared irq case) because we don't want to miss events should the
> following scenario occur:

I see, I miseed the bit where we're reading the status register
also in the ->poll() loop.

Reading the status register at least twice every interrupt is
really expensive.

I hope there is a lesson being learned, and nobody out there is
making modern networking NICs that put the interrupt status
in a register.

It should always be in a DMA'd status block, without any exception.
This way it can be polled in the cheapest manner possible.  When the
status block is in main memory, the CPU only takes the "cost" of a
read when the value actually changes.

Anyways, Eric your changes look fine as far as I can tell, can you
give them a really good testing on some SMP boxes?  Then we can
think about putting it into 2.6.21 or similar, I don't want to
put any more major networking changes into 2.6.20 at this time.
