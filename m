From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dm9601: fix phy/eeprom write routine
Date: Mon,  3 May 2010 22:01:26 +0200
Message-ID: <1272916886-8841-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>, stable@kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org, michael.planes@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:33597 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756410Ab0ECUBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 16:01:39 -0400
Received: by ey-out-2122.google.com with SMTP id d26so170210eyd.19
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 13:01:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use correct bit positions in DM_SHARED_CTRL register for writes.

Michael Planes recently encountered a 'KY-RS9600 USB-LAN converter', which
came with a driver CD containing a Linux driver. This driver turns out to
be a copy of dm9601.c with symbols renamed and my copyright stripped.
That aside, it did contain 1 functional change in dm_write_shared_word(),
and after checking the datasheet the original value was indeed wrong
(read versus write bits).

On Michaels HW, this change bumps receive speed from ~30KB/s to ~900KB/s.
On other devices the difference is less spectacular, but still significant
(~30%).

Reported-by: Michael Planes <michael.planes@free.fr>
CC: stable@kernel.org
Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/dm9601.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 04b2810..5dfed92 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -240,7 +240,7 @@ static int dm_write_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 valu
 		goto out;
 
 	dm_write_reg(dev, DM_SHARED_ADDR, phy ? (reg | 0x40) : reg);
-	dm_write_reg(dev, DM_SHARED_CTRL, phy ? 0x1c : 0x14);
+	dm_write_reg(dev, DM_SHARED_CTRL, phy ? 0x1a : 0x12);
 
 	for (i = 0; i < DM_TIMEOUT; i++) {
 		u8 tmp;
-- 
1.7.0

