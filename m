From: Mike Galbraith <efault@gmx.de>
Subject: Re: net/sched: latent livelock in dev_deactivate_many() due to
 yield() usage
Date: Wed, 05 Apr 2017 08:12:21 +0200
Message-ID: <1491372741.4536.165.camel@gmx.de>
References: <1491107321.13631.33.camel@gmx.de>
         <CAM_iQpWGMkDaoV2k0DEghqeqb9k=MbpBtT8zH3tvENxLUCefkQ@mail.gmail.com>
         <1491362429.4536.77.camel@gmx.de>
         <CAM_iQpVTmDfATw1HMPE9NnRBNnhgidz+UZOQDqyeq2uo0=c-+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:63532 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752282AbdDEGMu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 02:12:50 -0400
In-Reply-To: <CAM_iQpVTmDfATw1HMPE9NnRBNnhgidz+UZOQDqyeq2uo0=c-+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-04 at 22:25 -0700, Cong Wang wrote:
> On Tue, Apr 4, 2017 at 8:20 PM, Mike Galbraith <efault@gmx.de> wrote:
> > -               while (some_qdisc_is_busy(dev))
> > -                       yield();
> > +               swait_event_timeout(swait,
> > !some_qdisc_is_busy(dev), 1);
> >  }
> 
> I don't see why this is an improvement even if I don't care about the
> hardcoded timeout for now... Why the scheduler can make a better
> decision with swait_event_timeout() than with cond_resched()?

Because sleeping gets you out of the way?  There is no other decision
the scheduler can make while a SCHED_FIFO task is trying to yield when
it is the one and only task at it's priority.  The scheduler is doing
exactly what it is supposed to do, problem is people calling yield()
tend to think it does something it does not do, which is why it is
decorated with "if you think you want yield(), think again"

Yes, yield semantics suck rocks, basically don't exist.  Hop in your
time machine and slap whoever you find claiming responsibility :)

	-Mike
