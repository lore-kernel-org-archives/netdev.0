From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [ANNOUNCE] e1000 to e1000e migration of PCI
	Express devices
Date: Tue, 8 Apr 2008 10:36:06 +0200
Message-ID: <20080408083606.GA20863@elte.hu>
References: <47F69965.7030303@intel.com>
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
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>, Greg KH <greg@kroah.com>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <47F69965.7030303@intel.com>
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


* Kok, Auke <auke-jan.h.kok@intel.com> wrote:

> From kernel 2.6.26 onward all *PCI Express* device IDs previously 
> supported by e1000 will be moving to the e1000e driver.  This includes 
> ich8 and ich9 onboard LAN, server 5000 platform onboard LAN (es2) and 
> 82571/2/3 chipset based adapters and variants.
> 
> If you have not already enabled CONFIG_E1000E make sure that you do 
> so. You can already do this with 2.6.25.  From 2.6.26 on this change 
> will be required if you have such a device.

i'm not sure it's a good idea to unsupport hardware in a driver. It's OK 
to phase out a driver and restrict it to legacy hardware, it's OK to 
have an opt-in .config option for distros to select (or maybe even 
opt-out) to narrow down the number of PCI IDs that a driver recognizes, 
but lets not artificially break setups that worked before.

( sidenote: isnt there some facility that selects the "better" driver in 
  case there is an overlap between PCI IDs - with the ability for users 
  to override that selection? )

such driver transitions are never smooth. For example there's an open 
e1000e/e1000 regression in .25 in this area that i just noticed on a 
testbox while doing randconfig testing. (that's why i noticed this 
message of yours on lkml, i was searching for e1000 regression reports).

The following .config results in a non-working e1000 driver in a 
bzImage:

 CONFIG_E1000=y
 CONFIG_E1000_NAPI=y
 CONFIG_E1000_DISABLE_PACKET_SPLIT=y
 CONFIG_E1000E=m
 CONFIG_E1000E_ENABLED=y

the interface just doesnt come up.

This makes it work:

 CONFIG_E1000=y
 CONFIG_E1000_NAPI=y
 CONFIG_E1000_DISABLE_PACKET_SPLIT=y
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set

please fix such interactions and make the transition as smooth and as 
compatible as possible.

the hardware is a stock T60 laptop with:

02:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller

ich7 onboard LAN. (can send more info if needed.)

I just tried the same .config on another box with onboard e1000 (a 
desktop system with a different e1000 version), which is ich9, and that 
broke too.

	Ingo

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Register now and save $200. Hurry, offer ends at 11:59 p.m., 
Monday, April 7! Use priority code J8TLD2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
