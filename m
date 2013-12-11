From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/6] net_sched: make macro be enclosed in
 parenthesis
Date: Tue, 10 Dec 2013 22:49:00 -0500 (EST)
Message-ID: <20131210.224900.1427512059771492387.davem@davemloft.net>
References: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>
	<1386680134-85452-7-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54203 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634Ab3LKDtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 22:49:01 -0500
In-Reply-To: <1386680134-85452-7-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Tue, 10 Dec 2013 20:55:34 +0800

> Macros with complex values should be enclosed in parenthesis
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  net/sched/em_meta.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
> index e5cef956..852cd62 100644
> --- a/net/sched/em_meta.c
> +++ b/net/sched/em_meta.c
> @@ -272,10 +272,12 @@ META_COLLECTOR(int_rtiif)
>   **************************************************************************/
>  
>  #define SKIP_NONLOCAL(skb)			\
> +({						\
>  	if (unlikely(skb->sk == NULL)) {	\
>  		*err = -1;			\
>  		return;				\
> -	}
> +	}					\
> +})

I can't apply this.

First of all, "({ })" is for statements that evaluate to an lvalue,
this macro does not.

Second of all, and more importantly, this macro needs to be eliminated
entirely.  It completely hides control flow, and in the past we've
killed macros which do this such as the old netlink attribute
builders.

The control flow should be inlined and expanded explicitly in the
code so that someone who reads it can tell the control flow can
be changed by the statement.  Compare:

	SKIP_NONLOCAL(skb)

to:

	if (skip_nonlocal(skb)) {
		*err = -1;
		return;
	}
