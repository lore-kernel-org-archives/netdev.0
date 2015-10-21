From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Wed, 21 Oct 2015 13:56:30 +0200
Message-ID: <20151021115630.GO17308@twins.programming.kicks-ass.net>
References: <1445325735-121694-1-git-send-email-xiakaixu@huawei.com>
 <1445325735-121694-2-git-send-email-xiakaixu@huawei.com>
 <5626C5CE.8080809@plumgrid.com>
 <20151021091254.GF2881@worktop.programming.kicks-ass.net>
 <56277844.9090201@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Kaixu Xia <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56277844.9090201@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 21, 2015 at 07:34:28PM +0800, Wangnan (F) wrote:
> >If you want to actually disable the event: pmu->stop() will make it
> >stop, and you can restart using pmu->start().xiezuo
> 
> I also prefer totally disabling event because our goal is to reduce
> sampling overhead as mush as possible. However, events in perf is
> CPU bounded, one event in perf cmdline becomes multiple 'perf_event'
> in kernel in multi-core system. Disabling/enabling events on all CPUs
> by a BPF program a hard task due to racing, NMI, ...

But eBPF perf events must already be local afaik. Look at the
constraints perf_event_read_local() places on the events.
