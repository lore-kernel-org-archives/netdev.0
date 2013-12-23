From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH resend net-next 1/2] net_sched: replace pr_warning with
 pr_warn
Date: Sun, 22 Dec 2013 17:20:16 -0800
Message-ID: <1387761616.22671.40.camel@joe-AO722>
References: <1387760778-25256-1-git-send-email-yangyingliang@huawei.com>
	 <1387760778-25256-2-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0089.hostedemail.com ([216.40.44.89]:47296 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756362Ab3LWBUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 20:20:21 -0500
In-Reply-To: <1387760778-25256-2-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-23 at 09:06 +0800, Yang Yingliang wrote:
> Prefer pr_warn(... to pr_warning(...

Couple of trivial comments:

> diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
[]
> @@ -303,8 +303,8 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
>  		 * and don't need yet another qdisc as a bypass.
>  		 */
>  		if (p->mask[index] != 0xff || p->value[index])
> -			pr_warning("dsmark_dequeue: unsupported protocol %d\n",
> -				   ntohs(skb->protocol));
> +			pr_warn("dsmark_dequeue: unsupported protocol %d\n",
> +				ntohs(skb->protocol));

When converting messages with embedded function names,
consider using "%s: ...", __func__

> diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
[]
> @@ -370,8 +370,8 @@ static inline int gred_change_table_def(struct Qdisc *sch, struct nlattr *dps)
>  
>  	for (i = table->DPs; i < MAX_DPs; i++) {
>  		if (table->tab[i]) {
> -			pr_warning("GRED: Warning: Destroying "
> -				   "shadowed VQ 0x%x\n", i);
> +			pr_warn("GRED: Warning: Destroying "
> +				"shadowed VQ 0x%x\n", i);

When converting formats split across multiple lines,
please coalesce the format fragments like:

			pr_warn("GRED: Warning: Destroying shadowed V0 0x%x\n",
				i);
