From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next] bpf: fix bpf_perf_event_read() helper
Date: Wed, 21 Oct 2015 22:00:12 -0700
Message-ID: <56286D5C.2060009@plumgrid.com>
References: <1445468283-4592-1-git-send-email-ast@kernel.org>
 <56286ACD.3060604@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	He Kuang <hekuang@huawei.com>, Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34607 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbbJVFAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 01:00:16 -0400
Received: by padhk11 with SMTP id hk11so76041609pad.1
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 22:00:15 -0700 (PDT)
In-Reply-To: <56286ACD.3060604@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/15 9:49 PM, Wangnan (F) wrote:
> After applying this patch I'm unable to use perf passing perf_event
> again like this:

please do not top post and trim your replies.

>   # perf record -a -e evt=cycles -e
> ./test_config_map.c/maps.pmu_map.event=evt/ --exclude-perf ls
>
> With -v it output:
>
> ...
> adding perf_bpf_probe:func_write
> adding perf_bpf_probe:func_write to 0x367d6a0
> add bpf event perf_bpf_probe:func_write_return and attach bpf program 6
> adding perf_bpf_probe:func_write_return
> adding perf_bpf_probe:func_write_return to 0x3a7fc40
> mmap size 528384B
> ERROR: failed to insert value to pmu_map[0]
> ERROR: Apply config to BPF failed: Invalid option for map, add -v to see
> detail
> Opening /sys/kernel/debug/tracing//kprobe_events write=
> ...
>
> Looks like perf sets attr.inherit for cycles? I'll look into this problem.

yes. that's perf default.
How did it even work before?!
I was testing with your samples/bpf/tracex6 that sets inherit to zero.
