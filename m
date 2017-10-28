From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] lan78xx: Use common error handling code in lan78xx_phy_init()
Date: Sat, 28 Oct 2017 22:56:31 +0200
Message-ID: <1aa46505-686c-8e92-78a8-b2a562ccbb9d@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        UNGLinuxDriver@microchip.com,
        Woojung Huh <woojung.huh@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 28 Oct 2017 22:42:52 +0200

* Add a jump target so that a specific error message is stored only once
  at the end of this function implementation.

* Replace two calls of the function "netdev_err" by goto statements.

* Adjust two condition checks.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/usb/lan78xx.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 0161f77641fa..ff07e20621e3 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -2030,17 +2030,15 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 		/* external PHY fixup for KSZ9031RNX */
 		ret = phy_register_fixup_for_uid(PHY_KSZ9031RNX, 0xfffffff0,
 						 ksz9031rnx_fixup);
-		if (ret < 0) {
-			netdev_err(dev->net, "fail to register fixup\n");
-			return ret;
-		}
+		if (ret)
+			goto report_fixup_failure;
+
 		/* external PHY fixup for LAN8835 */
 		ret = phy_register_fixup_for_uid(PHY_LAN8835, 0xfffffff0,
 						 lan8835_fixup);
-		if (ret < 0) {
-			netdev_err(dev->net, "fail to register fixup\n");
-			return ret;
-		}
+		if (ret)
+			goto report_fixup_failure;
+
 		/* add more external PHY fixup here if needed */
 
 		phydev->is_internal = false;
@@ -2093,6 +2091,10 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
 	phy_unregister_fixup_for_uid(PHY_LAN8835, 0xfffffff0);
 
 	return ret;
+
+report_fixup_failure:
+	netdev_err(dev->net, "fail to register fixup\n");
+	return ret;
 }
 
 static int lan78xx_set_rx_max_frame_length(struct lan78xx_net *dev, int size)
-- 
2.14.3
