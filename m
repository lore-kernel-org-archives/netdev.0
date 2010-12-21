From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bnx2: remove cancel_work_sync() from
 remove_one
Date: Tue, 21 Dec 2010 12:20:00 -0800 (PST)
Message-ID: <20101221.122000.183069341.davem@davemloft.net>
References: <4D08C81D.8020606@kernel.org>
	<20101220.131146.115941299.davem@davemloft.net>
	<20101221105103.GA32744@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101221105103.GA32744@htj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Tue, 21 Dec 2010 11:51:04 +0100

> Yeah, I agree the synchronize_rcu() there would guarantee the actual
> timer completion but as it currently stands it looks a bit too subtle.
> Maybe it's a good idea to add a big fat comment explaining that the
> the timer is guaranteed to stop after close() and how it's guaranteed
> through synchronize_rcu() at the moment?  Also, it might be better to
> use synchronize_sched() there as timer synchronization through
> synchronize_rcu() is more of a happy accident.

I'm not sure the synchronize_*() is even necessary to guarentee
watchdog timer completion.

Like I said, I think the netif_tx_lock() held around both the timer
function itself, and the del_timer() call, are sufficient.

So, this ensures that the watchdog timer either runs to completion or
sees the no-op scheduler attached and returns immediately without
rescheduling the timer.

In any event, I'm going to apply your bnx2 patch to net-next-2.6

Thanks.
