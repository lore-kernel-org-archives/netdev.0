From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [Patch net] net_sched: check noop_qdisc before
 qdisc_hash_add()
Date: Thu, 6 Apr 2017 10:58:16 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1704061057580.28004@cbobk.fhfr.pm>
References: <1491357091-27064-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, dvyukov@google.com, edumazet@google.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58553 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756666AbdDFI62 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 04:58:28 -0400
In-Reply-To: <1491357091-27064-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Apr 2017, Cong Wang wrote:

> Dmitry reported a crash when injecting faults in
> attach_one_default_qdisc() and dev->qdisc is still
> a noop_disc, the check before qdisc_hash_add() fails
> to catch it because it tests NULL. We should test
> against noop_qdisc since it is the default qdisc
> at this point.
> 
> Fixes: 59cc1f61f09c ("net: sched: convert qdisc linked list to hashtable")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Jiri Kosina <jkosina@suse.cz>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jiri Kosina <jkosina@suse.cz>

Thanks.

> ---
>  net/sched/sch_generic.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index b052b27..1a2f9e9 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -794,7 +794,7 @@ static void attach_default_qdiscs(struct net_device *dev)
>  		}
>  	}
>  #ifdef CONFIG_NET_SCHED
> -	if (dev->qdisc)
> +	if (dev->qdisc != &noop_qdisc)
>  		qdisc_hash_add(dev->qdisc);
>  #endif
>  }
> -- 
> 2.5.5
> 

-- 
Jiri Kosina
SUSE Labs
