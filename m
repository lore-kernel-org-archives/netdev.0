From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 3/3] net_sched: Use pr_debug replace printk(KERN_DEBUG
 ...)
Date: Thu, 07 Nov 2013 18:43:35 +0400
Message-ID: <527BA717.5060301@cogentembedded.com>
References: <1383790412-41944-1-git-send-email-yangyingliang@huawei.com> <1383790412-41944-4-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jhs@mojatatu.com,
	stephen@networkplumber.org
To: Yang Yingliang <yangyingliang@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:47510 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083Ab3KGOnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 09:43:42 -0500
Received: by mail-la0-f41.google.com with SMTP id ea20so522804lab.28
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 06:43:41 -0800 (PST)
In-Reply-To: <1383790412-41944-4-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07-11-2013 6:13, Yang Yingliang wrote:

> Replace printk(KERN_DEBUG ...) with pr_debug() and

    Note that this is not an equivalent change: first variant always prints 
the message, while pr_debug() only does this if DEBUG is #define'd or dynamic 
debugging is enabled.

> replace pr_warning() with pr_warn().

    This should probably be in a separate patch.

> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>   net/sched/sch_cbq.c    | 2 +-
>   net/sched/sch_dsmark.c | 2 +-
>   net/sched/sch_gred.c   | 4 ++--
>   net/sched/sch_htb.c    | 6 +++---
>   4 files changed, 7 insertions(+), 7 deletions(-)

> diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
> index a8f40f5..9e3a9dc 100644
> --- a/net/sched/sch_cbq.c
> +++ b/net/sched/sch_cbq.c
> @@ -1060,7 +1060,7 @@ static void cbq_normalize_quanta(struct cbq_sched_data *q, int prio)
>   			}
>   			if (cl->quantum <= 0 ||
>   				cl->quantum > 32*qdisc_dev(cl->qdisc)->mtu) {
> -				pr_warning("CBQ: class %08x has bad quantum==%ld, repaired.\n",
> +				pr_warn("CBQ: class %08x has bad quantum==%ld, repaired.\n",
>   					   cl->common.classid, cl->quantum);

    You should also adjust indentation of the continuation line. Same comment 
to the code furhter below...

[...]
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index f6e8a74..6586f3b 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c

> @@ -1484,13 +1484,13 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
>   	if (!cl->level) {
>   		cl->quantum = hopt->rate.rate / q->rate2quantum;
>   		if (!hopt->quantum && cl->quantum < 1000) {
> -			pr_warning(
> +			pr_warn(
>   			       "HTB: quantum of class %X is small. Consider r2q change.\n",

    It would have been good if you moved the string literal to the preceding 
line. Same comment to the below code.

WBR, Sergei
