From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: net/sched: latent livelock in dev_deactivate_many() due to
 yield() usage
Date: Thu, 6 Apr 2017 13:08:27 +0200
Message-ID: <20170406110827.s3y6goahapq36evy@hirez.programming.kicks-ass.net>
References: <1491107321.13631.33.camel@gmx.de>
 <20170405173105.7f41d7fc@plumbers-lap.home.lan>
 <20170406102844.jr66tcf4qfmlj3wm@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Galbraith <efault@gmx.de>, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170406102844.jr66tcf4qfmlj3wm@hirez.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 06, 2017 at 12:28:44PM +0200, Peter Zijlstra wrote:
> On Wed, Apr 05, 2017 at 05:31:05PM -0700, Stephen Hemminger wrote:
> > On Sun, 02 Apr 2017 06:28:41 +0200
> > Mike Galbraith <efault@gmx.de> wrote:
> > 
> > > Livelock can be triggered by setting kworkers to SCHED_FIFO, then
> > > suspend/resume.. you come back from sleepy-land with a spinning
> > > kworker.  For whatever reason, I can only do that with an enterprise
> > > like config, my standard config refuses to play, but no matter, it's
> > > "Typical broken usage".
> > > 
> > > (yield() should be rendered dead)
> > 
> > The kernel is not normally built to have kworkers run at SCHED_FIFO.
> > The user has do some action to alter the process priorities.
> > 
> > I classify this as user error. We don't support killing kworker threads
> > either.
> 
> PI can boost anybody to FIFO, all you need is to be holding a lock.

Note that this extends to rcu_read_lock(), which can cause boosting
under some cases.
