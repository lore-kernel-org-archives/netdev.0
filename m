From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 net-next 04/10] perf, bpf: allow bpf programs attach
 to tracepoints
Date: Thu, 7 Apr 2016 22:58:47 +0200
Message-ID: <20160407205847.GI3448@twins.programming.kicks-ass.net>
References: <1459993411-2754735-1-git-send-email-ast@fb.com>
 <1459993411-2754735-5-git-send-email-ast@fb.com>
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
In-Reply-To: <1459993411-2754735-5-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 06, 2016 at 06:43:25PM -0700, Alexei Starovoitov wrote:
> introduce BPF_PROG_TYPE_TRACEPOINT program type and allow it to be attached
> to the perf tracepoint handler, which will copy the arguments into
> the per-cpu buffer and pass it to the bpf program as its first argument.
> The layout of the fields can be discovered by doing
> 'cat /sys/kernel/debug/tracing/events/sched/sched_switch/format'
> prior to the compilation of the program with exception that first 8 bytes
> are reserved and not accessible to the program. This area is used to store
> the pointer to 'struct pt_regs' which some of the bpf helpers will use:
> +---------+
> | 8 bytes | hidden 'struct pt_regs *' (inaccessible to bpf program)
> +---------+
> | N bytes | static tracepoint fields defined in tracepoint/format (bpf readonly)
> +---------+
> | dynamic | __dynamic_array bytes of tracepoint (inaccessible to bpf yet)
> +---------+
> 
> Not that all of the fields are already dumped to user space via perf ring buffer
> and broken application access it directly without consulting tracepoint/format.
> Same rule applies here: static tracepoint fields should only be accessed
> in a format defined in tracepoint/format. The order of fields and
> field sizes are not an ABI.
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
