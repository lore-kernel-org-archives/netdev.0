From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 2/3] bpf: introduce BPF_MAP_TYPE_STACK_TRACE
Date: Thu, 25 Feb 2016 08:42:40 -0800
Message-ID: <56CF2F00.2020608@fb.com>
References: <1455767939-2700534-1-git-send-email-ast@fb.com>
 <1455767939-2700534-3-git-send-email-ast@fb.com>
 <20160225142328.GN6357@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Wang Nan <wangnan0@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:30242 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759877AbcBYQnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 11:43:50 -0500
In-Reply-To: <20160225142328.GN6357@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/25/16 6:23 AM, Peter Zijlstra wrote:
>> +	id = hash & (smap->n_buckets - 1);
> Its not at all clear where the corresponding rcu_read_lock() is at.
>
>> >+	bucket = rcu_dereference(smap->buckets[id]);

bpf programs of all types are always executing under rcu_read_lock().
This is fundamental for maps and majority of the helpers
that's why there is no WARN_ON(rcu_read_lock_held) in this helper,
since we already have it in many other places.
The rcu_read_lock() for kprobe type is in trace_call_bpf().
