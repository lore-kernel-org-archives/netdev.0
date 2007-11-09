From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [RFC] dependencies for platform drivers (was Re: ax88796: add
	superh to kconfig dependencies)
Date: Fri, 9 Nov 2007 09:26:52 +0000
Message-ID: <20071109092652.GA13350@linux-mips.org>
References: <20071108073105.3996.70418.sendpatchset@clockwork.opensource.se> <20071108081854.GN8181@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
	lethal@linux-sh.org, ben-linux@fluff.org,
	akpm@linux-foundation.org, jeff@garzik.org,
	linux-arch@vger.kernel.org
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:38659 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbXKIJ1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 04:27:42 -0500
Content-Disposition: inline
In-Reply-To: <20071108081854.GN8181@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 08, 2007 at 08:18:54AM +0000, Al Viro wrote:

> On Thu, Nov 08, 2007 at 04:31:05PM +0900, Magnus Damm wrote:
> >  config AX88796
> >  	tristate "ASIX AX88796 NE2000 clone support"
> > -	depends on ARM || MIPS
> > +	depends on ARM || MIPS || SUPERH
> 
> You know, that really sucks more and more.  How about doing the following:
> 	a) making it depend on PLAT_HAS_AX88796
> 	b) adding selects for all subarchitectures that have the corresponding
> platform device
> and setting that as a uniform policy for platform drivers?  For things like
> SM501 we would do
> config MFD_SM501
> 	depends on PCI || PLAT_HAS_SM501
> etc.
> 
> Seriously, folks, we are getting shitloads of platform drivers with no
> dependencies whatsoever, needed on a handful of targets and occasionally
> failing to build on unrelated architectures.  Moreover, having a list
> of architectures in dependencies for each of those suckers is a PITA
> from the conflict POV.  Not to mention platform drivers that fall into
> the mainline kernel with not a single platform device for them, etc.
> 
> Comments?

commit def47c5095d53814512bb0c62ec02dfdec769db1
Author: Jeff Garzik <jeff@garzik.org>
Date:   Tue Jul 10 14:06:48 2007 -0400

    [netdrvr] Fix dependencies for ax88796 ne2k clone driver
    
    It needs writesb(), not available on all platforms.
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index a3bef22..a64c2fb 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -199,6 +199,7 @@ source "drivers/net/arm/Kconfig"
 
 config AX88796
        tristate "ASIX AX88796 NE2000 clone support"
+       depends on ARM || MIPS
        select CRC32
        select MII
        help


If writesb() is not an official API then maybe the answer should have been
to either add that API to other architectures or fix the driver.

I guess this incident means I need to go through all Kconfig* files to
see what bogus architecture dependencies on MIPS or !MIPS exist ...

  Ralf
