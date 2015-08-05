From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v6 3/4] bpf: Implement function bpf_perf_event_read() that
 get the selected hardware PMU conuter
Date: Wed, 5 Aug 2015 08:59:36 -0700
Message-ID: <55C232E8.50201@plumgrid.com>
References: <1438678696-88289-1-git-send-email-xiakaixu@huawei.com>
 <1438678696-88289-4-git-send-email-xiakaixu@huawei.com>
 <20150805100425.GZ25159@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, acme@kernel.org, mingo@redhat.com,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>,
	Kaixu Xia <xiakaixu@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150805100425.GZ25159@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/5/15 3:04 AM, Peter Zijlstra wrote:
>> >+	__perf_event_read(event);
>> >+	return perf_event_count(event);
>> >+}
> Also, you probably want a WARN_ON(in_nmi()) there, this function is
> _NOT_  NMI safe.

we check that very early on:
unsigned int trace_call_bpf(struct bpf_prog *prog, void *ctx)
{
         unsigned int ret;

         if (in_nmi()) /* not supported yet */
                 return 1;
...
