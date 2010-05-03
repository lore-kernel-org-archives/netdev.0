From: David Miller <davem@davemloft.net>
Subject: Re: OOP in ip_cmsg_recv (net-next)
Date: Mon, 03 May 2010 15:30:52 -0700 (PDT)
Message-ID: <20100503.153052.38313011.davem@davemloft.net>
References: <20100503094735.077c2af5@nehalam>
	<1272906266.2226.77.camel@edumazet-laptop>
	<20100503140048.30aedad7@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43396
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754343Ab0ECWap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 18:30:45 -0400
In-Reply-To: <20100503140048.30aedad7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 3 May 2010 14:00:48 -0700

> On Mon, 03 May 2010 19:04:26 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> diff --git a/net/core/datagram.c b/net/core/datagram.c
>> index 95b851f..88949b0 100644
>> --- a/net/core/datagram.c
>> +++ b/net/core/datagram.c
>> @@ -230,12 +230,8 @@ EXPORT_SYMBOL(skb_free_datagram);
>>  void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
>>  {
>>  	lock_sock_bh(sk);
>> -	skb_orphan(skb);
>> -	sk_mem_reclaim_partial(sk);
>> +	skb_free_datagram(sk, skb);
>>  	unlock_sock_bh(sk);
>> -
>> -	/* skb is now orphaned, might be freed outside of locked section */
>> -	consume_skb(skb);
>>  }
>>  EXPORT_SYMBOL(skb_free_datagram_locked);
> 
> This works great for me. No messages for several hours.

Eric if we can't refine properly your other approach to fixing this
I'd like to apply this version meanwhile...
