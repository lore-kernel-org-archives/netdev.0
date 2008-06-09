From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Mon, 9 Jun 2008 21:24:57 +0200
Message-ID: <20080609192457.GA28816@elte.hu>
References: <20080411112653.GC9205@elte.hu>
	<20080411113644.GA7767@infradead.org>
	<20080411121606.GA25661@elte.hu> <47FF9060.5040202@intel.com>
	<20080411164542.GA4066@infradead.org>
	<alpine.LFD.1.00.0804111028540.3143@woody.linux-foundation.org>
	<alpine.LNX.1.00.0804111700550.19665@iabervon.org>
	<alpine.LFD.1.00.0804111556200.3143@woody.linux-foundation.org>
	<47FFF7B5.3000609@garzik.org>
	<alpine.LFD.1.00.0804131410340.2982@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, Matthew Wilcox <matthew@wil.cx>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	Daniel Barkalow <barkalow@iabervon.org>,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@infradead.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak,  John" <john.ronciak@intel.com>, Greg KH <greg@kroah.com>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.00.0804131410340.2982@woody.linux-foundation.org>
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


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Fri, 11 Apr 2008, Jeff Garzik wrote:
> > Linus Torvalds wrote:
> > > .. but that said, I think your patch is certainly better than what we have
> > > now (or what Ingo was complaining about for the next merge window). I
> > > certainly could live with it. I would just suggest against ever then
> > > removing that "generic E1000" choice.
> > 
> > You mean never ever remove PCI-E support from e1000?
> 
> No. I mean never ever remove the *configure* level thinking that 
> "e1000 is e1000".
> 
> There is no sense in *ever* showing it as two drivers to users, 
> because users do not see them as separate chipsets. They look 
> identical, down to the part names.
> 
> If it's a single family, and users can't even easily tell whether they 
> have version 1 or version 2 (PCI vs PCI-E), you shouldn't even ask 
> them. You should literally ask them: "do you want e1000 support".
> 
> That's it.
> 
> Once you have asked them that, you can then decide "ok, if you 
> *really* know what version of the chip you have, you can decide to 
> only get limited driver support".
> 
> But that's a secondary thing from a user perspective.
> 
> See the patch I already sent out.

btw., in the last 2-3 months i've hit this bug about a dozen times, on 
various test-systems i have. And i just hit it a minute ago again, 
reminding me of this open issue, with such a config:

 CONFIG_E1000=y
 # CONFIG_E1000_NAPI is not set
 CONFIG_E1000_DISABLE_PACKET_SPLIT=y
 CONFIG_E1000E=y
 CONFIG_E1000E_ENABLED=y

Every time this bug hits i lose about 30 minutes of testing (sometimes 
hours of it, because my testing stalls) and once it took half an hour of 
head-scratching to notice that the bl**dy CONFIG_E1000E_ENABLED=y again 
was killing the e1000 driver i rely on having.

With up to 10 test-systems and a healthy mix of old and new distros it's 
just not realistic to reconfigure all those distros to use e1000e. 
(Also, i frequently have to bisect back into older kernels and have 
scripting to make this work most of the time - if i standardized on 
e1000e i'd lose the ability to do automated bisection.)

i have a patch that undoes this e1000 damage but sometimes i forget to 
apply it and then the bug can hit me. Whoever thinks that this isnt a 
problem in practice hasnt been doing a lot of systematic testing. It's 
quite a PITA and it's still not fixed upstream. (and it's not eligible 
for the v2.6.26 regression list anymore as it got introduced in v2.6.25)

	Ingo

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
