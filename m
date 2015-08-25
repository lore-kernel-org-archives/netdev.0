From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: use reinit_completion() in mdio accessor
 functions
Date: Tue, 25 Aug 2015 16:33:32 -0700 (PDT)
Message-ID: <20150825.163332.1359468744424655533.davem@davemloft.net>
References: <E1ZU9vV-0004nW-3C@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: B38611@freescale.com, netdev@vger.kernel.org
To: rmk+kernel@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60388 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756357AbbHYXdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:33:33 -0400
In-Reply-To: <E1ZU9vV-0004nW-3C@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>
Date: Tue, 25 Aug 2015 09:49:53 +0100

> Rather than re-initialising the entire completion on every mdio access,
> use reinit_completion() which only resets the completion count.  This
> avoids possible reinitialisation of the contained spinlock and waitqueue
> while they may be in use (eg, mid-completion.)
> 
> Such an event could occur if there's a long delay in interrupt handling
> causing the mdio accessor to time out, then a second access comes in
> while the interrupt handler on a different CPU has called complete().
> Another scenario where this has been observed is while locking has
> been missing at the phy layer, allowing concurrent attempts to access
> the MDIO bus.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Applied.
