From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 3/4] bpf: Implement function bpf_perf_event_read()
 that get the selected hardware PMU conuter
Date: Wed, 5 Aug 2015 18:21:52 +0200
Message-ID: <20150805162152.GC25159@twins.programming.kicks-ass.net>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
 <1438678696-88289-4-git-send-email-xiakaixu@huawei.com>
 <20150805100425.GZ25159@twins.programming.kicks-ass.net>
 <20150805135317.GZ18673@twins.programming.kicks-ass.net>
 <55C23500.1000207@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kaixu Xia <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55C23500.1000207@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 05, 2015 at 09:08:32AM -0700, Alexei Starovoitov wrote:
> On 8/5/15 6:53 AM, Peter Zijlstra wrote:
> >+	/*
> >+	 * If the event is currently on this CPU, its either a per-task event,
> >+	 * or local to this CPU. Furthermore it means its ACTIVE (otherwise
> >+	 * oncpu == -1).
> >+	 */
> >+	if (event->oncpu == smp_processor_id())
> >+		event->pmu->read(event);
> >+
> >+	val = local64_read(&event->count);
> >+	local_irq_restore(flags);
> >+
> 
> nice! cleaner and faster.
> so raw_spin_lock(&ctx->lock) is not needed, because
> update_*(event) methods are not called, right?

Indeed, and by ensuring the event is indeed local (by force of WARN_ON)
disabling IRQs will avoid counter scheduling and result in a stable
event state.
