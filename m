From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH] [POWERPC] 85xx: MPC85xx MDS - Unconditionally select PHYLIB
 for board fixups
Date: Fri, 6 Jun 2008 10:40:19 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0806061039390.13744@blarg.am.freescale.net>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net>
 <484419EE.5040503@garzik.org> <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org>
 <20080602165422.GA22051@cs181133002.pp.htv.fi>
 <Pine.LNX.4.64.0806021423380.11043@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Adrian Bunk <adrian.bunk@movial.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40965 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452AbYFFPkg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2008 11:40:36 -0400
In-Reply-To: <Pine.LNX.4.64.0806021423380.11043@blarg.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MPC85xx MDS board requires some board level tweaks of the PHYs that
either the eTSEC (gianfar) or UCC ethernet controllers are connected to.

Its possible to build the phylib as a module, however this breaks the
board level fix ups because phy_read and phy_write are not available
if we build as a module.

So we unconditionally select PHYLIB to ensure its built into the kernel
if we are building in MPC85xx MDS support.  This was determined to be
the easiest soultion even though it prevents the user from removing
PHYLIB support if they decide they don't want it.

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---

will go via the powerpc.git tree for 2.6.26.

- k

 arch/powerpc/platforms/85xx/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/platforms/85xx/Kconfig b/arch/powerpc/platforms/85xx/Kconfig
index 7ff29d5..ecbe580 100644
--- a/arch/powerpc/platforms/85xx/Kconfig
+++ b/arch/powerpc/platforms/85xx/Kconfig
@@ -34,6 +34,7 @@ config MPC85xx_MDS
 	bool "Freescale MPC85xx MDS"
 	select DEFAULT_UIMAGE
 	select QUICC_ENGINE
+	select PHYLIB
 	help
 	  This option enables support for the MPC85xx MDS board

-- 
1.5.5.1

