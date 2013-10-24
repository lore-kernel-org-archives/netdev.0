From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: sched: Don't free f before it is allocated in
 route4_change
Date: Thu, 24 Oct 2013 07:54:33 -0700
Message-ID: <1382626473.7572.58.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382626250-15676-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jing Wang <windsdaemon@gmail.com>
To: Christoph Paasch <christoph.paasch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f52.google.com ([209.85.214.52]:40728 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755291Ab3JXOyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 10:54:37 -0400
Received: by mail-bk0-f52.google.com with SMTP id e11so912174bkh.11
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 07:54:36 -0700 (PDT)
In-Reply-To: <1382626250-15676-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-24 at 16:50 +0200, Christoph Paasch wrote:
> f is set to *arg in route4_change at the beginning, which points to a
> route4_filter in the hash-table (gotten through route4_get, called by
> tc_ctl_filter). If the alloc of head fails, we should not goto errout,
> because this will free f and thus freed memory will be referenced by
> the hash-table.
> Only later the pointer f will change to an allocated route4_filter.
> 
> This patch returns err if the allocation of head fails as f has not yet
> been allocated inside route4_change.
> 
> Seems the code has been like this since Linus's original git-commit.
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  net/sched/cls_route.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
> index 37da567..f17c67f 100644
> --- a/net/sched/cls_route.c
> +++ b/net/sched/cls_route.c
> @@ -470,7 +470,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
>  	if (head == NULL) {
>  		head = kzalloc(sizeof(struct route4_head), GFP_KERNEL);
>  		if (head == NULL)
> -			goto errout;
> +			return err;
>  
>  		tcf_tree_lock(tp);
>  		tp->root = head;

I see no bug here, you missed the "goto reinsert;"

Guys, if there are no bugs, could we calm down ?

Thanks !
