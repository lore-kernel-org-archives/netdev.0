From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Wed, 21 Oct 2015 20:03:53 +0800
Message-ID: <56277F29.3000704@huawei.com>
References: <1445325735-121694-1-git-send-email-xiakaixu@huawei.com> <1445325735-121694-2-git-send-email-xiakaixu@huawei.com> <5626C5CE.8080809@plumgrid.com> <20151021091254.GF2881@worktop.programming.kicks-ass.net> <56277844.9090201@huawei.com> <20151021115630.GO17308@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Kaixu Xia <xiakaixu@huawei.com>, <davem@davemloft.net>,
	<acme@kernel.org>, <mingo@redhat.com>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>, <linux-kernel@vger.kernel.org>,
	<pi3orama@163.com>, <hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151021115630.GO17308@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/10/21 19:56, Peter Zijlstra wrote:
> On Wed, Oct 21, 2015 at 07:34:28PM +0800, Wangnan (F) wrote:
>>> If you want to actually disable the event: pmu->stop() will make it
>>> stop, and you can restart using pmu->start().xiezuo
>> I also prefer totally disabling event because our goal is to reduce
>> sampling overhead as mush as possible. However, events in perf is
>> CPU bounded, one event in perf cmdline becomes multiple 'perf_event'
>> in kernel in multi-core system. Disabling/enabling events on all CPUs
>> by a BPF program a hard task due to racing, NMI, ...
> But eBPF perf events must already be local afaik. Look at the
> constraints perf_event_read_local() places on the events.

I think soft disabling/enabling is free of this constraint,
because technically speaking a soft-disabled perf event is still
running.

What we want to disable is only sampling action to avoid
being overwhelming by sampling and reduce the overhead which
output those unneeded sampling data to perf.data. I don't
care whether the PMU counter is stopped or still running
too much. Even if it still generate interrupts I think it
should be acceptable because interruption handling can be fast.

Thank you.
