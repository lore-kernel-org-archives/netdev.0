From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next] bpf: fix bpf_perf_event_read() helper
Date: Thu, 22 Oct 2015 08:53:00 -0700
Message-ID: <5629065C.6020103@plumgrid.com>
References: <1445468283-4592-1-git-send-email-ast@kernel.org>
 <20151022135745.GM3604@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>, Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151022135745.GM3604@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/15 6:57 AM, Peter Zijlstra wrote:
> On Wed, Oct 21, 2015 at 03:58:03PM -0700, Alexei Starovoitov wrote:
>> diff --git a/kernel/events/core.c b/kernel/events/core.c
>> index 64754bfecd70..0b6333265872 100644
>> --- a/kernel/events/core.c
>> +++ b/kernel/events/core.c
>> @@ -3258,7 +3258,7 @@ static inline u64 perf_event_count(struct perf_event *event)
>>   u64 perf_event_read_local(struct perf_event *event)
>>   {
>>   	unsigned long flags;
>> -	u64 val;
>> +	u64 val = -EINVAL;
>
> No, you cannot do this, -EINVAL is a valid count value. You simply must
> not call this function on !local events, ever.

agree. Will keep perf_event_read_local() as-is and do all safety
checks on bpf side.
