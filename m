From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: SSB/b44 build failure
Date: Sat, 10 Mar 2007 10:03:46 -0500
Message-ID: <20070310150346.GB5062@tuxdriver.com>
References: <1173496449.13449@shark.he.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mb@bu3sch.de, bunk@stusta.de, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4148 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767844AbXCJPfa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2007 10:35:30 -0500
Content-Disposition: inline
In-Reply-To: <1173496449.13449@shark.he.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 09, 2007 at 07:14:09PM -0800, Randy Dunlap wrote:
> Hi,
> 
> In 2.6.21-rc3-mm2, with CONFIG_SSB=y but all other SSB kconfig
> symbols disabled, I get this (on x86_64):
> 
> drivers/built-in.o: In function `b44_init':
> b44.c:(.init.text+0x6e04): undefined reference to `ssb_pcihost_register'
> b44.c:(.init.text+0x6e2c): undefined reference to `ssb_pcihost_unregister'
> drivers/built-in.o: In function `b44_cleanup':
> b44.c:(.exit.text+0x63b): undefined reference to `ssb_pcihost_unregister'
> make: *** [.tmp_vmlinux1] Error 1

FWIW, this is coming from the port of b44 to use the SSB bus which
I'm carrying in the wireless-dev tree.

SSB (i.e. "Sonics Silicon Backplane") is a bus used in Broadcom SoCs
including the b44 and bcm43xx hardware.  The SSB bus driver and the
b44 port to SSB is being developed by Michael Buesch, the maintainer of
the bcm43xx driver.  I've been carrying the b44 SSB port in my tree for
Michael's convenience.  Just an FYI for those wondering what SSB is...

John

P.S.  How about this patch?

From: John W. Linville <linville@tuxdriver.com>

[PATCH] b44: make B44_PCI select SSB_PCIHOST in drivers/net/Kconfig

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 6a4325b..b2e1deb 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1402,6 +1402,7 @@ config B44
 config B44_PCI
 	bool "Broadcom 4400 PCI device support"
 	depends on B44 && NET_PCI
+	select SSB_PCIHOST
 	default y
 	help
 	  Support for b44 PCI devices.
-- 
John W. Linville
linville@tuxdriver.com
