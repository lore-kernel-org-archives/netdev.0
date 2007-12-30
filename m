From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [RFC/PATCH] e100 driver didn't support any
	MII-less PHYs...
Date: Sat, 29 Dec 2007 21:54:45 -0800
Message-ID: <477732A5.5020501@intel.com>
References: <20071228235118.GA31059@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com, bunk@kernel.org,
	linux-kernel@vger.kernel.org
To: andi@lisas.de
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20071228235118.GA31059@rhlx01.hs-esslingen.de>
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

Andreas Mohr wrote:
> Hi all,
> 
> I was mildly annoyed when rebooting my _headless_ internet gateway after a
> hotplug -> udev migration and witnessing it not coming up again,
> which turned out to be due to an eepro100 / e100 loading conflict
> since eepro100 supported both of my Intel-based network cards,
> whereas e100 only supported the "newer" one and entirely failed on ifup...
> (udev had somehow managed to tweak loading sequence as compared to
> a hotplug setup, which caused the drivers to probe differently)
> 
> After investigating this e100 failure for half an hour it was obvious
> that it was failing in e100_hw_init() -> e100_phy_init() since the driver was
> prepared to handle MII-capable PHYs only, not certain older(?) MII-less
> PHYs such as 80c24 or i82503.
> Investigating some FreeBSD etc. drivers it became terribly clear that there
> are also some MII-less PHYs and that one would have to handle them properly.
> 
> Thus I decided to add support for those:
> - after PHY init failure, try to detect whether the EEPROM lists one of
>   the MII-less PHYs
> - if so, don't fatally fail PHY init function
> - avoid touching MII in various utility functions in case of MII-less
>   PHY (FIXME: this may need review, it was a quick hack in some places)
> - add some proper logging on init failure
> 
> Note that this is an initial, semi-rough patch only, would love to have
> it corrected/improved by the e1000 team.
> (I also added some spelling updates for good measure, these would have
> to be committed separately obviously)
> 
> Frankly I'm quite uncertain as to why one would try to actively deprecate
> a driver which works for many cards with a newer one which fails to work
> for several card types and doesn't seem clearly superiour in hindsight
> after going through it...
> Oh, right, that's in order to brute-force people to report any
> nagging problems with the new driver, which is... errm... very
> understandable after all ;)
> (I hope that me "reporting" this problem via a patch is ok ;)
> 
> For reference, I'm using a BNC/AUI/TP PCI combo card
> Intel 82557 645477-004 FCC ID EJMNPDEPR10PCTPCI
> 
> This mail written using a reassuringly stable connection over the newly
> adapted driver...


ok, barely glanced over the patch but it might just be fine. Can you split up this
patch and send a separate patch for the spelling mistakes? I'll then have some
quick testing done on the result and do a bit deeper review after newyears.

Cheers,

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
