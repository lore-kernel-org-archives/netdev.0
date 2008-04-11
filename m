From: Willy Tarreau <w@1wt.eu>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 21:25:19 +0200
Message-ID: <20080411192519.GA8474@1wt.eu>
References: <47FE8566.5040809@intel.com> <20080411112653.GC9205@elte.hu>
	<20080411113644.GA7767@infradead.org>
	<20080411121606.GA25661@elte.hu> <47FF9060.5040202@intel.com>
	<20080411164542.GA4066@infradead.org>
	<alpine.LFD.1.00.0804111028540.3143@woody.linux-foundation.org>
	<20080411175304.GF11962@parisc-linux.org>
	<alpine.LFD.1.00.0804111146450.3143@woody.linux-foundation.org>
	<20080411190128.GG11962@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@infradead.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>, Greg KH <greg@kroah.com>,
	Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080411190128.GG11962@parisc-linux.org>
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

On Fri, Apr 11, 2008 at 01:01:28PM -0600, Matthew Wilcox wrote:
> On Fri, Apr 11, 2008 at 11:51:07AM -0700, Linus Torvalds wrote:
> > Because your version has exactly the same problem that the current code 
> > has: it asks questions that aren't sensible to people who don't care. It 
> > also keeps the old E1000 name for "PCI chips only", which means that 
> > people who just use an old config and ignore new questions will suddenly 
> > lose their ability to use the E1000 driver if they have a PCI-E card.
> 
> We only support people keeping their old configs after they run 'make
> oldconfig', right?  At which point they'd be prompted for E1000_SUPPORT.
> Presumably they'd think "That's odd.  I'm sure I had that selected
> before", then select it.  Then oldconfig skips over CONFIG_E1000 because
> it already knows the answer to that one and they're prompted with a
> question about PCIe support.  Now something is clearly strange.  Perhaps
> they look at the help text at this point and it says to go with 'Y' or
> 'M' if they're not sure.

I don't think this will happen like that. People will simply think as
usual "ah, they have added support for new hardware, but since everything
in my machine was supported, I don't need it".

I think that the correct solution to help people is not at build time,
but at run time. The e1000 driver should just *check* if there are PCI-IDs
that it used to manage and that it does not anymore, for unclaimed devices,
and report a warning message clearly indicating that these devices are not
handled anymore and that for this, the user must load e1000e. It will :

  a) help people know what to load if they need to update modprobe.conf
  b) just require a new "make menuconfig;make modules" after the poor guy
     has been caught.

It's not a problem to have to tweak the config and reboot several times,
provided that the user is guided. Almost none of us has ever blindly
upgraded without a few post-boot adjustments.

> That's the most important bit of help texts for me.  Do I want Control
> Groups?  Will my machine break if I don't select them?  I have no idea
> what a 'process cgroup subsystem' is, and I don't care.  But the help
> text tells me I can say "n" and nothing will break.

Here if people don't know, they will reply "no" too.

> > So most users:
> >  - want to just say "E1000", and not care about type.
> >  - want to have old configurations continue working (ie if you haev had 
> >    "E1000" driving your hardware before, it should _continue_ to do so, 
> >    with no need to select a _new_ E1000E question!
> > 
> > Nobody wants to care deeply whether it's a PCI-E or PCI chip. In fact, 
> > it's almost impossible to tell. Here, quickly, tell me which one mine is 
> > (this is from /sbin/lspci):
> > 
> > 	00:19.0 Ethernet controller: Intel Corporation 82566DM Gigabit Network Connection (rev 02)
> 
> I quite agree.  I have no idea either.  All I know is that my ICH9 box
> didn't work until e1000e was released ;-)

I'm pretty sure it's PCI-E, because Linus got caught first ;-) But of
course, that should not be an accepted guess method.

Willy


-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
