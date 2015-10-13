From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH 1/2] perf: Add the flag sample_disable not to output
 data on samples
Date: Tue, 13 Oct 2015 15:00:34 +0300
Message-ID: <561CF262.9040600@cogentembedded.com>
References: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com>
 <1444640563-159175-2-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wangnan0@huawei.com, linux-kernel@vger.kernel.org,
	pi3orama@163.com, hekuang@huawei.com, netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>, ast@plumgrid.com,
	davem@davemloft.net, acme@kernel.org, mingo@redhat.com,
	a.p.zijlstra@chello.nl, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444640563-159175-2-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/12/2015 12:02 PM, Kaixu Xia wrote:

> In some scenarios we don't want to output trace data when sampling
> to reduce overhead. This patch adds the flag sample_disable to
> implement this function. By setting this flag and integrating with
> ebpf, we can control the data output process and get the samples we
> are most interested in.
>
> Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>

[...]
> diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
> index 29ace10..4ae82c9 100644
> --- a/kernel/bpf/arraymap.c
> +++ b/kernel/bpf/arraymap.c
[...]
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index b11756f..f6ef45c 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -6337,6 +6337,9 @@ static int __perf_event_overflow(struct perf_event *event,
>   		irq_work_queue(&event->pending);
>   	}
>
> +	if ((event->sample_disable) && atomic_read(event->sample_disable))

    Inner parens not needed at all.

[...]

MBR, Sergei
