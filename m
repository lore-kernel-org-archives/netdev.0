From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [ANNOUNCE] e1000 to e1000e migration of PCI
	Express devices
Date: Fri, 04 Apr 2008 17:52:05 -0400
Message-ID: <47F6A305.7050809@garzik.org>
References: <47F69965.7030303@intel.com>
	<1207344669.26869.33.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	"Allan,  Bruce W" <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak,  John" <john.ronciak@intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>, Greg KH <greg@kroah.com>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1207344669.26869.33.camel@nimitz.home.sr71.net>
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

Dave Hansen wrote:
> On Fri, 2008-04-04 at 14:11 -0700, Kok, Auke wrote:
>> >From kernel 2.6.26 onward all *PCI Express* device IDs previously
>> supported by e1000 will be moving to the e1000e driver.  This includes
>> ich8 and ich9 onboard LAN, server 5000 platform onboard LAN (es2) and
>> 82571/2/3 chipset based adapters and variants.
>>
>> If you have not already enabled CONFIG_E1000E make sure that you do so.
>> You can already do this with 2.6.25.  From 2.6.26 on this change will be
>> required if you have such a device.
> 
> I've been bitten by one or two of these in the past.  Can we do
> something like this for a couple of releases?
> 
> Shouldn't this default the E1000E config option to the same thing that
> people have the E1000 set as?  It should catch the dumb people like me
> who's enter key gets held down during a 'make oldconfig'. :)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 3a0b20a..aa0fe14 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2005,6 +2005,7 @@ config E1000_DISABLE_PACKET_SPLIT
>  config E1000E
>         tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
>         depends on PCI
> +       default E1000
>         ---help---
>           This driver supports the PCI-Express Intel(R) PRO/1000 gigabit
>           ethernet family of adapters. For PCI or PCI-X e1000 adapters,

That's not pretty for embedded folks who don't want an extra driver to 
come along for the ride ;-)

It's also been suggested, as an alternative, to add 'select E1000E' to 
E1000's Kconfig entry.

Rather than doing that, I am hoping that education -- Auke's 
announcements -- plus "ripping the band-aid off quickly", will be the 
best approach.

Most kernel distributions will have enabled both Kconfig options anyway, 
so that leaves individual kernel hackers who missed the announcements as 
the only target audience for the patch quoted above.

And as a side note...  we really really try not to do this very often. 
Migrating users from one driver to another is not a seamless process in 
Linux -- but unfortuantely the alternative solution, the same PCI ID in 
multiple drivers, presents an even worse set of breakages and problems. 
  This e1000->e1000e move is an exception to the rule.

	Jeff




-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
