From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH] rebalance locks by converting write_lock_bh
	towrite_lock+local_bh_disable
Date: Mon, 25 Nov 2013 11:37:51 +0100
Message-ID: <20131125103751.GC23813@opentech.at>
References: <20131121235402.GA11774@opentech.at> <20131123.143929.975712910203893827.davem@davemloft.net> <20131123235823.GA23670@opentech.at> <AE90C24D6B3A694183C094C60CF0A2F6026B7441@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	eric.dumazet@gmail.com, roque@di.fc.ul.pt, peterz@infradead.org,
	netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hofr.at ([212.69.189.236]:46273 "EHLO mail.hofr.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068Ab3KYKhx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Nov 2013 05:37:53 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7441@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Nov 2013, David Laight wrote:

> > in one of the cases I do not understand the intent behind the split:
> > in net/core/sock.c:lock_sock_fast
> > 
> > 	spin_lock_bh(&sk->sk_lock.slock);
> > 	...
> >         spin_unlock(&sk->sk_lock.slock);
> >         /*
> >          * The sk_lock has mutex_lock() semantics here:
> >          */
> >         mutex_acquire(&sk->sk_lock.dep_map, 0, 0, _RET_IP_);
> >         local_bh_enable();
> > 
> >  I think that
> > 
> > 	spin_lock_bh(&sk->sk_lock.slock);
> > 	...
> >         /*
> >          * The sk_lock has mutex_lock() semantics here:
> >          */
> >         mutex_acquire(&sk->sk_lock.dep_map, 0, 0, _RET_IP_);
> >         spin_unlock_bh(&sk->sk_lock.slock);
> > 
> >  should be equivalent ?
> 
> You've added a lock ordering that wasn't there before.
> Also I suspect that mutex_acquire() might be allowed to sleep,
> whereas you shouldn't sleep with a spin lock held.
>
mutex_acquire is not a lock but a lockdep entry. 
As far as I understand it it nither can sleep nor is there a change of 
order here. Am I missing something ?

thx!
hofrat
