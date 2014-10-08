From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: sunvnet and ->xmit_more
Date: Wed, 8 Oct 2014 19:51:26 -0400
Message-ID: <20141008235126.GN25891@oracle.com>
References: <20141007.151849.84417269004453869.davem@davemloft.net>
 <20141007192922.GA31406@oracle.com>
 <20141007.153829.1919460115976279645.davem@davemloft.net>
 <CACP96tSqmPzwYQKbAfVFc2YmyEOdyRtxeoCSuczx1EZTrF0JMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, Raghuram.Kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46809 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbaJHXvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 19:51:31 -0400
Content-Disposition: inline
In-Reply-To: <CACP96tSqmPzwYQKbAfVFc2YmyEOdyRtxeoCSuczx1EZTrF0JMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


One thought occurred to me about a way to use this..

It's true that in the case of sunvnet, we send the tx-trigger
at the *start* of a burst, thus we would do the same amount of work
whether we had 1 or N (>1) packets for a burst, until a STOPPED was
received, 

and if we tried playing games with this, for every sequence where
the game-playing around "when should I send START" helps, there would
always be a counter-example where it would hurt..

but there *is* one way in which it could be used- if the producer
could somehow signal the "xmit_more" info to the consumer, then
the consumer could factor that information in, when trying to
decide whether or not to declare STOPPED (recall the discussion 
around the fudge-factor that we had earlier in
http://www.spinics.net/lists/netdev/msg294549.html -  the skb_more
provides a better hint than merely guessing a udelay)

Raghuram just pointed out to me

" But this can only be used as a hint, as we cannot rely on the peer to
  send the next pack in specific time frame, the peer may be stuck in something
  else or switched out due to scheduling or some bug etc.

  To pass this hint, ..  we could use a bit in a descriptor in TxDring too."

That might be worth investigating (but I might not get to it till
I get the NAPI on its way).

--Sowmini
