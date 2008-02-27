From: Adrian Bunk <adrian.bunk@movial.fi>
Subject: [2.6.25 patch] FIXED_PHY must depend on PHYLIB=y
Date: Wed, 27 Feb 2008 17:07:54 +0200
Message-ID: <20080227150754.GA29269@cs181133002.pp.htv.fi>
References: <200802271158.00453.olaf@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Olaf Hering <olaf@aepfle.de>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Vitaly Bordug <vitb@kernel.crashing.org>,
	Jeff Garzik <jeff@garzik.org>,
	Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:39099 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754845AbYB0PJF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 10:09:05 -0500
Content-Disposition: inline
In-Reply-To: <200802271158.00453.olaf@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following build error introduced by commit 
a79d8e93d300adb84cccc38ac396cfb118c238ad and reported by Olaf Hering:

<--  snip  -->

...
  LD      .tmp_vmlinux1
arch/powerpc/sysdev/built-in.o: In function `of_add_fixed_phys':
fsl_soc.c:(.init.text+0xd34): undefined reference to `fixed_phy_add'
make: *** [.tmp_vmlinux1] Error 1

<--   snip  -->

Signed-off-by: Adrian Bunk <adrian.bunk@movial.fi>

---
47a94f1d74e448d39f34f0ad37f8b4f69412ee13 diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index f4ca059..3ac8529 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -67,6 +67,7 @@ config REALTEK_PHY
 
 config FIXED_PHY
 	bool "Driver for MDIO Bus/PHY emulation with fixed speed/link PHYs"
+	depends on PHYLIB=y
 	---help---
 	  Adds the platform "fixed" MDIO Bus to cover the boards that use
 	  PHYs that are not connected to the real MDIO bus.

