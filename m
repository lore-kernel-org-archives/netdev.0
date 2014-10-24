From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net] net/sched: Fix use of wild pointer in mq_destroy()
 when qdisc_alloc fail
Date: Fri, 24 Oct 2014 10:49:46 -0700
Message-ID: <544A913A.1060100@gmail.com>
References: <OF7A403C69.2C35464E-ON48257D7B.002E24AA-48257D7B.002F2A62@zte.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org,
	cui.yunfeng@zte.com.cn
To: wang.bo116@zte.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:50786 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756065AbaJXRuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 13:50:04 -0400
Received: by mail-oi0-f48.google.com with SMTP id g201so688219oib.35
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 10:50:03 -0700 (PDT)
In-Reply-To: <OF7A403C69.2C35464E-ON48257D7B.002E24AA-48257D7B.002F2A62@zte.com.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2014 01:34 AM, wang.bo116@zte.com.cn wrote:
>

[...]

>
> --------------------------------------------------------------------------------
>
> This patch  fix this problem, base on linux 3.18-rc-1:
>
> Signed-off-by: Wang Bo <wang.bo116@zte.com.cn>
> Tested-by: Ma Chenggong <ma.chenggong@zte.com.cn>
> diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
> index 42f72f1..a0c90e7 100755
> --- a/net/sched/sch_mq.c
> +++ b/net/sched/sch_mq.c
> @@ -33,6 +33,7 @@ static void mq_destroy(struct Qdisc *sch)
>   	for (ntx = 0; ntx < dev->num_tx_queues && priv->qdiscs[ntx]; ntx++)
>   		qdisc_destroy(priv->qdiscs[ntx]);
>   	kfree(priv->qdiscs);
> +	priv->qdiscs = NULL;
>   }
>
>   static int mq_init(struct Qdisc *sch, struct nlattr *opt)
>

Acked-by: John Fastabend <john.r.fastabend@intel.com>

Patch looks fine, another way to fix this would be drop the
mq_destroy() call in the error path. I'm not convinced one
is any better than the other but maybe some other folks have
opinions, it seems a bit wrong to call mq_destroy twice so in
that sense it may be a bit nicer to drop the mq_destroy().

Also same bug in mqprio do you want to submit a patch for
that qdisc as well? Otherwise I can.

Thanks!


-- 
John Fastabend         Intel Corporation
