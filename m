From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/sched: latent livelock in dev_deactivate_many() due to
 yield() usage
Date: Tue, 4 Apr 2017 22:25:19 -0700
Message-ID: <CAM_iQpVTmDfATw1HMPE9NnRBNnhgidz+UZOQDqyeq2uo0=c-+g@mail.gmail.com>
References: <1491107321.13631.33.camel@gmx.de> <CAM_iQpWGMkDaoV2k0DEghqeqb9k=MbpBtT8zH3tvENxLUCefkQ@mail.gmail.com>
 <1491362429.4536.77.camel@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>
To: Mike Galbraith <efault@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1491362429.4536.77.camel@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 4, 2017 at 8:20 PM, Mike Galbraith <efault@gmx.de> wrote:
> -               while (some_qdisc_is_busy(dev))
> -                       yield();
> +               swait_event_timeout(swait, !some_qdisc_is_busy(dev), 1);
>  }

I don't see why this is an improvement even if I don't care about the
hardcoded timeout for now... Why the scheduler can make a better
decision with swait_event_timeout() than with cond_resched()?
