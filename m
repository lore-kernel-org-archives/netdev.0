From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] sunvnet: set queue mapping when doing packet
 copies
Date: Thu, 29 Jan 2015 14:15:58 -0800 (PST)
Message-ID: <20150129.141558.2191091565448535105.davem@davemloft.net>
References: <54CA8D33.6020006@oracle.com>
	<1422563996.21689.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.stevens@oracle.com, netdev@vger.kernel.org,
	sowmini.varadhan@oracle.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758094AbbA2WP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 17:15:59 -0500
In-Reply-To: <1422563996.21689.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Jan 2015 12:39:56 -0800

> On Thu, 2015-01-29 at 14:42 -0500, David L Stevens wrote:
>> @@ -1123,6 +1123,16 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, int ncookies)
>>  			skb_shinfo(nskb)->gso_size = skb_shinfo(skb)->gso_size;
>>  			skb_shinfo(nskb)->gso_type = skb_shinfo(skb)->gso_type;
>>  		}
>> +		nskb->queue_mapping = skb->queue_mapping;
>> +		/* Following permits correct back-pressure, for protocols
>> +		 * using skb_set_owner_w().
>> +		 * Idea is to transfer ownership from skb to nskb.
>> +		 */
>> +		if (skb->destructor == sock_wfree) {
> 
> Sorry, but you should remove this test.
> 
> (TCP uses another destructor, not sock_wfree())
> 
> All sent packets will support these swap() operations,
> regardless of destructor.

Then we need to fix skb_segment() too.
