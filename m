From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 0/8] allow bpf attach to tracepoints
Date: Mon, 18 Apr 2016 14:25:08 -0700
Message-ID: <571550B4.4060204@fb.com>
References: <1459831974-2891931-1-git-send-email-ast@fb.com>
 <20160418121311.10c88768@gandalf.local.home> <57153ACF.9090105@fb.com>
 <20160418164713.337cd66f@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:48377 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751830AbcDRV0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 17:26:14 -0400
In-Reply-To: <20160418164713.337cd66f@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/16 1:47 PM, Steven Rostedt wrote:
> On Mon, 18 Apr 2016 12:51:43 -0700
> Alexei Starovoitov <ast@fb.com> wrote:
>
>
>> yeah, it could be added to ftrace as well, but it won't be as effective
>> as perf_trace, since the cost of trace_event_buffer_reserve() in
>> trace_event_raw_event_() handler is significantly higher than
>> perf_trace_buf_alloc() in perf_trace_().
>
> Right, because ftrace optimizes the case where all traces make it into
> the ring buffer (zero copy). Of course, if a filter is a attached, it
> would be trivial to add a case to copy first into a per cpu context
> buffer, and only copy into the ring buffer if the filter succeeds. Hmm,
> that may actually be something I want to do regardless with the current
> filter system.
>
>> Then from the program point of view it wouldn't care how that memory
>> is allocated, so the user tools will just use perf_trace_() style.
>> The only use case I see for bpf with ftrace's tracepoint handler
>> is to work as an actual filter, but we already have filters there...
>
> But wasn't it shown that eBPF could speed up the current filters? If we
> hook into eBPF then we could replace what we have with a faster filter.

yes. Long ago I had a patch to accelerate filter_match_preds(),
but then abandoned it, since, as you said, ftrace is primarily targeting
streaming these events to user space and faster filtering probably
won't be much noticeable to the end user.
So far all the tools around bpf have been capitalizing on
the ability to aggregate data in the kernel.

>> At the same time there is whole ftrace as function tracer. That is
>> very lucrative field for bpf to plug into ;)
>
> Which could get this as a side-effect of this change.

not really as side-effect. That would be the new thing to design.
I only have few rough ideas on how to approach that.
