From: Simon Que <sque@chromium.org>
Subject: [PATCH] net: usb: initialize tmp in dm9601.c to avoid warning
Date: Thu, 17 Jan 2013 11:29:49 -0800
Message-ID: <1358450989-25205-1-git-send-email-sque@chromium.org>
Cc: msb@chromium.org, Simon Que <sque@chromium.org>
To: jacmet@sunsite.dk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:58912 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641Ab3AQTg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 14:36:56 -0500
Received: by mail-ie0-f202.google.com with SMTP id s9so763414iec.1
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 11:36:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In two places, tmp is initialized implicitly by being passed as a
pointer during a function call.  However, this is not obvious to the
compiler, which logs a warning.

Signed-off-by: Simon Que <sque@chromium.org>
---
 drivers/net/usb/dm9601.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index e0433ce..94e716d 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -199,7 +199,7 @@ static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 *valu
 	dm_write_reg(dev, DM_SHARED_CTRL, phy ? 0xc : 0x4);
 
 	for (i = 0; i < DM_TIMEOUT; i++) {
-		u8 tmp;
+		u8 tmp = 0;
 
 		udelay(1);
 		ret = dm_read_reg(dev, DM_SHARED_CTRL, &tmp);
@@ -242,7 +242,7 @@ static int dm_write_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 valu
 	dm_write_reg(dev, DM_SHARED_CTRL, phy ? 0x1a : 0x12);
 
 	for (i = 0; i < DM_TIMEOUT; i++) {
-		u8 tmp;
+		u8 tmp = 0;
 
 		udelay(1);
 		ret = dm_read_reg(dev, DM_SHARED_CTRL, &tmp);
-- 
1.7.8.6
