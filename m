From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v9 tip 8/9] samples: bpf: IO latency analysis
 (iosnoop/heatmap)
Date: Mon, 23 Mar 2015 08:40:28 +0100
Message-ID: <20150323074028.GE25184@gmail.com>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com>
 <1426894210-27441-9-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38112 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbbCWHkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 03:40:33 -0400
Content-Disposition: inline
In-Reply-To: <1426894210-27441-9-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Alexei Starovoitov <ast@plumgrid.com> wrote:

> BPF C program attaches to blk_mq_start_request/blk_update_request kprobe events
> to calculate IO latency.

 ...

> +/* kprobe is NOT a stable ABI
> + * This bpf+kprobe example can stop working any time.
> + */
> +SEC("kprobe/blk_mq_start_request")
> +int bpf_prog1(struct pt_regs *ctx)
> +{
> +	long rq = ctx->di;
> +	u64 val = bpf_ktime_get_ns();
> +
> +	bpf_map_update_elem(&my_map, &rq, &val, BPF_ANY);
> +	return 0;
> +}

So just to make sure the original BPF instrumentation model is still 
upheld: no matter in what way the kernel changes, neither the kprobe, 
nor the BPF program can ever crash or corrupt the kernel, assuming the 
kprobes, perf and BPF subsystem has no bugs, correct?

So 'stops working' here means that the instrumentation data might not 
be reliable if kernel internal interfaces change - but it won't ever 
make the kernel unreliable in any fashion. Right?

Thanks,

	Ingo
