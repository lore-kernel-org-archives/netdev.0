From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: convert hashtab lock to raw lock
Date: Sun, 1 Nov 2015 14:56:22 -0800
Message-ID: <20151101225620.GA28272@Alexeis-MacBook-Pro.local>
References: <1446243386-26582-1-git-send-email-yang.shi@linaro.org>
 <20151031000356.GA28070@Alexeis-MacBook-Pro.local>
 <20151031094736.494427d7@grimm.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yang Shi <yang.shi@linaro.org>, ast@kernel.org,
	linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org,
	netdev@vger.kernel.org, linaro-kernel@lists.linaro.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151031094736.494427d7@grimm.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 31, 2015 at 09:47:36AM -0400, Steven Rostedt wrote:
> On Fri, 30 Oct 2015 17:03:58 -0700
> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> 
> > On Fri, Oct 30, 2015 at 03:16:26PM -0700, Yang Shi wrote:
> > > When running bpf samples on rt kernel, it reports the below warning:
> > > 
> > > BUG: sleeping function called from invalid context at kernel/locking/rtmutex.c:917
> > > in_atomic(): 1, irqs_disabled(): 128, pid: 477, name: ping
> > > Preemption disabled at:[<ffff80000017db58>] kprobe_perf_func+0x30/0x228  
> > ...
> > > diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
> > > index 83c209d..972b76b 100644
> > > --- a/kernel/bpf/hashtab.c
> > > +++ b/kernel/bpf/hashtab.c
> > > @@ -17,7 +17,7 @@
> > >  struct bpf_htab {
> > >  	struct bpf_map map;
> > >  	struct hlist_head *buckets;
> > > -	spinlock_t lock;
> > > +	raw_spinlock_t lock;  
> > 
> > How do we address such things in general?
> > I bet there are tons of places around the kernel that
> > call spin_lock from atomic.
> > I'd hate to lose the benefits of lockdep of non-raw spin_lock
> > just to make rt happy.
> 
> You wont lose any benefits of lockdep. Lockdep still checks
> raw_spin_lock(). The only difference between raw_spin_lock and
> spin_lock is that in -rt spin_lock turns into an rt_mutex() and
> raw_spin_lock stays a spin lock.

I see. The patch makes sense then.
Would be good to document this peculiarity of spin_lock.
