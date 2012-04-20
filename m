From: Yong Zhang <yong.zhang0@gmail.com>
Subject: Re: [PATCH 1/2] workqueue: Catch more locking problems with
 flush_work()
Date: Fri, 20 Apr 2012 16:32:02 +0800
Message-ID: <20120420083202.GB17846@zhy>
References: <1334805958-29119-1-git-send-email-sboyd@codeaurora.org>
 <20120419081002.GB3963@zhy>
 <4F905B30.4080501@codeaurora.org>
 <20120420052633.GA16219@zhy>
 <20120420060101.GA16563@zhy>
 <4F9101A7.5010100@codeaurora.org>
 <20120420071759.GA17846@zhy>
 <4F911BCB.7010809@codeaurora.org>
Reply-To: Yong Zhang <yong.zhang0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F911BCB.7010809@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 20, 2012 at 01:18:19AM -0700, Stephen Boyd wrote:
> On 4/20/2012 12:18 AM, Yong Zhang wrote:
> > On Thu, Apr 19, 2012 at 11:26:47PM -0700, Stephen Boyd wrote:
> >> complain in the case where the work is not queued. That case is not a
> >> false positive. We will get a lockdep warning if the work is running
> > IIRC, flush_work() is just a nop when a work is not queued nor running.
> 
> Agreed, but it's better to always print a lockdep warning instead of
> only when the deadlock is going to occur.

It will IMHO.

> 
> >
> >> (when start_flush_work() returns true) solely with the
> >> lock_map_acquire() on cwq->wq->lockdep_map.
> > Yeah, that is the point we use lockdep to detect deadlock for workqueue.
> >
> > But when looking at start_flush_work(), for some case
> > !(cwq->wq->saved_max_active == 1 || cwq->wq->flags & WQ_RESCUER),
> > lock_map_acquire_read() is called, but recursive read is not added to
> > the chain list. So when lock_map_acquire_read(&cwq->wq->lockdep_map)
> > is called, deadlock will not be detected. I hope you don't hit that
> > special case.
> 
> Hmm. Originally I had what you suggested in my patch but I left it out
> because I wasn't sure if it would cause false positives.
> Do you see any
> possibility for false positives?

No, I don't. My test indeed show nothing (just build and boot).

>I'll add it back in if not.

It's great if you can try it :)

Thanks,
Yong
