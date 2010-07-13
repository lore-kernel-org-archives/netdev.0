From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.35-rc3-git7] axnet_cs: use spin_lock_irqsave
 in ax_interrupt
Date: Mon, 12 Jul 2010 20:08:55 -0700 (PDT)
Message-ID: <20100712.200855.212405288.davem@davemloft.net>
References: <1278816388.6139.10.camel@localhost>
	<20100710.194928.116377282.davem@davemloft.net>
	<1278817954.6139.24.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ken_kawasaki@spring.nifty.jp, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37226
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752126Ab0GMDIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 23:08:40 -0400
In-Reply-To: <1278817954.6139.24.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sun, 11 Jul 2010 04:12:34 +0100

> But an interrupt handler will not be called recursively for the same
> IRQ.  Since this device only uses one IRQ, surely it was OK to use
> spin_lock() in this function so long as it was only called from the
> interrupt handler.

It seems your right, I'll make a note about the real reason we're
doing this in the commit message.

But frankly anything else is dangerous.  Especially if one intends to
support ->poll_controller() which we pretty much expect every modern
and future driver to do.
