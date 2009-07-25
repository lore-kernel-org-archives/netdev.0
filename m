From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH 06/13] igb: move all multicast addresses
 into multicast table array
Date: Fri, 24 Jul 2009 18:41:29 -0700
Message-ID: <1248486089.3462.1.camel@localhost.localdomain>
References: <20090724040700.30709.31473.stgit@localhost.localdomain>
	 <20090724040853.30709.97954.stgit@localhost.localdomain>
	 <Pine.LNX.4.64.0907241053200.24126@tyr.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44093 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752247AbZGYBmE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jul 2009 21:42:04 -0400
In-Reply-To: <Pine.LNX.4.64.0907241053200.24126@tyr.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-07-24 at 01:57 -0700, Jesper Dangaard Brouer wrote:
> On Thu, 23 Jul 2009, Jeff Kirsher wrote:
> 
> > From: Alexander Duyck <alexander.h.duyck@intel.com>
> >
> > This patch moves all of the multicast addresses out of the free Receive
> > address registers and instead programs them all into the multicast table
> > array.  As a result the multicast filtering may not be as precise, but it
> > also greatly reduces the overhead for multicast addresses.
> 
> What do you mean by "the multicast filtering may not be as precise" ?
> 
> I'm planning to use these NICs for multicast traffic (both routing and 
> monitoring).  Is there any precausing I need to be aware of?
> 

The receive address registers, or RARs, are perfect match filters.  The
multicast table array, or MTA, contains hashed values of the multicast
addresses.  Therefore, it isn't a perfect match for the multicast
addresses anymore.  But to support a larger number of multicast
addresses, they can't be written to the RARs, since those resources are
small and are needed for MAC and unicast address filtering.

Cheers,
-PJ Waskiewicz

