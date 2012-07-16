From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv6: fix incorrect route 'expires' value passed to
 userspace.
Date: Mon, 16 Jul 2012 09:41:24 -0700
Message-ID: <20120716094124.0040561f@s6510.linuxnetplumber.net>
References: <5003CC41.9080204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36866 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752078Ab2GPQla (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 12:41:30 -0400
In-Reply-To: <5003CC41.9080204@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jul 2012 16:09:37 +0800
Li Wei <lw@cn.fujitsu.com> wrote:

> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index becb048..a7fec9d 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -2516,7 +2516,7 @@ static int rt6_fill_node(struct net *net,
>  		goto nla_put_failure;
>  	if (!(rt->rt6i_flags & RTF_EXPIRES))
>  		expires = 0;
> -	else if (rt->dst.expires - jiffies < INT_MAX)
> +	else if ((int)(rt->dst.expires - jiffies) < INT_MAX)
>  		expires = rt->dst.expires - jiffies;
>  	else
>  		expires = INT_MAX;

Why not use time_is_after_jiffies() macro?
