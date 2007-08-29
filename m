From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Thu, 30 Aug 2007 00:53:00 +0200
Message-ID: <20070829225300.GA15652@edgar.underground.se.axis.com>
References: <5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com> <20070829.144656.104048365.davem@davemloft.net> <46D5F32F.2070502@hp.com> <20070829.153503.18295527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rick.jones2@hp.com, ian.mcdonald@jandi.co.nz,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:57096 "EHLO
	miranda.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754881AbXH2XFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 19:05:13 -0400
Received: from axis.com (edgar.se.axis.com [10.92.151.1])
	by miranda.se.axis.com (8.13.4/8.13.4/Debian-3sarge3) with ESMTP id l7TMr1Du031166
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2007 00:53:01 +0200
Content-Disposition: inline
In-Reply-To: <20070829.153503.18295527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 29, 2007 at 03:35:03PM -0700, David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Wed, 29 Aug 2007 15:29:03 -0700
> 
> > David Miller wrote:
> > > None of the research folks want to commit to saying a lower value is
> > > OK, even though it's quite clear that on a local 10 gigabit link a
> > > minimum value of even 200 is absolutely and positively absurd.
> > > 
> > > So what do these cellphone network people want to do, increate the
> > > minimum RTO or increase it?  Exactly how does it help them?
> > 
> > They want to increase it.  The folks who triggered this want to make it 
> > 3 seconds to avoid spurrious RTOs.  Their experience the "other 
> > platform" they widh to replace suggests that 3 seconds is a good value 
> > for their network.
> > 
> > > If the issue is wireless loss, algorithms like FRTO might help them,
> > > because FRTO tries to make a distinction between capacity losses
> > > (which should adjust cwnd) and radio losses (which are not capacity
> > > based and therefore should not affect cwnd).
> > 
> > I was looking at that.  FRTO seems only to affect the cwnd calculations, 
> > and not the RTO calculation, so it seems to "deal with" spurrious RTOs 
> > rather than preclude them.  There is a strong desire here to not have 
> > spurrious RTO's in the first place.  Each spurrious retransmission will 
> > increase a user's charges.
> 
> All of this seems to suggest that the RTO calculation is wrong.
> 
> It seems that packets in this network can be delayed several orders of
> magnitude longer than the usual round trip as measured by TCP.
> 
> What exactly causes such a huge delay?  What is the TCP measured RTO
> in these circumstances where spurious RTOs happen and a 3 second
> minimum RTO makes things better?

I don't know what they are doing, but it reminds me of what happens when
you run TCP over a reliable medium. You don't see loss, instead the
RTT starts to jitter alot. 

IIRC FRTO does help avoid unnecessary retransmits (although the RTO still
hits).

Best regards
-- 
        Programmer
        Edgar E. Iglesias <edgar.iglesias@axis.com> 46.46.272.1946
