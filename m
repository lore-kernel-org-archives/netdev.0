From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Thu, 22 Oct 2015 15:51:37 +0800
Message-ID: <56289589.1030008@huawei.com>
References: <20151021113316.GM17308@twins.programming.kicks-ass.net> <56277BCE.6030400@huawei.com> <20151021121713.GC3604@twins.programming.kicks-ass.net> <56279634.5000606@huawei.com> <20151021134951.GH3604@twins.programming.kicks-ass.net> <1D2C9396-01CB-4981-B493-EA311F0457E7@163.com> <20151021140921.GI3604@twins.programming.kicks-ass.net> <586A5B33-C9C9-433D-B6E9-019264BF7DDB@163.com> <20151021165758.GK3604@twins.programming.kicks-ass.net> <56284E03.1020008@huawei.com> <20151022073959.GA18791@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>, pi3orama <pi3orama@163.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	xiakaixu <xiakaixu@huawei.com>, <davem@davemloft.net>,
	<acme@kernel.org>, <mingo@redhat.com>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>, <linux-kernel@vger.kernel.org>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151022073959.GA18791@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/10/22 15:39, Ingo Molnar wrote:
> * Wangnan (F) <wangnan0@huawei.com> wrote:
>
[SNIP]
>>
>> In summary, your either-or logic doesn't hold in BPF world. A BPF
>> program can only access perf event in a highly restricted way. We
>> don't allow it calling perf_event_read_local() across core, so it
>> can't.
>>> Urgh, that's still horridly inconsistent. Can we please come up with a
>>> consistent interface to perf?
>> BPF program and kernel module are two different worlds as I said before.
>>
>> I don't think making them to share a common interface is a good idea because
>> such sharing will give BPF programs too much freedom than it really need, then
>> it will be hard prevent them to do something bad. If we really need kernel
>> interface, I think what we need is kernel module, not BPF program.
> What do you mean, as this does not parse for me.

Because I'm not very sure what the meaning of "inconsistent" in
Peter's words...

I think what Peter want us to do is to provide similar (consistent) 
interface
between kernel and eBPF that, if kernel reads from a perf_event through
perf_event_read_local(struct perf_event *), BPF program should
do this work with similar code, or at least similar logic, so
we need to create handler for a perf event, and provide a BPF function
called BPF_FUNC_perf_event_read_local then pass such handler to it.

I don't think like this because if we want kernel interface we'd
better use kernel module, not eBPF so I mentioned kernel module here.

Ingo, do you think BPF inerface should be *consistent* with anything?

Thank you.

> We obviously can (and very likely should) make certain perf functionality
> available to BPF programs.
>
> It should still be a well defined yet flexible iterface, with safe behavior,
> obviously - all in line with existing BPF sandboxing principles.
>
> 'Kernel modules' don't enter this consideration at all, not sure why you mention
> them - all this functionality is also available if CONFIG_MODULES is turned off
> completely.
>
> Thanks,
>
> 	Ingo
>
