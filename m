From: David Miller <davem@davemloft.net>
Subject: Re: [patch 01/13] KS8851: Fix ks8851 snl transmit problem
Date: Sun, 02 May 2010 22:38:52 -0700 (PDT)
Message-ID: <20100502.223852.219748077.davem@davemloft.net>
References: <20100429231621.015936077@fluff.org.uk>
	<20100429231739.509103394@fluff.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tristram.ha@micrel.com,
	support@tincantools.com
To: ben@simtec.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56000
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751773Ab0ECFiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 01:38:46 -0400
In-Reply-To: <20100429231739.509103394@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Dooks <ben@simtec.co.uk>
Date: Fri, 30 Apr 2010 00:16:22 +0100

> From: Tristram Ha <Tristram.Ha@micrel.com>
> 
> This fixes a transmit problem of the ks8851 snl network driver.
> 
> Under heavy TCP traffic the device will stop transmitting. Turning off
> the transmit interrupt avoids this issue.  A new workqueue was
> implemented to replace the functionality of the transmit interrupt processing.
> 
> Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>

Please, try to fix this properly.  Unless you have a known chip errata
with the TX interrupt that cannot be worked around reasonably, which
would need to be detailed and explained completely in the commit log
message, you should try to figure out what the real problem is.

Otherwise just tossing everything to a workqueue looks like a hack, at
best.

I suspect you have some kind of race between IRQ processing and the
->ndo_start_xmit() handler, so you end up missing a queue wakeup.
Either that or you end up misprogramming the hardware due to the race.

There is no way I'm applying this as-is.
