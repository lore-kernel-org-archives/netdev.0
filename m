From: Bill Fink <billfink@mindspring.com>
Subject: Re: TSO trimming question
Date: Fri, 21 Dec 2007 13:54:37 -0500
Message-ID: <20071221135437.16fa63c8.billfink@mindspring.com>
References: <20071221030648.389669c4.billfink@mindspring.com>
	<20071221.012720.67812056.davem@davemloft.net>
	<20071221092927.GA32434@gondor.apana.org.au>
	<20071221.013642.29817274.davem@davemloft.net>
	<20071221055822.8d977800.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org, jheffner@psc.edu
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:41727 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752086AbXLUSys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 13:54:48 -0500
In-Reply-To: <20071221055822.8d977800.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Dec 2007, Bill Fink wrote:

> Or perhaps even:
> 
> 	/* Ok, it looks like it is advisable to defer.  */
> 	tp->tso_deferred = jiffies;
> 
> 	/* need to return a non-zero value to defer, which means won't
> 	 * defer if jiffies == 0 but it's only a 1 in 4 billion event
> 	 * (and avoids a compare/branch by not checking jiffies)
> 	 /
>         return jiffies;

Ack.  I introduced my own 64-bit to 32-bit issue (too late at night).
How about:

	/* Ok, it looks like it is advisable to defer.  */
	tp->tso_deferred = jiffies;

	/* this won't defer if jiffies == 0 but it's only a 1 in
	 * 4 billion event (and avoids a branch)
	 */
	return (jiffies != 0);

							-Bill
