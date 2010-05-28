From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] workqueue: Add an API to create a singlethread	workqueue
 attached to the current task's cgroup
Date: Fri, 28 May 2010 17:54:42 +0200
Message-ID: <4BFFE742.2060205@kernel.org>
References: <1274227491.2370.110.camel@w-sridhar.beaverton.ibm.com> <20100527091426.GA6308@redhat.com> <20100527124448.GA4241@redhat.com> <20100527131254.GB7974@redhat.com> <4BFE9ABA.6030907@kernel.org> <20100527163954.GA21710@redhat.com> <4BFEA434.6080405@kernel.org> <20100527173207.GA21880@redhat.com> <4BFEE216.2070807@kernel.org> <20100528150830.GB21880@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
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
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100528150830.GB21880@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 05/28/2010 05:08 PM, Michael S. Tsirkin wrote:
> Well, we have create_singlethread_workqueue, right?
> This is not very different ... is it?
> 
> Just copying structures and code from workqueue.c,
> adding vhost_ in front of it will definitely work:

Sure it will, but you'll probably be able to get away with much less.

> there is nothing magic about the workqueue library.
> But this just involves cut and paste which might be best avoided.

What I'm saying is that some magic needs to be added to workqueue and
if you add this single(!) exception, it will have to be backed out
pretty soon, so it would be better to do it properly now.

> One final idea before we go the cut and paste way: how about
> 'create_workqueue_from_task' that would get a thread and have workqueue
> run there?

You can currently depend on that implementation detail but it's not
the workqueue interface is meant to do.  The single threadedness is
there as execution ordering and concurrency specification and it
doesn't (or rather won't) necessarily mean that a specific single
thread is bound to certain workqueue.

Can you please direct me to have a look at the code.  I'll be happy to
do the conversion for you.

Thanks.

-- 
tejun
