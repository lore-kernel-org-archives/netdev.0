From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/2] NET: phy_device, fix lock imbalance
Date: Mon, 13 Jul 2009 23:23:39 +0200
Message-ID: <1247520220-31960-1-git-send-email-jirislaby@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Slaby <jirislaby@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server1.wserver.cz ([82.113.45.157]:52905 "EHLO
	server1.wserver.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757462AbZGMVdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 17:33:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't forget to unlock a mutex in phy_scan_fixups on a fail path.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
---
 drivers/net/phy/phy_device.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index eba937c..b10fedd 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -134,8 +134,10 @@ int phy_scan_fixups(struct phy_device *phydev)
 
 			err = fixup->run(phydev);
 
-			if (err < 0)
+			if (err < 0) {
+				mutex_unlock(&phy_fixup_lock);
 				return err;
+			}
 		}
 	}
 	mutex_unlock(&phy_fixup_lock);
-- 
1.6.3.2

