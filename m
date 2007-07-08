From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: [RFC 2/2] shrink size of scatterlist on common i386/x86-64
Date: Sun, 8 Jul 2007 19:11:54 +0300
Message-ID: <20070708161154.GZ4146@rhun.haifa.ibm.com>
References: <20070705.171535.105173068.davem@davemloft.net> <08FE5CC30C9A3F41BF819A502CF7BF6E0198249D@fmsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:10403 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262AbXGHQL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2007 12:11:58 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l68GBufQ424224
	for <netdev@vger.kernel.org>; Sun, 8 Jul 2007 16:11:56 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l68GBumE1708178
	for <netdev@vger.kernel.org>; Sun, 8 Jul 2007 17:11:56 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l68GBtmw025221
	for <netdev@vger.kernel.org>; Sun, 8 Jul 2007 17:11:56 +0100
Content-Disposition: inline
In-Reply-To: <08FE5CC30C9A3F41BF819A502CF7BF6E0198249D@fmsmsx411.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 06, 2007 at 10:14:56AM -0700, Williams, Mitch A wrote:
> David Miller wrote:
> >> Okay, but then using SG lists makes skbuff's much bigger.
> >>     
> >> 	fraglist	scatterlist		   per skbuff
> >> 32 bit	8		20		+12 * 18 = +216!
> >> 64 bit	16		32		+16 * 18 = +288
> >> 
> >> So never mind...
> >
> >I know, this is why nobody ever really tries to tackle this.
> >
> >> I'll do a fraglist to scatter list set of routines, but not sure
> >> if it's worth it.
> >
> >It's better to add dma_map_skb() et al. interfaces to be honest.
> >
> >Also even with the scatterlist idea, we'd still need to do two
> >map calls, one for skb->data and one for the page vector.
> 
> FWIW, I tried this about a year ago to try to improve e1000
> performance on pSeries.  I was hoping to simplify the driver
> transmit code and make IOMMU mapping easier.  This was on 2.6.16 or
> thereabouts.
> 
> Net result:  zilch.  No performance increase, no noticeable CPU
> utilization
> benefits.  Nothing.  So I dropped it.

Do you have pointers to the patches perchance?

> Slightly off topic:
> The real problem that I saw on pSeries is lock contention for the IOMMU.
> It's architected with a single table per slot, which is great in that
> two boards in separate slots won't have lock contention.  However, this
> all goes out the window when you drop a quad-port gigabit adapter in
> there.
> The time spent waiting for the IOMMU table lock goes up exponentially
> as you activate each additional port.
> 
> In my opinion, IOMMU table locking is the major issue with this type
> of architecture.  Since both Intel and AMD are touting IOMMUs for
> virtual- ization support, this is an issue that's going to need a
> lot of scrutiny.

Agreed.

Cheers,
Muli
