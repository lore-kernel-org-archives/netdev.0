From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/3] bpf: introduce bpf_perf_event_output()
 helper
Date: Wed, 21 Oct 2015 10:26:21 -0700
Message-ID: <5627CABD.7030609@plumgrid.com>
References: <1445396556-4854-1-git-send-email-ast@kernel.org>
 <1445396556-4854-3-git-send-email-ast@kernel.org>
 <20151021120636.GB3604@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151021120636.GB3604@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/15 5:06 AM, Peter Zijlstra wrote:
>>   	PERF_COUNT_SW_DUMMY			= 9,
>> >+	PERF_COUNT_SW_BPF_OUTPUT		= 10,
>> >
>> >  	PERF_COUNT_SW_MAX,			/* non-ABI */
>> >  };
> Do you really need the new type? Can't you use DUMMY for this?

It works fine with dummy, but user space code looked odd when
it perf_event_open-s dummy events and starts reading them.
So I thought either to add alias:
PERF_COUNT_SW_BPF_OUTPUT = PERF_COUNT_SW_DUMMY
or
add new number like I did above.
New number is cheap and I saw that dummy used for probing,
so went with new number to disambiguate.
