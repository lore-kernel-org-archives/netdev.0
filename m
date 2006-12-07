From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: NAPI and shared interrupt control
Date: Thu, 7 Dec 2006 01:45:02 -0800
Message-ID: <20061207094502.GA19479@gate.ebshome.net>
References: <1165465300.5469.187.camel@localhost.localdomain> <1165465446.5469.189.camel@localhost.localdomain> <20061207.011627.43485384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.ebshome.net ([208.106.21.240]:47842 "EHLO gate.ebshome.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031911AbWLGJpC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 04:45:02 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061207.011627.43485384.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 07, 2006 at 01:16:27AM -0800, David Miller wrote:
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Thu, 07 Dec 2006 15:24:06 +1100
> 
> > 
> > > What Eugene does currently, which seems to me like it's actually the
> > > only proper solution, is to create a separate net_device structure for
> > > the DMA engine and thus have a single NAPI poll & weighting for all the
> > > EMACs sharing a given MAL (MAL is the name of that DMA engine). This
> > > means that Rx from any of the channels schedules the poll, and
> > > interrupts can be properly masked/unmasked globally based on the
> > > presence/absence of work on all the channels.
> > 
> > Actually, another solution would be to have one of the instances do the
> > NAPI poll for all of them instead of creating a separate net_device for
> > the DMA engine...
> 
> I think this idea would work the best.

I fail to see how this is not even more ugly and more complex than the 
solution we have right now. Instead of trivial "orthogonal" polling 
code you are suggesting adding additional complexity - handle 
dynamic selection of that "master" EMAC and also handling situation 
when this master device goes down and you have to switch to 
another one without disturbing polling for other active devices. Why 
all this? This hw is ugly enough as it is.

> Just link the other related devices into a list in the driver private
> struct.  Or a simple "work pending" bitmask for each of the EMACs,
> which tell the primary EMAC netdev which devices should be polled.
> 
> This architecture doesn't make things easy, that's for sure :-)
> 
> If things get too hairy, don't feel too bad about ideas like forgoing
> NAPI altogether and just using the interrupt mitigation features of
> the chip.  Does it have any?

No, it does not.

-- 
Eugene

