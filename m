From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Wed, 19 Sep 2012 17:17:59 -0400 (EDT)
Message-ID: <20120919.171759.954995920168438601.davem@davemloft.net>
References: <1347913239.26523.173.camel@edumazet-glaptop>
	<20120919.163406.487082174277409074.davem@davemloft.net>
	<1348088634.31352.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brutus@google.com, edumazet@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643Ab2ISVSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 17:18:03 -0400
In-Reply-To: <1348088634.31352.26.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Sep 2012 23:03:54 +0200

> On Wed, 2012-09-19 at 16:34 -0400, David Miller wrote:
> 
>> I have an idea on how to handle this.
>> 
>> In drivers/net/loopback.c:loopback_tx(), skip the SKB orphan operation
>> if there is a friend socket at skb->friend.
>> 
>> When sending such friend SKBs out at connection startup, arrange it
>> such that the skb->destructor will zap the skb->friend pointer to
>> NULL.
>> 
>> Also, in skb_orphan*(), if necessary, set skb->friend to NULL.
>> 
>> skb->sk will hold a reference to the socket, and since skb->friend
>> will be equal, this will make sure a pointer to an unreferenced
>> socket does not escape.
> 
> I now am wondering if we still need skb->friend field.
> 
> If skb->sk is not zeroed by a premature skb_orphan(), then
> 
> skb->sk->sk_friend gives the friend ?

Good point.
