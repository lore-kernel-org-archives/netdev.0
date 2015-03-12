From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v6 tip 2/8] tracing: attach BPF programs to kprobes
Date: Thu, 12 Mar 2015 12:23:45 -0400
Message-ID: <20150312122345.0b28c266@gandalf.local.home>
References: <1426047534-8148-1-git-send-email-ast@plumgrid.com>
	<1426047534-8148-3-git-send-email-ast@plumgrid.com>
	<20150312151507.GI2896@worktop.programming.kicks-ass.net>
	<5501BC5A.6000204@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5501BC5A.6000204@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Mar 2015 09:18:34 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

> > You've so far tried very hard to not get into tracing; and then you call
> > rcu_read_lock() :-)
> >
> > So either document why this isn't a problem, provide
> > rcu_read_lock_notrace() or switch to RCU-sched and thereby avoid the
> > problem.
> 
> I don't see the problem.
> I actually do turn on func and func_graph tracers from time to time to
> debug bpf core itself. Why would tracing interfere with anything that
> this patch is doing? When we're inside tracing processing, we need to
> use only _notrace() helpers otherwise recursion will hurt, but this
> code is not invoked from there. It's called from 
> kprobe_ftrace_handler|kprobe_int3_handler->kprobe_dispatcher->
> kprobe_perf_func->trace_call_bpf which all are perfectly traceable.
> Probably my copy paste of preempt_disable_notrace() line from
> stack_trace_call() became source of confusion? I believe
> normal preempt_disable() here will be just fine.
> It's actually redundant too, since preemption is disabled by kprobe
> anyway. Please help me understand what I'm missing.

As Peter stated, "You've so far tried very hard to not get into
tracing", which the preempt_disable_notrace() is the source of confusion.

Just remove the _notrace() part, as it doesn't make sense to have part
not traced, and other parts traced for no apparent reason.

-- Steve
