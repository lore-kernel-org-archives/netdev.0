From: David Miller <davem@davemloft.net>
Subject: Re: ppp: Fix race condition with queue start/stop
Date: Fri, 13 Apr 2012 13:07:07 -0400 (EDT)
Message-ID: <20120413.130707.1734763456520627875.davem@davemloft.net>
References: <20120403.172958.144419545310336164.davem@davemloft.net>
	<1333915104.31812.61.camel@shinybook.infradead.org>
	<1333915304.31812.63.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848Ab2DMRIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 13:08:13 -0400
In-Reply-To: <1333915304.31812.63.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 08 Apr 2012 21:01:44 +0100

> Commit e675f0cc9a872fd152edc0c77acfed19bf28b81e ("ppp: Don't stop and
> restart queue on every TX packet") introduced a race condition which
> could leave the net queue stopped even when the channel is no longer
> busy. By calling netif_stop_queue() from ppp_start_xmit(), based on the
> return value from ppp_xmit_process() but *after* all the locks have been
> dropped, we could potentially do so *after* the channel has actually
> finished transmitting and attempted to re-wake the queue.
> 
> Fix this by moving the netif_stop_queue() into ppp_xmit_process() under
> the xmit lock. I hadn't done this previously, because it gets called
> from other places than ppp_start_xmit(). But I now think it's the better
> option. The net queue *should* be stopped if the channel becomes
> congested due to writes from pppd, anyway.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Applied, thanks David.
