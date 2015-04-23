From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix tcp fin memory accounting
Date: Thu, 23 Apr 2015 13:12:34 -0400 (EDT)
Message-ID: <20150423.131234.2270841808622853554.davem@davemloft.net>
References: <20150423.115447.2163146250304402014.davem@davemloft.net>
	<1429805815.22254.57.camel@edumazet-glaptop2.roam.corp.google.com>
	<1429807692.22254.59.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johunt@akamai.com, netdev@vger.kernel.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42650 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754813AbbDWRMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 13:12:38 -0400
In-Reply-To: <1429807692.22254.59.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Apr 2015 09:48:12 -0700

> On Thu, 2015-04-23 at 09:16 -0700, Eric Dumazet wrote:
>> On Thu, 2015-04-23 at 11:54 -0400, David Miller wrote:
>> > From: Eric Dumazet <eric.dumazet@gmail.com>
>> > Date: Thu, 23 Apr 2015 07:02:47 -0700
>> > 
>> > > +		if (!tcp_send_head(sk)) {
>> > > +			tp->snd_nxt++;
>> > > +			return;
>> > > +		}
>> > 
>> > I'm not so sure about this.  Why is this needed?
>> > 
>> > Otherwise patch looks fine to me.
>> > 
>> 
>> I guess I need to add a comment then ;)
>> 
>> If we want to pretend FIN was sent, we also need to tweak tp->snd_nxt to
>> match new tskb->end_seq (or tp->write_seq).
>> 
>> I tested following packetdrill script and confirmed that if I do not
>> tweak snd_nxt, last packet sent is incorrect :
>> 
>> 	> . 5001:5001(0) ack 2
>> 
>> This might be because our stack relies that we never coalesce something
>> on one already sent skb (we do this check in tcp_sendmsg() for example)
> 
> Well, real reason is that tp->snd_nxt is not touched in retransmit
> paths, but when new data is sent (tcp_event_new_data_sent())

That makes sense, thanks for explaining.
