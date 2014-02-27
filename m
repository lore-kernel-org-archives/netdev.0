From: David Miller <davem@davemloft.net>
Subject: Re: IPv6 routing table max_size badly dimensioned compared to IPv4
Date: Thu, 27 Feb 2014 17:47:55 -0500 (EST)
Message-ID: <20140227.174755.801004637112620140.davem@davemloft.net>
References: <1393532583.26794.26.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140227205010.GB27495@order.stressinduktion.org>
	<1393534920.26794.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, bert.hubert@netherlabs.nl,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50080 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaB0Wr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 17:47:58 -0500
In-Reply-To: <1393534920.26794.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 Feb 2014 13:02:00 -0800

> On Thu, 2014-02-27 at 21:50 +0100, Hannes Frederic Sowa wrote:
> 
>> We store those routes back into the routing table, so we must have a way to
>> count them and trigger gc at some point.
> 
> Right, and current implementation will not scale.
> 
> If we need to perform 10000 inserts per second, and gc timeout is 60
> seconds, tree contains 600.000 entries, gc takes forever...

The only long term solution is to align ipv6 to be more like ipv4.

What's interesting is that if you look at the code, the original
author clearly intended to make callers be able to use route's
from the tree as-is without cloning.
