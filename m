From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [RFC PATCH 2/2] bpf: Implement bpf_perf_event_sample_enable/disable()
 helpers
Date: Tue, 13 Oct 2015 11:27:27 +0800
Message-ID: <561C7A1F.6040702@huawei.com>
References: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com> <1444640563-159175-3-git-send-email-xiakaixu@huawei.com> <561C0A1E.2080500@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Kaixu Xia <xiakaixu@huawei.com>, <davem@davemloft.net>,
	<acme@kernel.org>, <mingo@redhat.com>, <a.p.zijlstra@chello.nl>,
	<masami.hiramatsu.pt@hitachi.com>, <jolsa@kernel.org>,
	<daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <561C0A1E.2080500@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/10/13 3:29, Alexei Starovoitov wrote:
> On 10/12/15 2:02 AM, Kaixu Xia wrote:
>> +extern const struct bpf_func_proto bpf_perf_event_sample_enable_proto;
>> +extern const struct bpf_func_proto bpf_perf_event_sample_disable_proto;
>
> externs are unnecessary. Just make them static.
> Also I prefer single helper that takes a flag, so we can extend it
> instead of adding func_id for every little operation.
>
> To avoid conflicts if you touch kernel/bpf/* or bpf.h please always
> base your patches of net-next.
>
> > +    atomic_set(&map->perf_sample_disable, 0);
>
> global flag per map is no go.
> events are independent and should be treated as such.
>

Then how to avoid racing? For example, when one core disabling all events
in a map, another core is enabling all of them. This racing may causes 
sereval
perf events in a map dump samples while other events not. To avoid such 
racing
I think some locking must be introduced, then cost is even higher.

The reason why we introduce an atomic pointer is because each operation 
should
controls a set of events, not one event, due to the per-cpu manner of 
perf events.

Thank you.

> Please squash these two patches, since they're part of one logical
> feature. Splitting them like this only makes review harder.
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe 
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
