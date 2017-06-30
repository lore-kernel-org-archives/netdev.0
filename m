From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH RFC 02/26] task_work: Replace spin_unlock_wait() with
 lock/unlock pair
Date: Fri, 30 Jun 2017 15:50:33 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1706301549240.2177-100000@iolanthe.rowland.org>
References: <20170630192123.GA8471@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        <linux-kernel@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <akpm@linux-foundation.org>,
        <mingo@redhat.com>, <dave@stgolabs.net>,
        <manfred@colorfullife.com>, <tj@kernel.org>, <arnd@arndb.de>,
        <linux-arch@vger.kernel.org>, <will.deacon@arm.com>,
        <peterz@infradead.org>, <parri.andrea@gmail.com>,
        <torvalds@linux-foundation.org>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:57952 "HELO
        iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1752777AbdF3Tue (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 15:50:34 -0400
In-Reply-To: <20170630192123.GA8471@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Jun 2017, Oleg Nesterov wrote:

> On 06/30, Paul E. McKenney wrote:
> >
> > On Fri, Jun 30, 2017 at 05:20:10PM +0200, Oleg Nesterov wrote:
> > >
> > > I do not think the overhead will be noticeable in this particular case.
> > >
> > > But I am not sure I understand why do we want to unlock_wait. Yes I agree,
>                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> if it was not clear, I tried to say "why do we want to _remove_ unlock_wait".
> 
> > > it has some problems, but still...
> > >
> > > The code above looks strange for me. If we are going to repeat this pattern
> > > the perhaps we should add a helper for lock+unlock and name it unlock_wait2 ;)
> > >
> > > If not, we should probably change this code more:
> >
> > This looks -much- better than my patch!  May I have your Signed-off-by?
> 
> Only if you promise to replace all RCU flavors with a single simple implementation
> based on rwlock ;)
> 
> Seriously, of course I won't argue, and it seems that nobody except me likes
> this primitive, but to me spin_unlock_wait() looks like synchronize_rcu(() and
> sometimes it makes sense.

If it looks like synchronize_rcu(), why not actually use 
synchronize_rcu()?

Alan Stern

> Including this particular case. task_work_run() is going to flush/destroy the
> ->task_works list, so it needs to wait until all currently executing "readers"
> (task_work_cancel()'s which have started before ->task_works was updated) have
> completed.
