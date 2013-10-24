From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net:sched  fix a bug about memery leak
Date: Thu, 24 Oct 2013 02:33:38 -0700
Message-ID: <1382607218.7572.45.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382605964-2693-1-git-send-email-windsdaemon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jhs@mojatatu.com, netdev@vger.kernel.org
To: Jing Wang <windsdaemon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:56403 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516Ab3JXJdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 05:33:42 -0400
Received: by mail-ee0-f43.google.com with SMTP id e52so1232286eek.30
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 02:33:41 -0700 (PDT)
In-Reply-To: <1382605964-2693-1-git-send-email-windsdaemon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-24 at 17:12 +0800, Jing Wang wrote:
> From: Jing Wang <windsdaemon@gmail.com>
> 
> the code isn't properly release memory
> 
> Signed-off-by: Jing Wang <windsdaemon@gmail.com>
> ---
>  net/sched/cls_route.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
> index 37da567..118f8d5 100644
> --- a/net/sched/cls_route.c
> +++ b/net/sched/cls_route.c
> @@ -466,11 +466,11 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
>  		goto reinsert;
>  	}
>  
> -	err = -ENOBUFS;
> +	err = -ENOMEM;
>  	if (head == NULL) {
>  		head = kzalloc(sizeof(struct route4_head), GFP_KERNEL);
>  		if (head == NULL)
> -			goto errout;
> +			goto errhead;
>  
>  		tcf_tree_lock(tp);
>  		tp->root = head;
> @@ -479,7 +479,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
>  
>  	f = kzalloc(sizeof(struct route4_filter), GFP_KERNEL);
>  	if (f == NULL)
> -		goto errout;
> +		goto errflt;
>  
>  	err = route4_set_parms(net, tp, base, f, handle, head, tb,
>  		tca[TCA_RATE], 1);
> @@ -517,6 +517,9 @@ reinsert:
>  
>  errout:
>  	kfree(f);
> +errflt:
> +    kfree(head);
> +errhead:
>  	return err;
>  }
>  

I don't think this patch is needed or correct.

tp->root is the head, you cannot free it like that.

It will be freed properly in route4_destroy()

Please elaborate, thanks.
