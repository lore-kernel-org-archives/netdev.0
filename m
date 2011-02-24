From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: [PATCH] DM9000: Allow randomised ethernet address
Date: Thu, 24 Feb 2011 13:17:12 +0000
Message-ID: <1298553432-30240-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Cc: netdev@vger.kernel.org, patches@opensource.wolfsonmicro.com,
	Ben Dooks <ben-linux@fluff.org>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:56196 "EHLO
	opensource2.wolfsonmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751742Ab1BXNQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 08:16:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Dooks <ben-linux@fluff.org>

Allow randomised ethernet address if the device does not have a valid
EEPROM or pre-set MAC address.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>
Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
---
 drivers/net/dm9000.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 461dd6f..3177081 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -1593,10 +1593,15 @@ dm9000_probe(struct platform_device *pdev)
 			ndev->dev_addr[i] = ior(db, i+DM9000_PAR);
 	}
 
-	if (!is_valid_ether_addr(ndev->dev_addr))
+	if (!is_valid_ether_addr(ndev->dev_addr)) {
 		dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please "
 			 "set using ifconfig\n", ndev->name);
 
+		random_ether_addr(ndev->dev_addr);
+		mac_src = "random";
+	}
+
+
 	platform_set_drvdata(pdev, ndev);
 	ret = register_netdev(ndev);
 
-- 
1.7.2.3

