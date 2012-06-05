From: Josh Boyer <jwboyer@redhat.com>
Subject: [PATCH] netdev: mv643xx_eth: Prevent build on PPC32
Date: Tue, 5 Jun 2012 15:28:21 -0400
Message-ID: <20120605192820.GC7683@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, Olof Johansson <olof@lixom.net>,
	netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47329 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750887Ab2FET3K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 15:29:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 452503ebc (ARM: Orion: Eth: Add clk/clkdev support.) added use of
the clk driver API which results in compile errors on architectures that
don't implement the clk API.

ERROR: "clk_enable" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
ERROR: "clk_disable" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
ERROR: "clk_put" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
ERROR: "clk_get_rate" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
ERROR: "clk_get" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!

Selecting CLKDEV_LOOKUP doesn't fix this either, as the build then fails with:

In file included from drivers/clk/clkdev.c:21:0:
include/linux/clkdev.h:15:24: fatal error: asm/clkdev.h: No such file or directory

So we just prevent this from building at all on PPC32.

Signed-off-by: Josh Boyer <jwboyer@redhat.com>
---
 drivers/net/ethernet/marvell/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index 0029934..628f5b1 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -20,7 +20,7 @@ if NET_VENDOR_MARVELL
 
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
-	depends on (MV64X60 || PPC32 || PLAT_ORION) && INET
+	depends on (MV64X60 || PLAT_ORION) && INET
 	select INET_LRO
 	select PHYLIB
 	---help---
-- 
1.7.10.2
