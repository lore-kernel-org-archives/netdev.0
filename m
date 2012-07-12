From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Apple Thunderbolt Ethernet device support
Date: Thu, 12 Jul 2012 16:23:42 -0700
Message-ID: <20120712232342.GB26823@kroah.com>
References: <20120712202131.GA26436@kroah.com>
 <20120712205706.GB27999@kroah.com>
 <4FFF59A9.4010009@hp.com>
 <20120712231834.GA26823@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59271 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162037Ab2GLXXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 19:23:46 -0400
Received: by pbbrp8 with SMTP id rp8so4457099pbb.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 16:23:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120712231834.GA26823@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 12, 2012 at 04:18:34PM -0700, Greg KH wrote:
> On Thu, Jul 12, 2012 at 04:11:37PM -0700, Rick Jones wrote:
> > On 07/12/2012 01:57 PM, Greg KH wrote:
> > >On Thu, Jul 12, 2012 at 01:21:31PM -0700, Greg KH wrote:
> > >>I have an Apple Thunderbolt Ethernet device here, and running 3.5-rc6 it
> > >>isn't detected.  It has PCI id 14e4:1682, which seems like it should be
> > >>supported by the tg3 driver.  Any hints?
> > >>
> > >>I guess I could just go and add the device id to the driver and see what
> > >>happens...
> > >And that worked, patch sent.
> > >
> > >But, as the patch shows, odds are it has a "real" device type in it,
> > >so the #define I used isn't as descriptive as it should be.  Any hints
> > >on how I can figure out what to look at to make it more "correct"?
> > 
> > a long-shot, but maybe there is something in the pci.ids database?
> 
> Ah, nice, there is something there:
> 	1682 NetXtreme BCM57762 Gigabit Ethernet PCIe
> 
> I'll redo the patch with that information, thanks.

Wait, something's a bit "odd" here.  We already have:
	#define  TG3PCI_DEVICE_TIGON3_57762 0x1682
in drivers/net/ethernet/broadcom/tg3.h

But it's only used in the function where we can't figure out what type
of vpd we have in tg3_read_vpd().  One could ask how that codepath
was ever tested, as that device id was not in the MODULE_DEVICE_TABLE();

I wonder if someone reused the device id?

Anyway, I'll respin the patch...

greg k-h
