From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] sr9800: Use common error handling code in
 sr9800_phy_powerup()
Date: Sun, 29 Oct 2017 11:45:40 +0100
Message-ID: <10f2b5a4-1dbd-2c4f-caaa-4225dff35296@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>,
        "David S. Miller" <davem@davemloft.net>,
        Greg Ungerer <gerg@linux-m68k.org>,
        Liu Junliang <liujunliang_ljl@163.com>,
        Philippe Reynes <tremyfr@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Language: en-GB
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 29 Oct 2017 11:33:14 +0100

Add a jump target so that a specific error message is stored only once
at the end of this function implementation.
Replace two calls of the function "netdev_err" by goto statements.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/usb/sr9800.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/usb/sr9800.c b/drivers/net/usb/sr9800.c
index 9277a0f228df..79cfa72c68ba 100644
--- a/drivers/net/usb/sr9800.c
+++ b/drivers/net/usb/sr9800.c
@@ -700,10 +700,9 @@ static int sr9800_phy_powerup(struct usbnet *dev)
 
 	/* set the embedded Ethernet PHY in power-up state */
 	ret = sr_sw_reset(dev, SR_SWRESET_IPRL);
-	if (ret < 0) {
-		netdev_err(dev->net, "Failed to reset PHY: %d\n", ret);
-		return ret;
-	}
+	if (ret < 0)
+		goto report_reset_failure;
+
 	msleep(600);
 
 	/* set the embedded Ethernet PHY in reset state */
@@ -716,12 +715,14 @@ static int sr9800_phy_powerup(struct usbnet *dev)
 
 	/* set the embedded Ethernet PHY in power-up state */
 	ret = sr_sw_reset(dev, SR_SWRESET_IPRL);
-	if (ret < 0) {
-		netdev_err(dev->net, "Failed to reset PHY: %d\n", ret);
-		return ret;
-	}
+	if (ret < 0)
+		goto report_reset_failure;
 
 	return 0;
+
+report_reset_failure:
+	netdev_err(dev->net, "Failed to reset PHY: %d\n", ret);
+	return ret;
 }
 
 static int sr9800_bind(struct usbnet *dev, struct usb_interface *intf)
-- 
2.14.3

