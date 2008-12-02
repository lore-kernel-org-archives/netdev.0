From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: [PATCH 07/13] dmaengine: introduce dma_request_channel and
 private channels
Date: Tue, 2 Dec 2008 18:27:26 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0812021820560.5663@axis700.grange>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
 <20081114213453.32354.53002.stgit@dwillia2-linux.ch.intel.com>
 <Pine.LNX.4.64.0812021642120.5663@axis700.grange>
 <e9c3a7c20812020916ud0b426cvd0764f23a97973ad@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	nicolas.ferre@atmel.com
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:58672 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756131AbYLBR1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 12:27:19 -0500
In-Reply-To: <e9c3a7c20812020916ud0b426cvd0764f23a97973ad@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Dec 2008, Dan Williams wrote:

> On Tue, Dec 2, 2008 at 8:52 AM, Guennadi Liakhovetski
> <g.liakhovetski@gmx.de> wrote:
> > Hi Dan,
> >
> > I think, there is a problem with your dma_request_channel() /
> > private_candidate() implementation: your current version only tries one
> > channel from a dma device list, which matched capabilities. If this
> > channel is not accepted by the client, you do not try other channels from
> > this device and just go to the next one...
> >
> 
> Which dma driver are you using?

This is the idmac dmaengine driver I submitted a few weeks ago, that I am 
porting to your modified dmaengine framework. Initial version:

http://marc.info/?l=linux-arm-kernel&m=122607472721145&w=2

BTW - it does look nicer and more simple now, so, in general, I like the 
change.

> The dmaengine code assumes that all
> channels on a device are equal.  It sounds like there are differences
> between peer-channels on the device in this case.  If the driver
> registers a device per channel that should give the flexibility you
> want.

Ooh... Do you really think registering 32 dma-devices is a better solution 
than allowing non-equal dma-channels? As I explained in the commit 
comment, this is a specialised Image Processing DMA Controller, and each 
its channel has a fixed role. So, each client has to get a specific 
channel.

> > Another problem I encountered with my framebuffer is the initialisation
> > order. You initialise dmaengine per subsys_initcall(), whereas the only
> > way to guarantee the order:
> >
> > dmaengine
> > dma-device driver
> > framebuffer
> 
> hmm... can the framebuffer be moved to late_initcall?

I assumed, that one wants to register the framebuffer as early as 
possible...

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
