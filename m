From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 15:35:03 -0700 (PDT)
Message-ID: <20070829.153503.18295527.davem@davemloft.net>
References: <5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com>
	<20070829.144656.104048365.davem@davemloft.net>
	<46D5F32F.2070502@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.mcdonald@jandi.co.nz, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42311
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752361AbXH2WfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 18:35:04 -0400
In-Reply-To: <46D5F32F.2070502@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 29 Aug 2007 15:29:03 -0700

> David Miller wrote:
> > None of the research folks want to commit to saying a lower value is
> > OK, even though it's quite clear that on a local 10 gigabit link a
> > minimum value of even 200 is absolutely and positively absurd.
> > 
> > So what do these cellphone network people want to do, increate the
> > minimum RTO or increase it?  Exactly how does it help them?
> 
> They want to increase it.  The folks who triggered this want to make it 
> 3 seconds to avoid spurrious RTOs.  Their experience the "other 
> platform" they widh to replace suggests that 3 seconds is a good value 
> for their network.
> 
> > If the issue is wireless loss, algorithms like FRTO might help them,
> > because FRTO tries to make a distinction between capacity losses
> > (which should adjust cwnd) and radio losses (which are not capacity
> > based and therefore should not affect cwnd).
> 
> I was looking at that.  FRTO seems only to affect the cwnd calculations, 
> and not the RTO calculation, so it seems to "deal with" spurrious RTOs 
> rather than preclude them.  There is a strong desire here to not have 
> spurrious RTO's in the first place.  Each spurrious retransmission will 
> increase a user's charges.

All of this seems to suggest that the RTO calculation is wrong.

It seems that packets in this network can be delayed several orders of
magnitude longer than the usual round trip as measured by TCP.

What exactly causes such a huge delay?  What is the TCP measured RTO
in these circumstances where spurious RTOs happen and a 3 second
minimum RTO makes things better?
