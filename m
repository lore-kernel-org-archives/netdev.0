From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [regression] e1000e broke e1000 (was: Re:
	[ANNOUNCE] e1000 to	e1000e migration of PCI Express devices)
Date: Tue, 8 Apr 2008 21:51:23 +0200
Message-ID: <20080408195123.GA28148@elte.hu>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>
	<47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu>
	<20080408193245.GG11962@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>, Greg KH <greg@kroah.com>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080408193245.GG11962@parisc-linux.org>
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


* Matthew Wilcox <matthew@wil.cx> wrote:

> On Tue, Apr 08, 2008 at 08:39:21PM +0200, Ingo Molnar wrote:
> > so the pure presence of the e1000e module breaks the e1000 driver. That 
> > is a regression and a bug that should be fixed.
> 
> I think you've found the wrong problem ... it looks deliberate to me 
> that enabling e1000e disables e1000 from claiming the PCI IDs (see the 
> PCIE() macro right before the e1000_pci_tbl in 
> drivers/net/e1000/e1000_main.c).
> 
> The question is why e1000e isn't claiming the device ...

because i have e1000 built-in and dont load the e1000e module at all. 
That worked before and doesnt work now.

the solution is rather straightforward: if E1000 is built-in then E1000E 
should be built-in as well or disabled (i.e. it should not be possible 
to build it as a module in that case) - because the PCI ID stealing 
trick now connects the two drivers unconditionally. [ If e1000 is a 
module then e1000e can be a module (or disabled) - this would be the 
most common configuration. ]

	Ingo

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Register now and save $200. Hurry, offer ends at 11:59 p.m., 
Monday, April 7! Use priority code J8TLD2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
