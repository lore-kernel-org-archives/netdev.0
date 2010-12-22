From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH net-next-2.6] bnx2: remove cancel_work_sync() from
 remove_one
Date: Wed, 22 Dec 2010 09:48:19 +0100
Message-ID: <20101222084816.GA27861@htj.dyndns.org>
References: <4D08C81D.8020606@kernel.org>
 <20101220.131146.115941299.davem@davemloft.net>
 <20101221105103.GA32744@htj.dyndns.org>
 <20101221.122000.183069341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101221.122000.183069341.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Tue, Dec 21, 2010 at 12:20:00PM -0800, David Miller wrote:
> From: Tejun Heo <tj@kernel.org>
> Date: Tue, 21 Dec 2010 11:51:04 +0100
> 
> > Yeah, I agree the synchronize_rcu() there would guarantee the actual
> > timer completion but as it currently stands it looks a bit too subtle.
> > Maybe it's a good idea to add a big fat comment explaining that the
> > the timer is guaranteed to stop after close() and how it's guaranteed
> > through synchronize_rcu() at the moment?  Also, it might be better to
> > use synchronize_sched() there as timer synchronization through
> > synchronize_rcu() is more of a happy accident.
> 
> I'm not sure the synchronize_*() is even necessary to guarentee
> watchdog timer completion.
> 
> Like I said, I think the netif_tx_lock() held around both the timer
> function itself, and the del_timer() call, are sufficient.
> 
> So, this ensures that the watchdog timer either runs to completion or
> sees the no-op scheduler attached and returns immediately without
> rescheduling the timer.
> 
> In any event, I'm going to apply your bnx2 patch to net-next-2.6

Oh, yeah, all is good if the timer is guaranteed to stop after close
one way or the other.  Thanks and happy new year!

-- 
tejun
