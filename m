From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH] net: smc91x: fix neponset breakage by pxa u16 writes
Date: Wed, 19 Oct 2016 23:23:50 +0200
Message-ID: <1476912230-18175-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Robert Jarzmik <robert.jarzmik@free.fr>
To: Nicolas Pitre <nico@fluxnic.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch isolating the u16 writes for pxa assumed all machine_is_*()
calls were removed, and therefore removed the mach-types.h include which
provided them.

Unfortunately 2 machine_is_*() remained in smc91x.c file including
smc91x.h from which the include was removed, triggering the error:
 drivers/net/ethernet/smsc/smc91x.c: In function ‘smc_drv_probe’:
 drivers/net/ethernet/smsc/smc91x.c:2380:2: error: implicit declaration
 of function ‘machine_is_assabet’
 [-Werror=implicit-function-declaration]
	if (machine_is_assabet() && machine_has_neponset())

This adds back the wrongly removed include.

Fixes: d09d747ae4c2 ("net: smc91x: isolate u16 writes alignment workaround")
Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
---
 drivers/net/ethernet/smsc/smc91x.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 45e6b81a6a92..08b17adf0a65 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -63,6 +63,8 @@
 
 #if defined(CONFIG_ARM)
 
+#include <asm/mach-types.h>
+
 /* Now the bus width is specified in the platform data
  * pretend here to support all I/O access types
  */
-- 
2.1.4
