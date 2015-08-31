From: Andrew Lunn <andrew@lunn.ch>
Subject: [Patch v2 RFT net-next 3/9] phy: fixed_phy: Set supported speed in phydev
Date: Mon, 31 Aug 2015 15:56:48 +0200
Message-ID: <1441029414-20062-4-git-send-email-andrew@lunn.ch>
References: <1441029414-20062-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>, Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42611 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752165AbbHaOEs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2015 10:04:48 -0400
In-Reply-To: <1441029414-20062-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the supported field of the phydev to indicate the speed features
of the phy. If the phy is never attached to a netdev, but used in an
adjust_link() function, the speed will be incorrectly evaluated to
10/half rather than the correct speed/duplex.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/fixed_phy.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
index ce46428ff21f..2f9457f05a2e 100644
--- a/drivers/net/phy/fixed_phy.c
+++ b/drivers/net/phy/fixed_phy.c
@@ -305,6 +305,18 @@ struct phy_device *fixed_phy_register(unsigned int irq,
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
