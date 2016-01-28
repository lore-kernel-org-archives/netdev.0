From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net_sched: drr: check for NULL pointer in drr_dequeue
Date: Thu, 28 Jan 2016 17:04:19 +0300
Message-ID: <56AA1FE3.6060201@cogentembedded.com>
References: <CAM_iQpX=x6gvuhxbN7zjbCa+zfyeh0nN86Ao_wVg6f9U3OEJew@mail.gmail.com>
 <1453951851-24501-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jhs@mojatatu.com, stable@vger.kernel.org
To: Bernie Harris <bernie.harris@alliedtelesis.co.nz>,
	netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1453951851-24501-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 1/28/2016 6:30 AM, Bernie Harris wrote:

> There are cases where qdisc_dequeue_peeked can return NULL, and the result
> is dereferenced later on in the function.
>
> Similarly to the other qdisc dequeue functions, check whether the skb
> pointer is NULL and if it is, goto out.
>
> Signed-off-by: Bernie Harris <bernie.harris@alliedtelesis.co.nz>
> ---
>   net/sched/sch_drr.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
> index f26bdea..a1cd778 100644
> --- a/net/sched/sch_drr.c
> +++ b/net/sched/sch_drr.c
> @@ -403,6 +403,8 @@ static struct sk_buff *drr_dequeue(struct Qdisc *sch)
>   		if (len <= cl->deficit) {
>   			cl->deficit -= len;
>   			skb = qdisc_dequeue_peeked(cl->qdisc);
> +			if (unlikely(skb == NULL))

    !skb is preferred in the networking code. I think scripts/checkpatch.pl 
should've warned you.

[...]

MBR, Sergei
