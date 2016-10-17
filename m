From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH 4/8] tools lib bpf: export function to set type
Date: Mon, 17 Oct 2016 09:56:39 +0800
Message-ID: <58042FD7.3010008@huawei.com>
References: <20161016211834.11732-1-eric@regit.org>
 <20161016211834.11732-5-eric@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <ast@fb.com>
To: Eric Leblond <eric@regit.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161016211834.11732-5-eric@regit.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/10/17 5:18, Eric Leblond wrote:
> Current API was not allowing the user to set a type like socket
> filter. To avoid a setter function for each type, the patch simply
> exports a set function that takes the type in parameter.
>
> Signed-off-by: Eric Leblond <eric@regit.org>
> ---
>   tools/lib/bpf/libbpf.c | 19 +++++++++----------
>   tools/lib/bpf/libbpf.h |  3 +++
>   2 files changed, 12 insertions(+), 10 deletions(-)
>
> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
> index 90932f1..7cd341e 100644
> --- a/tools/lib/bpf/libbpf.c
> +++ b/tools/lib/bpf/libbpf.c
> @@ -1336,26 +1336,25 @@ int bpf_program__nth_fd(struct bpf_program *prog, int n)
>   	return fd;
>   }
>   
> -static void bpf_program__set_type(struct bpf_program *prog,
> -				  enum bpf_prog_type type)
> +int bpf_program__set_type(struct bpf_program *prog, unsigned int type)
>   {
> +	if (!prog)
> +		return -EINVAL;
> +	if (type >= __MAX_BPF_PROG_TYPE)
> +		return -EINVAL;
> +
>   	prog->type = type;
> +	return 0;
>   }
>   
>   int bpf_program__set_tracepoint(struct bpf_program *prog)
>   {
> -	if (!prog)
> -		return -EINVAL;
> -	bpf_program__set_type(prog, BPF_PROG_TYPE_TRACEPOINT);
> -	return 0;
> +	return bpf_program__set_type(prog, BPF_PROG_TYPE_TRACEPOINT);
>   }
>   
>   int bpf_program__set_kprobe(struct bpf_program *prog)
>   {
> -	if (!prog)
> -		return -EINVAL;
> -	bpf_program__set_type(prog, BPF_PROG_TYPE_KPROBE);
> -	return 0;
> +	return bpf_program__set_type(prog, BPF_PROG_TYPE_KPROBE);
>   }
>   
>   static bool bpf_program__is_type(struct bpf_program *prog,
> diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
> index e40c8d3..a18783b 100644
> --- a/tools/lib/bpf/libbpf.h
> +++ b/tools/lib/bpf/libbpf.h
> @@ -173,6 +173,9 @@ int bpf_program__set_kprobe(struct bpf_program *prog);
>   bool bpf_program__is_tracepoint(struct bpf_program *prog);
>   bool bpf_program__is_kprobe(struct bpf_program *prog);
>   
> +int bpf_program__set_type(struct bpf_program *prog,
> +				  unsigned int type);
> +

Although you don't include uapi/linux/bpf.h in this patch, logically
you add this dependency.

Please continously add bpf_program__set_socket_filter() and
bpf_program__is_socket_filter() like what we do for tracepoint.
This way libbpf.h is indenpendent from kernel header.

We can use macro in both .h and .c.

Thank you.
