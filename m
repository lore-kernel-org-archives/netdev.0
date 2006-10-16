From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 1/2] [PCI] Check that MWI bit really did get set
Date: Mon, 16 Oct 2006 10:44:30 +1000
Message-ID: <17714.54766.390707.532248@cargo.ozlabs.ibm.com>
References: <1160161519800-git-send-email-matthew@wil.cx>
	<20061015191631.DE49D19FEC8@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
	<20061015123432.4c6b7f15.akpm@osdl.org>
	<200610151545.59477.david-b@pacbell.net>
	<20061015161834.f96a0761.akpm@osdl.org>
	<1160956960.5732.99.camel@localhost.localdomain>
	<20061015164402.f9b8b4d2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Brownell <david-b@pacbell.net>, matthew@wil.cx,
	val_henson@linux.intel.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org,
	gregkh@suse.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030308AbWJPApO@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061015164402.f9b8b4d2.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton writes:

> Let me restore the words from my earlier email which you removed so that
> you could say that:
> 
>   For you the driver author to make assumptions about what's happening
>   inside pci_set_mwi() is a layering violation.  Maybe the bridge got
>   hot-unplugged.  Maybe the attempt to set MWI caused some synchronous PCI
>   error.  For example, take a look at the various implementations of
>   pci_ops.read() around the place - various of them can fail for various
>   reasons.  

Maybe aliens are firing a ray-gun at the card.  I think it's
fundamentally wrong for the driver to deny service completely because
of a maybe.

Either there was a transient error that only affected the attempt to
set MWI, in which case a printk (inside pci_set_mwi!) is appropriate,
and we carry on.  Or there is a persistent error condition, in which
case the driver will see something else fail soon enough - something
that the driver actually needs to have working in order to operate -
and fail at that point.

For the driver to stop and refuse to go any further because of an
error in pci_set_mwi has far more disadvantages than advantages.

Paul.
