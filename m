From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [regression] e1000e broke e1000 (was: Re:
	[ANNOUNCE] e1000	toe1000e migration of PCI Express devices)
Date: Tue, 8 Apr 2008 22:17:23 +0200
Message-ID: <20080408201723.GD28148@elte.hu>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>
	<47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu>
	<36D9DB17C6DE9E40B059440DB8D95F5204E2A55C@orsmsx418.amr.corp.intel.com>
	<20080408195949.GB28148@elte.hu>
	<20080408200417.GI11962@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	"Brandeburg,  Jesse" <jesse.brandeburg@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>, Greg KH <greg@kroah.com>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080408200417.GI11962@parisc-linux.org>
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

> On Tue, Apr 08, 2008 at 09:59:49PM +0200, Ingo Molnar wrote:
> > Btw., a sidenote: this is another generally annoying property of Linux: 
> > there's no easy and user-visible enumeration of PCI IDs (devices) that 
> > we _could_ support but dont enable for some reason. It is a royal PITA 
> > to track down when some driver decides to (silently) ignore a piece of 
> > hardware.
> > 
> > Having a seemingly dead piece of hardware component is one of the most 
> > frustrating user experiences possible - the first instinctive reaction 
> > is "did my hw break???". The kernel should proactively know about all 
> > inactive pieces of hardware and should have a one-stop-shop for users 
> > where they can reassure themselves which devices are not active and why.
> 
> It's almost trivial to add new string attributes to sysfs.  We could 
> have a file, say, /sys/bus/pci/devices/0000:07:03.0/broken which lspci 
> could read to see if anything's left a message for us.
> 
> Is that the kind of thing you had in mind?

yep, that would be fantastic.

i guess more could be done as well - this was just the result of 10 
seconds of thinking - please try to think all such scenarios through 
with the mindset of the user who is faced with a non-working device. Our 
failure diagnostics are rather ad-hoc in general. Say an USB stick did 
not come up. Or some card isnt working. Or the mouse is dead. Plain 
everyday annoyances - we need good, unified, understandable interfaces 
for users to get reassurances and vectors of action from. Maybe even a 
WARN_ON() for kerneloops.org to pick up automatically. _Anything_ that 
is actionable by plain users. Because failures in hw functionality is 
one of the most serious failure an OS can impose on users (it's only 
slightly better than say data loss, and clearly worse to most users than 
say sporadic crashes), and it is the main area where we _lose_ users 
every day.

	Ingo

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Register now and save $200. Hurry, offer ends at 11:59 p.m., 
Monday, April 7! Use priority code J8TLD2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
