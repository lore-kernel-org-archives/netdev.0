From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH V4 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Mon, 19 Oct 2015 19:14:05 -0700
Message-ID: <5625A36D.8070200@plumgrid.com>
References: <1445251060-114617-1-git-send-email-xiakaixu@huawei.com>
 <1445251060-114617-2-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wangnan0@huawei.com, linux-kernel@vger.kernel.org,
	pi3orama@163.com, hekuang@huawei.com, netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, a.p.zijlstra@chello.nl,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445251060-114617-2-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/19/15 3:37 AM, Kaixu Xia wrote:
> +/* flags for PERF_EVENT_ARRAY maps*/
> +enum {
> +	BPF_EVENT_CTL_BIT_CUR = 0,
> +	BPF_EVENT_CTL_BIT_ALL = 1,
> +	__NR_BPF_EVENT_CTL_BITS,
> +};
> +
> +#define	BPF_CTL_BIT_FLAG_MASK \
> +	((1ULL << __NR_BPF_EVENT_CTL_BITS) - 1)
> +#define	BPF_CTL_BIT_DUMP_CUR \
> +	(1ULL << BPF_EVENT_CTL_BIT_CUR)
> +#define	BPF_CTL_BIT_DUMP_ALL \
> +	(1ULL << BPF_EVENT_CTL_BIT_ALL)
> +

the above shouldn't be part of uapi header. It can stay in bpf_trace.c
Just document these bits next to helper similar to skb_store_bytes()

The rest looks ok.
It still needs an ack from Peter for perf_event bits
