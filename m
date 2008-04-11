From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 11:53:05 -0600
Message-ID: <20080411175304.GF11962@parisc-linux.org>
References: <47FD2325.2030705@intel.com> <47FE5C89.5060209@intel.com> <20080410192714.GA14055@elte.hu> <47FE8566.5040809@intel.com> <20080411112653.GC9205@elte.hu> <20080411113644.GA7767@infradead.org> <20080411121606.GA25661@elte.hu> <47FF9060.5040202@intel.com> <20080411164542.GA4066@infradead.org> <alpine.LFD.1.00.0804111028540.3143@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jeff@garzik.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Greg KH <greg@kroah.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:41632 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758817AbYDKRxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 13:53:22 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.00.0804111028540.3143@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2008 at 10:34:01AM -0700, Linus Torvalds wrote:
> Here's a suggested patch. Not much tested, but it's fairly obvious.
> 
> It basically makes one top-level config option (E1000) to pick the driver 
> at all, and two sub-options (E1000_PCI and E1000_PCIE) that you can choose 
> between.

I think it's a little over-engineered ... why not simply:

config E1000_SUPPORT
	bool "Intel(R) PRO/1000 Gigabit Ethernet support"
	depends on PCI

config E1000
	depends on E1000_SUPPORT
	tristate "E1000 PCI support"
	help
	  Include support for Conventional PCI devices.  This includes
	  chips built into motherboards ... blah blah, if unsure say "Y"
	  or "M"

config E1000E
	depends on E1000_SUPPORT
	tristate "E1000 PCI Express support"
	help
	  Include support for PCI Express devices.  This includes chips
	  built into motherboards such as ICH9 ... blah blah, if unsure
	  say "Y" or "M".

and get rid of the PCIE() macros from the e1000 driver.  While it does
allow someone like Ingo to create a E1000=y and E1000E=m situation
(which won't bind to an ethernet card that E1000 used to), having the
E1000_SUPPORT symbol means that oldconfig will stop and ask you which
hopefully makes it obvious enough that things have changed here and you
need to pay attention.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
