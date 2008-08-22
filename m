From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Fri, 22 Aug 2008 03:16:54 -0700 (PDT)
Message-ID: <20080822.031654.29257013.davem@davemloft.net>
References: <20080822005122.4697.26953.stgit@jtkirshe-mobile.jf.intel.com>
	<20080822005129.4697.77680.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48796
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752651AbYHVKQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 06:16:55 -0400
In-Reply-To: <20080822005129.4697.77680.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 21 Aug 2008 17:51:29 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch restores the multiqueue prio scheduler which was removed along with
> the RR scheduler during the early changes for multiple tx queue support.  This
> patch fixes the regression which occured as a result disabling the multiqueue
> qdisc functionality.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

So how in the world would you use this?

If it's just to tag traffic into different TX queues by priority,
that's not very wise nor desirable.  What's the point?

The TX queues are useful for multiplexing traffic and seperating
the locking and cpu overhead across execution entities in the
system.  They can also be useful for virtualization, but that's
not relevant in this discussion.

The TX queues, on the other hand, are not useful for exposing the
round-robin or whatever algorithm that some cards just so happen to
enforce fairness amongst the TX queues.  That's an implementation
detail.

The truth is, the only reason the RR prio scheduler got added was
because Jamal and myself didn't understand very well how to use these
multiqueue cards, or at least I didn't understand it.

And therefore we, at the time, recommended to implement the RR prio
thing even though now I realize it's totally the wrong thing to do
for TX multiqueue stuff.

I removed this code very much intentionally, and it's only going to go
back if I hear a very good argument for doing so.  And "taking it away
is a regression" is not what I'm looking for, give me something better
than that :)
