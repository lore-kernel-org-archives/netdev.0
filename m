From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH v2 net-next 3/6] tools/lib/bpf: expose
 bpf_program__set_type()
Date: Sat, 1 Apr 2017 10:29:56 +0800
Message-ID: <a6aaf1e1-9c4e-ee4e-172e-9e9701aca96e@huawei.com>
References: <20170331044543.4075183-1-ast@fb.com>
 <20170331044543.4075183-4-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:4893 "EHLO
        dggrg02-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750816AbdDACb7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 22:31:59 -0400
In-Reply-To: <20170331044543.4075183-4-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/3/31 12:45, Alexei Starovoitov wrote:
> expose bpf_program__set_type() to set program type
>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Martin KaFai Lau <kafai@fb.com>
> ---
>   tools/lib/bpf/libbpf.c | 3 +--
>   tools/lib/bpf/libbpf.h | 2 ++
>   2 files changed, 3 insertions(+), 2 deletions(-)
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

Since it become a public interface, we need to check if prog is a
NULL pointer and check if the value of type is okay, and let it
return an errno.

> diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
> index b30394f9947a..32c7252f734e 100644
> --- a/tools/lib/bpf/libbpf.h
> +++ b/tools/lib/bpf/libbpf.h
> @@ -25,6 +25,7 @@
>   #include <stdint.h>
>   #include <stdbool.h>
>   #include <sys/types.h>  // for size_t
> +#include <linux/bpf.h>
>   
>   enum libbpf_errno {
>   	__LIBBPF_ERRNO__START = 4000,
> @@ -185,6 +186,7 @@ int bpf_program__set_sched_cls(struct bpf_program *prog);
>   int bpf_program__set_sched_act(struct bpf_program *prog);
>   int bpf_program__set_xdp(struct bpf_program *prog);
>   int bpf_program__set_perf_event(struct bpf_program *prog);
> +void bpf_program__set_type(struct bpf_program *prog, enum bpf_prog_type type);
>   

The above bpf_program__set_xxx become redundancy. It should be generated
using macro as static inline functions.

>   bool bpf_program__is_socket_filter(struct bpf_program *prog);
>   bool bpf_program__is_tracepoint(struct bpf_program *prog);

bpf_program__is_xxx should be updated like bpf_program__set_xxx, since
enum bpf_prog_type is not a problem now.

Thank you.
