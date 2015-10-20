From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Tue, 20 Oct 2015 15:53:02 -0700
Message-ID: <5626C5CE.8080809@plumgrid.com>
References: <1445325735-121694-1-git-send-email-xiakaixu@huawei.com>
 <1445325735-121694-2-git-send-email-xiakaixu@huawei.com>
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
In-Reply-To: <1445325735-121694-2-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/15 12:22 AM, Kaixu Xia wrote:
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index b11756f..5219635 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -6337,6 +6337,9 @@ static int __perf_event_overflow(struct perf_event *event,
>   		irq_work_queue(&event->pending);
>   	}
>
> +	if (unlikely(!atomic_read(&event->soft_enable)))
> +		return 0;
> +
>   	if (event->overflow_handler)
>   		event->overflow_handler(event, data, regs);
>   	else

Peter,
does this part look right or it should be moved right after
if (unlikely(!is_sampling_event(event)))
                 return 0;
or even to other function?

It feels to me that it should be moved, since we probably don't
want to active throttling, period adjust and event_limit for events
that are in soft_disabled state.
