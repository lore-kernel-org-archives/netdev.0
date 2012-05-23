From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: fix the rcu race between free_fib_info and
 ip_route_output_slow
Date: Wed, 23 May 2012 08:43:33 +0200
Message-ID: <1337755413.3361.1896.camel@edumazet-glaptop>
References: <4FBB6105.2060808@intel.com>
	 <20120522.151554.106838106733194160.davem@davemloft.net>
	 <1337742123.14538.175.camel@ymzhang.sh.intel.com>
	 <20120522.232310.911242148705021745.davem@davemloft.net>
	 <1337747829.3361.1599.camel@edumazet-glaptop>
	 <1337748897.14538.184.camel@ymzhang.sh.intel.com>
	 <1337749339.3361.1655.camel@edumazet-glaptop>
	 <1337755038.3361.1878.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kunx.jiang@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yanmin Zhang <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:48170 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892Ab2EWGnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 02:43:41 -0400
In-Reply-To: <1337755038.3361.1878.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-23 at 08:37 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index ffcb3b0..b56b91e 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2127,7 +2127,7 @@ static int __mkroute_input(struct sk_buff *skb,
>  	u32 itag;
>  
>  	/* get a working reference to the output device */
> -	out_dev = __in_dev_get_rcu(FIB_RES_DEV(*res));
> +	out_dev = __in_dev_get_rcu(rcu_dereference(FIB_RES_DEV(*res)));

This part might need additional fix (if FIB_RES_DEV(*res) is NULL),
because __in_dev_get_rcu() could crash dereferencing NULL pointer.
