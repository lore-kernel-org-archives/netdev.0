From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/mv643xx: don't disable the mib timer too early
 and lock properly
Date: Wed, 18 Feb 2009 17:37:44 -0800 (PST)
Message-ID: <20090218.173743.181282052.davem@davemloft.net>
References: <20090216145610.GX17914@xi.wantstofly.org>
	<20090216212815.GA21732@Chamillionaire.breakpoint.cc>
	<20090219010529.GA17914@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian@breakpoint.cc, jeff@garzik.org, netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47609
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751381AbZBSBh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 20:37:59 -0500
In-Reply-To: <20090219010529.GA17914@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Thu, 19 Feb 2009 02:05:29 +0100

> On Mon, Feb 16, 2009 at 10:28:15PM +0100, Sebastian Andrzej Siewior wrote:
> 
> > mib_counters_update() also restarts the timer.
> > So the timer is dequeued, the stats are read and then the timer is
> > enqueued again. This is "okay" unless someone unloads the module.
> > The locking here is also broken:
> > mib_counters_update() grabs just a simple spinlock. The only thing the
> > lock is good for is to protect the timer func against other callers
> > namely mv643xx_eth_stop() && mv643xx_eth_get_ethtool_stats(). That means
> > if the spinlock is taken via the ethtool path and than the timer kicks
> > in then the box will lock up.
> > 
> > Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
> 
> Acked-by: Lennert Buytenhek <buytenh@marvell.com>

Also applied, thanks!
