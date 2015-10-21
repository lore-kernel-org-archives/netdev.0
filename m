From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 2/3] bpf: introduce bpf_perf_event_output()
 helper
Date: Wed, 21 Oct 2015 21:33:17 +0200
Message-ID: <20151021193317.GF2508@worktop.programming.kicks-ass.net>
References: <1445396556-4854-1-git-send-email-ast@kernel.org>
 <1445396556-4854-3-git-send-email-ast@kernel.org>
 <20151021120636.GB3604@twins.programming.kicks-ass.net>
 <5627CABD.7030609@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37679 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198AbbJUTdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 15:33:07 -0400
Content-Disposition: inline
In-Reply-To: <5627CABD.7030609@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 10:26:21AM -0700, Alexei Starovoitov wrote:
> On 10/21/15 5:06 AM, Peter Zijlstra wrote:
> >>  	PERF_COUNT_SW_DUMMY			= 9,
> >>>+	PERF_COUNT_SW_BPF_OUTPUT		= 10,
> >>>
> >>>  	PERF_COUNT_SW_MAX,			/* non-ABI */
> >>>  };
> >Do you really need the new type? Can't you use DUMMY for this?
> 
> It works fine with dummy, but user space code looked odd when
> it perf_event_open-s dummy events and starts reading them.
> So I thought either to add alias:
> PERF_COUNT_SW_BPF_OUTPUT = PERF_COUNT_SW_DUMMY
> or
> add new number like I did above.
> New number is cheap and I saw that dummy used for probing,
> so went with new number to disambiguate.

Ah, ok. It wasn't clear to me why you needed another number.

The SW numbers add some extra (unused) data size to the kernel as a
number of arrays are sized by them, but one more should not hurt (too)
much.
