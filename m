From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH] net/sched: remove redundant null check on head
Date: Wed, 03 May 2017 16:21:15 +0200
Message-ID: <5909E75B.30305@bfs.de>
References: <20170503135040.32023-1-colin.king@canonical.com>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02-sz.bfs.de ([194.94.69.103]:57696 "EHLO mx02-sz.bfs.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752582AbdECOVU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 10:21:20 -0400
In-Reply-To: <20170503135040.32023-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 03.05.2017 15:50, schrieb Colin King:
> From: Colin Ian King <colin.king@canonical.com>
> 
> head is previously null checked and so the 2nd null check on head
> is redundant and therefore can be removed.
> 
> Detected by CoverityScan, CID#1399505 ("Logically dead code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/sched/cls_matchall.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
> index 2efb36c08f2a..dee469fed967 100644
> --- a/net/sched/cls_matchall.c
> +++ b/net/sched/cls_matchall.c
> @@ -203,8 +203,7 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
>  
>  	*arg = (unsigned long) head;
>  	rcu_assign_pointer(tp->root, new);
> -	if (head)
> -		call_rcu(&head->rcu, mall_destroy_rcu);
> +	call_rcu(&head->rcu, mall_destroy_rcu);
>  	return 0;
>  
>  err_replace_hw_filter:


if someone cares .. the err=0 in the the line above the patch is also useless
because err is never used again. Merging both if will save 1 indent level.

 err = mall_replace_hw_filter(tp, new, (unsigned long) new);
 if (err && tc_skip_sw(flags) )
	goto errout;


just my impression,
re
 wh
