From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.38.2, kernel panic, probably related to framentation
 handling
Date: Wed, 04 May 2011 14:05:33 -0700 (PDT)
Message-ID: <20110504.140533.35050081.davem@davemloft.net>
References: <1304528581.32152.15.camel@edumazet-laptop>
	<1304532674.32152.16.camel@edumazet-laptop>
	<1304539346.32152.81.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56471
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753837Ab1EDVGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 17:06:06 -0400
In-Reply-To: <1304539346.32152.81.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 May 2011 22:02:26 +0200

> [PATCH] net: ip_expire() must revalidate route
> 
> Commit 4a94445c9a5c (net: Use ip_route_input_noref() in input path)
> added a bug in IP defragmentation handling, in case timeout is fired.
> 
> When a frame is defragmented, we use last skb dst field when building
> final skb. Its dst is valid, since we are in rcu read section.
> 
> But if a timeout occurs, we take first queued fragment to build one ICMP
> TIME EXCEEDED message. Problem is all queued skb have weak dst pointers,
> since we escaped RCU critical section after their queueing. icmp_send()
> might dereference a now freed (and possibly reused) part of memory.
> 
> Calling skb_dst_drop() and ip_route_input_noref() to revalidate route is
> the only possible choice.
> 
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---

Applied to net-2.6 and queued up for -stable, thanks Eric!
