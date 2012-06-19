From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Mon, 18 Jun 2012 21:27:21 -0700 (PDT)
Message-ID: <20120618.212721.2148947025741866390.davem@davemloft.net>
References: <20120618.211539.105938285016510975.davem@davemloft.net>
	<1340079813.7491.2164.camel@edumazet-glaptop>
	<1340079938.7491.2172.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab2FSE1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 00:27:21 -0400
In-Reply-To: <1340079938.7491.2172.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Jun 2012 06:25:38 +0200

> On Tue, 2012-06-19 at 06:23 +0200, Eric Dumazet wrote:
>> On Mon, 2012-06-18 at 21:15 -0700, David Miller wrote:
>> > From: Eric Dumazet <eric.dumazet@gmail.com>
>> > Date: Tue, 19 Jun 2012 06:07:26 +0200
>> > 
>> > > On Mon, 2012-06-18 at 19:40 -0700, David Miller wrote:
>> > >> You know you want it.
>> > >> 
>> > >> Signed-off-by: David S. Miller <davem@davemloft.net>
>> > > 
>> > > Yeah, very good idea David ;)
>> > > 
>> > > needs some polishing of course.
>> > 
>> > Such as?  IPv6 support?
>> > 
>> 
>> I was referring to socket leak in :
>> 
>> +       if (sk) {
>> +               skb->sk = sk;
>> +               skb->destructor = sock_edemux;
>> +               if (sk->sk_state != TCP_TIME_WAIT) {
>> +                       struct dst_entry *dst = sk->sk_rx_dst;
>> +                       if (dst) {
>> +                               skb_dst_set_noref(skb, dst);
>> +                               err = 0;
>> +                       }
>> +               }
>> +       }
>> 
>> 
> 
> It's not a leak, but seems strange to keep it around if we dont use it
> yet.

How are we not using it?  We use the cached SKB socket no matter what
happens.

Look at how inet hash lookup works.

The error tells the caller solely whether a route lookup is still
necessary.
