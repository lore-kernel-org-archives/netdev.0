From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH 1/1] Reverse sense of promisc tests in ip6_mc_input
Date: Sat, 12 May 2007 17:21:10 -0700
Message-ID: <OFFD46637C.90C02CF8-ON882572DA.0001BA3C-882572DA.0001E6DB@us.ibm.com>
References: <20070512225135.GA1143@nc.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Corey Mutter <crm-netdev@the-machine.mutternet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:59179 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755877AbXEMAVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2007 20:21:33 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4D0LNZ8014820
	for <netdev@vger.kernel.org>; Sat, 12 May 2007 20:21:23 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4D0LHfZ242020
	for <netdev@vger.kernel.org>; Sat, 12 May 2007 18:21:22 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4D0LHoj009342
	for <netdev@vger.kernel.org>; Sat, 12 May 2007 18:21:17 -0600
In-Reply-To: <20070512225135.GA1143@nc.rr.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Your patch looks correct to me.

                        +-DLS

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

netdev-owner@vger.kernel.org wrote on 05/12/2007 03:51:35 PM:

> From: Corey Mutter <crm-netdev@mutternet.com>
> 
> Reverse the sense of the promiscuous-mode tests in ip6_mc_input(). 
> 
> Signed-off-by: Corey Mutter <crm-netdev@mutternet.com>
> 
> ---
> 
> I had been suspicious of this code for a while, but just assumed I must 
> have been missing something. However, I did some tests and, sure enough, 

> I can open a socket and it will see IPv6 multicast packets come in, then 

> the packets will stop coming in when I turn on IFF_ALLMULTI on the 
> interface. 
> 
> In my tests, this change works more like I'd expect; I can open a 
> socket, and it doesn't see any multicast packets (unless I join a group 
> or something) until after I turn on IFF_ALLMULTI. 
> 
> --- linux-2.6.21.1/net/ipv6/ip6_input.c   2007-04-27 17:49:26.000000000 
-0400
> +++ linux/net/ipv6/ip6_input.c   2007-05-12 18:19:09.597750000 -0400
> @@ -235,7 +235,7 @@ int ip6_mc_input(struct sk_buff *skb)
>     IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INMCASTPKTS);
> 
>     hdr = skb->nh.ipv6h;
> -   deliver = likely(!(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI))) ||
> +   deliver = unlikely(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI)) ||
>         ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, NULL);
> 
>     /*
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

