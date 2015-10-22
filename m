From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Wed, 21 Oct 2015 20:26:53 -0700
Message-ID: <5628577D.4030300@plumgrid.com>
References: <1445325735-121694-1-git-send-email-xiakaixu@huawei.com>
 <1445325735-121694-2-git-send-email-xiakaixu@huawei.com>
 <5626C5CE.8080809@plumgrid.com>
 <20151021091254.GF2881@worktop.programming.kicks-ass.net>
 <56276968.6070604@huawei.com>
 <20151021113316.GM17308@twins.programming.kicks-ass.net>
 <56277BCE.6030400@huawei.com>
 <20151021121713.GC3604@twins.programming.kicks-ass.net>
 <56279634.5000606@huawei.com> <5628423B.4010504@huawei.com>
 <5628535F.5060505@plumgrid.com> <56285410.3060505@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiakaixu <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>,
	Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56285410.3060505@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/15 8:12 PM, Wangnan (F) wrote:
>
>
> On 2015/10/22 11:09, Alexei Starovoitov wrote:
>> On 10/21/15 6:56 PM, Wangnan (F) wrote:
>>>> One alternative solution I can image is to attach a BPF program
>>>> at sampling like kprobe, and return 0 if we don't want sampling
>>>> take action. Thought?
>>>
>>> Do you think attaching BPF programs to sampling is an acceptable idea?
>>
>> If you mean to extend 'filter' concept to sampling events?
>> So instead of soft_disable of non-local events, you'll attach bpf
>> program to sampling events and use map lookup to decide whether
>> to filter out or not such sampling event?
>
> Yes.
>
>> What pt_regs would be in such case?
>>
>
> Sampling is based on interruption. We can use pt_reg captured by the IRQ
> handler,
> or we can simply pass NULL to those BPF program.

NULL is obviously not ok. Try to answer yourself 'why it's not'.
Clean implementation should add single 'if (..->prog)' to event sampling
critical path. Please don't rush it and think it through.
but the first thing first, please see my fix for bpf_perf_event_read:
http://patchwork.ozlabs.org/patch/534120/
and ack it if it makes sense.
we need to make sure existing stuff is solid, before going further.
