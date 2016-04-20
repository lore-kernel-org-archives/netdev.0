From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp-tso: do not split TSO packets at
 retransmit time
Date: Tue, 19 Apr 2016 21:10:52 -0400 (EDT)
Message-ID: <20160419.211052.2203209755339071835.davem@davemloft.net>
References: <1461012972-15757-1-git-send-email-edumazet@google.com>
	<20160419.203656.505846026424405432.davem@davemloft.net>
	<1461113390.10638.233.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, ncardwell@google.com,
	ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608AbcDTBK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 21:10:56 -0400
In-Reply-To: <1461113390.10638.233.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Apr 2016 17:49:50 -0700

> On Tue, 2016-04-19 at 20:36 -0400, David Miller wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> Date: Mon, 18 Apr 2016 13:56:12 -0700
>> 
>> > 1 % packet losses are common today, and at 100Gbit speeds, this
>> > translates to ~80,000 losses per second. If we are unlucky and
>> > first MSS of a 45-MSS TSO is lost, we are cooking 44 MSS segments
>> > at rtx instead of a single 44-MSS TSO packet.
>> 
>> I'm having trouble understanding this.
>> 
>> If the first mss is lost, then we simply chop the 45 MSS TSO skb into
>> two pieces.  The first piece is a 1 MSS chunk for the retransmit, and
>> the second piece is remaining 44 MSS TSO skb.
>> 
>> I am pretty sure that is what the current stack does, and regardless
>> it is certainly what I intended it to do all those years ago when I
>> wrote this code. :-)
>> 
>> The only case where I can see this patch helping is when we have to
>> retransmit multi-mss chunks.  And yes indeed, it might be a useful
>> optimization to TSO those frames rather than sending them one MSS at a
>> time.
> 
> Yeah, it looks like I got the changelog wrong. We definitely see these
> 1-MSS splits during retransmits all the time, and we had to change the
> sch_fq flow_limit from 100 to 1000 packets to cope with that. (TCP Small
> Queues does not guard TCP from sending hundred of rtx at the same time)

Ok, please rewrite the commit log message so that it is more accuate.

Thank you.
