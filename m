From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: netlink locking warnings in 2.6.21-rc7-mm1
Date: Tue, 24 Apr 2007 14:26:40 -0700
Message-ID: <20070424142640.eedffa9d.akpm@linux-foundation.org>
References: <20070424124250.d55789cd.akpm@linux-foundation.org>
	<20070424.142008.35506725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:35956 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423125AbXDXV0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 17:26:47 -0400
In-Reply-To: <20070424.142008.35506725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Apr 2007 14:20:08 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Tue, 24 Apr 2007 12:42:50 -0700
> 
> > void debug_mutex_unlock(struct mutex *lock)
> > {
> > 	if (unlikely(!debug_locks))
> > 		return;
> > 
> > -->	DEBUG_LOCKS_WARN_ON(lock->owner != current_thread_info());
> > 	DEBUG_LOCKS_WARN_ON(lock->magic != lock);
> > 
> > so it's complaining that cb_mutex is being release by a thread other than
> > the one which acquired it.  I'm unable to reproduce it with their config,
> > naturally.
> 
> Is it illegal to sleep with a mutex held?

Nope.  Otherwise we'd use spinlocks everywhere ;)

> I think I see what might be the problem, nlk->cb_mutex is set
> to "rtnl_mutex" and this is used for other purposes in various
> code paths here, maybe there is a double mutex_unlock() or
> similar due to that?

ooh, this might explain my mysterious ASSERT_RTNL failures, perhaps.
Am ready to test a patch.
