From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Sun, 18 Nov 2007 14:40:10 -0800 (PST)
Message-ID: <20071118.144010.236028466.davem@davemloft.net>
References: <p73bq9tau2x.fsf@bingen.suse.de>
	<20071117.160926.232024605.davem@davemloft.net>
	<20071118214515.GA8161@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36480
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753310AbXKRWkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2007 17:40:16 -0500
In-Reply-To: <20071118214515.GA8161@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Sun, 18 Nov 2007 22:45:15 +0100

> > We could defer the increment until we check the checksum,
> > but that is likely to break even more things because people
> > (as Wang Chen did initially) will send a packet to some
> > port with an app that doesn't eat the packets, and expect the
> > InDatagrams counter to increase once the stack eats the packet.
> 
> Who expects that? Is there really any program who relies on that?
> 
> If it's just a human: there are a couple of "non intuitive" behaviours
> in the stack. This would be just another one. Not too big a deal.

I would consider this a legitimate thing to check in a test suite
such as TAHI or similar.

The networking stack DID receive the packet.  Just because a socket
owner is busy doing something else or blocked on some other event
is no excuse not to bump the InDataGgrams counter.

The behavior would suck.

> > But it won't until the application does the read.
> > 
> > All of our options suck, we just have to choose the least sucking one
> > and right now to me that's decrementing the counter as much as I
> > empathize with the SNMP application overflow detection issue.
> 
> If the SNMP monitor detects an false overflow the error it reports 
> will be much worse than a single missing packet. So you would replace 
> one error with a worse error.

This can be fixed, the above cannot.
