From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 2/3] net_sched: fix some checkpatch errors
Date: Thu, 07 Nov 2013 18:33:40 +0400
Message-ID: <527BA4C4.50704@cogentembedded.com>
References: <1383790412-41944-1-git-send-email-yangyingliang@huawei.com> <1383790412-41944-3-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jhs@mojatatu.com,
	stephen@networkplumber.org
To: Yang Yingliang <yangyingliang@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:34106 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754535Ab3KGOdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 09:33:46 -0500
Received: by mail-lb0-f182.google.com with SMTP id w6so504248lbh.27
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 06:33:45 -0800 (PST)
In-Reply-To: <1383790412-41944-3-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07-11-2013 6:13, Yang Yingliang wrote:

> There are some checkpatch errors, fix them.

> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
[...]

> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index fd70728..d92a90e9 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -191,7 +191,8 @@ u32 tcf_hash_new_index(u32 *idx_gen, struct tcf_hashinfo *hinfo)
>   			val = 1;
>   	} while (tcf_hash_lookup(val, hinfo));
>
> -	return (*idx_gen = val);
> +	*idx_gen = val;
> +	return *idx_gen;

	return val;

would have been simpler.

> diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
> index 7a42c81..a8f40f5 100644
> --- a/net/sched/sch_cbq.c
> +++ b/net/sched/sch_cbq.c
> @@ -1058,7 +1058,8 @@ static void cbq_normalize_quanta(struct cbq_sched_data *q, int prio)
>   				cl->quantum = (cl->weight*cl->allot*q->nclasses[prio])/
>   					q->quanta[prio];
>   			}
> -			if (cl->quantum <= 0 || cl->quantum>32*qdisc_dev(cl->qdisc)->mtu) {
> +			if (cl->quantum <= 0 ||
> +				cl->quantum > 32*qdisc_dev(cl->qdisc)->mtu) {

    According to the networking coding style, the continuation line should 
start right under 'cl' on the first line of *if*. The way you did it makes it 
harder for the eyes to differentiate the code in the *if* branch from the *if* 
expression.

>   				pr_warning("CBQ: class %08x has bad quantum==%ld, repaired.\n",
>   					   cl->common.classid, cl->quantum);
>   				cl->quantum = qdisc_dev(cl->qdisc)->mtu/2 + 1;
[...]

WBR, Sergei
