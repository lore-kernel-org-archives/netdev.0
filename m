From: "Edgar E. Iglesias" <edgar.iglesias@gmail.com>
Subject: Re: [PATCH] [V2] Add non-Virtex5 support for LL TEMAC driver
Date: Thu, 18 Mar 2010 01:46:35 +0100
Message-ID: <20100318004635.GB3201@laped.iglesias.mooo.com>
References: <bda26c8d-00b2-411d-b4b7-ad6954b9049e@SG2EHSMHS005.ehs.local>
 <4B9DF254.2030402@petalogix.com>
 <2d2cb4b6-627a-4e42-bc59-7845bbb6b680@SG2EHSMHS004.ehs.local>
 <4B9E46B5.1060508@petalogix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Linn <John.Linn@xilinx.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, grant.likely@secretlab.ca,
	jwboyer@linux.vnet.ibm.com, john.williams@petalogix.com,
	John Tyner <jtyner@cs.ucr.edu>
To: Michal Simek <michal.simek@petalogix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:26416 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242Ab0CRAqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 20:46:40 -0400
Received: by ey-out-2122.google.com with SMTP id d26so165083eyd.19
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 17:46:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4B9E46B5.1060508@petalogix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 15, 2010 at 03:39:49PM +0100, Michal Simek wrote:
> John Linn wrote:
> >> -----Original Message-----
> >> From: Michal Simek [mailto:michal.simek@petalogix.com]
> >> Sent: Monday, March 15, 2010 2:40 AM
> >> To: John Linn
> >> Cc: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org;
> > grant.likely@secretlab.ca;
> >> jwboyer@linux.vnet.ibm.com; john.williams@petalogix.com; John Tyner
> >> Subject: Re: [PATCH] [V2] Add non-Virtex5 support for LL TEMAC driver
> >>
> >> John Linn wrote:
> >>> This patch adds support for using the LL TEMAC Ethernet driver on
> >>> non-Virtex 5 platforms by adding support for accessing the Soft DMA
> >>> registers as if they were memory mapped instead of solely through
> > the
> >>> DCR's (available on the Virtex 5).
> >>>
> >>> The patch also updates the driver so that it runs on the MicroBlaze.
> >>> The changes were tested on the PowerPC 440, PowerPC 405, and the
> >>> MicroBlaze platforms.
> >> Which git-tree have you tested on? (Of course microblaze)
> > 
> > It was tested on the Xilinx tree for MicroBlaze which is based on the
> > mainline and the Petalogix tree as DMA was needed. I tried to build
> > against the mainline head but got errors with the DMA routines. I guess
> > it's possible that it was a configuration issue there as I didn't dig
> > real deep.
> 
> New dma api is in for-linus branch.
> I tested it on that version and I am seeing some weird things. :-(
> Access to bad area. I will try your tree.
> 
> The second thing which I see is in ll_temac_recv function.
> On the following line is read a packet length which could be 0-16k.
> 		length = cur_p->app4 & 0x3FFF;
> 
> But allocated skb has max size XTE_MAX_JUMBO_FRAME_SIZE + XTE_ALIGN.
> 
> What happen if driver get packet greater than 9kB?
> I got it (I don't know how) but skb_put has one checking mechanism which 
> will cal skb_over_panic which caused panic.
> That's why I think that will be good always to check that length is less 
> than XTE_MAX_JUMBO_FRAME_SIZE + XTE_ALIGN.
> 
> What do you think?

I agree. IIRC the LLTEMAC when configured to accept jumboframes will
accepts packets up to 16K and the driver should handle that without
raising panics.

I remeber beeing a bit surprised about that when hacking the QEMU model.
Not sure if I remember correctly though.

Cheers
