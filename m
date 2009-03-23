From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2.6.29-rc8] dm9000 locking bugfix
Date: Sun, 22 Mar 2009 21:28:57 -0700 (PDT)
Message-ID: <20090322.212857.96030314.davem@davemloft.net>
References: <200903221612.13055.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38642
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750758AbZCWE3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 00:29:10 -0400
In-Reply-To: <200903221612.13055.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <david-b@pacbell.net>
Date: Sun, 22 Mar 2009 16:12:12 -0700

> This fixes a locking bug in the dm9000 driver.  It calls
> request_irq() without setting IRQF_DISABLED ... which is
> correct for handlers that support IRQ sharing, since that
> behavior is not guaranteed for shared IRQs.  However, its
> IRQ handler then wrongly assumes that IRQs are blocked.
> So the fix just uses the right spinlock primitives in the
> IRQ handler.
> 
> NOTE:  this is a classic example of the type of bug which
> lockdep currently masks by forcibly setting IRQF_DISABLED
> on IRQ handlers that did not request that flag.
> 
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>

Applied, thanks.
