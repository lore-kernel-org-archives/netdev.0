From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4/ip_gre: make ipgre_tunnel_xmit() not parse
 network header as IP unconditionally
Date: Fri, 21 Dec 2012 13:15:15 -0800 (PST)
Message-ID: <20121221.131515.719932350655314456.davem@davemloft.net>
References: <9ee0cd8f94e1ee866b40ee7b6755e8d8705325c9.1356052319.git.yamahata@valinux.co.jp>
	<1356054521.21834.4043.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yamahata@valinux.co.jp, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44556 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011Ab2LUVPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 16:15:20 -0500
In-Reply-To: <1356054521.21834.4043.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Dec 2012 17:48:41 -0800

> On Fri, 2012-12-21 at 10:12 +0900, Isaku Yamahata wrote:
>> ipgre_tunnel_xmit() parses network header as IP unconditionally.
>> But transmitting packets are not always IP packet. For example such packet
>> can be sent by packet socket with sockaddr_ll.sll_protocol set.
>> So make the function check if skb->protocol is IP.
>> 
>> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
>> ---
>>  net/ipv4/ip_gre.c |    5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>> 
>> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
>> index a85ae2f..8fcf0ed 100644
>> --- a/net/ipv4/ip_gre.c
>> +++ b/net/ipv4/ip_gre.c
>> @@ -760,7 +760,10 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>>  
>>  	if (dev->header_ops && dev->type == ARPHRD_IPGRE) {
>>  		gre_hlen = 0;
>> -		tiph = (const struct iphdr *)skb->data;
>> +		if (skb->protocol == htons(ETH_P_IP))
>> +			tiph = (const struct iphdr *)skb->data;
>> +		else
>> +			tiph = &tunnel->parms.iph;
>>  	} else {
>>  		gre_hlen = tunnel->hlen;
>>  		tiph = &tunnel->parms.iph;
> 
> Seems good to me thanks !
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
