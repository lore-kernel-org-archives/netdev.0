From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 1/8] perf: optimize perf_fetch_caller_regs
Date: Tue, 5 Apr 2016 14:06:26 +0200
Message-ID: <20160405120626.GM3448@twins.programming.kicks-ass.net>
References: <1459831974-2891931-1-git-send-email-ast@fb.com>
 <1459831974-2891931-2-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt@goodmis.org>,
	"David S . Miller" <davem@davemloft.net>,
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
In-Reply-To: <1459831974-2891931-2-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 04, 2016 at 09:52:47PM -0700, Alexei Starovoitov wrote:
> avoid memset in perf_fetch_caller_regs, since it's the critical path of all tracepoints.
> It's called from perf_sw_event_sched, perf_event_task_sched_in and all of perf_trace_##call
> with this_cpu_ptr(&__perf_regs[..]) which are zero initialized by perpcu_alloc

Its not actually allocated; but because its a static uninitialized
variable we get .bss like behaviour and the initial value is copied to
all CPUs when the per-cpu allocator thingy bootstraps SMP IIRC.

> and
> subsequent call to perf_arch_fetch_caller_regs initializes the same fields on all archs,
> so we can safely drop memset from all of the above cases and 

Indeed.

> move it into
> perf_ftrace_function_call that calls it with stack allocated pt_regs.

Hmm, is there a reason that's still on-stack instead of using the
per-cpu thing, Steve?

> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

In any case,

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
