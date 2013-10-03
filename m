From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: shrink tcp6_timewait_sock by one cache
 line
Date: Thu, 03 Oct 2013 16:02:52 -0400 (EDT)
Message-ID: <20131003.160252.2071364130742864278.davem@davemloft.net>
References: <1380711604.19002.78.camel@edumazet-glaptop.roam.corp.google.com>
	<20131003.153158.1558578931500427624.davem@davemloft.net>
	<1380829642.19002.225.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754976Ab3JCUCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 16:02:54 -0400
In-Reply-To: <1380829642.19002.225.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Oct 2013 12:47:22 -0700

> On Thu, 2013-10-03 at 15:31 -0400, David Miller wrote:
> 
>> Eric just use tcp_time_stamp in all of these locations, then you can
>> lose the casts and still achieve your stated objective.
> 
> I thought about this, but this would break if tcp_time_stamp was no
> longer tied to jiffies.
> 
> Van Jacobson had the idea of using finer resolution tcp_time_stamp for
> TCP flows in data centers, for better RTT estimation and and cwin
> control, but also for better diagnostics.
> 
> Note we used this (u32)jiffies thing in net/ipv4/inetpeer.c in the past,
> and tp->tso_deferred is also a u32 value.

I am sure that you could define a set of interfaces which are named
such that the intent and usage is clear, would do the u32 cast, and
would be updated by whoever changes the timestamp implementation in
the future.

The cast is really ugly, even if we do it in inetpeer already, and
you're already here cleaning things up, so please do it right.

Thank you.
