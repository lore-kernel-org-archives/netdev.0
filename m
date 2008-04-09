From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [regression] e1000e broke e1000
Date: Wed, 9 Apr 2008 21:12:56 +0200
Message-ID: <20080409191256.GB9276@elte.hu>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu> <20080408193245.GG11962@parisc-linux.org> <20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org> <20080408200652.GC28148@elte.hu> <47FBD620.1080508@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Matthew Wilcox <matthew@wil.cx>,
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
Received: from mx2.mail.elte.hu ([157.181.151.9]:47630 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752701AbYDITNe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 15:13:34 -0400
Content-Disposition: inline
In-Reply-To: <47FBD620.1080508@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Kok, Auke <auke-jan.h.kok@intel.com> wrote:

> > it is an obvious regression that could and should be solved in the 
> > Kconfig space: do not allow E1000=y && E1000E=m.
> 
> this is really not the solution imho, having e1000 builtin and e1000e 
> as a module is a perfectly viable choice. They are two separate 
> drivers that are completely independent.

you try to argue against a strong and established concept that Linux 
always had from day one on: DRIVER_X=y means the user prefers that 
driver so strongly that he has selected it built-in. Such drivers are 
special in every sense: they run first before any of the module init, 
they cannot be disabled, etc. etc.

The only case where that should be overriden as the primary driver for 
that piece of hardware if _another_ driver is built-in _too_.

... which is exactly the E1000=y && E1000E=m regression that bit me and 
the simple solution of forcing E1000E to follow the mode of the E1000 
driver solves it.

The most common distro setup is E1000=m and E1000E=m. The most common 
embedded setup is _one_ of the two drivers as =y. So i'm not sure why 
you are arguing about all this. Please just fix this bug, simple as 
that.

	Ingo
