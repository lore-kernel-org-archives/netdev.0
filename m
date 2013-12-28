From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 19/20] net: plip: slight optimization of addr
 compare
Date: Sat, 28 Dec 2013 13:07:44 +0800
Message-ID: <52BE5CA0.40009@huawei.com>
References: <52BD22ED.4030302@huawei.com>	 <1388159283.12212.80.camel@edumazet-glaptop2.roam.corp.google.com> <1388163982.30298.12.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:64303 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705Ab3L1FIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 00:08:13 -0500
In-Reply-To: <1388163982.30298.12.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/28 1:06, Joe Perches wrote:
> On Fri, 2013-12-27 at 07:48 -0800, Eric Dumazet wrote:
>> On Fri, 2013-12-27 at 14:49 +0800, Ding Tianhong wrote:
>>> Use possibly more efficient ether_addr_equal
>>> to instead of memcmp.
> []
>>> diff --git a/drivers/net/plip/plip.c b/drivers/net/plip/plip.c
> []
>>> @@ -549,7 +549,7 @@ static __be16 plip_type_trans(struct sk_buff *skb, struct net_device *dev)
>>>  
>>>  	if(*eth->h_dest&1)
>>>  	{
>>> -		if(memcmp(eth->h_dest,dev->broadcast, ETH_ALEN)==0)
>>> +		if(ether_addr_equal(eth->h_dest, dev->broadcast))
>>>  			skb->pkt_type=PACKET_BROADCAST;
>>>  		else
>>>  			skb->pkt_type=PACKET_MULTICAST;
>>
>> What about :
>>
>>         if (is_multicast_ether_addr(eth->h_dest)) {
>>                 if (ether_addr_equal_64bits(eth->h_dest, dev->broadcast))
>>                         skb->pkt_type = PACKET_BROADCAST;
>>                 else
>>                         skb->pkt_type = PACKET_MULTICAST;
>>         }
> 
> That is better though I wonder how many systems are
> still using laplink via parallel null-printer cables.
> 
> No matter, better is better.
> 
> The same optimization using ether_addr_equal_64bits
> may be possible to do in other places given other
> structs too.
> 
> Perhaps it's a possible spatch/coccinelle conversion,
> 
> I don't know spatch well enough to know if a
> mechanism to check if structure members have other
> fields that follow them in the structure or if the
> structure member is an array of a minimum size.
> 
> Maybe Julia does.  (cc'd)
> 
> 
As the below patch said, that a lot of ether_addr_equal
could be instead of ether_addr_equal_64bits, and I need to
review them and resend.

Regards
Ding 

> 
