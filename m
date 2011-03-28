From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] netdev: bfin_mac: document TE setting in RMII modes
Date: Mon, 28 Mar 2011 03:17:29 -0400
Message-ID: <1301296649-25603-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:35104 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016Ab1C1IQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2011 04:16:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code sometimes generates build warnings due to how it checks
the silicon revision, so clean it up and properly document things.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 22abfb3..0c68816 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -1237,9 +1237,16 @@ static int bfin_mac_enable(struct phy_device *phydev)
 
 	if (phydev->interface == PHY_INTERFACE_MODE_RMII) {
 		opmode |= RMII; /* For Now only 100MBit are supported */
-#if (defined(CONFIG_BF537) || defined(CONFIG_BF536)) && CONFIG_BF_REV_0_2
-		opmode |= TE;
-#endif
+		if (__SILICON_REVISION__ < 3) {
+			/*
+			 * This isn't publicly documented (fun times!), but in
+			 * silicon <=0.2, the RX and TX pins are clocked together.
+			 * So in order to recv, we must enable the transmit side
+			 * as well.  This will cause a spurious TX interrupt too,
+			 * but we can easily consume that.
+			 */
+			opmode |= TE;
+		}
 	}
 
 	/* Turn on the EMAC rx */
-- 
1.7.4.1

