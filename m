From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/3] workqueue: Add an API to create a singlethread
	workqueue attached to the current task's cgroup
Date: Thu, 27 May 2010 20:32:07 +0300
Message-ID: <20100527173207.GA21880@redhat.com>
References: <1274227491.2370.110.camel@w-sridhar.beaverton.ibm.com> <20100527091426.GA6308@redhat.com> <20100527124448.GA4241@redhat.com> <20100527131254.GB7974@redhat.com> <4BFE9ABA.6030907@kernel.org> <20100527163954.GA21710@redhat.com> <4BFEA434.6080405@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleg Nesterov <oleg@redhat.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BFEA434.6080405@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 27, 2010 at 06:56:20PM +0200, Tejun Heo wrote:
> Hello,
> 
> On 05/27/2010 06:39 PM, Michael S. Tsirkin wrote:
> >> Unless you're gonna convert every driver to use this
> >> special kind of workqueue (and what happens when multiple tasks from
> >> different cgroups share the driver?),
> > 
> > We'll then create a workqueue per task. Each workqueue will have the
> > right cgroup. But we are not trying to selve the problem for
> > every driver.
> 
> Ah... I see.  You're gonna use multiple workqueues.  Once concern that
> I have is that this is abuse of workqueue interface to certain level
> and depends on the implementation detail of workqueue rather than its
> intended usage model.

Well, this is why I proposed adding a new API for creating
workqueue within workqueue.c, rather than exposing the task
and attaching it to cgroups in our driver: so that workqueue
maintainers can fix the implementation if it ever changes.

And after all, it's an internal API, we can always change
it later if we need.

> stop_machine() was a similar case and in the
> end it was better served by a different mechanism built on kthread
> directly (cpu_stop).  Wouldn't it be cleaner to use kthread directly
> for your case too?  You're basically trying to use workqueue as a
> frontend to kthread, so...
> 
> Thanks.

Well, yes but we are using APIs like flush_work etc. These are very
handy.  It seems much easier than rolling our own queue on top of kthread.

Makes sense?

> -- 
> tejun
