From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net v3] net: smc91x: Fix build without gpiolib
Date: Mon, 15 Dec 2014 10:02:27 +0100
Message-ID: <1418634147-13442-1-git-send-email-tklauser@distanz.ch>
Cc: "David S. Miller" <davem@davemloft.net>,
	Tony Lindgren <tony@atomide.com>, netdev@vger.kernel.org
To: Nicolas Pitre <nico@fluxnic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:60615 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211AbaLOJCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2014 04:02:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If GPIOLIB=n the following build errors occur:

drivers/net/ethernet/smsc/smc91x.c: In function 'try_toggle_control_gpio':
drivers/net/ethernet/smsc/smc91x.c:2204:2: error: implicit declaration of function 'devm_gpiod_get_index' [-Werror=implicit-function-declaration]
drivers/net/ethernet/smsc/smc91x.c:2204:7: warning: assignment makes pointer from integer without a cast [enabled by default]
drivers/net/ethernet/smsc/smc91x.c:2213:2: error: implicit declaration of function 'gpiod_direction_output' [-Werror=implicit-function-declaration]
drivers/net/ethernet/smsc/smc91x.c:2216:3: error: implicit declaration of function 'devm_gpiod_put' [-Werror=implicit-function-declaration]
drivers/net/ethernet/smsc/smc91x.c:2222:2: error: implicit declaration of function 'gpiod_set_value_cansleep' [-Werror=implicit-function-declaration]

Fix this by letting the driver depend on GPIOLIB if OF is selected.

Fixes: 7d2911c4381 ("net: smc91x: Fix gpios for device tree based booting")
Cc: Tony Lindgren <tony@atomide.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
v3:
 - Let the driver depend on GPIOLIB if OF is selected instead of including GPIO
   function stubs.

 drivers/net/ethernet/smsc/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
index 6279268..9468e64 100644
--- a/drivers/net/ethernet/smsc/Kconfig
+++ b/drivers/net/ethernet/smsc/Kconfig
@@ -39,7 +39,7 @@ config SMC91X
 	select CRC32
 	select MII
 	depends on (ARM || M32R || SUPERH || MIPS || BLACKFIN || \
-		    MN10300 || COLDFIRE || ARM64 || XTENSA || NIOS2)
+		    MN10300 || COLDFIRE || ARM64 || XTENSA || NIOS2) && (!OF || GPIOLIB)
 	---help---
 	  This is a driver for SMC's 91x series of Ethernet chipsets,
 	  including the SMC91C94 and the SMC91C111. Say Y if you want it
-- 
2.2.0
