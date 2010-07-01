From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Thu, 1 Jul 2010 16:08:16 +0300
Message-ID: <20100701130816.GB32223@redhat.com>
References: <20100624081135.GA937@redhat.com>
 <1277419551.27868.27.camel@w-sridhar.beaverton.ibm.com>
 <20100625101022.GA16321@redhat.com>
 <20100701110708.GA27368@redhat.com>
 <1277983179.1917.10.camel@laptop>
 <1277984603.1917.15.camel@laptop>
 <20100701115507.GA31333@redhat.com>
 <20100701122340.GB31333@redhat.com>
 <1277987657.1917.32.camel@laptop>
 <1277988395.1917.47.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Sridhar Samudrala <sri@us.ibm.com>,
	Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andi Kleen <ak@linux.intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1277988395.1917.47.camel@laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 01, 2010 at 02:46:35PM +0200, Peter Zijlstra wrote:
> On Thu, 2010-07-01 at 14:34 +0200, Peter Zijlstra wrote:
> > On Thu, 2010-07-01 at 15:23 +0300, Michael S. Tsirkin wrote:
> > > 
> > > The patch using this is here:
> > > http://www.mail-archive.com/kvm@vger.kernel.org/msg35411.html
> > > 
> > > It simply copies the affinity from the parent when thread is created.
> > 
> > Sounds like policy, not something the kernel should do..
> 
> The alternative would be using clone() instead of thread_create() and
> inherit everything from the creating task.
> Inheriting from kthreadd and then undoing some aspects just sounds
> like daft policy that really ought to be in userspace.

Yes, that's basically what this patchset is trying to do:
create a workqueue inheriting everything from the creating task.
Sridhar started with an API to do exactly this:
http://linux.derkeiler.com/Mailing-Lists/Kernel/2010-05/msg07478.html

Then we switched to raw kthread to avoid stepping on cwq toes.
Maybe it makes sense to add kthread_clone (in addition to
kthread_create) that would do what you suggest?
If yes, any hints on an implementation?


-- 
MST
