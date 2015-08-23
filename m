From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 3/9] phy: fixed_phy: Set supported speed in phydev
Date: Sun, 23 Aug 2015 11:46:54 +0200
Message-ID: <1440323220-20438-4-git-send-email-andrew@lunn.ch>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38085 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751971AbbHWJzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2015 05:55:09 -0400
In-Reply-To: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the supported field of the phydev to indicate the speed features
of the phy. If the phy is never attached to a netdev, but used in an
adjust_link() function, the speed will be incorrectly evaluated to
10/half rather than the correct speed/duplex.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/fixed_phy.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index 1a400ef92d65..7244336dee7a 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -296,6 +296,18 @@ struct phy_device *fixed_phy_register(unsigned int irq,
 	phy->dev.of_node = np;
 	phy->is_pseudo_fixed_link = true;
 
+	switch (status->speed) {
+	case SPEED_1000:
+		phy->supported = PHY_1000BT_FEATURES;
+		break;
+	case SPEED_100:
+		phy->supported = PHY_100BT_FEATURES;
+		break;
+	case SPEED_10:
+	default:
+		phy->supported = PHY_10BT_FEATURES;
+	}
+
 	ret = phy_device_register(phy);
 	if (ret) {
 		phy_device_free(phy);
-- 
2.5.0
