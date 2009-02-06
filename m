From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Fix UDP short packet false positive
Date: Fri, 06 Feb 2009 01:08:24 -0800 (PST)
Message-ID: <20090206.010824.99072382.davem@davemloft.net>
References: <1233838027.20497.132.camel@localhost.localdomain>
	<20090205.150612.208352009.davem@davemloft.net>
	<1233910824.21135.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55513
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751690AbZBFJI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 04:08:28 -0500
In-Reply-To: <1233910824.21135.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Fri, 06 Feb 2009 10:00:24 +0100

> On Thu, 2009-02-05 at 15:06 -0800, David Miller wrote:
> > From: Jesper Dangaard Brouer <jdb@comx.dk>
> > Date: Thu, 05 Feb 2009 13:47:07 +0100
> >
> > > The UDP header pointer assignment must happen after calling
> > > pskb_may_pull().  As pskb_may_pull() can potentially alter the SKB
> > > buffer.
> >
> > Excellent work!
> 
> Thanks :-)
> 
> I'm wondering if the ip_hdr() pointer can be changed by the
> pskb_may_pull(), but I assume it cannot as it should already be in the
> linear area... right?
> 
> Well the patch below, shows what I mean...

It has the same potential problem, but in this case you'd
only see corruption if the old skb->data buffer were reallocated
by another user and written into very quickly (or poison'd by
SLAB debugging).

Please respin this patch of your's with proper commit message
and signoffs, thanks!

BTW, ipv6 udp gets all of this right :-)
