From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] inetpeer: Support ipv6 addresses.
Date: Mon, 29 Mar 2010 15:21:39 -0700 (PDT)
Message-ID: <20100329.152139.235700903.davem@davemloft.net>
References: <20100328131112.GA15984@gondor.apana.org.au>
	<20100328.064012.193708716.davem@davemloft.net>
	<20100328135931.GA16430@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59287
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754258Ab0C2WVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 18:21:38 -0400
In-Reply-To: <20100328135931.GA16430@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 28 Mar 2010 21:59:31 +0800

> On Sun, Mar 28, 2010 at 06:40:12AM -0700, David Miller wrote:
>>
>> Same for all the other metrics at the TCP level.
> 
> I don't think they are quite the same.  The TCP time stamp is
> an attribute of the destination host, it doesn't vary depending
> on which route you take to reach the host.  The MTU on the other
> hand is an attribute of the route that reaches the host.

It does make a difference, I think.

When we use IPSEC rules on ports and crazy stuff like that,
we end up with cases such as:

1) We're going over a VPN so RTT, RTTVAR, SSTHRESH, CWND, and other
   TCP metrics which are based upon aspects of the path can end up
   being wildly different.

2) even the end host can be different in some convoluted
   setups

IPSEC encapsulation can effectively change the entire universe in fact
:-) Also, even considering only case #1 above, that's nearly half of
the metrics which we arguably can't move into something like the
inetpeer cache.

This is basically why I've been resistent in the past to these kinds
of ideas to simplify metric handling, as it has the potential to break
something.

The gains of being able to pull this off are still enticing which
is why this topic keeps getting revisited nonetheless :-)
