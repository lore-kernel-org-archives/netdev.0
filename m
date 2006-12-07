From: David Miller <davem@davemloft.net>
Subject: Re: NAPI and shared interrupt control
Date: Thu, 07 Dec 2006 01:16:27 -0800 (PST)
Message-ID: <20061207.011627.43485384.davem@davemloft.net>
References: <1165465300.5469.187.camel@localhost.localdomain>
	<1165465446.5469.189.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebs@ebshome.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59568
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031877AbWLGJQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 04:16:16 -0500
To: benh@kernel.crashing.org
In-Reply-To: <1165465446.5469.189.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 07 Dec 2006 15:24:06 +1100

> 
> > What Eugene does currently, which seems to me like it's actually the
> > only proper solution, is to create a separate net_device structure for
> > the DMA engine and thus have a single NAPI poll & weighting for all the
> > EMACs sharing a given MAL (MAL is the name of that DMA engine). This
> > means that Rx from any of the channels schedules the poll, and
> > interrupts can be properly masked/unmasked globally based on the
> > presence/absence of work on all the channels.
> 
> Actually, another solution would be to have one of the instances do the
> NAPI poll for all of them instead of creating a separate net_device for
> the DMA engine...

I think this idea would work the best.

Just link the other related devices into a list in the driver private
struct.  Or a simple "work pending" bitmask for each of the EMACs,
which tell the primary EMAC netdev which devices should be polled.

This architecture doesn't make things easy, that's for sure :-)

If things get too hairy, don't feel too bad about ideas like forgoing
NAPI altogether and just using the interrupt mitigation features of
the chip.  Does it have any?

