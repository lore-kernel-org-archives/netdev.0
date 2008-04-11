From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 16:00:24 -0700 (PDT)
Message-ID: <alpine.LFD.1.00.0804111556200.3143@woody.linux-foundation.org>
References: <47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu>
	<47FD2325.2030705@intel.com> <47FE5C89.5060209@intel.com>
	<20080410192714.GA14055@elte.hu> <47FE8566.5040809@intel.com>
	<20080411112653.GC9205@elte.hu>
	<20080411113644.GA7767@infradead.org>
	<20080411121606.GA25661@elte.hu> <47FF9060.5040202@intel.com>
	<20080411164542.GA4066@infradead.org>
	<alpine.LFD.1.00.0804111028540.3143@woody.linux-foundation.org>
	<alpine.LNX.1.00.0804111700550.19665@iabervon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, Matthew Wilcox <matthew@wil.cx>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@infradead.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak,  John" <john.ronciak@intel.com>, Greg KH <greg@kroah.com>,
	Ingo Molnar <mingo@elte.hu>,
	Arjan van de Ven <arjan@linux.intel.com>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>
To: Daniel Barkalow <barkalow@iabervon.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.LNX.1.00.0804111700550.19665@iabervon.org>
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



On Fri, 11 Apr 2008, Daniel Barkalow wrote:
> 
> Wouldn't it make more sense to turn E1000 into a option that does nothing 
> except select both E1000E and E1000_PCI, and have those two be the options 
> that build drivers?

Yes, that sounds fine too. Although you need to add a

	depends on PCI

to the E1000 thing (because the "select" would not honor the dependencies 
that E1000E and E1000_PCI have).

However:

> Then, after a while, we drop the E1000 option entirely

I agree we could, but as I tried to explain, I fundamentally don't think 
we _should_.

Why should people _ever_ be asked about whether they want "E1000 PCI 
support" vs "E1000 PCI-E" support, when it's almost impossible to tell 
which kind of card you have?

In other words, I suspect that anybody who selects E1000 support would 
actually want the "support both" case, and simply not care. Unless they 
were _really_ deeply aware of their hardware.

> AFAICT, this makes "make oldconfig" always give the same support that the 
> the earlier kernel had and people get set it to what they actually want if 
> they notice.

.. but that said, I think your patch is certainly better than what we have 
now (or what Ingo was complaining about for the next merge window). I 
certainly could live with it. I would just suggest against ever then 
removing that "generic E1000" choice.

		Linus

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
