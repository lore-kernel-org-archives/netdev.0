From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH] net/ieee802154/mrf24j40: Use module_spi_driver to register driver
Date: Mon, 20 May 2013 21:54:46 +0200
Message-ID: <1369079686-6160-1-git-send-email-peterhuewe@gmx.de>
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Peter Huewe <peterhuewe@gmx.de>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing some boilerplate by using module_spi_driver instead of calling
register and unregister in the otherwise empty init/exit functions

Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
---
 drivers/net/ieee802154/mrf24j40.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 3f2c7aa..4dcae02 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -749,19 +749,7 @@ static struct spi_driver mrf24j40_driver = {
 	.remove = mrf24j40_remove,
 };
 
-static int __init mrf24j40_init(void)
-{
-	return spi_register_driver(&mrf24j40_driver);
-}
-
-static void __exit mrf24j40_exit(void)
-{
-	spi_unregister_driver(&mrf24j40_driver);
-}
-
-module_init(mrf24j40_init);
-module_exit(mrf24j40_exit);
-
+module_spi_driver(mrf24j40_driver);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Alan Ott");
 MODULE_DESCRIPTION("MRF24J40 SPI 802.15.4 Controller Driver");
-- 
1.8.1.5
