From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel BUG in ipmr_queue_xmit()
Date: Thu, 29 Oct 2015 21:15:42 -0700
Message-ID: <1446178542.6254.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.OSX.2.00.1510291646320.59200@animac.local>
	 <20151030001510.GG18062@breakpoint.cc>
	 <alpine.OSX.2.00.1510291841480.68875@animac.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	ani@anirban.org, fruggeri@arista.com
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34366 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbbJ3EPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 00:15:44 -0400
Received: by padhk11 with SMTP id hk11so61185953pad.1
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 21:15:44 -0700 (PDT)
In-Reply-To: <alpine.OSX.2.00.1510291841480.68875@animac.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-29 at 18:41 -0700, Ani Sinha wrote:

> 
> Signed-off-by: Ani Sinha <ani@arista.com>
> ---
>  net/ipv4/ipmr.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index 866ee89..48df3cc 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -936,7 +936,9 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
>  
>  			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
>  		} else {
> +			preempt_disable();
>  			ip_mr_forward(net, mrt, skb, c, 0);
> +			preempt_enable();
>  		}
>  	}
>  }

I do not believe this fix is correct.

Better replace the 
IP_INC_STATS_BH() by IP_INC_STATS()

and IP_ADD_STATS_BH() by IP_ADD_STATS()
