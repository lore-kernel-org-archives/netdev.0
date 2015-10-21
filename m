From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Wed, 21 Oct 2015 14:17:13 +0200
Message-ID: <20151021121713.GC3604@twins.programming.kicks-ass.net>
References: <1445325735-121694-1-git-send-email-xiakaixu@huawei.com>
 <1445325735-121694-2-git-send-email-xiakaixu@huawei.com>
 <5626C5CE.8080809@plumgrid.com>
 <20151021091254.GF2881@worktop.programming.kicks-ass.net>
 <56276968.6070604@huawei.com>
 <20151021113316.GM17308@twins.programming.kicks-ass.net>
 <56277BCE.6030400@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiakaixu <xiakaixu@huawei.com>,
	Alexei Starovoitov <ast@plumgrid.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56277BCE.6030400@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 21, 2015 at 07:49:34PM +0800, Wangnan (F) wrote:
> If our task is sampling cycle events during a function is running,
> and if two cores start that function overlap:
> 
> Time:   ...................A
> Core 0: sys_write----\
>                       \
>                        \
> Core 1:             sys_write%return
> Core 2: ................sys_write
> 
> Then without counter at time A it is highly possible that
> BPF program on core 1 and core 2 get conflict with each other.
> The final result is we make some of those events be turned on
> and others turned off. Using atomic counter can avoid this
> problem.

But but, how and why can an eBPF program access a !local event? I
thought we had hard restrictions on that.
