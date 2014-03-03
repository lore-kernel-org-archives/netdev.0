From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next] vlan: use ether_addr_equal_64bits to instead
 of ether_addr_equal
Date: Mon, 3 Mar 2014 10:49:36 +0800
Message-ID: <5313EDC0.6020701@huawei.com>
References: <5313D77F.3090508@huawei.com> <1393811384.13719.47.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:37059 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759AbaCCCuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 21:50:00 -0500
In-Reply-To: <1393811384.13719.47.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/3 9:49, Joe Perches wrote:
> On Mon, 2014-03-03 at 09:14 +0800, Ding Tianhong wrote:
>> Ether_addr_equal_64bits is more efficient than ether_addr_equal, and
>> can be used when each argument is an array within a structure that
>> contains at least two bytes of data beyond the array, so it is safe
>> to use it for vlan.
> []
>> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> []
>> @@ -26,7 +26,7 @@ bool vlan_do_receive(struct sk_buff **skbp)
>>  		/* Our lower layer thinks this is not local, let's make sure.
>>  		 * This allows the VLAN to have a different MAC than the
>>  		 * underlying device, and still route correctly. */
>> -		if (ether_addr_equal(eth_hdr(skb)->h_dest, vlan_dev->dev_addr))
>> +		if (ether_addr_equal_64bits(eth_hdr(skb)->h_dest, vlan_dev->dev_addr))
>>  			skb->pkt_type = PACKET_HOST;
>>  	}
> 
> Hi again Ding
> 
> If you do have performance numbers:
> 
> The lines above this ether_addr_equal_64 are:
> 
> 	if (skb->pkt_type == PACKET_OTHERHOST) {
> 		/* Our lower layer thinks this is not local, let's make sure.
> 		 * This allows the VLAN to have a different MAC than the
> 		 * underlying device, and still route correctly. */
> 		if (ether_addr_equal(eth_hdr(skb)->h_dest, vlan_dev->dev_addr))
> 			skb->pkt_type = PACKET_HOST;
> 	}
> 
> Maybe it'd be faster overall to add an unlikely
> to the == test
> 
> 	if (unlikely(skb->pkt_type == PACKET_OTHERHOST)) {
> 
> 
> 

Sorry, I can't understand it clearly, do you mean that if the skb deliver to the vlan dev,
it is impossible that the pkt_type is PACKET_OTHERHOST at most time?

Regards
Ding

> 
