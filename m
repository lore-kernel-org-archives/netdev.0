From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 19:43:49 -0400
Message-ID: <47FFF7B5.3000609@garzik.org>
References: <47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu>
	<47FD2325.2030705@intel.com> <47FE5C89.5060209@intel.com>
	<20080410192714.GA14055@elte.hu> <47FE8566.5040809@intel.com>
	<20080411112653.GC9205@elte.hu>
	<20080411113644.GA7767@infradead.org>
	<20080411121606.GA25661@elte.hu> <47FF9060.5040202@intel.com>
	<20080411164542.GA4066@infradead.org>
	<alpine.LFD.1.00.0804111028540.3143@woody.linux-foundation.org>
	<alpine.LNX.1.00.0804111700550.19665@iabervon.org>
	<alpine.LFD.1.00.0804111556200.3143@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <matthew@wil.cx>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	Daniel Barkalow <barkalow@iabervon.org>,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@infradead.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak,  John" <john.ronciak@intel.com>, Greg KH <greg@kroah.com>,
	Ingo Molnar <mingo@elte.hu>,
	Arjan van de Ven <arjan@linux.intel.com>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.LFD.1.00.0804111556200.3143@woody.linux-foundation.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> .. but that said, I think your patch is certainly better than what we have 
> now (or what Ingo was complaining about for the next merge window). I 
> certainly could live with it. I would just suggest against ever then 
> removing that "generic E1000" choice.


You mean never ever remove PCI-E support from e1000?

Won't that will inflict long term headaches on the people that matter 
most -- users and maintainers -- to avoid short term headaches for 
kernel power users?

To review the overall situation,

* e1000 supports so many chips, that making a change for new hardware in 
e1000 involves breaking stability of older chips

* //You know this// from past kernel history, when late-breaking e1000 
changes for new hardware wound up breaking working setups on multiple 
occasions

* There is 100% agreement that e1000 is a maintenance nightmare, from 
the people who actually touch the code (or even read it).

* Therefore, e1000e receives new h/w support and new devel, leaving 
e1000 to sit and be stable


However, due to a mistake now released to the public -- a tiny few PCI-E 
chips are supported by e1000 -- you have a widely disparate feature set:

	e1000, old chips:		full support

	e1000, a few PCI-E chips:	basic support

	e1000e, all PCI-E chips:	full support

Since e1000e is all new and fancy AND CLEAN, the code for the same chips 
is different -- thus Intel must make every PCI-E fix _twice_.

It also means WE HAVE TO KEEP TOUCHING E1000, while supporting PCI-E 
chips.  After this PCI-E issue is resolved, I want to let e1000 sit and 
be stable and not be touched.

For a temporary situation, this is fine.  Give me transition 
suggestions, please!

For a permanent situation, that sucks.

Distros will ship e1000 sans PCI-E support, which means you are asking 
that PCI-E support be maintained indefinitely, purely for the few kernel 
hackers that still use it?

I __don't care__ how we get there, but a permanent situation where e1000 
continues to support a few PCI-E chips in basic mode seems the least 
desireable of all available options.

Wait six months?  Sure.  Whatever.  As long as we get to where we can 
disable PCI-E support in e1000.

	Jeff





-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
