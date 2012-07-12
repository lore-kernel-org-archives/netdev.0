From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [RFC PATCH v2] tcp: TCP Small Queues
Date: Thu, 12 Jul 2012 12:44:55 -0400
Message-ID: <CABrhC0mONb3Ki5YYM1rfiBZnCKd2tYFvdYpuur-u3gDYRii1tw@mail.gmail.com>
References: <CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
	<1340945457.29822.7.camel@edumazet-glaptop>
	<1341396687.2583.1757.camel@edumazet-glaptop>
	<20120709.000834.1182150057463599677.davem@davemloft.net>
	<1341845722.3265.3065.camel@edumazet-glaptop>
	<1341933215.3265.5476.camel@edumazet-glaptop>
	<CABrhC0=Ls7G-noW1cjsyiF+G5v9f9R=bi6JvrOoT5ZDQB=gSXg@mail.gmail.com>
	<1342100812.3265.8260.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, ycheng@google.com,
	dave.taht@gmail.com, netdev@vger.kernel.org,
	codel@lists.bufferbloat.net, therbert@google.com,
	mattmathis@google.com, nanditad@google.com, ncardwell@google.com,
	andrewmcgr@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:33771 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755233Ab2GLQo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 12:44:56 -0400
Received: by gglu4 with SMTP id u4so2623483ggl.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 09:44:56 -0700 (PDT)
In-Reply-To: <1342100812.3265.8260.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 12, 2012 at 9:46 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-07-12 at 09:33 -0400, John Heffner wrote:
>> One general question: why a per-connection limit?  I haven't been
>> following the bufferbloat conversation closely so I may have missed
>> some of the conversation.  But it seems that multiple connections will
>> still cause longer queue times.
>
> We already have a per-device limit, in qdisc.
>
> If you want to monitor several tcp sessions, I urge you use a controller
> for that. Like codel or fq_codel.
>
> Experiments show that limiting to two TSO packets in qdisc per tcp flow
> is enough to stop insane qdisc queueing, without impact on throughput
> for people wanting fast tcp sessions.
>
> Thats not solving the more general problem of having 1000 competing
> flows.

Right, AQM (and probably some modifications to the congestion control)
is the more general solution.

I guess I'm just trying to justify in my mind that the case of a small
number of local connections is worth handling in this special way.  It
seems like a generally reasonable thing, but it's definitely not a
general solution to minimizing latency.  One thing worth noting: on a
system routing traffic, local connections may be at a disadvantage
relative to connections being forwarded, sharing the same interface
queue, if that queue is the bottleneck.

Architecturally, the inconsistency between a local queue and a queue
one hop away bothers me a bit, but it's something I can learn to live
with if it really does improve a common case significantly. ;-)

Thanks,
  -John
