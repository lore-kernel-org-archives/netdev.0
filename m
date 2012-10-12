From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp resets are misrouted
Date: Fri, 12 Oct 2012 13:53:43 -0400 (EDT)
Message-ID: <20121012.135343.2054104958323622117.davem@davemloft.net>
References: <20121012143417.GA8481@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shawn.lu@ericsson.com,
	eric.dumazet@gmail.com, sol@eqv.ru
To: kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49377 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757703Ab2JLRxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 13:53:48 -0400
In-Reply-To: <20121012143417.GA8481@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Fri, 12 Oct 2012 18:34:17 +0400

> After commit e2446eaa.. tcp resets are always lost, when routing is asymmetric.
> Yes, backing out that patch will result in misrouting of resets for dead connections
> which used interface binding when were alive, but we actually cannot do anything here.
> What's died that's died and correct handling normal unbound connections is obviously a priority.
> 
> Comment to comment:
>> This has few benefits:
>>   1. tcp_v6_send_reset already did that.
> 
> It was done to route resets for IPv6 link local addresses. It was a mistake to
> do so for global addresses. The patch fixes this as well.
> 
> Actually, the problem appears to be even more serious than guaranteed loss of resets.
> As reported by Sergey Soloviev <sol@eqv.ru>, those misrouted resets create a lot of
> arp traffic and huge amount of unresolved arp entires putting down to knees NAT firewalls
> which use asymmetric routing.
> 
> Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

Applied and queued up for -stable, thanks!
