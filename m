From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH v2 net-next] bpf: fix bpf_perf_event_read() helper
Date: Thu, 22 Oct 2015 20:30:36 +0800
Message-ID: <5628D6EC.3040606@huawei.com>
References: <1445468283-4592-1-git-send-email-ast@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>, He Kuang <hekuang@huawei.com>,
	Kaixu Xia <xiakaixu@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445468283-4592-1-git-send-email-ast@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/10/22 6:58, Alexei Starovoitov wrote:

[SNIP]
> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
> index e3cfe46b074f..75529cc94304 100644
> --- a/kernel/bpf/arraymap.c
> +++ b/kernel/bpf/arraymap.c
> @@ -294,10 +294,11 @@ static void *perf_event_fd_array_get_ptr(struct bpf_map *map, int fd)
>   	if (IS_ERR(attr))
>   		return (void *)attr;
>   
> -	if (attr->type != PERF_TYPE_RAW &&
> -	    !(attr->type == PERF_TYPE_SOFTWARE &&
> -	      attr->config == PERF_COUNT_SW_BPF_OUTPUT) &&
> -	    attr->type != PERF_TYPE_HARDWARE) {
> +	if ((attr->type != PERF_TYPE_RAW &&
> +	     !(attr->type == PERF_TYPE_SOFTWARE &&
> +	       attr->config == PERF_COUNT_SW_BPF_OUTPUT) &&
> +	     attr->type != PERF_TYPE_HARDWARE) ||
> +	    attr->inherit) {
>   		perf_event_release_kernel(event);
>   		return ERR_PTR(-EINVAL);
>   	}

I have a question on inherit, not related to this patch:
Is it safe for perf to disable attr->inherit if the event is system wide?
I haven't read relate code completely. In my current knowledge the behavior
of a system wide perf event should be same whether inherit is set or not.
Is that true?

Thank you.
