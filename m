From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH net-next] bpf: make tracing helpers gpl only
Date: Sun, 25 Oct 2015 10:14:11 +0100
Message-ID: <20151025091411.GE24337@gmail.com>
References: <1445637499-11146-1-git-send-email-ast@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:33380 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbbJYJOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 05:14:16 -0400
Content-Disposition: inline
In-Reply-To: <1445637499-11146-1-git-send-email-ast@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Alexei Starovoitov <ast@plumgrid.com> wrote:

> exported perf symbols are GPL only, mark eBPF helper functions
> used in tracing as GPL only as well.
> 
> Suggested-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> ---
> this is on top of this patch that touches the same file:
> http://patchwork.ozlabs.org/patch/534664/
> 
>  kernel/trace/bpf_trace.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
> index 003df3887287..4228fd3682c3 100644
> --- a/kernel/trace/bpf_trace.c
> +++ b/kernel/trace/bpf_trace.c
> @@ -214,7 +214,7 @@ static u64 bpf_perf_event_read(u64 r1, u64 index, u64 r3, u64 r4, u64 r5)
>  
>  static const struct bpf_func_proto bpf_perf_event_read_proto = {
>  	.func		= bpf_perf_event_read,
> -	.gpl_only	= false,
> +	.gpl_only	= true,
>  	.ret_type	= RET_INTEGER,
>  	.arg1_type	= ARG_CONST_MAP_PTR,
>  	.arg2_type	= ARG_ANYTHING,
> @@ -255,7 +255,7 @@ static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 index, u64 r4, u64 size)
>  
>  static const struct bpf_func_proto bpf_perf_event_output_proto = {
>  	.func		= bpf_perf_event_output,
> -	.gpl_only	= false,
> +	.gpl_only	= true,
>  	.ret_type	= RET_INTEGER,
>  	.arg1_type	= ARG_PTR_TO_CTX,
>  	.arg2_type	= ARG_CONST_MAP_PTR,

So there's a lot more 'gpl_only = false' cases that I can see:

triton:~/tip> git grep gpl_only | grep false
kernel/bpf/core.c: .gpl_only    = false,
kernel/bpf/helpers.c: .gpl_only = false,
kernel/bpf/helpers.c: .gpl_only = false,
kernel/bpf/helpers.c: .gpl_only = false,
kernel/bpf/helpers.c: .gpl_only = false,
kernel/bpf/helpers.c: .gpl_only = false,
kernel/bpf/helpers.c: .gpl_only = false,
kernel/bpf/helpers.c: .gpl_only = false,
kernel/bpf/helpers.c: .gpl_only = false,
kernel/trace/bpf_trace.c:       .gpl_only   = false,
net/core/filter.c: .gpl_only    = false,
net/core/filter.c: .gpl_only    = false,
net/core/filter.c: .gpl_only    = false,
net/core/filter.c: .gpl_only       = false,
net/core/filter.c: .gpl_only       = false,
net/core/filter.c: .gpl_only       = false,
net/core/filter.c: .gpl_only       = false,
net/core/filter.c: .gpl_only    = false,
net/core/filter.c: .gpl_only    = false,

and only a handful of 'true' cases:

triton:~/tip> git grep gpl_only | grep true
kernel/bpf/helpers.c: .gpl_only = true,
kernel/trace/bpf_trace.c:       .gpl_only   = true,
kernel/trace/bpf_trace.c:       .gpl_only   = true,

so I don't know the netfilter ones, but in particular the tracing ones I'm sure 
should be gpl-only. Do we really, really want proprietary modules mucking with 
such internals??

Thanks,

	Ingo
