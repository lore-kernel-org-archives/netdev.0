From: David Miller <davem@davemloft.net>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Wed, 27 Aug 2008 14:34:01 -0700 (PDT)
Message-ID: <20080827.143401.76242975.davem@davemloft.net>
References: <48B46B48.7030609@cosmosbay.com>
	<20080826205158.GA15266@2ka.mipt.ru>
	<87vdxmr53f.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, dada1@cosmosbay.com, denys@visp.net.lb,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59473
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752396AbYH0VeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 17:34:06 -0400
In-Reply-To: <87vdxmr53f.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 27 Aug 2008 14:54:12 +0200

> Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:
> >
> > Yup, this innocent toys can end up with this such behaviour on modern
> > highly loaded machines.
> 
> I and also other people had some patches to move the time stamp
> measuring into the socket. This way the time stamping didn't need to
> be enabled on all packets, only on those that actually end up at a
> socket that requires the time stamp.

By the time you get to the socket, it might be eons (relatively
speaking) later, decreasing the usefulness of the timestamp.

As just an odd example if the TCP socket is user locked at the moment,
because the user is blocked on a GFP_KERNEL allocation, it could be
a very long time before we actually process the packet and timestamp
it.

UDP now does similar socket locking so could potentially hit the same
kind of problem.

That was my argument against such a change.

I find it amusing that nobody it talking about fixing the tools
that are creating the timestamp requests when they have no real
reason for having them in the first place.
