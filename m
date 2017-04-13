From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 2/2] net: phy: simplify phy_supported_speeds()
Date: Thu, 13 Apr 2017 16:49:20 +0100
Message-ID: <E1cygzo-0002s5-T0@rmk-PC.armlinux.org.uk>
References: <20170406100033.GA24671@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:60516 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752453AbdDMPta (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 11:49:30 -0400
In-Reply-To: <20170406100033.GA24671@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify the loop in phy_supported_speeds().

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 00280d4eeb56..6afbd973a779 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -320,17 +320,11 @@ unsigned int phy_supported_speeds(struct phy_device *phy,
 	unsigned int count = 0;
 	unsigned int idx = 0;
 
-	for (idx = 0; idx < ARRAY_SIZE(settings) && count < size; idx++) {
-		if (!(settings[idx].setting & phy->supported))
-			continue;
-
+	for (idx = 0; idx < ARRAY_SIZE(settings) && count < size; idx++)
 		/* Assumes settings are grouped by speed */
-		if ((count == 0) ||
-		    (speeds[count - 1] != settings[idx].speed)) {
-			speeds[count] = settings[idx].speed;
-			count++;
-		}
-	}
+		if ((settings[idx].setting & phy->supported) &&
+		    (count == 0 || speeds[count - 1] != settings[idx].speed))
+			speeds[count++] = settings[idx].speed;
 
 	return count;
 }
-- 
2.7.4
