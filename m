From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 3/4] bpf: Implement function bpf_perf_event_read()
 that get the selected hardware PMU conuter
Date: Wed, 5 Aug 2015 15:59:32 +0200
Message-ID: <20150805135932.GA18673@twins.programming.kicks-ass.net>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
 <1438678696-88289-4-git-send-email-xiakaixu@huawei.com>
 <20150805100425.GZ25159@twins.programming.kicks-ass.net>
 <20150805135317.GZ18673@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@plumgrid.com, davem@davemloft.net, acme@kernel.org,
	mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150805135317.GZ18673@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 05, 2015 at 03:53:17PM +0200, Peter Zijlstra wrote:
> +/*
> + * NMI-safe method to read a local event, that is an event that
> + * is:
> + *   - either for the current task, or for this CPU
> + *   - does not have inherit set, for inherited task events
> + *     will not be local and we cannot read them atomically
> + *   - must not have a pmu::count method
> + */
> +u64 perf_event_read_local(struct perf_event *event)
> +{
> +	unsigned long flags;
> +	u64 val;
> +
> +	/*
> +	 * Disabling interrupts avoids all counter scheduling (context
> +	 * switches, timer based rotation and IPIs).
> +	 */
> +	local_irq_safe(flags);

Hmm, I think local_irq_save(flags) will compile much better. Obviously
this patch hasn't seen a compiler up close.
