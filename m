From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Thu, 22 Oct 2015 11:49:02 +0200
Message-ID: <20151022094902.GM2508@worktop.programming.kicks-ass.net>
References: <5626C5CE.8080809@plumgrid.com>
 <20151021091254.GF2881@worktop.programming.kicks-ass.net>
 <56276968.6070604@huawei.com>
 <20151021113316.GM17308@twins.programming.kicks-ass.net>
 <56277BCE.6030400@huawei.com>
 <20151021121713.GC3604@twins.programming.kicks-ass.net>
 <56279634.5000606@huawei.com>
 <5628423B.4010504@huawei.com>
 <5628535F.5060505@plumgrid.com>
 <56285410.3060505@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	xiakaixu <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56285410.3060505@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2015 at 11:12:16AM +0800, Wangnan (F) wrote:
> On 2015/10/22 11:09, Alexei Starovoitov wrote:
> >On 10/21/15 6:56 PM, Wangnan (F) wrote:
> >>>One alternative solution I can image is to attach a BPF program
> >>>at sampling like kprobe, and return 0 if we don't want sampling
> >>>take action. Thought?
> >>
> >>Do you think attaching BPF programs to sampling is an acceptable idea?
> >
> >If you mean to extend 'filter' concept to sampling events?
> >So instead of soft_disable of non-local events, you'll attach bpf
> >program to sampling events and use map lookup to decide whether
> >to filter out or not such sampling event?
> 
> Yes.

One could overload or stack the overflow handler I suppose. But this
would be in line with the software/tracepoint events calling eBPF muck
on trigger, right?

> >What pt_regs would be in such case?

> Sampling is based on interruption. We can use pt_reg captured by the IRQ
> handler,

s/IRQ/NMI/

Also, we 'edit' the pt_regs on the way down to the overflow handler as
sometimes 'better' information can be had from PMU state. But a pt_regs
is available there.
