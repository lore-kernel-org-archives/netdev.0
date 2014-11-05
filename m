From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 1/3] dsa: mv88e6171: Add support for mv88e6172
Date: Wed,  5 Nov 2014 20:01:59 +0100
Message-ID: <1415214121-29286-2-git-send-email-andrew@lunn.ch>
References: <1415214121-29286-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org,
	linux ARM <linux-arm-kernel@lists.infradead.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	tawfik@marvell.com, maxime.ripard@free-electrons.com,
	Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49056 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750860AbaKETDf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 14:03:35 -0500
In-Reply-To: <1415214121-29286-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6172 is very similar to the mv88e6171.  So extend the
mv88e6171 driver to support it.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/Kconfig     | 6 +++---
 drivers/net/dsa/mv88e6171.c | 5 ++++-
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 9234d808cbb3..69bed5b2f078 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -37,13 +37,13 @@ config NET_DSA_MV88E6123_61_65
 	  ethernet switch chips.
 
 config NET_DSA_MV88E6171
-	tristate "Marvell 88E6171 ethernet switch chip support"
+	tristate "Marvell 88E6171/6172 ethernet switch chip support"
 	select NET_DSA
 	select NET_DSA_MV88E6XXX
 	select NET_DSA_TAG_EDSA
 	---help---
-	  This enables support for the Marvell 88E6171 ethernet switch
-	  chip.
+	  This enables support for the Marvell 88E6171/6172 ethernet switch
+	  chips.
 
 config NET_DSA_BCM_SF2
 	tristate "Broadcom Starfighter 2 Ethernet switch support"
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 1020a7af67cf..d9919ce2b005 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -1,4 +1,4 @@
-/* net/dsa/mv88e6171.c - Marvell 88e6171 switch chip support
+/* net/dsa/mv88e6171.c - Marvell 88e6171/8826172 switch chip support
  * Copyright (c) 2008-2009 Marvell Semiconductor
  * Copyright (c) 2014 Claudio Leite <leitec@staticky.com>
  *
@@ -29,6 +29,8 @@ static char *mv88e6171_probe(struct device *host_dev, int sw_addr)
 	if (ret >= 0) {
 		if ((ret & 0xfff0) == 0x1710)
 			return "Marvell 88E6171";
+		if ((ret & 0xfff0) == 0x1720)
+			return "Marvell 88E6172";
 	}
 
 	return NULL;
@@ -409,3 +411,4 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 };
 
 MODULE_ALIAS("platform:mv88e6171");
+MODULE_ALIAS("platform:mv88e6172");
-- 
2.1.3
