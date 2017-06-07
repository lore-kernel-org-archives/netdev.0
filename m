From: David Ahern <dsahern@gmail.com>
Subject: Re: Repeatable inet6_dump_fib crash in stock 4.12.0-rc4+
Date: Tue, 6 Jun 2017 18:34:47 -0600
Message-ID: <da189b9d-760f-0591-2acf-1a6b7910e227@gmail.com>
References: <bbfa5208-3a04-c87a-a6e1-ee0ae73965d0@candelatech.com>
 <a5733c67-e3a3-9cc0-0862-40ef6fc03de3@gmail.com>
 <1496795269.736.21.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33287 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750766AbdFGAeu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 20:34:50 -0400
Received: by mail-pg0-f42.google.com with SMTP id f185so39787838pgc.0
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 17:34:50 -0700 (PDT)
In-Reply-To: <1496795269.736.21.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/6/17 6:27 PM, Eric Dumazet wrote:
> Good catch, but it looks like similar fix is needed a few lines before.
> 
> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> index deea901746c8570c5e801e40592c91e3b62812e0..b214443dc8346cef3690df7f27cc48a864028865 100644
> --- a/net/ipv6/ip6_fib.c
> +++ b/net/ipv6/ip6_fib.c
> @@ -372,12 +372,13 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
>  
>  		read_lock_bh(&table->tb6_lock);
>  		res = fib6_walk(net, w);
> -		read_unlock_bh(&table->tb6_lock);
>  		if (res > 0) {
>  			cb->args[4] = 1;
>  			cb->args[5] = w->root->fn_sernum;
>  		}
> +		read_unlock_bh(&table->tb6_lock);

indeed. tunnel vision on Ben's problem
