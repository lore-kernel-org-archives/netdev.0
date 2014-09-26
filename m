From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/9] ipv6: fib6: socket dst_entry
 improvments and cleanups
Date: Fri, 26 Sep 2014 12:46:43 -0400 (EDT)
Message-ID: <20140926.124643.202150841147181272.davem@davemloft.net>
References: <cover.1411308211.git.hannes@stressinduktion.org>
	<20140926.002853.1097612772155886372.davem@davemloft.net>
	<1411718323.1731596.171980125.03C65719@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	hideaki@yoshifuji.org, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754703AbaIZQqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 12:46:45 -0400
In-Reply-To: <1411718323.1731596.171980125.03C65719@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 26 Sep 2014 09:58:43 +0200

> On Fri, Sep 26, 2014, at 06:28, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Sun, 21 Sep 2014 16:11:44 +0200
>> 
>> > Eric Dumazet noticed that rt6_nodes wich are neither RTF_NONEXTHOP nor
>> > RTF_GATEWAY but DST_HOST ones cause major routing lookup churn because
>> > their rt6_genid is never renewed, thus ip6_dst_check always considers
>> > them outdated. This is a major problem, because these kind of routes
>> > are normally used to in input handling.
>> 
>> This series is a disappointment for me from the perspective of the
>> fact that we have a regression in mainline and this is too complex
>> of a set of changes for there.
>> 
>> If we relookup the thing every TCP input packet, we might as well
>> not do the input route caching in the socket.
> 
> I can understand.
> 
> Toss this series, I'll try to do better tomorrow and send changes for
> net and submit net-next cleanups when your queue is a bit smaller.

BTW, don't get me wrong, I like the new code and for 'net-next' it's
good.

But for 'net' we have to come up with something simpler meanwhile.
