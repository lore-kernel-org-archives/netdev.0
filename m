From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [regression] e1000e broke e1000
Date: Tue, 08 Apr 2008 13:31:28 -0700
Message-ID: <47FBD620.1080508@intel.com>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu> <20080408193245.GG11962@parisc-linux.org> <20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org> <20080408200652.GC28148@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
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
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21685 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156AbYDHUke (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 16:40:34 -0400
In-Reply-To: <20080408200652.GC28148@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> * Jeff Garzik <jeff@garzik.org> wrote:
> 
>> Then disable E1000E in your kernel config, and the PCIE() macro will 
>> do the right thing...
> 
> it is an obvious regression that could and should be solved in the 
> Kconfig space: do not allow E1000=y && E1000E=m.

this is really not the solution imho, having e1000 builtin and e1000e as a module
is a perfectly viable choice. They are two separate drivers that are completely
independent.

I also think that the word "regression" is way out of proportion. I did not
complain myself when IDE/ATA->SATA driver merges broke all my systems and I was
pleasantly provided with the 'cannot find root vfs' message. (that's what I get
for running my own distro).

> i repeat, it took me more than an hour to figure out why there's no 
> networking on my laptop. Guess how much it takes for a plain user to 
> figure out the same problem.

a plain user uses a distro which is aware of the issue and that will load e1000e
automatically, because it was tested by the distro.

that is just pushing the discussion to the wrong point. The decision has been made
a long time ago to split e1000 in two. now that we have two drivers, we have a
migration issue. you can't fix this migration issue by forcing a specific .config
endresult on the user.

I've seen suggestions that will alleviate the issue by adding a 'default E1000' to
the e1000e Kconfig section, and something like that makes sense to me and I still
would be happy to merge something like that.

I do not think that hiding the existence of e1000e for any user by always enabling
it will fix things at all however, and will just lead to a lot of other issues
later on.


Auke
