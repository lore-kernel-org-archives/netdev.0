From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [regression] e1000e broke e1000 (was: Re:
	[ANNOUNCE] e1000 toe1000e migration of PCI Express devices)
Date: Tue, 8 Apr 2008 12:43:00 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5204E2A55C@orsmsx418.amr.corp.intel.com>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>
	<47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>, Greg KH <greg@kroah.com>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Ingo Molnar" <mingo@elte.hu>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <20080408183921.GA20803@elte.hu>
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

Auke is out sick, so I'm responding...

Ingo Molnar wrote:
> this is a simple bzImage kernel, no modules at all. Here's the full
> regression report:

then why are you compiling e1000e as a module?  no "=y" in your kernel
means no support, and this kernel .config has e1000e supporting your
hardware.

your expectation is that e1000 once loaded on this device in a previous
kernel (2.6.24) so it should continue to work, right?  I see your point
but we are trying to make general improvements to both drivers, and the
best way forward was a split, in order to make the user experience
better by eliminating chances for regressions on older hardware.  
 
> v2.6.25-rc8 regresses relative to v2.6.24, with the following config,
> which config works fine in v2.6.24:

> the eth0 interface is not detected at all:
>    http://redhat.com/~mingo/misc/dmesg.e1000.bad

if you're running a no module kernel, you'll need to set CONFIG_E1000E=y
for your device to be detected.  

> so the pure presence of the e1000e module breaks the e1000 driver.
> That 
> is a regression and a bug that should be fixed.

The device IDs moved to e1000e, we don't want collisions between drivers
that support the same IDs, so to avoid those user support issues, we're
trying to make the process as painless as possible with announcements
and time.  The distros are already including the e1000e driver in their
builds and new installs with the new ID layout will automatically select
the correct driver for their hardware.

Users that take an upgrade to their kernel (with e1000e enabled) might
benefit if the distro upgrading that kernel included a post upgrade
script that migrated e1000e devices previously using e1000 in
modprobe.conf to alias ethX e1000e

If there is a more reasonable solution you can come up with I am
interested.

Jesse

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Register now and save $200. Hurry, offer ends at 11:59 p.m., 
Monday, April 7! Use priority code J8TLD2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
