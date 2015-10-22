From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH v2 net-next] bpf: fix bpf_perf_event_read() helper
Date: Thu, 22 Oct 2015 13:30:02 +0800
Message-ID: <5628745A.4080204@huawei.com>
References: <1445468283-4592-1-git-send-email-ast@kernel.org> <56286ACD.3060604@huawei.com> <56286D5C.2060009@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	He Kuang <hekuang@huawei.com>, Kaixu Xia <xiakaixu@huawei.com>,
	"Daniel Borkmann" <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56286D5C.2060009@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/10/22 13:00, Alexei Starovoitov wrote:
> On 10/21/15 9:49 PM, Wangnan (F) wrote:
>> After applying this patch I'm unable to use perf passing perf_event
>> again like this:
>
> please do not top post and trim your replies.
>
>>   # perf record -a -e evt=cycles -e
>> ./test_config_map.c/maps.pmu_map.event=evt/ --exclude-perf ls
>>
>> With -v it output:
>>
>> ...
>> adding perf_bpf_probe:func_write
>> adding perf_bpf_probe:func_write to 0x367d6a0
>> add bpf event perf_bpf_probe:func_write_return and attach bpf program 6
>> adding perf_bpf_probe:func_write_return
>> adding perf_bpf_probe:func_write_return to 0x3a7fc40
>> mmap size 528384B
>> ERROR: failed to insert value to pmu_map[0]
>> ERROR: Apply config to BPF failed: Invalid option for map, add -v to see
>> detail
>> Opening /sys/kernel/debug/tracing//kprobe_events write=
>> ...
>>
>> Looks like perf sets attr.inherit for cycles? I'll look into this 
>> problem.
>
> yes. that's perf default.
> How did it even work before?!
> I was testing with your samples/bpf/tracex6 that sets inherit to zero.
>

Tested perf record -i option and it works for me:

# echo "" > /sys/kernel/debug/tracing/trace
# perf record -i -a -e evt=cycles -e 
./test_config_map.c/maps.pmu_map.event=evt/ --exclude-perf ls
# cat /sys/kernel/debug/tracing/trace  | grep ls
               ls-8227  [001] dN..  2526.184611: : pmu inc: 82270
               ls-8227  [001] dN..  2526.184626: : pmu inc: 40951
               ls-8227  [001] dN..  2526.184642: : pmu inc: 50659
               ls-8227  [001] dN..  2526.184657: : pmu inc: 43511
               ls-8227  [001] dN..  2526.184675: : pmu inc: 56921
...
And no warning message found in dmesg.

So I think your fix is good, we should improve perf.

Thank you.
