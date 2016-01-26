From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net_sched: drr: check for NULL pointer in drr_dequeue
Date: Tue, 26 Jan 2016 10:03:38 -0800
Message-ID: <CAM_iQpX=x6gvuhxbN7zjbCa+zfyeh0nN86Ao_wVg6f9U3OEJew@mail.gmail.com>
References: <1453780265-29508-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>, stable@vger.kernel.org
To: Bernie Harris <bernie.harris@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:35715 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932586AbcAZSDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 13:03:39 -0500
In-Reply-To: <1453780265-29508-1-git-send-email-bernie.harris@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 25, 2016 at 7:51 PM, Bernie Harris
<bernie.harris@alliedtelesis.co.nz> wrote:
> There are cases where qdisc_dequeue_peeked can return NULL, and the result
> is dereferenced later on in the function.
>
> Similarly to the other qdisc dequeue functions, check whether the skb
> pointer is NULL and if it is, goto out.
>
> Signed-off-by: Bernie Harris <bernie.harris@alliedtelesis.co.nz>

Looks good to me, just one minor thing: an unlikely() can be used for this case.


> ---
>  net/sched/sch_drr.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
> index f26bdea..8086c3d 100644
> --- a/net/sched/sch_drr.c
> +++ b/net/sched/sch_drr.c
> @@ -403,6 +403,8 @@ static struct sk_buff *drr_dequeue(struct Qdisc *sch)
>                 if (len <= cl->deficit) {
>                         cl->deficit -= len;
>                         skb = qdisc_dequeue_peeked(cl->qdisc);
> +                       if (skb == NULL)
> +                               goto out;
>                         if (cl->qdisc->q.qlen == 0)
>                                 list_del(&cl->alist);
>
> --
> 2.7.0
>
