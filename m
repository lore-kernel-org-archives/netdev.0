From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH 1/2][RFC] Update net core to use devres.
Date: Wed, 25 Jul 2007 00:09:22 +0100
Message-ID: <20070724230922.GA27392@ftp.linux.org.uk>
References: <11853167931415-git-send-email-bphilips@suse.de> <11853167964115-git-send-email-bphilips@suse.de> <20070724225134.GV21668@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: bphilips@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59894 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753921AbXGXXJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 19:09:23 -0400
Content-Disposition: inline
In-Reply-To: <20070724225134.GV21668@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24, 2007 at 11:51:34PM +0100, Al Viro wrote:
> On Tue, Jul 24, 2007 at 03:39:52PM -0700, bphilips@suse.de wrote:
> > * netdev_pci_remove_one() can replace simple pci device remove
> >   functions
> > 
> > * devm_alloc_netdev() is like alloc_netdev but allocates memory using devres.
> >   alloc_netdev() can be removed once all drivers use devres.
>  
> Ewwww...  What the hell for?  To make sure that we have struct device
> for everything, whether we need it or not?  Have you actually read
> through drivers/net?  I mean, _really_ read through it, looking for
> ugly cases...
> 
> I've done just that several times and I'm sorry, but I would classify
> that project as hopeless.  It's way, _way_ more diverse than SATA...

Actually, it's even worse - net_device itself simply *cannot* be
dealt with that way.  Its lifetime can indefinitely exceed that
of underlying e.g. PCI device.
