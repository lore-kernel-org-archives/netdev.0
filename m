From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/2] [PCI] Check that MWI bit really did get set
Date: Mon, 16 Oct 2006 12:02:56 +0100
Message-ID: <1160996576.24237.21.camel@localhost.localdomain>
References: <1160161519800-git-send-email-matthew@wil.cx>
	 <20061015191631.DE49D19FEC8@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
	 <20061015123432.4c6b7f15.akpm@osdl.org>
	 <200610151545.59477.david-b@pacbell.net>
	 <20061015161834.f96a0761.akpm@osdl.org>
	 <1160956960.5732.99.camel@localhost.localdomain>
	 <20061015164402.f9b8b4d2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Brownell <david-b@pacbell.net>, matthew@wil.cx,
	val_henson@linux.intel.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org,
	gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:51075 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1751092AbWJPKgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 06:36:17 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061015164402.f9b8b4d2.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Sul, 2006-10-15 am 16:44 -0700, ysgrifennodd Andrew Morton:
> Let me restore the words from my earlier email which you removed so that
> you could say that:
> 
>   For you the driver author to make assumptions about what's happening
>   inside pci_set_mwi() is a layering violation.  Maybe the bridge got
>   hot-unplugged.  Maybe the attempt to set MWI caused some synchronous PCI
>   error.  For example, take a look at the various implementations of
>   pci_ops.read() around the place - various of them can fail for various
>   reasons.  

Let me repeat what I said before. As a driver author I do not care. It
doesn't matter if it failed because it is not supported or because a
pink elephant went for a dance on the PCI bus.

>   Now it could be that an appropriate solution is to make pci_set_mwi()
>   return only 0 or 1, and to generate a warning from within pci_set_mwi()
>   if some unexpected error happens.  In which case it is legitimate for
>   callers to not check for errors.

That would be my belief, and ditto for a lot of these other functions -
even the correctly __must_check ones like pci_set_master should do the
error reporting in the set_master() function etc not in every driver.
That gives us a single consistent printk and avoids missing them out or
bloat.

Alan

