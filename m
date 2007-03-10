From: Michael Buesch <mb@bu3sch.de>
Subject: Re: SSB/b44 build failure
Date: Sat, 10 Mar 2007 18:33:48 +0100
Message-ID: <200703101833.48961.mb@bu3sch.de>
References: <1173496449.13449@shark.he.net> <20070310150346.GB5062@tuxdriver.com> <20070310153816.GP3441@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:60199
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbXCJRf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2007 12:35:28 -0500
In-Reply-To: <20070310153816.GP3441@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 10 March 2007 16:38, Adrian Bunk wrote:
> On Sat, Mar 10, 2007 at 10:03:46AM -0500, John W. Linville wrote:
> > On Fri, Mar 09, 2007 at 07:14:09PM -0800, Randy Dunlap wrote:
> > > Hi,
> > > 
> > > In 2.6.21-rc3-mm2, with CONFIG_SSB=y but all other SSB kconfig
> > > symbols disabled, I get this (on x86_64):
> > > 
> > > drivers/built-in.o: In function `b44_init':
> > > b44.c:(.init.text+0x6e04): undefined reference to `ssb_pcihost_register'
> > > b44.c:(.init.text+0x6e2c): undefined reference to `ssb_pcihost_unregister'
> > > drivers/built-in.o: In function `b44_cleanup':
> > > b44.c:(.exit.text+0x63b): undefined reference to `ssb_pcihost_unregister'
> > > make: *** [.tmp_vmlinux1] Error 1
> > 
> > FWIW, this is coming from the port of b44 to use the SSB bus which
> > I'm carrying in the wireless-dev tree.
> > 
> > SSB (i.e. "Sonics Silicon Backplane") is a bus used in Broadcom SoCs
> > including the b44 and bcm43xx hardware.  The SSB bus driver and the
> > b44 port to SSB is being developed by Michael Buesch, the maintainer of
> > the bcm43xx driver.  I've been carrying the b44 SSB port in my tree for
> > Michael's convenience.  Just an FYI for those wondering what SSB is...
> > 
> > John
> > 
> > P.S.  How about this patch?
> > 
> > From: John W. Linville <linville@tuxdriver.com>
> > 
> > [PATCH] b44: make B44_PCI select SSB_PCIHOST in drivers/net/Kconfig
> > 
> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
> > ---
> >  drivers/net/Kconfig |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> > index 6a4325b..b2e1deb 100644
> > --- a/drivers/net/Kconfig
> > +++ b/drivers/net/Kconfig
> > @@ -1402,6 +1402,7 @@ config B44
> >  config B44_PCI
> >  	bool "Broadcom 4400 PCI device support"
> >  	depends on B44 && NET_PCI
> > +	select SSB_PCIHOST
> >  	default y
> >  	help
> >  	  Support for b44 PCI devices.
> 
> 
> This also requires a depends or select on SSB.

Sorry for this stupid bug. I'm to blame. :)
The SSB config is already selected by B44. B44_PCI is for
adding the PCI support routines.

The following patch is the right one to fix the issue
completely.

Signed-off-by: Michael Buesch <mb@bu3sch.de>


Index: wireless-dev/drivers/net/Kconfig
===================================================================
--- wireless-dev.orig/drivers/net/Kconfig	2007-03-10 18:31:25.000000000 +0100
+++ wireless-dev/drivers/net/Kconfig	2007-03-10 18:32:35.000000000 +0100
@@ -1402,6 +1402,8 @@ config B44
 config B44_PCI
 	bool "Broadcom 4400 PCI device support"
 	depends on B44 && NET_PCI
+	select SSB_PCIHOST
+	select SSB_DRIVER_PCICORE
 	default y
 	help
 	  Support for b44 PCI devices.


-- 
Greetings Michael.
