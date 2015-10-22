From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH v2 net-next] bpf: fix bpf_perf_event_read() helper
Date: Thu, 22 Oct 2015 15:39:52 +0800
Message-ID: <562892C8.7030108@huawei.com>
References: <1445468283-4592-1-git-send-email-ast@kernel.org> <562874A5.1050307@huawei.com> <5628807C.3040305@plumgrid.com>
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
In-Reply-To: <5628807C.3040305@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/10/22 14:21, Alexei Starovoitov wrote:
> On 10/21/15 10:31 PM, Wangnan (F) wrote:
>>> +    if ((attr->type != PERF_TYPE_RAW &&
>>> +         !(attr->type == PERF_TYPE_SOFTWARE &&
>>> +           attr->config == PERF_COUNT_SW_BPF_OUTPUT) &&
>>> +         attr->type != PERF_TYPE_HARDWARE) ||
>>> +        attr->inherit) {
>>
>> This 'if' statement is so complex. What about using a inline function
>> instead?
>
> hmm. don't see how inline function will help readability.
>

For example (not tested):

  static inline bool perf_event_can_insert_to_map(struct perf_event_attr 
*attr)
  {
     /* is inherit? */
     if (attr->inherit)
         return false;

     /* is software event? */
     if (attr->type == PERF_TYPE_SOFTWARE)
         if (attr->config == PERF_COUNT_SW_BPF_OUTPUT)
             return true;
         else
             return false;

     /* Comment... */
     if (attr->type == PERF_TYPE_RAW)
         return true;
     if (attr->type == PERF_TYPE_HARDWARE)
         return true;
     return false;
  }

  ...
  if (!perf_event_can_insert_to_map(attr))
     ....

Do you think redability is improved?

Thank you.
