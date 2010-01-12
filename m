From: Greg KH <gregkh@suse.de>
Subject: Re: Can we remove pci_find_device() yet?
Date: Tue, 12 Jan 2010 13:18:01 -0800
Message-ID: <20100112211801.GA27999@suse.de>
References: <20100108112236.462a3da2.sfr@canb.auug.org.au>
 <20100108044646.GC6611@suse.de>
 <4B4B802A.2010709@imap.cc>
 <20100111200136.GA29955@suse.de>
 <m3fx6bxdt7.fsf@intrepid.localdomain>
 <1263329605.3011.8.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Halasa <khc@pm.waw.pl>, Tilman Schmidt <tilman@imap.cc>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49661 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752259Ab0ALVUR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2010 16:20:17 -0500
Content-Disposition: inline
In-Reply-To: <1263329605.3011.8.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2010 at 08:53:25PM +0000, Ben Hutchings wrote:
> > How do I do that properly, in terms of PCI API?
> 
> One of our older controllers had a similar design error in that the two
> functions would sometimes have to be reset together.  The way we look
> for the second function is:
> 
> 	dev = pci_dev_get(dev1);
> 	while ((dev = pci_get_device(vendor_id, device_id, dev))) {
> 		if (dev->bus == dev1->bus &&
> 		    dev->devfn == dev1->devfn + 1) {
> 			dev2 = dev;
> 			break;
> 		}
> 	}
> 
> I assume this is 'properly' since no-one has told me otherwise.

As of right now, yes, this is the "correct" way to do this.

I need to dig up the "let multiple drivers bind to a single device"
patch set to make this not necessary in the future.

thanks,

greg k-h
