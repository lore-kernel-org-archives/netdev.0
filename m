From: Roland Dreier <roland@topspin.com>
Subject: Re: [PATCH][6/12][RFC/v1] Add IPoIB (IP-over-InfiniBand) driver
Date: Mon, 22 Nov 2004 07:14:34 -0800
Message-ID: <52sm71ex0l.fsf@topspin.com>
References: <200411181046.6Dz1IPtDKfpgSXN9@topspin.com>
	<200411181046.Jj0jsF5E2KmiGN8f@topspin.com>
	<20041118200017.GA26976@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

OK, the "real" patches are coming now.  I just thought I would let you
know which of your comments I've acted on and which are still pending....

    Christoph> Please avoid -I statements for kernel code wherever
    Christoph> possible.  Just put the Infiniband Kernel Internal API
    Christoph> into $(TOPDIR)/include/infiniband/

This is no problem to do.  However, I'd like to see whether we can get
a consensus about where to put .h files.

    Christoph> This should read more like:

OK, Makefile is fixed.  I didn't realize foo-objs and foo-y worked the
same, thanks for teaching me.

    Christoph> Also ib_ipoib is a rather strange name, the double ib
    Christoph> doesn't make much sense.

True.  We use ib_xxx for all our module names, so ib_ipoib is
consistent, but changing to ipoib for the IPoIB driver is easy to do
if that's the right way to go.

    Christoph> Please don't refer to licenses at urls as they can
    Christoph> changed easily.  There's a toplevel COPYING file you
    Christoph> can reference, and if you want additional license bits
    Christoph> I'd suggets to keep them simple enough to be in the
    Christoph> file header.  Or better just stop the dual-licensing
    Christoph> sillyness - you'll copy code from other parts of the
    Christoph> kernel sooner or later that are GPL-only.

License is not fixed yet (needs to be cleared with all contributors).

    Christoph> Please make this and inline so you have proper
    Christoph> typechecking.  (And give it a less shouting name)

Done.

    Christoph> Please try to avoid global lists.  Looking at the code
    Christoph> this is used in two places:

    Christoph>  (1) the debugging pseudo fs (2) ipoib_remove_one

    Christoph> the latter would be much better served with a per
    Christoph> ib_device list anyway, and for (1) there must be a
    Christoph> better way than the global list either.

OK, I got rid of the global list, although the debug fs keeps a list
of devices added before the fs was mounted (static to the file with
debugging code).  I could get rid of that list by just creating the fs
superblock etc. at startup rather than waiting for a mount request,
but I didn't do that yet.  (I don't want to call kern_mount because
then the module use count gets bumped and the module can't be
unloaded)

    Christoph> Please don't use PCI dma calls in highlevel protocol
    Christoph> handlers.  At least use the dma_* calls or even better
    Christoph> restructure the code to avoid dma mapping outside the
    Christoph> HCA driver.

We can switch to dma_* (and in fact I see some reasons to do so).
However Greg KH suggested sticking with pci_* stuff until there's a
non-PCI device to deal with.

I'm pretty convinced that the DMA mapping needs to be exposed outside
the low-level driver.  Otherwise you're limiting what upper level code
can do with reusing DMA mappings, DMA pools, etc.

Thanks,
  Roland
