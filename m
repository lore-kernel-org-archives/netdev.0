From: Mike Galbraith <efault@gmx.de>
Subject: Re: [Patch net] net_sched: replace yield() with cond_resched()
Date: Wed, 05 Apr 2017 05:55:45 +0200
Message-ID: <1491364545.4536.90.camel@gmx.de>
References: <1491357139-27108-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:55515 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751169AbdDEDzs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 23:55:48 -0400
In-Reply-To: <1491357139-27108-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-04 at 18:52 -0700, Cong Wang wrote:

> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 1a2f9e9..4725d2f 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -925,7 +925,7 @@ void dev_deactivate_many(struct list_head *head)
>  	/* Wait for outstanding qdisc_run calls. */
>  	list_for_each_entry(dev, head, close_list)
>  		while (some_qdisc_is_busy(dev))
> -			yield();
> +			cond_resched();
>  }

That won't help, cond_resched() has the same impact upon a lone
SCHED_FIFO task as yield() does.. none.

	-Mike
