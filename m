From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] smsc95xx: Use common error handling code in
 smsc95xx_write_eeprom()
Date: Sun, 29 Oct 2017 11:15:08 +0100
Message-ID: <fa1658cc-4363-f07f-864b-6d87dc2b656c@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        UNGLinuxDriver@microchip.com,
        Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 29 Oct 2017 11:08:34 +0100

Add a jump target so that a specific error message is stored only once
at the end of this function implementation.
Replace two calls of the function "netdev_warn" by goto statements.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/usb/smsc95xx.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 309b88acd3d0..6a82e8055e9d 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -399,10 +399,8 @@ static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 	/* Issue write/erase enable command */
 	val = E2P_CMD_BUSY_ | E2P_CMD_EWEN_;
 	ret = smsc95xx_write_reg(dev, E2P_CMD, val);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Error writing E2P_DATA\n");
-		return ret;
-	}
+	if (ret < 0)
+		goto report_write_failure;
 
 	ret = smsc95xx_wait_eeprom(dev);
 	if (ret < 0)
@@ -413,10 +411,8 @@ static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 		/* Fill data register */
 		val = data[i];
 		ret = smsc95xx_write_reg(dev, E2P_DATA, val);
-		if (ret < 0) {
-			netdev_warn(dev->net, "Error writing E2P_DATA\n");
-			return ret;
-		}
+		if (ret < 0)
+			goto report_write_failure;
 
 		/* Send "write" command */
 		val = E2P_CMD_BUSY_ | E2P_CMD_WRITE_ | (offset & E2P_CMD_ADDR_);
@@ -434,6 +430,10 @@ static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
 	}
 
 	return 0;
+
+report_write_failure:
+	netdev_warn(dev->net, "Error writing E2P_DATA\n");
+	return ret;
 }
 
 static int __must_check smsc95xx_write_reg_async(struct usbnet *dev, u16 index,
-- 
2.14.3
