From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] xmit_compl_seq: information to reclaim vmsplice
 buffers
Date: Sun, 19 Sep 2010 11:35:33 -0700 (PDT)
Message-ID: <20100919.113533.59698518.davem@davemloft.net>
References: <alpine.DEB.1.00.1009141318490.20088@pokey.mtv.corp.google.com>
	<20100915.213832.43031989.davem@davemloft.net>
	<AANLkTimoHcbpyp95a23GXxWO3gQTxB6SJuP0WSJf1DB-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sridharr@google.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44111
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755219Ab0ISSfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Sep 2010 14:35:14 -0400
In-Reply-To: <AANLkTimoHcbpyp95a23GXxWO3gQTxB6SJuP0WSJf1DB-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 16 Sep 2010 12:09:08 -0700

> We return the seq # as part of receive message since: 1) the socket is
> already being accessed in the recvmsg, so tacking on this data should be
> cheap 2) the recvmsg may often coincide with an acknowledgment that would
> allow buffers to be reclaimed (esp. in response of a client request) 3) this
> could also be achieved by another system call after recvmsg, but then we're
> adding the cost of the system call.
> 
> The recvmsg and sockopt return the sequence number of first unacknowleged
> data, as opposed to the number of bytes outstanding.  The sequence number is
> not a relative value for our purposes, but the other is.  Given just the
> number of bytes outstanding, we would also need the # bytes that have ever
> been written by application at that instant to compute the completed byte
> number for reclaiming buffers-- so we would need synchronization between
> read and write path in the application (lock needed).

Ok, I'm convinced, thanks for explaining.

Please address the other feedback you've received (if any) and formally
submit this for inclusion into net-next-2.6

Thanks.
