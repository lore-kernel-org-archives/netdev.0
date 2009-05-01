From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc95xx: configure LED outputs
Date: Fri,  1 May 2009 16:46:51 +0100
Message-ID: <1241192811-6429-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>, vlad.lyalikov@smsc.com,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:47934 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756312AbZEAPqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 11:46:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SMSC LAN9500 has dual purpose GPIO/LED pins, and by default at power-on
these are configured as GPIOs.  This means that if LEDs are fitted they
won't ever light.

This patch sets them to be LED outputs for speed, duplex and
link/activity.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |   10 ++++++++++
 drivers/net/usb/smsc95xx.h |    3 +++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index dc16653..0fd68a5 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -941,6 +941,16 @@ static int smsc95xx_reset(struct usbnet *dev)
 	if (netif_msg_ifup(dev))
 		devdbg(dev, "ID_REV = 0x%08x", read_buf);
 
+	/* Configure GPIO pins as LED outputs */
+	write_buf = LED_GPIO_CFG_SPD_LED | LED_GPIO_CFG_LNK_LED |
+		LED_GPIO_CFG_FDX_LED;
+	ret = smsc95xx_write_reg(dev, LED_GPIO_CFG, write_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to write LED_GPIO_CFG register, ret=%d",
+			ret);
+		return ret;
+	}
+
 	/* Init Tx */
 	write_buf = 0;
 	ret = smsc95xx_write_reg(dev, FLOW, write_buf);
diff --git a/drivers/net/usb/smsc95xx.h b/drivers/net/usb/smsc95xx.h
index 66b5c84..86bc449 100644
--- a/drivers/net/usb/smsc95xx.h
+++ b/drivers/net/usb/smsc95xx.h
@@ -99,6 +99,9 @@
 #define PM_CTL_WUPS_MULTI_		(0x00000003)
 
 #define LED_GPIO_CFG			(0x24)
+#define LED_GPIO_CFG_SPD_LED		(0x01000000)
+#define LED_GPIO_CFG_LNK_LED		(0x00100000)
+#define LED_GPIO_CFG_FDX_LED		(0x00010000)
 
 #define GPIO_CFG			(0x28)
 
-- 
1.6.0.6

