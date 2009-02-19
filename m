From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH v2] net/mv643xx: don't disable the mib timer too early and lock properly
Date: Thu, 19 Feb 2009 02:05:29 +0100
Message-ID: <20090219010529.GA17914@xi.wantstofly.org>
References: <20090215092719.GB12280@Chamillionaire.breakpoint.cc> <20090216082922.GA18030@Chamillionaire.breakpoint.cc> <20090216145610.GX17914@xi.wantstofly.org> <20090216212815.GA21732@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>,
	jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:40453 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbZBSBFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 20:05:31 -0500
Content-Disposition: inline
In-Reply-To: <20090216212815.GA21732@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 16, 2009 at 10:28:15PM +0100, Sebastian Andrzej Siewior wrote:

> mib_counters_update() also restarts the timer.
> So the timer is dequeued, the stats are read and then the timer is
> enqueued again. This is "okay" unless someone unloads the module.
> The locking here is also broken:
> mib_counters_update() grabs just a simple spinlock. The only thing the
> lock is good for is to protect the timer func against other callers
> namely mv643xx_eth_stop() && mv643xx_eth_get_ethtool_stats(). That means
> if the spinlock is taken via the ethtool path and than the timer kicks
> in then the box will lock up.
> 
> Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>

Acked-by: Lennert Buytenhek <buytenh@marvell.com>
