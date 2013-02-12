From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] netpoll: Fix __netpoll_rcu_free so that it can
 hold the rtnl lock
Date: Mon, 11 Feb 2013 19:19:45 -0500 (EST)
Message-ID: <20130211.191945.29632365432532819.davem@davemloft.net>
References: <1360248961-30721-1-git-send-email-nhorman@tuxdriver.com>
	<1360614331-29247-1-git-send-email-nhorman@tuxdriver.com>
	<1360614331-29247-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com, eric.dumazet@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43861 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760679Ab3BLATq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 19:19:46 -0500
In-Reply-To: <1360614331-29247-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 11 Feb 2013 15:25:30 -0500

> __netpoll_rcu_free is used to free netpoll structures when the rtnl_lock is
> already held.  The mechanism is used to asynchronously call __netpoll_cleanup
> outside of the holding of the rtnl_lock, so as to avoid deadlock.
> Unfortunately, __netpoll_cleanup modifies pointers (dev->np), which means the
> rtnl_lock must be held while calling it.  Further, it cannot be held, because
> rcu callbacks may be issued in softirq contexts, which cannot sleep.
> 
> Fix this by converting the rcu callback to a work queue that is guaranteed to
> get scheduled in process context, so that we can hold the rtnl properly while
> calling __netpoll_cleanup
> 
> Tested successfully by myself.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
