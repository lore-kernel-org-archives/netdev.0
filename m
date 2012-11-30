From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 4/5] smsc95xx: fix smsc_crc return type
Date: Fri, 30 Nov 2012 15:55:51 +0000
Message-ID: <1354290952-27109-5-git-send-email-steve.glendinning@shawell.net>
References: <1354290952-27109-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	Joe Perches <joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:47841 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030986Ab2K3P4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 10:56:02 -0500
In-Reply-To: <1354290952-27109-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug introduced in bbd9f9e which could prevent
some wakeups from working correctly if multiple wol options were
selected.

This helper function calculates a 16-bit crc and shifts it into
either the high or low 16 bits of a u32 so the caller can or it
directly into place.  The function previously had a u16 return
type so would always have returned zero when filter was odd.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
Reported-by: Bjorn Mork <bjorn@mork.no>
Cc: Joe Perches <joe@perches.com>
---
 drivers/net/usb/smsc95xx.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 064df1a..b9eb490 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1074,9 +1074,10 @@ static void smsc95xx_unbind(struct usbnet *dev, struct usb_interface *intf)
 	}
 }
 
-static u16 smsc_crc(const u8 *buffer, size_t len, int filter)
+static u32 smsc_crc(const u8 *buffer, size_t len, int filter)
 {
-	return bitrev16(crc16(0xFFFF, buffer, len)) << ((filter % 2) * 16);
+	u32 crc = bitrev16(crc16(0xFFFF, buffer, len));
+	return crc << ((filter % 2) * 16);
 }
 
 static int smsc95xx_enable_phy_wakeup_interrupts(struct usbnet *dev, u16 mask)
-- 
1.7.10.4
