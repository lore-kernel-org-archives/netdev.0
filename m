From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/3] workqueue: Add an API to create a singlethread
	workqueue attached to the current task's cgroup
Date: Thu, 27 May 2010 19:39:54 +0300
Message-ID: <20100527163954.GA21710@redhat.com>
References: <1274227491.2370.110.camel@w-sridhar.beaverton.ibm.com> <20100527091426.GA6308@redhat.com> <20100527124448.GA4241@redhat.com> <20100527131254.GB7974@redhat.com> <4BFE9ABA.6030907@kernel.org>
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
In-Reply-To: <4BFE9ABA.6030907@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 27, 2010 at 06:15:54PM +0200, Tejun Heo wrote:
> Hello,
> 
> On 05/27/2010 03:12 PM, Michael S. Tsirkin wrote:
> >> I don't understand the reasons for this patch, but this doesn't matter.
> > 
> > Depending on userspace application, driver can create a lot of work
> > for a workqueue to handle. By making the workqueue thread
> > belong in a cgroup, we make it possible to the CPU and other
> > resources thus consumed.
> 
> Hmmm.... I don't really get it.  The unit of scheduling in workqueue
> is a work.

Yes. However, we use cgroups to limit when the workqueue itself is scheduled.
This affects all of work done on this workqueue, so it's a bit
of a blunt intrument. Thus we are not trying to apply this
to all drivers, we intend to start with vhost-net.

> Unless you're gonna convert every driver to use this
> special kind of workqueue (and what happens when multiple tasks from
> different cgroups share the driver?),

We'll then create a workqueue per task. Each workqueue will have the
right cgroup. But we are not trying to selve the problem for
every driver.

> I can't see how this is gonna be
> useful.  If you really wanna impose cgroup control on workqueue items,
> you'll have to do it per work item which might lead to the problem of
> priority inversion.

Exactly. cgroup is per-workqueue not per work item.
If driver wants to let administrators control priority
for different kinds of items separately, driver will have
to submit them to separate workqueues.

>  Can you please describe what you're trying to do
> in more detail?
> 
> Thank you.

vhost-net driver is under control from userspace,
it queues potentially a lot of work into the workqueue, which
might load the system beyond the cgroup limits.
And staying within cgroups limits is important for virtualization
where vhost is used.


> -- 
> tejun
