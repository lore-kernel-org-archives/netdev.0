From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH net-next 4/6] tools/lib/bpf: expose
 bpf_program__set_type()
Date: Fri, 31 Mar 2017 10:33:50 +0800
Message-ID: <b4ebf55a-d509-f4b8-8d71-c5dfc31f9c9d@huawei.com>
References: <20170331013157.3298003-1-ast@fb.com>
 <20170331013157.3298003-5-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:4926 "EHLO
        dggrg03-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750820AbdCaCet (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 22:34:49 -0400
In-Reply-To: <20170331013157.3298003-5-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/3/31 9:31, Alexei Starovoitov wrote:
> expose bpf_program__set_type() to set program type
>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Martin KaFai Lau <kafai@fb.com>
> ---
>   tools/lib/bpf/libbpf.c | 3 +--
>   tools/lib/bpf/libbpf.h | 1 +
>   2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
> index ac6eb863b2a4..1a2c07eb7795 100644
> --- a/tools/lib/bpf/libbpf.c
> +++ b/tools/lib/bpf/libbpf.c
> @@ -1618,8 +1618,7 @@ int bpf_program__nth_fd(struct bpf_program *prog, int n)
>   	return fd;
>   }
>   
> -static void bpf_program__set_type(struct bpf_program *prog,
> -				  enum bpf_prog_type type)
> +void bpf_program__set_type(struct bpf_program *prog, enum bpf_prog_type type)
>   {
>   	prog->type = type;
>   }
> diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
> index b30394f9947a..82adde30b696 100644
> --- a/tools/lib/bpf/libbpf.h
> +++ b/tools/lib/bpf/libbpf.h
> @@ -185,6 +185,7 @@ int bpf_program__set_sched_cls(struct bpf_program *prog);
>   int bpf_program__set_sched_act(struct bpf_program *prog);
>   int bpf_program__set_xdp(struct bpf_program *prog);
>   int bpf_program__set_perf_event(struct bpf_program *prog);
> +void bpf_program__set_type(struct bpf_program *prog, enum bpf_prog_type type);
>   

This makes libbpf.h depend on uapi/linux/bpf.h (because of enum
bpf_prog_type), which is not always available.

What about defining another enum inside libbpf.h?

Thank you.
