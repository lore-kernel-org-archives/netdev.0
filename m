From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Move rcu_barrier from rollback_registered_many to
 netdev_run_todo.
Date: Wed, 19 Oct 2011 16:59:54 -0400 (EDT)
Message-ID: <20111019.165954.1408534680992838617.davem@davemloft.net>
References: <m1r52g7zf0.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753892Ab1JSU75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 16:59:57 -0400
In-Reply-To: <m1r52g7zf0.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 14 Oct 2011 01:25:23 -0700

> 
> This patch moves the rcu_barrier from rollback_registered_many
> (inside the rtnl_lock) into netdev_run_todo (just outside the rtnl_lock).
> This allows us to gain the full benefit of sychronize_net calling
> synchronize_rcu_expedited when the rtnl_lock is held.
> 
> The rcu_barrier in rollback_registered_many was originally a synchronize_net
> but was promoted to be a rcu_barrier() when it was found that people were
> unnecessarily hitting the 250ms wait in netdev_wait_allrefs().  Changing
> the rcu_barrier back to a synchronize_net is therefore safe.
> 
> Since we only care about waiting for the rcu callbacks before we get
> to netdev_wait_allrefs() it is also safe to move the wait into
> netdev_run_todo.
> 
> This was tested by creating and destroying 1000 tap devices and observing
> /proc/lock_stat.  /proc/lock_stat reports this change reduces the hold
> times of the rtnl_lock by a factor of 10.  There was no observable
> difference in the amount of time it takes to destroy a network device.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-next, thanks Eric.
