From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 05/10] net: dsa: mv88e6171: Add other members of the family
Date: Wed,  6 May 2015 01:09:51 +0200
Message-ID: <1430867396-2268-6-git-send-email-andrew@lunn.ch>
References: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44541 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754270AbbEEXPw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 19:15:52 -0400
In-Reply-To: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 6171 is one member of the family 6171/6175/6350/6351. Add the
other family members to the driver.

Not tested on these new devices.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/Kconfig     | 6 +++---
 drivers/net/dsa/mv88e6171.c | 9 +++++++++
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index d96f2e24e6a9..7ad0a4d8e475 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -37,13 +37,13 @@ config NET_DSA_MV88E6123_61_65
 	  ethernet switch chips.
 
 config NET_DSA_MV88E6171
-	tristate "Marvell 88E6171 ethernet switch chip support"
+	tristate "Marvell 88E6171/6175/6350/6351 ethernet switch chip support"
 	depends on NET_DSA
 	select NET_DSA_MV88E6XXX
 	select NET_DSA_TAG_EDSA
 	---help---
-	  This enables support for the Marvell 88E6171 ethernet switch
-	  chips.
+	  This enables support for the Marvell 88E6171/6175/6350/6351
+	  ethernet switches chips.
 
 config NET_DSA_MV88E6352
 	tristate "Marvell 88E6172/88E6176/88E6352 ethernet switch chip support"
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 132783cc8aea..1c7808495a9d 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -29,6 +29,12 @@ static char *mv88e6171_probe(struct device *host_dev, int sw_addr)
 	if (ret >= 0) {
 		if ((ret & 0xfff0) == PORT_SWITCH_ID_6171)
 			return "Marvell 88E6171";
+		if ((ret & 0xfff0) == PORT_SWITCH_ID_6175)
+			return "Marvell 88E6175";
+		if ((ret & 0xfff0) == PORT_SWITCH_ID_6350)
+			return "Marvell 88E6350";
+		if ((ret & 0xfff0) == PORT_SWITCH_ID_6351)
+			return "Marvell 88E6351";
 	}
 
 	return NULL;
@@ -116,3 +122,6 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 };
 
 MODULE_ALIAS("platform:mv88e6171");
+MODULE_ALIAS("platform:mv88e6175");
+MODULE_ALIAS("platform:mv88e6350");
+MODULE_ALIAS("platform:mv88e6351");
-- 
2.1.4
