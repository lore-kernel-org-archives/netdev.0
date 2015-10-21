From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Wed, 21 Oct 2015 14:19:49 -0700
Message-ID: <56280175.8060404@plumgrid.com>
References: <20151021091254.GF2881@worktop.programming.kicks-ass.net>
 <56276968.6070604@huawei.com>
 <20151021113316.GM17308@twins.programming.kicks-ass.net>
 <56277BCE.6030400@huawei.com>
 <20151021121713.GC3604@twins.programming.kicks-ass.net>
 <56279634.5000606@huawei.com>
 <20151021134951.GH3604@twins.programming.kicks-ass.net>
 <1D2C9396-01CB-4981-B493-EA311F0457E7@163.com>
 <20151021140921.GI3604@twins.programming.kicks-ass.net>
 <586A5B33-C9C9-433D-B6E9-019264BF7DDB@163.com>
 <20151021165758.GK3604@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Wangnan (F)" <wangnan0@huawei.com>,
	xiakaixu <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net,
	linux-kernel@vger.kernel.org, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>, pi3orama <pi3orama@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151021165758.GK3604@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/15 9:57 AM, Peter Zijlstra wrote:
>> In summary, your either-or logic doesn't hold in BPF world. A BPF
>> >program can only access perf event in a highly restricted way. We
>> >don't allow it calling perf_event_read_local() across core, so it
>> >can't.

That's actually broken. My fault as well, since I didn't review that
patch carefully enough. Will send a fix in a second.
No matter what bpf program does that should never be a kernel splat.

> Urgh, that's still horridly inconsistent. Can we please come up with a
> consistent interface to perf?

I had the same concerns during v1-v4 series of this set.
My suggestion was to do ioctl(enable/disable) of events from userspace
after receiving notification from kernel via my bpf_perf_event_output()
helper.
Wangnan's argument was that display refresh happens often and it's fast,
so the time taken by user space to enable events on all cpus is too
slow and ioctl does ipi and disturbs other cpus even more.
So soft_disable done by the program to enable/disable particular events
on all cpus kinda makes sense.
