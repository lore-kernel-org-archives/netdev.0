From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 2/2] shrink size of scatterlist on common i386/x86-64
Date: Mon, 09 Jul 2007 00:06:40 -0700 (PDT)
Message-ID: <20070709.000640.122589877.davem@davemloft.net>
References: <08FE5CC30C9A3F41BF819A502CF7BF6E0198249D@fmsmsx411.amr.corp.intel.com>
	<20070706.122019.55506705.davem@davemloft.net>
	<20070708161730.GA4146@rhun.haifa.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: muli@il.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49389
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751090AbXGIHGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 03:06:18 -0400
In-Reply-To: <20070708161730.GA4146@rhun.haifa.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Muli Ben-Yehuda <muli@il.ibm.com>
Date: Sun, 8 Jul 2007 19:17:30 +0300

> On Fri, Jul 06, 2007 at 12:20:19PM -0700, David Miller wrote:
> > From: "Williams, Mitch A" <mitch.a.williams@intel.com>
> > Date: Fri, 6 Jul 2007 10:14:56 -0700
> > 
> > > In my opinion, IOMMU table locking is the major issue with this
> > > type of architecture.  Since both Intel and AMD are touting IOMMUs
> > > for virtual- ization support, this is an issue that's going to
> > > need a lot of scrutiny.
> > 
> > For the allocation of IOMMU entries themselves you can play tricks
> > using atomic operations on 64-bit words of the allocator bitmap to
> > avoid locking that.
> 
> Hmm, any pointers?

I've never implemented it but it is certainly possible to do.

> That works, but isn't optimal when you have an isolation-capable IOMMU
> and you want the full isolation properties of the IOMMU. If you only
> flush the IOTLB when the allocator wraps around, a stale entry in the
> IOTLB can allow a DMA to go through for an IO entry that has already
> been unmapped. One way to mitigate that and still retain full
> isolation is to make sure no one else gets to use the frames that are
> the targets of the DMA until the translation has been flushed out of
> the IOTLB, but that requires pretty deep surgery.

Virtualization sucks doesn't it? :-)

It's one of the worst aspects of all of this virtualization business.
In my view it makes no sense to split up the physical hardware.  Just
give control nodes complete access to everything and instead of
playing games partializing real hardware, just give virtual instances
to everybody and be done with all of this complexity.

Anyways, hypervisors et al. have already decided to do this braindamage
so you will need to find some way to make it go fast now won't you? :)
