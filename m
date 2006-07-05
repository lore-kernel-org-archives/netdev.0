From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] [PKT_SCHED]: Fix error handling while dumping
	actions
Date: Tue, 04 Jul 2006 21:47:38 -0400
Message-ID: <1152064058.5199.12.camel@jzny2>
References: <20060704220504.787776000@postel.suug.ch>
	 <20060704220550.406275000@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:59844 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932443AbWGEBrm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 21:47:42 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FxwUW-0000in-Se
	for netdev@vger.kernel.org; Tue, 04 Jul 2006 21:47:48 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060704220550.406275000@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I need to stare at this one for longer than 1 minute and i dont have
time right now; it does look strange (I am unsure what my thoughts were
at that point with -err - or maybe that was a change made by someone
else). 
I dont have time until tommorow - but i would  think the better fix will
be to change "return -err" to  "return -1"?

cheers,
jamal 

On Wed, 2006-05-07 at 00:00 +0200, Thomas Graf wrote:
> plain text document attachment (act_fix_dump_err_handling)
> "return -err" and blindly inheriting the error code in the netlink
> failure exception handler causes errors codes to be returned as
> positive value therefore making them being ignored by the caller.
> 
> May lead to sending out incomplete netlink messages.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> 
> Index: net-2.6.git/net/sched/act_api.c
> ===================================================================
> --- net-2.6.git.orig/net/sched/act_api.c
> +++ net-2.6.git/net/sched/act_api.c
> @@ -250,15 +250,17 @@ tcf_action_dump(struct sk_buff *skb, str
>  		RTA_PUT(skb, a->order, 0, NULL);
>  		err = tcf_action_dump_1(skb, a, bind, ref);
>  		if (err < 0)
> -			goto rtattr_failure;
> +			goto errout;
>  		r->rta_len = skb->tail - (u8*)r;
>  	}
>  
>  	return 0;
>  
>  rtattr_failure:
> +	err = -EINVAL;
> +errout:
>  	skb_trim(skb, b - skb->data);
> -	return -err;
> +	return err;
>  }
>  
>  struct tc_action *tcf_action_init_1(struct rtattr *rta, struct rtattr *est,
> 
> --
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

