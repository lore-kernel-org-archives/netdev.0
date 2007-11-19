From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Mon, 19 Nov 2007 14:23:13 -0800 (PST)
Message-ID: <20071119.142313.63549156.davem@davemloft.net>
References: <20071118214515.GA8161@one.firstfloor.org>
	<20071118.144010.236028466.davem@davemloft.net>
	<20071119152933.GA19126@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38435
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752030AbXKSWXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 17:23:13 -0500
In-Reply-To: <20071119152933.GA19126@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 19 Nov 2007 16:29:33 +0100

> > > > 
> > > > All of our options suck, we just have to choose the least sucking one
> > > > and right now to me that's decrementing the counter as much as I
> > > > empathize with the SNMP application overflow detection issue.
> > > 
> > > If the SNMP monitor detects an false overflow the error it reports 
> > > will be much worse than a single missing packet. So you would replace 
> > > one error with a worse error.
> > 
> > This can be fixed, the above cannot.
> 
> I don't see how, short of breaking the interface
> (e.g. reporting 64bit or separate overflow counts)

As someone who just spent an entire weekend working on
cpu performance counter code, I know it's possible.

When you overflow, the new value is "a lot" less than
the last sampled one.  When the value backtracks like
we're discussing it could here, it only decrease
a very little bit.
