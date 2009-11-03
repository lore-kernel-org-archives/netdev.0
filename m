From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 09/20] tg3: 5785: Set port mode to MII when link down
Date: Mon, 2 Nov 2009 16:27:02 -0800
Message-ID: <1257211999.22007@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1378 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757598AbZKCBd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 20:33:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch sets the port mode to MII when the link is down for the 5785.
Setting the port mode to MII instead of GMII saves power.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 003ab53..d726da8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1363,8 +1363,11 @@ static void tg3_adjust_link(struct net_device *dev)
 
 		if (phydev->speed == SPEED_100 || phydev->speed == SPEED_10)
 			mac_mode |= MAC_MODE_PORT_MODE_MII;
-		else
+		else if (phydev->speed == SPEED_1000 ||
+			 GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785)
 			mac_mode |= MAC_MODE_PORT_MODE_GMII;
+		else
+			mac_mode |= MAC_MODE_PORT_MODE_MII;
 
 		if (phydev->duplex == DUPLEX_HALF)
 			mac_mode |= MAC_MODE_HALF_DUPLEX;
-- 
1.6.4.4


