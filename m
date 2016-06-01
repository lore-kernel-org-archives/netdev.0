From: William Breathitt Gray <vilhelm.gray@gmail.com>
Subject: [PATCH] can: tscan1: Utilize the module_isa_driver macro
Date: Wed, 1 Jun 2016 08:59:51 -0400
Message-ID: <20160601125951.GA31041@sophia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: wg@grandegger.com, mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver does not do anything special in module init/exit. This patch
eliminates the module init/exit boilerplate code by utilizing the
module_isa_driver macro.

Signed-off-by: William Breathitt Gray <vilhelm.gray@gmail.com>
---
 drivers/net/can/sja1000/tscan1.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/net/can/sja1000/tscan1.c b/drivers/net/can/sja1000/tscan1.c
index 76513dd..7957245 100644
--- a/drivers/net/can/sja1000/tscan1.c
+++ b/drivers/net/can/sja1000/tscan1.c
@@ -203,14 +203,4 @@ static struct isa_driver tscan1_isa_driver = {
 	},
 };
 
-static int __init tscan1_init(void)
-{
-	return isa_register_driver(&tscan1_isa_driver, TSCAN1_MAXDEV);
-}
-module_init(tscan1_init);
-
-static void __exit tscan1_exit(void)
-{
-	isa_unregister_driver(&tscan1_isa_driver);
-}
-module_exit(tscan1_exit);
+module_isa_driver(tscan1_isa_driver, TSCAN1_MAXDEV);
-- 
2.7.3

