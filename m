From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: [RFC 2/2] shrink size of scatterlist on common i386/x86-64
Date: Mon, 9 Jul 2007 11:53:07 +0300
Message-ID: <20070709085307.GK3182@rhun.haifa.ibm.com>
References: <08FE5CC30C9A3F41BF819A502CF7BF6E0198249D@fmsmsx411.amr.corp.intel.com> <20070706.122019.55506705.davem@davemloft.net> <20070708161730.GA4146@rhun.haifa.ibm.com> <20070709.000640.122589877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mitch.a.williams@intel.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:50409 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbXGIIxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 04:53:11 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l698r9Mn542350
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 08:53:09 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l698r93j3084504
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 09:53:09 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l698r8am030404
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 09:53:08 +0100
Content-Disposition: inline
In-Reply-To: <20070709.000640.122589877.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 09, 2007 at 12:06:40AM -0700, David Miller wrote:

> > That works, but isn't optimal when you have an isolation-capable
> > IOMMU and you want the full isolation properties of the IOMMU. If
> > you only flush the IOTLB when the allocator wraps around, a stale
> > entry in the IOTLB can allow a DMA to go through for an IO entry
> > that has already been unmapped. One way to mitigate that and still
> > retain full isolation is to make sure no one else gets to use the
> > frames that are the targets of the DMA until the translation has
> > been flushed out of the IOTLB, but that requires pretty deep
> > surgery.
> 
> Virtualization sucks doesn't it? :-)

no comment :-) FWIW isolation capable IOMMUs are also useful to catch
DMA errors when drivers program devices to DMA where they
shouldn't. Sure, drivers can trash the kernel in other ways, but a
printk beats random memory corruption any day of the week.

> It's one of the worst aspects of all of this virtualization
> business.  In my view it makes no sense to split up the physical
> hardware.  Just give control nodes complete access to everything and
> instead of playing games partializing real hardware, just give
> virtual instances to everybody and be done with all of this
> complexity.

Virtual instances have a non-negligible performance cost and
development cost - you need a virtual driver for any device or class
of devices out there. Not to say that they aren't useful, just that
direct access (aka "passthrough") has its uses too.

> Anyways, hypervisors et al. have already decided to do this
> braindamage so you will need to find some way to make it go fast now
> won't you? :)

Working on it :-)

Cheers,
Muli
