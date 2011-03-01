From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] tlan: Remove changelog
Date: Tue,  1 Mar 2011 08:56:32 -0800
Message-ID: <901ce76108a5ab7327159b57a1b8c9283673532b.1298998514.git.joe@perches.com>
Cc: Sakari Ailus <sakari.ailus@iki.fi>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As it isn't necessary nor really useful any longer.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tlan.c |  145 ----------------------------------------------------
 1 files changed, 0 insertions(+), 145 deletions(-)

diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index e48a808..7721e6c 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -25,151 +25,6 @@
  *		Microchip Technology, 24C01A/02A/04A Data Sheet
  *			available in PDF format from www.microchip.com
  *
- * Change History
- *
- *	Tigran Aivazian <tigran@sco.com>:	TLan_PciProbe() now uses
- *						new PCI BIOS interface.
- *	Alan Cox	<alan@lxorguk.ukuu.org.uk>:
- *						Fixed the out of memory
- *						handling.
- *
- *	Torben Mathiasen <torben.mathiasen@compaq.com> New Maintainer!
- *
- *	v1.1 Dec 20, 1999    - Removed linux version checking
- *			       Patch from Tigran Aivazian.
- *			     - v1.1 includes Alan's SMP updates.
- *			     - We still have problems on SMP though,
- *			       but I'm looking into that.
- *
- *	v1.2 Jan 02, 2000    - Hopefully fixed the SMP deadlock.
- *			     - Removed dependency of HZ being 100.
- *			     - We now allow higher priority timers to
- *			       overwrite timers like TLAN_TIMER_ACTIVITY
- *			       Patch from John Cagle <john.cagle@compaq.com>.
- *			     - Fixed a few compiler warnings.
- *
- *	v1.3 Feb 04, 2000    - Fixed the remaining HZ issues.
- *			     - Removed call to pci_present().
- *			     - Removed SA_INTERRUPT flag from irq handler.
- *			     - Added __init and __initdata to reduce resisdent
- *			       code size.
- *			     - Driver now uses module_init/module_exit.
- *			     - Rewrote init_module and tlan_probe to
- *			       share a lot more code. We now use tlan_probe
- *			       with builtin and module driver.
- *			     - Driver ported to new net API.
- *			     - tlan.txt has been reworked to reflect current
- *			       driver (almost)
- *			     - Other minor stuff
- *
- *	v1.4 Feb 10, 2000    - Updated with more changes required after Dave's
- *			       network cleanup in 2.3.43pre7 (Tigran & myself)
- *			     - Minor stuff.
- *
- *	v1.5 March 22, 2000  - Fixed another timer bug that would hang the
- *			       driver if no cable/link were present.
- *			     - Cosmetic changes.
- *			     - TODO: Port completely to new PCI/DMA API
- *				     Auto-Neg fallback.
- *
- *	v1.6 April 04, 2000  - Fixed driver support for kernel-parameters.
- *			       Haven't tested it though, as the kernel support
- *			       is currently broken (2.3.99p4p3).
- *			     - Updated tlan.txt accordingly.
- *			     - Adjusted minimum/maximum frame length.
- *			     - There is now a TLAN website up at
- *			       http://hp.sourceforge.net/
- *
- *	v1.7 April 07, 2000  - Started to implement custom ioctls. Driver now
- *			       reports PHY information when used with Donald
- *			       Beckers userspace MII diagnostics utility.
- *
- *	v1.8 April 23, 2000  - Fixed support for forced speed/duplex settings.
- *			     - Added link information to Auto-Neg and forced
- *			       modes. When NIC operates with auto-neg the driver
- *			       will report Link speed & duplex modes as well as
- *			       link partner abilities. When forced link is used,
- *			       the driver will report status of the established
- *			       link.
- *			       Please read tlan.txt for additional information.
- *			     - Removed call to check_region(), and used
- *			       return value of request_region() instead.
- *
- *	v1.8a May 28, 2000   - Minor updates.
- *
- *	v1.9 July 25, 2000   - Fixed a few remaining Full-Duplex issues.
- *			     - Updated with timer fixes from Andrew Morton.
- *			     - Fixed module race in TLan_Open.
- *			     - Added routine to monitor PHY status.
- *			     - Added activity led support for Proliant devices.
- *
- *	v1.10 Aug 30, 2000   - Added support for EISA based tlan controllers
- *			       like the Compaq NetFlex3/E.
- *			     - Rewrote tlan_probe to better handle multiple
- *			       bus probes. Probing and device setup is now
- *			       done through TLan_Probe and TLan_init_one. Actual
- *			       hardware probe is done with kernel API and
- *			       TLan_EisaProbe.
- *			     - Adjusted debug information for probing.
- *			     - Fixed bug that would cause general debug
- *			       information to be printed after driver removal.
- *			     - Added transmit timeout handling.
- *			     - Fixed OOM return values in tlan_probe.
- *			     - Fixed possible mem leak in tlan_exit
- *			       (now tlan_remove_one).
- *			     - Fixed timer bug in TLan_phyMonitor.
- *			     - This driver version is alpha quality, please
- *			       send me any bug issues you may encounter.
- *
- *	v1.11 Aug 31, 2000   - Do not try to register irq 0 if no irq line was
- *			       set for EISA cards.
- *			     - Added support for NetFlex3/E with nibble-rate
- *			       10Base-T PHY. This is untestet as I haven't got
- *			       one of these cards.
- *			     - Fixed timer being added twice.
- *			     - Disabled PhyMonitoring by default as this is
- *			       work in progress. Define MONITOR to enable it.
- *			     - Now we don't display link info with PHYs that
- *			       doesn't support it (level1).
- *			     - Incresed tx_timeout beacuse of auto-neg.
- *			     - Adjusted timers for forced speeds.
- *
- *	v1.12 Oct 12, 2000   - Minor fixes (memleak, init, etc.)
- *
- *	v1.13 Nov 28, 2000   - Stop flooding console with auto-neg issues
- *			       when link can't be established.
- *			     - Added the bbuf option as a kernel parameter.
- *			     - Fixed ioaddr probe bug.
- *			     - Fixed stupid deadlock with MII interrupts.
- *			     - Added support for speed/duplex selection with
- *			       multiple nics.
- *			     - Added partly fix for TX Channel lockup with
- *			       TLAN v1.0 silicon. This needs to be investigated
- *			       further.
- *
- *	v1.14 Dec 16, 2000   - Added support for servicing multiple frames per.
- *			       interrupt. Thanks goes to
- *			       Adam Keys <adam@ti.com>
- *			       Denis Beaudoin <dbeaudoin@ti.com>
- *			       for providing the patch.
- *			     - Fixed auto-neg output when using multiple
- *			       adapters.
- *			     - Converted to use new taskq interface.
- *
- *	v1.14a Jan 6, 2001   - Minor adjustments (spinlocks, etc.)
- *
- *	Samuel Chessman <chessman@tux.org> New Maintainer!
- *
- *	v1.15 Apr 4, 2002    - Correct operation when aui=1 to be
- *			       10T half duplex no loopback
- *			       Thanks to Gunnar Eikman
- *
- *	Sakari Ailus <sakari.ailus@iki.fi>:
- *
- *	v1.15a Dec 15 2008   - Remove bbuf support, it doesn't work anyway.
- *	v1.16  Jan 6  2011   - Make checkpatch.pl happy.
- *	v1.17  Jan 6  2011   - Add suspend/resume support.
- *
  ******************************************************************************/
 
 #include <linux/module.h>
-- 
1.7.4.2.g597a6.dirty
