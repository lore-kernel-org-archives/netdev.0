From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] flow-dissector: Fix alignment issue in
 __skb_flow_get_ports
Date: Fri, 10 Oct 2014 14:15:59 -0400 (EDT)
Message-ID: <20141010.141559.2024576018585843684.davem@davemloft.net>
References: <54380E49.5050504@redhat.com>
	<20141010.135851.1743803688676076555.davem@davemloft.net>
	<54381F1C.2030800@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, eric.dumazet@gmail.com,
	David.Laight@ACULAB.COM, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbaJJSQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 14:16:01 -0400
In-Reply-To: <54381F1C.2030800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 10 Oct 2014 11:02:04 -0700

> On 10/10/2014 10:58 AM, David Miller wrote:
>> From: Alexander Duyck <alexander.h.duyck@redhat.com>
>> Date: Fri, 10 Oct 2014 09:50:17 -0700
>>
>>> If I just use get_unaligned that is pretty easy in terms of cleanup
>>> for the ports and IPv4 addresses, the IPv6 will still be a significant
>>> hurdle to overcome though.
>> Actually, it's not that simple.
>>
>> When the compiler sees things like "th->doff" it will load the 32-bit
>> word that 4-bit field contains and extract the value using shifts and
>> masking.
>>
>> So we might need to sprinkle a "attribute((packed))" here and there
>> to make it work.
> 
> I'll do some digging.  I know I had this working in igb/ixgbe before so
> I probably just need to add a few small tweaks to resolve the remaining
> issues for v4 of the patch.

Your original code works because you do things like "byte[12] & 0xf0" to
extract these fields.
