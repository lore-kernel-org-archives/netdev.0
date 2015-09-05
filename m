From: Michael Welling <mwelling@ieee.org>
Subject: [PATCH] net: phy: Handle postive return codes in phy_connect
Date: Sat,  5 Sep 2015 13:01:29 -0500
Message-ID: <1441476089-22108-1-git-send-email-mwelling@ieee.org>
Cc: Michael Welling <mwelling@ieee.org>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:34588 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbbIESBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 14:01:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function phy_connect_direct can possibly return a positive
return code. Using ERR_PTR with a positive value can lead to
deferencing of an invalid pointer.

Signed-off-by: Michael Welling <mwelling@ieee.org>
---
 drivers/net/phy/phy_device.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index c0f2111..a7e14a6 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -477,6 +477,9 @@ struct phy_device *phy_connect(struct net_device *dev, const char *bus_id,
 	phydev = to_phy_device(d);
 
 	rc = phy_connect_direct(dev, phydev, handler, interface);
+	if (rc > 0)
+		return ERR_PTR(-ENODEV);
+
 	if (rc)
 		return ERR_PTR(rc);
 
-- 
2.1.4
