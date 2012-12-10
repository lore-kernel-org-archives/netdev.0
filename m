From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 1/2] smsc95xx: fix register dump of last register
Date: Mon, 10 Dec 2012 11:03:07 +0000
Message-ID: <1355137388-2938-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:48304 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754421Ab2LJLDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 06:03:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the ethtool register dump for smsc95xx to dump
all 4 bytes of the final register (COE_CR) instead of just the
first byte.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index f7e1e18..a00dcc4 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -691,7 +691,7 @@ static int smsc95xx_ethtool_set_eeprom(struct net_device *netdev,
 static int smsc95xx_ethtool_getregslen(struct net_device *netdev)
 {
 	/* all smsc95xx registers */
-	return COE_CR - ID_REV + 1;
+	return COE_CR - ID_REV + sizeof(u32);
 }
 
 static void
-- 
1.7.10.4
