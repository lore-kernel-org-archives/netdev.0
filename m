From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Thu, 01 Jul 2010 14:32:43 +0200
Message-ID: <1277987563.1917.28.camel@laptop>
References: <20100528150830.GB21880@redhat.com>
	 <4BFFE742.2060205@kernel.org> <20100530112925.GB27611@redhat.com>
	 <4C02C99D.9070204@kernel.org> <20100624081135.GA937@redhat.com>
	 <1277419551.27868.27.camel@w-sridhar.beaverton.ibm.com>
	 <20100625101022.GA16321@redhat.com> <20100701110708.GA27368@redhat.com>
	 <1277983179.1917.10.camel@laptop> <1277984603.1917.15.camel@laptop>
	 <20100701115507.GA31333@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
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
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100701115507.GA31333@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-07-01 at 14:55 +0300, Michael S. Tsirkin wrote:

> >  - why can't it set the kernel thread's affinity too?
> 
> It can. However: the threads are started internally by the driver
> when qemu does an ioctl.  What we want to do is give it a sensible
> default affinity. management tool can later tweak it if it wants to.

So have that ioctl return the tid of that new fancy thread and then set
its affinity, stuff it in cgroup, whatever you fancy.

> >  - what happens if someone changes the tasks' affinity?
> 
> We would normally create a cgroup including all internal
> tasks, making it easy to find and change affinity for
> them all if necessary. 

And to stuff them in a cgroup you also need the tid, at which point it
might as well set the affinity from userspace, right?
