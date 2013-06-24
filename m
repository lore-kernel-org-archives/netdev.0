From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 01/45] CPU hotplug: Provide APIs to prevent CPU offline
 from atomic context
Date: Mon, 24 Jun 2013 18:49:56 -0400
Message-ID: <1372114196.18733.185.camel@gandalf.local.home>
References: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
	 <20130623133756.19094.41723.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20130623133756.19094.41723.stgit@srivatsabhat.in.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-06-23 at 19:08 +0530, Srivatsa S. Bhat wrote:
> The current CPU offline code uses stop_machine() internally. And disabling
> preemption prevents stop_machine() from taking effect, thus also preventing
> CPUs from going offline, as a side effect.
> 
> There are places where this side-effect of preempt_disable() (or equivalent)
> is used to synchronize with CPU hotplug. Typically these are in atomic
> sections of code, where they can't make use of get/put_online_cpus(), because
> the latter set of APIs can sleep.
> 
> Going forward, we want to get rid of stop_machine() from the CPU hotplug
> offline path. And then, with stop_machine() gone, disabling preemption will
> no longer prevent CPUs from going offline.
> 
> So provide a set of APIs for such atomic hotplug readers, to prevent (any)
> CPUs from going offline. For now, they will default to preempt_disable()
> and preempt_enable() itself, but this will help us do the tree-wide conversion,
> as a preparatory step to remove stop_machine() from CPU hotplug.
> 
> (Besides, it is good documentation as well, since it clearly marks places
> where we synchronize with CPU hotplug, instead of combining it subtly with
> disabling preemption).
> 
> In future, when actually removing stop_machine(), we will alter the
> implementation of these APIs to a suitable synchronization scheme.
> 
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Reviewed-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> ---
> 
>  include/linux/cpu.h |   18 ++++++++++++++++++
>  kernel/cpu.c        |   38 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 56 insertions(+)
