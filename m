From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 15/45] rcu: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Wed, 26 Jun 2013 23:58:48 +0530
Message-ID: <51CB32E0.3040106@linux.vnet.ibm.com>
References: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com> <20130625202755.16593.67819.stgit@srivatsabhat.in.ibm.com> <20130625220026.GG3828@linux.vnet.ibm.com> <51CAF624.6060004@linux.vnet.ibm.com> <AE90C24D6B3A694183C094C60CF0A2F6026B72AA@saturn3.aculab.com> <20130626143424.GN3828@linux.vnet.ibm.com> <1372258271.18733.256.camel@gandalf.local.home> <20130626152148.GA4405@mtj.dyndns.org> <1372260823.18733.263.camel@gandalf.local.home> <20130626172948.GD4405@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>, peterz@infradead.org,
	fweisbec@gmail.com, oleg@redhat.com, walken@google.com,
	mingo@kernel.org, linux-arch@vger.kernel.org,
	vincent.guittot@linaro.org, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, namhyung@kernel.org, tglx@linutronix.de,
	laijs@cn.fujitsu.com, zhong@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, sbw@mit.edu,
	David Laight <David.Laight@ACULAB.COM>,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130626172948.GD4405@mtj.dyndns.org>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/26/2013 10:59 PM, Tejun Heo wrote:
> Hello,
> 
> On Wed, Jun 26, 2013 at 11:33:43AM -0400, Steven Rostedt wrote:
>> I thought the whole deal with this patchset was to remove stop_machine
>> from CPU hotplug. Why halt all CPUs just to remove one? stomp_machine()
>> is extremely intrusive for the entire system, where as one CPU making
>> sure all CPUs schedule isn't very intrusive at all.
>>
>> I didn't think the idea of this patch set was to make CPU hotplug
>> faster, just less intrusive to the system.
> 
> Yeap, removal of stop_machine is a great improvement in itself.

Absolutely. To make hotplug less intrusive on the system.

>  ISTR
> mentions of hot-unplug latency but I could be mistaken.  Srivatsa, can
> you please chime in on that?
> 

Yes, we were discussing hot-unplug latency for use-cases such as
suspend/resume. We didn't want to make those operations slower in the
process of removing stop_machine() from hotplug.

Regards,
Srivatsa S. Bhat

