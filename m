From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc95xx: remove EEPROM loaded check
Date: Tue, 28 Jul 2009 13:37:58 +0100
Message-ID: <1248784678-31726-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:39250 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753233AbZG1Mpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 08:45:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The eeprom read & write commands currently check the E2P_CMD_LOADED_ bit is
set before allowing any operations.  This prevents any reading or writing
unless a correctly programmed EEPROM is installed.

This patch removes the check, so it is possible to program blank EEPROMS
via ethtool.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index fe04589..09bd635 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -220,11 +220,6 @@ static int smsc95xx_eeprom_confirm_not_busy(struct usbnet *dev)
 	do {
 		smsc95xx_read_reg(dev, E2P_CMD, &val);
 
-		if (!(val & E2P_CMD_LOADED_)) {
-			devwarn(dev, "No EEPROM present");
-			return -EIO;
-		}
-
 		if (!(val & E2P_CMD_BUSY_))
 			return 0;
 
-- 
1.6.2.5

