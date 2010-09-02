From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Fix lockdep warning on est_tree_lock in
 gen_estimator
Date: Thu, 02 Sep 2010 13:59:29 -0700 (PDT)
Message-ID: <20100902.135929.15241881.davem@davemloft.net>
References: <20100902201257.GA3089@del.dom.local>
	<1283460813.3699.243.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50240
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753478Ab0IBU7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 16:59:12 -0400
In-Reply-To: <1283460813.3699.243.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Sep 2010 22:53:33 +0200

> Maybe after a night, I'll understand ?
> 
> est_tree_lock is only taken by process context, and I dont see what can
> be the problem. Are you sure its not a lockdep false positive, or that
> the real bug is elsewhere ?
> 
> Sure, we can block BH everywhere, it will reduce bugs and lockdep
> alarms, but I would like to understand before, why its needed.
> 
> If you believe est_tree_lock can be taken by a softirq handler, please
> tell me ;)

Hint: est->stats_lock is actually a pointer to a qdisc->lock

Therefore we must comply with the rules of qdisc locking if we wish
to take est->stats_lock in conjunction with est_tree_lock.

The strange mention of qdisc_tx_lock changing state inside of
est_timer() in the lockdep warning should have been the clue :-)
