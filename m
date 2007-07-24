From: Brandon Philips <bphilips@suse.de>
Subject: Re: [PATCH 1/2][RFC] Update net core to use devres.
Date: Tue, 24 Jul 2007 16:26:21 -0700
Message-ID: <20070724232621.GB11350@ifup.org>
References: <11853167931415-git-send-email-bphilips@suse.de> <11853167964115-git-send-email-bphilips@suse.de> <20070724225134.GV21668@ftp.linux.org.uk> <20070724230922.GA27392@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41325 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760564AbXGXX0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 19:26:24 -0400
Content-Disposition: inline
In-Reply-To: <20070724230922.GA27392@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 00:09 Wed 25 Jul 2007, Al Viro wrote:
> On Tue, Jul 24, 2007 at 11:51:34PM +0100, Al Viro wrote:
> > On Tue, Jul 24, 2007 at 03:39:52PM -0700, bphilips@suse.de wrote:
> > > * netdev_pci_remove_one() can replace simple pci device remove
> > >   functions
> > > 
> > > * devm_alloc_netdev() is like alloc_netdev but allocates memory using devres.
> > >   alloc_netdev() can be removed once all drivers use devres.
> >  
> > Ewwww...  What the hell for?  To make sure that we have struct device
> > for everything, whether we need it or not?  Have you actually read
> > through drivers/net?  I mean, _really_ read through it, looking for
> > ugly cases...
> > 
> > I've done just that several times and I'm sorry, but I would classify
> > that project as hopeless.  It's way, _way_ more diverse than SATA...
> 
> Actually, it's even worse - net_device itself simply *cannot* be
> dealt with that way.  Its lifetime can indefinitely exceed that
> of underlying e.g. PCI device.

Could you point me to an example you have in mind?

I quickly searched through a handful of the PCI device drivers and
couldn't find an example where the .remove function didn't do something
to the tune of:

	unregister_netdev(dev);
	... various un-allocs and cleanup ...
	free_netdev(dev)
	...
	return;

Thank You,

	Brandon
