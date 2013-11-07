From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v2 3/3] net_sched: Use pr_debug replace printk(KERN_DEBUG
 ...)
Date: Thu, 07 Nov 2013 09:30:30 +0100
Message-ID: <527B4FA6.1080409@redhat.com>
References: <1383790412-41944-1-git-send-email-yangyingliang@huawei.com> <1383790412-41944-4-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, jhs@mojatatu.com,
	stephen@networkplumber.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44165 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750896Ab3KGIam (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 03:30:42 -0500
In-Reply-To: <1383790412-41944-4-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/07/2013 03:13 AM, Yang Yingliang wrote:
> Replace printk(KERN_DEBUG ...) with pr_debug() and
> replace pr_warning() with pr_warn().
>
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>   net/sched/sch_cbq.c    | 2 +-
>   net/sched/sch_dsmark.c | 2 +-
>   net/sched/sch_gred.c   | 4 ++--
>   net/sched/sch_htb.c    | 6 +++---
>   4 files changed, 7 insertions(+), 7 deletions(-)
>
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

You also need to fix alignment of the second line here and in all other places
you did changes like that.

>   				cl->quantum = qdisc_dev(cl->qdisc)->mtu/2 + 1;
>   			}
> diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
> index 3886365..190cf65 100644
> --- a/net/sched/sch_dsmark.c
> +++ b/net/sched/sch_dsmark.c
> @@ -303,7 +303,7 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
>   		 * and don't need yet another qdisc as a bypass.
>   		 */
>   		if (p->mask[index] != 0xff || p->value[index])
> -			pr_warning("dsmark_dequeue: unsupported protocol %d\n",
> +			pr_warn("dsmark_dequeue: unsupported protocol %d\n",
>   				   ntohs(skb->protocol));
>   		break;
>   	}
> diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
> index d42234c..19fa4dc 100644
> --- a/net/sched/sch_gred.c
> +++ b/net/sched/sch_gred.c
> @@ -370,7 +370,7 @@ static inline int gred_change_table_def(struct Qdisc *sch, struct nlattr *dps)
>
>   	for (i = table->DPs; i < MAX_DPs; i++) {
>   		if (table->tab[i]) {
> -			pr_warning("GRED: Warning: Destroying "
> +			pr_warn("GRED: Warning: Destroying "
>   				   "shadowed VQ 0x%x\n", i);
>   			gred_destroy_vq(table->tab[i]);
>   			table->tab[i] = NULL;
> @@ -456,7 +456,7 @@ static int gred_change(struct Qdisc *sch, struct nlattr *opt)
>   			if (table->tab[table->def])
>   				def_prio = table->tab[table->def]->prio;
>
> -			printk(KERN_DEBUG "GRED: DP %u does not have a prio "
> +			pr_debug("GRED: DP %u does not have a prio "
>   			       "setting default to %d\n", ctl->DP, def_prio);
>
>   			prio = def_prio;
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index f6e8a74..6586f3b 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -712,7 +712,7 @@ static s64 htb_do_events(struct htb_sched *q, const int level,
>
>   	/* too much load - let's continue after a break for scheduling */
>   	if (!(q->warned & HTB_WARN_TOOMANYEVENTS)) {
> -		pr_warning("htb: too many events!\n");
> +		pr_warn("htb: too many events!\n");
>   		q->warned |= HTB_WARN_TOOMANYEVENTS;
>   	}
>
> @@ -1484,13 +1484,13 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
>   	if (!cl->level) {
>   		cl->quantum = hopt->rate.rate / q->rate2quantum;
>   		if (!hopt->quantum && cl->quantum < 1000) {
> -			pr_warning(
> +			pr_warn(
>   			       "HTB: quantum of class %X is small. Consider r2q change.\n",

Also, this looks quite ugly, so changing into pr_warn("HTB: .....") would be better if
you're at it anyway.

>   			       cl->common.classid);
>   			cl->quantum = 1000;
>   		}
>   		if (!hopt->quantum && cl->quantum > 200000) {
> -			pr_warning(
> +			pr_warn(
>   			       "HTB: quantum of class %X is big. Consider r2q change.\n",
>   			       cl->common.classid);

Ditto

>   			cl->quantum = 200000;
>
