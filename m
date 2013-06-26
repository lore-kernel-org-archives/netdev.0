From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 15/45] rcu: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Wed, 26 Jun 2013 11:33:43 -0400
Message-ID: <1372260823.18733.263.camel@gandalf.local.home>
References: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com>
	 <20130625202755.16593.67819.stgit@srivatsabhat.in.ibm.com>
	 <20130625220026.GG3828@linux.vnet.ibm.com>
	 <51CAF624.6060004@linux.vnet.ibm.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B72AA@saturn3.aculab.com>
	 <20130626143424.GN3828@linux.vnet.ibm.com>
	 <1372258271.18733.256.camel@gandalf.local.home>
	 <20130626152148.GA4405@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, David Laight <David.Laight@ACULAB.COM>,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	peterz@infradead.org, fweisbec@gmail.com,
	linux-kernel@vger.kernel.org, walken@google.com, mingo@kernel.org,
	linux-arch@vger.kernel.org, vincent.guittot@linaro.org,
	xiaoguangrong@linux.vnet.ibm.com, wangyun@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, namhyung@kernel.org, tglx@linutronix.de,
	laijs@cn.fujitsu.com, zhong@linux.vnet.ibm.com,
	netdev@vger.kernel.org, oleg@redhat.com, sbw@mit.edu,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130626152148.GA4405@mtj.dyndns.org>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-26 at 08:21 -0700, Tejun Heo wrote:
> On Wed, Jun 26, 2013 at 10:51:11AM -0400, Steven Rostedt wrote:
> > > It would also increase the latency of CPU-hotunplug operations.
> > 
> > Is that a big deal?
> 
> I thought that was the whole deal with this patchset - making cpu
> hotunplugs lighter and faster mostly for powersaving.  That said, just
> removing stop_machine call would be a pretty good deal and I don't
> know how meaningful reducing CPU hotunplug latency is.  Srivatsa?

I thought the whole deal with this patchset was to remove stop_machine
from CPU hotplug. Why halt all CPUs just to remove one? stomp_machine()
is extremely intrusive for the entire system, where as one CPU making
sure all CPUs schedule isn't very intrusive at all.

I didn't think the idea of this patch set was to make CPU hotplug
faster, just less intrusive to the system.

-- Steve


