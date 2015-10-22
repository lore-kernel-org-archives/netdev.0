From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Thu, 22 Oct 2015 10:46:27 +0800
Message-ID: <56284E03.1020008@huawei.com>
References: <20151021091254.GF2881@worktop.programming.kicks-ass.net> <56276968.6070604@huawei.com> <20151021113316.GM17308@twins.programming.kicks-ass.net> <56277BCE.6030400@huawei.com> <20151021121713.GC3604@twins.programming.kicks-ass.net> <56279634.5000606@huawei.com> <20151021134951.GH3604@twins.programming.kicks-ass.net> <1D2C9396-01CB-4981-B493-EA311F0457E7@163.com> <20151021140921.GI3604@twins.programming.kicks-ass.net> <586A5B33-C9C9-433D-B6E9-019264BF7DDB@163.com> <20151021165758.GK3604@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	xiakaixu <xiakaixu@huawei.com>, <davem@davemloft.net>,
	<acme@kernel.org>, <mingo@redhat.com>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>, <linux-kernel@vger.kernel.org>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>, pi3orama <pi3orama@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:48500 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756568AbbJVCvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 22:51:18 -0400
In-Reply-To: <20151021165758.GK3604@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2015/10/22 0:57, Peter Zijlstra wrote:
> On Wed, Oct 21, 2015 at 11:06:47PM +0800, pi3orama wrote:
>>> So explain; how does this eBPF stuff work.
>> I think I get your point this time, and let me explain the eBPF stuff to you.
>>
>> You are aware that BPF programmer can break the system in this way:
>>
>> A=get_non_local_perf_event()
>> perf_event_read_local(A)
>> BOOM!
>>
>> However the above logic is impossible because BPF program can't work this
>> way.
>>
>> First of all, it is impossible for a BPF program directly invoke a
>> kernel function.  Doesn't like kernel module, BPF program can only
>> invoke functions designed for them, like what this patch does. So the
>> ability of BPF programs is strictly restricted by kernel. If we don't
>> allow BPF program call perf_event_read_local() across core, we can
>> check this and return error in function we provide for them.
>>
>> Second: there's no way for a BPF program directly access a perf event.
>> All perf events have to be wrapped by a map and be accessed by BPF
>> functions described above. We don't allow BPF program fetch array
>> element from that map. So pointers of perf event is safely protected
>> from BPF program.
>>
>> In summary, your either-or logic doesn't hold in BPF world. A BPF
>> program can only access perf event in a highly restricted way. We
>> don't allow it calling perf_event_read_local() across core, so it
>> can't.
> Urgh, that's still horridly inconsistent. Can we please come up with a
> consistent interface to perf?

BPF program and kernel module are two different worlds as I said before.

I don't think making them to share a common interface is a good idea
because such sharing will give BPF programs too much freedom than it
really need, then it will be hard prevent them to do something bad.
If we really need kernel interface, I think what we need is kernel
module, not BPF program.

Thank you.
