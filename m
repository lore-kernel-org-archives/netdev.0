From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/sched: latent livelock in dev_deactivate_many() due to
 yield() usage
Date: Wed, 5 Apr 2017 16:55:55 -0700
Message-ID: <CAM_iQpVz5_9C_4=rmWjr6khTAz2jHc_RPGrWb+FXVTA7RSC=5A@mail.gmail.com>
References: <1491107321.13631.33.camel@gmx.de> <CAM_iQpWGMkDaoV2k0DEghqeqb9k=MbpBtT8zH3tvENxLUCefkQ@mail.gmail.com>
 <1491362429.4536.77.camel@gmx.de> <CAM_iQpVTmDfATw1HMPE9NnRBNnhgidz+UZOQDqyeq2uo0=c-+g@mail.gmail.com>
 <1491372741.4536.165.camel@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>
To: Mike Galbraith <efault@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1491372741.4536.165.camel@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 4, 2017 at 11:12 PM, Mike Galbraith <efault@gmx.de> wrote:
> On Tue, 2017-04-04 at 22:25 -0700, Cong Wang wrote:
>> On Tue, Apr 4, 2017 at 8:20 PM, Mike Galbraith <efault@gmx.de> wrote:
>> > -               while (some_qdisc_is_busy(dev))
>> > -                       yield();
>> > +               swait_event_timeout(swait,
>> > !some_qdisc_is_busy(dev), 1);
>> >  }
>>
>> I don't see why this is an improvement even if I don't care about the
>> hardcoded timeout for now... Why the scheduler can make a better
>> decision with swait_event_timeout() than with cond_resched()?
>
> Because sleeping gets you out of the way?  There is no other decision
> the scheduler can make while a SCHED_FIFO task is trying to yield when
> it is the one and only task at it's priority.  The scheduler is doing
> exactly what it is supposed to do, problem is people calling yield()
> tend to think it does something it does not do, which is why it is
> decorated with "if you think you want yield(), think again"
>
> Yes, yield semantics suck rocks, basically don't exist.  Hop in your
> time machine and slap whoever you find claiming responsibility :)

I am not trying to defend for yield(), I am trying to understand when
cond_resched() is not a right solution to replace yield() and when it is.
For me, the dev_deactivate_many() case is, because I interpret
"be nice" differently.

Thanks.
