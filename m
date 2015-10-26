From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next] bpf: fix bpf_perf_event_read() helper
Date: Mon, 26 Oct 2015 14:28:39 -0700
Message-ID: <562E9B07.3020100@plumgrid.com>
References: <1445559014-4667-1-git-send-email-ast@kernel.org>
 <20151023120335.GZ17308@twins.programming.kicks-ass.net>
 <562A474E.6040401@plumgrid.com> <20151025092142.GB4380@gmail.com>
 <562D0208.7090608@plumgrid.com>
 <20151026123200.GT2508@worktop.programming.kicks-ass.net>
 <562E2293.5090600@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	He Kuang <hekuang@huawei.com>, Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>,
	Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <562E2293.5090600@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/26/15 5:54 AM, Wangnan (F) wrote:
>
>
> On 2015/10/26 20:32, Peter Zijlstra wrote:
>> On Sun, Oct 25, 2015 at 09:23:36AM -0700, Alexei Starovoitov wrote:
>>> bpf_perf_event_read() muxes of -EINVAL into return value, but it's non
>>> ambiguous to the program whether it got an error or real counter value.
>> How can that be, the (u64)-EINVAL value is a valid counter value..
>> unlikely maybe, but still quite possible.
> In our real usecase we simply treat return value larger than
> 0x7fffffffffffffff
> as error result. We can make it even larger, for example, to
> 0xffffffffffff0000.

either above or write the program that index is valid, then you
don't need to check for errors.

> Resuling values can be pre-processed by a script to filter potential
> error result
> out so it is not a very big problem for our real usecases.
>
> For a better interface, I suggest
>
>   u64 bpf_perf_event_read(bool *perror);
>
> which still returns counter value through its return value but put error
> code
> to stack. Then BPF program can pass NULL to the function if BPF problem
> doesn't want to deal with error code.

no. we're not going to introduce another interface for this.
The current one is fine. Don't pass incorrect index and you won't see
einval. Returning ints or bools via stack is much slower.
