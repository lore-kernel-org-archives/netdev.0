From: Don Fry <pcnet32@verizon.net>
Subject: Re: [PATCH] pcnet32: only allocate init_block dma consistent
Date: Tue, 6 Mar 2007 10:30:05 -0800
Message-ID: <20070306183005.GA21731@verizon.net>
References: <20070306021037.GA7139@verizon.net> <45ED4CCA.7030606@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [71.117.224.81] ([71.117.224.81]:4876 "EHLO linux.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965987AbXCFS3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 13:29:38 -0500
Content-Disposition: inline
In-Reply-To: <45ED4CCA.7030606@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The change to use netdev_priv can only be done After moving the init
block out of the private structure.  It will break the driver if done
first, which is why they were sent together.

I will separate the changes and resend them.

On Tue, Mar 06, 2007 at 06:13:14AM -0500, Jeff Garzik wrote:
> Don Fry wrote:
> >The patch below moves the init_block out of the private struct and
> >only allocates init block with pci_alloc_consistent.
> >
> >This has two effects:
> >
> >1. Performance increase for non cache coherent machines, because the
> >   CPU only data in the private struct are now cached
> >
> >2. locks are working now for platforms, which need to have locks
> >   in cached memory
> >
> >Also use netdev_priv() instead of dev->priv
> >
> >Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
> 
> please separate the netdev_priv() change into a separate, precursor 
> patch, and resend both
> 
> 
