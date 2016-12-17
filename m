From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] net: mv643xx_eth: fix build failure
Date: Sat, 17 Dec 2016 00:45:05 +0000
Message-ID: <1481935505-24475-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The build of sparc allmodconfig fails with the error:
"of_irq_to_resource" [drivers/net/ethernet/marvell/mv643xx_eth.ko]
	undefined!

of_irq_to_resource() is defined when CONFIG_OF_IRQ is defined. And also
CONFIG_OF_IRQ can only be defined if CONFIG_IRQ is defined. So we can
safely use #if defined(CONFIG_OF_IRQ) in the code.

Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
---

build log of next-20161216 is at:
https://travis-ci.org/sudipm-mukherjee/parport/jobs/184652820

 drivers/net/ethernet/marvell/mv643xx_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 5f62c3d..1fa7c03 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2713,7 +2713,7 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
 MODULE_DEVICE_TABLE(of, mv643xx_eth_shared_ids);
 #endif
 
-#if defined(CONFIG_OF) && !defined(CONFIG_MV64X60)
+#if defined(CONFIG_OF_IRQ) && !defined(CONFIG_MV64X60)
 #define mv643xx_eth_property(_np, _name, _v)				\
 	do {								\
 		u32 tmp;						\
-- 
1.9.1
