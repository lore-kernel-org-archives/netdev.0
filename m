From: Daniel Petre <daniel.petre@rcs-rds.ro>
Subject: Re: [PATCH] ip_gre: fix kernel panic with icmp_dest_unreach
Date: Fri, 24 May 2013 12:40:02 +0300
Message-ID: <519F3572.7060503@rcs-rds.ro>
References: <D2CA09D3-A93C-48CF-A23B-DC1B76D66818@rcs-rds.ro>  <1369170063.3301.251.camel@edumazet-glaptop> <519C839E.1000309@rcs-rds.ro>   <1369222666.3301.304.camel@edumazet-glaptop> <519CB0D3.8000406@rcs-rds.ro>  <1369230739.3301.334.camel@edumazet-glaptop> <519CE6F0.3040703@rcs-rds.ro>  <519DD7A4.9090801@rcs-rds.ro> <1369324409.3301.382.camel@edumazet-glaptop> <1369329033.3301.389.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailproxy.rcs-rds.ro ([212.54.120.14]:42129 "EHLO
	mailproxy.rcs-rds.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab3EXJkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 05:40:05 -0400
In-Reply-To: <1369329033.3301.389.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2013 08:10 PM, Eric Dumazet wrote:
> On Thu, 2013-05-23 at 08:53 -0700, Eric Dumazet wrote:
>> On Thu, 2013-05-23 at 11:47 +0300, Daniel Petre wrote:
>>
>>>
>>> Hello again Eric,
>>> we applied the little patch from:
>>> http://lkml.indiana.edu/hypermail/linux/kernel/1007.0/00961.html
>>> we have flapped the link few times and everything recovered smooth.
>>>
>>
>> Thats a very good catch, now we have to fix the bug at the right place.
> 
> 
> Please try the following patch :

we have compiled it, tested it few times and.. nothing evil happens anymore!

> 
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 91d66db..563358e 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -795,6 +795,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>  
>  	if (dev->type == ARPHRD_ETHER)
>  		IPCB(skb)->flags = 0;
> +	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
>  
>  	if (dev->header_ops && dev->type == ARPHRD_IPGRE) {
>  		gre_hlen = 0;
> @@ -952,7 +953,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>  	skb_push(skb, gre_hlen);
>  	skb_reset_network_header(skb);
>  	skb_set_transport_header(skb, sizeof(*iph));
> -	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
>  	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
>  			      IPSKB_REROUTED);
>  	skb_dst_drop(skb);
> 
> 
