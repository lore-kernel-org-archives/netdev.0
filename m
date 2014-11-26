From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/5] ethernet/intel: Use eth_skb_pad helper
Date: Wed, 26 Nov 2014 15:41:13 -0500 (EST)
Message-ID: <20141126.154113.1689979442673394078.davem@davemloft.net>
References: <1416966185.29427.46.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141125.221900.653470310152197801.davem@davemloft.net>
	<1416974473.29427.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	kuznet@ms2.inr.ac.ru
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701AbaKZUlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 15:41:15 -0500
In-Reply-To: <1416974473.29427.49.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Nov 2014 20:01:13 -0800

[ I am still intrigued, CC:'ing Alexey ]

> On Tue, 2014-11-25 at 22:19 -0500, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 25 Nov 2014 17:43:05 -0800
>> 
>> > I believe I finally have an idea why we had various + 15 in skb
>> > allocations in TCP stack !
>> 
>> It was so that you could do one level of tunneling with "for
>> free".  Or that is my recollection.
>> 
>> Those + 15 existed way before any of these padto() calls even
>> existed.
> 
> Well, tunneling is added in front of the packet. Thats why we use
> MAX_TCP_HEADER.
> 
> The +15 is in fact because TCP stack wanted to make sure the eventual
> padding (needing tailroom, not headroom) was possible...
> 
> Note that ack packets never used the +15, but other packets did.

Alexey, do you remember exact reason for that +15 everywhere in TCP
packet allocation sizing?

I thought it was for headroom, but as Eric shows that's illogical,
it can only be for tailroom considerations.
