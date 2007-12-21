From: David Miller <davem@davemloft.net>
Subject: Re: TSO trimming question
Date: Fri, 21 Dec 2007 01:27:20 -0800 (PST)
Message-ID: <20071221.012720.67812056.davem@davemloft.net>
References: <Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi>
	<20071220.035621.147230372.davem@davemloft.net>
	<20071221030648.389669c4.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, jheffner@psc.edu
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46145
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753734AbXLUJ1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 04:27:20 -0500
In-Reply-To: <20071221030648.389669c4.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Fink <billfink@mindspring.com>
Date: Fri, 21 Dec 2007 03:06:48 -0500

> What's with all the shifting back and forth?  Here with:
> 
> 	((jiffies<<1)>>1) - (tp->tso_deferred>>1)
> 
> and later with:
> 
> 	/* Ok, it looks like it is advisable to defer.  */
> 	tp->tso_deferred = 1 | (jiffies<<1);
> 
> Is this just done to try and avoid the special case of jiffies==0 
> when the jiffies wrap?  If so it seems like a lot of unnecessary
> work just to avoid a 1 in 4 billion event, since it's my understanding
> that the whole tcp_tso_should_defer function is just an optimization
> and not a criticality to the proper functioning of TCP, especially
> considering it hasn't even been executing at all up to now.

How else would you avoid the incorrect result when jiffies is
indeed zero?

It's two shifts, and this gets scheduled along with the other
instructions on many cpus so it's effectively free.

I don't see why this is even worth mentioning and discussing.
