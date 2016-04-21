From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next] perf, bpf: minimize the size of perf_trace_()
 tracepoint handler
Date: Thu, 21 Apr 2016 16:02:55 +0200
Message-ID: <20160421140255.GH3430@twins.programming.kicks-ass.net>
References: <1461035510-2810305-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1461035510-2810305-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 18, 2016 at 08:11:50PM -0700, Alexei Starovoitov wrote:
> move trace_call_bpf() into helper function to minimize the size
> of perf_trace_*() tracepoint handlers.
>     text	   data	    bss	    dec	 	   hex	filename
> 10541679	5526646	2945024	19013349	1221ee5	vmlinux_before
> 10509422	5526646	2945024	18981092	121a0e4	vmlinux_after
> 
> It may seem that perf_fetch_caller_regs() can also be moved,
> but that is incorrect, since ip/sp will be wrong.
> 
> bpf+tracepoint performance is not affected, since
> perf_swevent_put_recursion_context() is now inlined.
> export_symbol_gpl can also be dropped.
> 
> No measurable change in normal perf tracepoints.
> 
> Suggested-by: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> ---
>  include/linux/trace_events.h |  5 +++++
>  include/trace/perf.h         | 13 +++----------
>  kernel/events/core.c         | 20 +++++++++++++++++++-
>  3 files changed, 27 insertions(+), 11 deletions(-)
> 

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

David, please take through the net tree as this depends on prior patches
by Alexei that are already in your tree.
