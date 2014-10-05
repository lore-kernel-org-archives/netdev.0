From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] team: add rescheduling jiffy delay on !rtnl_trylock
Date: Sat, 4 Oct 2014 22:13:25 -0400
Message-ID: <20141005021325.GB8549@htj.dyndns.org>
References: <20140929115445.40221d8e@jlaw-desktop.mno.stratus.com>
 <20140929160601.GD15925@htj.dyndns.org>
 <20141002064308.GN5015@linux.vnet.ibm.com>
 <20141003153701.7c7da030@jlaw-desktop.mno.stratus.com>
 <20141004083732.GG5015@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Lawrence <joe.lawrence@stratus.com>, netdev@vger.kernel.org,
	Jiri Pirko <jiri@resnulli.us>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:52056 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610AbaJECN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 22:13:28 -0400
Received: by mail-qa0-f51.google.com with SMTP id k15so2316029qaq.10
        for <netdev@vger.kernel.org>; Sat, 04 Oct 2014 19:13:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20141004083732.GG5015@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Sat, Oct 04, 2014 at 01:37:32AM -0700, Paul E. McKenney wrote:
> On Fri, Oct 03, 2014 at 03:37:01PM -0400, Joe Lawrence wrote:
> > I gave this a spin, probably inserting the call in the wrong place:
> > 
> > diff --git a/kernel/workqueue.c b/kernel/workqueue.c
> > index 5dbe22a..77f128e 100644
> > --- a/kernel/workqueue.c
> > +++ b/kernel/workqueue.c
> > @@ -2045,7 +2045,8 @@ __acquires(&pool->lock)
> >          * indefinitely requeue itself while all other CPUs are trapped in
> >          * stop_machine.
> >          */
> > -       cond_resched();
> > +       if (!cond_resched())
> > +               rcu_note_context_switch(raw_smp_processor_id());
> > 
> >         spin_lock_irq(&pool->lock);
> 
> If the cond_resched() is in the right place, then you should be good.

Yeah, it looks good to me.

> FWIW, there is a cond_resched_rcu_qs() that should be going into the next
> merge window that could be used in place of the above two lines.  This is
> commit bde6c3aa9930 in -tip.

That sounds even better.

Joe, can you please send a patch with proper SOB and description?

Thanks.

-- 
tejun
