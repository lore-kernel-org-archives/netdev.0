From: Philip Craig <philipc@snapgear.com>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 10:46:00 +1000
Message-ID: <47FEB4C8.3020303@snapgear.com>
References: <20080408193245.GG11962@parisc-linux.org> <20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org> <20080408200652.GC28148@elte.hu> <47FBD34A.6080508@garzik.org> <20080408203314.GA28952@elte.hu> <47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu> <47FD2325.2030705@intel.com> <47FE5C89.5060209@intel.com> <20080410192714.GA14055@elte.hu> <47FE8566.5040809@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jeff@garzik.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Greg KH <greg@kroah.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:50945 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750949AbYDKAqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 20:46:11 -0400
In-Reply-To: <47FE8566.5040809@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kok, Auke wrote:
> Again - If there is a way to auto-enable e1000e in the right way so that more
> systems migrate better then I'm all for it (even if forcing E1000E=y). But it
> seems that the various patches proposed don't cut it and frankly Kconfig is
> completely inadequate as a hardware enabling script since it knows absolutely
> nothing about the hardware in the first place. And it wasn't meant for that
> either. `make oldconfig` is not the answer ;).

One problem is that the meaning of E1000 has been changed.  It covers less
hardware than it used to.

You could add a new option to control the e1000 driver, and make E1000 set
both this new option and E1000E.  Thus it will always cover at least all
the IDs that the original e1000 driver handled.

config E1000
	tristate "Both Intel(R) PRO/1000 Gigabit Ethernet support"
	depends on PCI

config E1000_ONLY
	tristate "Intel(R) PRO/1000 Gigabit Ethernet support" if E1000=n
	default E1000
	depends on PCI

config E1000E
	tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support" if E1000=n
	default E1000
	depends on PCI

The E1000E prompt restriction is required to upgrade existing E1000=y,
E1000E=m configs to E1000E=y.

But it will also upgrade E1000=y/m,E1000E=n to E1000E=y/m, which may not
always be right.

This still doesn't solve any problems with loading modules for E1000=m.
Loading the e1000 module will still load support for less than it used to.
(Because make oldconfig is not the answer ;-)
