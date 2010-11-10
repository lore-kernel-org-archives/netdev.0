From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Routing over multiple interfaces
Date: Wed, 10 Nov 2010 15:51:01 +0000
Message-ID: <1289404262.8076.13.camel@i7.infradead.org>
References: <1288645922.5977.41.camel@macbook.infradead.org>
	 <20101101.141638.116372747.davem@davemloft.net>
	 <1288647330.2660.116.camel@edumazet-laptop>
	 <1289400654.2721.7.camel@macbook.infradead.org>
	 <1289401704.2860.182.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	uweber@astaro.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54804 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756744Ab0KJPvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 10:51:06 -0500
In-Reply-To: <1289401704.2860.182.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-11-10 at 16:08 +0100, Eric Dumazet wrote:
> Its a bit problematic, as you said you want to use both links to do
> one upload ;)

When it's *necessary*, yes :)

> Maybe it is possible to instruct teql to try to not change links
> unless one link is full... 

Hm... teql doesn't have any visibility into which packets belong to
which flow, does it?

Perhaps the answer is based on my previous setup ('ip route add default
src 90.155.92.214 nexthop dev ppp0 nexthop dev ppp1'). That would
naturally distribute connections between the interfaces, so all we need
on top is a qdisc which will move packets from one interface to the
other when one queue becomes full (or at a given rate limit).

-- 
dwmw2

