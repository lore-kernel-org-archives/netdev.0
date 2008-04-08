From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [regression] e1000e broke e1000
Date: Tue, 08 Apr 2008 15:56:48 -0400
Message-ID: <47FBCE00.2020309@garzik.org>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu> <20080408193245.GG11962@parisc-linux.org> <20080408195123.GA28148@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <matthew@wil.cx>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
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
Received: from srv5.dvmed.net ([207.36.208.214]:36874 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751853AbYDHT5H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 15:57:07 -0400
In-Reply-To: <20080408195123.GA28148@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> * Matthew Wilcox <matthew@wil.cx> wrote:
> 
>> On Tue, Apr 08, 2008 at 08:39:21PM +0200, Ingo Molnar wrote:
>>> so the pure presence of the e1000e module breaks the e1000 driver. That 
>>> is a regression and a bug that should be fixed.
>> I think you've found the wrong problem ... it looks deliberate to me 
>> that enabling e1000e disables e1000 from claiming the PCI IDs (see the 
>> PCIE() macro right before the e1000_pci_tbl in 
>> drivers/net/e1000/e1000_main.c).
>>
>> The question is why e1000e isn't claiming the device ...
> 
> because i have e1000 built-in and dont load the e1000e module at all. 
> That worked before and doesnt work now.
> 
> the solution is rather straightforward: if E1000 is built-in then E1000E 
> should be built-in as well or disabled (i.e. it should not be possible 
> to build it as a module in that case) - because the PCI ID stealing 
> trick now connects the two drivers unconditionally. [ If e1000 is a 
> module then e1000e can be a module (or disabled) - this would be the 
> most common configuration. ]


Then disable E1000E in your kernel config, and the PCIE() macro will do 
the right thing...

Have you reviewed the discussion that led to PCIE()?

	Jeff



