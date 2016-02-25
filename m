From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 1/3] perf: generalize perf_callchain
Date: Thu, 25 Feb 2016 09:27:38 -0800
Message-ID: <56CF398A.8020905@fb.com>
References: <1455767939-2700534-1-git-send-email-ast@fb.com>
 <1455767939-2700534-2-git-send-email-ast@fb.com>
 <20160225164729.GS6356@twins.programming.kicks-ass.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160225164729.GS6356@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/25/16 8:47 AM, Peter Zijlstra wrote:
> On Wed, Feb 17, 2016 at 07:58:57PM -0800, Alexei Starovoitov wrote:
>> +static inline int perf_callchain_store(struct perf_callchain_entry *entry, u64 ip)
>>   {
>> +	if (entry->nr < PERF_MAX_STACK_DEPTH) {
>>   		entry->ip[entry->nr++] = ip;
>> +		return 0;
>> +	} else {
>> +		return -1; /* no more room, stop walking the stack */
>> +	}
>>   }
>
> Why 0 and -1 ?

because that's the interface you had for callbacks in
'struct stacktrace_ops' including a comment there:
/* On negative return stop dumping */

> What's wrong with something like:
>
> static inline bool perf_callchain_store(struct perf_callchain_entry *entry, u64 ip)
> {
> 	if (entry->nr < PERF_MAX_STACK_DEPTH) {
> 		entry->ip[entry->nr++] = ip;
> 		return true;
> 	}
> 	return false;
> }

I would prefer something like this as well, but it would look
inconsistent with what is already there. To make it bool
one would need to change struct stacktrace_ops for all archs
and touch a lot of files all over the tree.
Way more than 51 insertions(+), 29 deletions(-) as this patch did
for no real gain.
It's better to be consistent with existing code.
