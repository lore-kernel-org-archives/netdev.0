From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 13:01:28 -0600
Message-ID: <20080411190128.GG11962@parisc-linux.org>
References: <20080410192714.GA14055@elte.hu> <47FE8566.5040809@intel.com> <20080411112653.GC9205@elte.hu> <20080411113644.GA7767@infradead.org> <20080411121606.GA25661@elte.hu> <47FF9060.5040202@intel.com> <20080411164542.GA4066@infradead.org> <alpine.LFD.1.00.0804111028540.3143@woody.linux-foundation.org> <20080411175304.GF11962@parisc-linux.org> <alpine.LFD.1.00.0804111146450.3143@woody.linux-foundation.org>
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
Received: from palinux.external.hp.com ([192.25.206.14]:52063 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758285AbYDKTBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 15:01:45 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.00.0804111146450.3143@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2008 at 11:51:07AM -0700, Linus Torvalds wrote:
> Because your version has exactly the same problem that the current code 
> has: it asks questions that aren't sensible to people who don't care. It 
> also keeps the old E1000 name for "PCI chips only", which means that 
> people who just use an old config and ignore new questions will suddenly 
> lose their ability to use the E1000 driver if they have a PCI-E card.

We only support people keeping their old configs after they run 'make
oldconfig', right?  At which point they'd be prompted for E1000_SUPPORT.
Presumably they'd think "That's odd.  I'm sure I had that selected
before", then select it.  Then oldconfig skips over CONFIG_E1000 because
it already knows the answer to that one and they're prompted with a
question about PCIe support.  Now something is clearly strange.  Perhaps
they look at the help text at this point and it says to go with 'Y' or
'M' if they're not sure.

That's the most important bit of help texts for me.  Do I want Control
Groups?  Will my machine break if I don't select them?  I have no idea
what a 'process cgroup subsystem' is, and I don't care.  But the help
text tells me I can say "n" and nothing will break.

> So most users:
>  - want to just say "E1000", and not care about type.
>  - want to have old configurations continue working (ie if you haev had 
>    "E1000" driving your hardware before, it should _continue_ to do so, 
>    with no need to select a _new_ E1000E question!
> 
> Nobody wants to care deeply whether it's a PCI-E or PCI chip. In fact, 
> it's almost impossible to tell. Here, quickly, tell me which one mine is 
> (this is from /sbin/lspci):
> 
> 	00:19.0 Ethernet controller: Intel Corporation 82566DM Gigabit Network Connection (rev 02)

I quite agree.  I have no idea either.  All I know is that my ICH9 box
didn't work until e1000e was released ;-)

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
