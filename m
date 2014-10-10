From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] flow-dissector: Fix alignment issue in
 __skb_flow_get_ports
Date: Fri, 10 Oct 2014 15:32:38 -0400 (EDT)
Message-ID: <20141010.153238.1534216185987913103.davem@davemloft.net>
References: <20141010.141559.2024576018585843684.davem@davemloft.net>
	<20141010.142255.359367991309840826.davem@davemloft.net>
	<54382B2F.8030203@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, eric.dumazet@gmail.com,
	David.Laight@ACULAB.COM, netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbaJJTck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 15:32:40 -0400
In-Reply-To: <54382B2F.8030203@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Fri, 10 Oct 2014 11:53:35 -0700

> On 10/10/2014 11:22 AM, David Miller wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Fri, 10 Oct 2014 14:15:59 -0400 (EDT)
>>
>>> Your original code works because you do things like "byte[12] & 0xf0"
>>> to
>>> extract these fields.
>> Changing that th->doff sequence to instead be:
>>
>> 		const u8 *bp;
>> 		u8 buf[13];
>>
>> 		bp = __skb_header_pointer(skb, poff, sizeof(buf),
>> 					  data, hlen, &buf);
>> 		if (!bp)
>> 			return poff;
>>
>> 		poff += max_t(u32, sizeof(struct tcphdr), (bp[12] & 0xf0) >> 2);
>> 		break;
>>
>> on top of your v3 patch works for me.
>>
>> Please double-check my calculations.
> 
> Any reason why you are grabbing all 13 bytes instead of just the 1 we
> care about?  Seems like we could just use a u8 buf instead of the
> array since we are only grabbing doff.

No reason, just a thinko, my brain implemented this as if skb_header_pointer
worked like skb_pull :-/
