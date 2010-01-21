From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH] sky2: Fix WARNING: at lib/dma-debug.c:902 check_sync
Date: Fri, 22 Jan 2010 00:22:10 +0900
Message-ID: <20100122002053X.fujita.tomonori@lab.ntt.co.jp>
References: <20100120094103.GA6225@ff.dom.local>
	<20100120222414.57909d14@lxorguk.ukuu.org.uk>
	<20100120225322.GC3072@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, davem@davemloft.net,
	shemminger@linux-foundation.org, mbreuer@majjas.com,
	akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mchan@broadcom.com, pcnet32@verizon.net, romieu@fr.zoreil.com,
	mcarlson@broadcom.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:50575 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750922Ab0AUPXU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2010 10:23:20 -0500
In-Reply-To: <20100120225322.GC3072@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jan 2010 23:53:22 +0100
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On Wed, Jan 20, 2010 at 10:24:14PM +0000, Alan Cox wrote:
> > > > Seems like an underlying bug in the DMA api. Maybe it just can't
> > > > handle operations on partial mapping.
> > > > 
> > > > Other drivers with same problem:
> > > >   bnx2, cassini, pcnet32, r8169, rrunner, skge, sungem, tg3, 
> > > 
> > > It seems using the same length (even without pci_unmap_len()) is
> > > crucial here, but I hope maintainers (added to CC) will take care.
> > 
> > The API needs fixing - if you've got a large mapping and you want to sync
> > part of it then we need to support that. Now it might well be that the
> > implementation on some braindead platform has to sync the entire thing,
> > and some implementations entire pages or cache lines.
> > 
> > You can't fix this in the drivers, they requested a service and they
> > don't have enough information nor is it their job to know about all the
> > platform specific rules.
> 
> Yes, the need to repeat some other values if there is a dedicated
> structure/pointer could be misleading. Btw, it seems to be a trivial
> overlooking since there is dma_sync_single_range() ready to use.

Yeah, dma_sync_single_range() enables you to do a partial sync. But
you must be really careful with a partial sync (as DMA-API.txt says).
