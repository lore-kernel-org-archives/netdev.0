From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] net/macb: add proper header file
Date: Thu, 17 Dec 2015 17:45:53 +0530
Message-ID: <1450354553-18745-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

mips allmodconfig build fails with the error:

drivers/net/ethernet/cadence/macb.c: In function 'macb_probe':
drivers/net/ethernet/cadence/macb.c:2908:2: error: implicit declaration of function 'devm_gpiod_get_optional' [-Werror=implicit-function-declaration]
  bp->reset_gpio = devm_gpiod_get_optional(&bp->pdev->dev, "phy-reset",
  ^
drivers/net/ethernet/cadence/macb.c:2909:8: error: 'GPIOD_OUT_HIGH' undeclared (first use in this function)
        GPIOD_OUT_HIGH);
        ^
drivers/net/ethernet/cadence/macb.c:2909:8: note: each undeclared identifier is reported only once for each function it appears in
drivers/net/ethernet/cadence/macb.c: In function 'macb_remove':
drivers/net/ethernet/cadence/macb.c:2979:3: error: implicit declaration of function 'gpiod_set_value' [-Werror=implicit-function-declaration]
   gpiod_set_value(bp->reset_gpio, 0);
   ^

Add the proper header file to resolve it.  

Fixes: 5833e0526820 ("net/macb: add support for resetting PHY using GPIO")
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---

build log with next-20151217 is at:
https://travis-ci.org/sudipm-mukherjee/parport/jobs/97388463

 drivers/net/ethernet/cadence/macb.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 0123646..988ee14 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -19,6 +19,7 @@
 #include <linux/init.h>
 #include <linux/io.h>
 #include <linux/gpio.h>
+#include <linux/gpio/consumer.h>
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-- 
1.9.1
