From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Tue, 20 Nov 2007 00:29:45 -0500
Message-ID: <20071120002945.91fafb2b.billfink@mindspring.com>
References: <20071118214515.GA8161@one.firstfloor.org>
	<20071118.144010.236028466.davem@davemloft.net>
	<20071119152933.GA19126@one.firstfloor.org>
	<20071119.142313.63549156.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, wangchen@cn.fujitsu.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:55631 "EHLO
	elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755195AbXKTFaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 00:30:04 -0500
In-Reply-To: <20071119.142313.63549156.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Nov 2007, David Miller wrote:

> From: Andi Kleen <andi@firstfloor.org>
> Date: Mon, 19 Nov 2007 16:29:33 +0100
> 
> > > > > 
> > > > > All of our options suck, we just have to choose the least sucking one
> > > > > and right now to me that's decrementing the counter as much as I
> > > > > empathize with the SNMP application overflow detection issue.
> > > > 
> > > > If the SNMP monitor detects an false overflow the error it reports 
> > > > will be much worse than a single missing packet. So you would replace 
> > > > one error with a worse error.
> > > 
> > > This can be fixed, the above cannot.
> > 
> > I don't see how, short of breaking the interface
> > (e.g. reporting 64bit or separate overflow counts)
> 
> As someone who just spent an entire weekend working on
> cpu performance counter code, I know it's possible.
> 
> When you overflow, the new value is "a lot" less than
> the last sampled one.  When the value backtracks like
> we're discussing it could here, it only decrease
> a very little bit.

While I agree with your analysis that it could be worked around,
who knows how all the various SNMP monitoring applications out there
would interpret such an unusual event.  I liked Stephen's suggestion
of a deferred decrement that would insure the counter didn't ever
run backwards.  But the best approach seems to be just not to count
it in the first place until tha application has actually received
the packet, since as Herbert pointed out, that's what the RFC
actually specifies for the meaning of the udpInDatagrams counter.

						-Bill
