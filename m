From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Any good documentation on RTNL
Date: Wed, 12 Dec 2012 23:37:33 +0000
Message-ID: <1355355453.3149.91.camel@bwh-desktop.uk.solarflarecom.com>
References: <50C9101A.6000906@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33644 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754860Ab2LLXhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 18:37:36 -0500
In-Reply-To: <50C9101A.6000906@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-12-12 at 15:15 -0800, Ben Greear wrote:
> I'm wondering if anyone could point me to some documentation on
> the finer points of what the rtnl_lock() does?  I can't find anything
> overly useful in google or the kernel docs.
> 
> For instance, can the packet rx-logic run (on other threads?) while rtnl is held?
>
> How about tx-logic?

rtnl_lock() is just mutex_lock() on a particular global mutex.  Since
the RX and TX paths obviously don't take such a mutex, it has no effect
on them.

All rtnetlink operations and most net device ioctls are serialised by
this mutex (it's the BKL of networking!).

> In particular, I'm interested to know if it is valid to have
> this state:
> 
> thread 1 holds RTNL, and blocks on thread 2 due to trying to flush a work-queue.
> 
> thread 2 is processing an item on that work-queue, and the work item is sending packets
>    (and blocking for up to 200ms timeout trying to flush a wifi driver's queues).

So long as the workqueue is private (if you're flushing it, I suppose it
must be) then I don't see any problem with that.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
