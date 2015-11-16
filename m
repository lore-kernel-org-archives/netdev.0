From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] net: phy: Use interrupts when available in NOLINK state
Date: Mon, 16 Nov 2015 23:36:46 +0100
Message-ID: <1447713406-26137-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34756 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424AbbKPWgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2015 17:36:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NOLINK state will poll the phy once a second to see if the link
has come up. If the phy has an interrupt line, this polling can be
skipped, since the phy should interrupt when the link returns.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/phy.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index adb48abafc87..48ce6ef400fe 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -863,6 +863,9 @@ void phy_state_machine(struct work_struct *work)
 			needs_aneg = true;
 		break;
 	case PHY_NOLINK:
+		if (phy_interrupt_is_valid(phydev))
+			break;
+
 		err = phy_read_status(phydev);
 		if (err)
 			break;
-- 
2.6.2
