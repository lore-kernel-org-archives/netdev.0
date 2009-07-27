From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-2.6 PATCH] ixgbe: fix for 82599 errata marking UDP checksum
 errors
Date: Sun, 26 Jul 2009 23:11:40 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0907262306090.9296@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090724040031.30202.1531.stgit@localhost.localdomain>
 <20090726.202154.00452824.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:19124 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750908AbZG0GLk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 02:11:40 -0400
In-Reply-To: <20090726.202154.00452824.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 26 Jul 2009, David Miller wrote:

> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu, 23 Jul 2009 21:00:39 -0700
> 
> > From: Don Skidmore <donald.c.skidmore@intel.com>
> > 
> > There is an 82599 errata that UDP frames with a zero checksum are
> > incorrectly marked as checksum invalid by the hardware.  This was
> > leading to misleading hw_csum_rx_error counts. This patch adds a
> > test around this counter increase for this condition.
> > 
> > Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Applied, thanks.
> 
> But I wonder.   When you compute a checksum, and it's zero,
> you have to use the complement as the checksum value.  How
> does that relate to the problem being tackled here?

The problem is our hardware has an errata.  If the packet data contains no 
checksum, or no checksum computed, our hardware doesn't recognize it.  So 
when it tries to compute the checksum on Rx, it doesn't just figure out 
that it needs to use the one's complement.  So it's not recognizing the 
fact the checksum is either not computed, or computes to zero.

The only place we've seen this show up is receiving from pktgen, where no 
checksum is computed.  It is a really stupid HW errata, and is just an 
annoyance really (our bad checksum counter soars when doing pktgen stress 
testing).

Cheers,
-PJ Waskiewicz
