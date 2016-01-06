From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 01/22] phy: Consistently use addr for address on an MII bus
Date: Wed,  6 Jan 2016 20:11:06 +0100
Message-ID: <1452107487-475-2-git-send-email-andrew@lunn.ch>
References: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42378 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752055AbcAFTNs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 14:13:48 -0500
In-Reply-To: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Within phy.h, an address on an MII bus has been called both addr and
phy_id. phy_id is particularly confusion, since it also means the ID
found in register 3, if the device on the bus is a phy. Consistently
use addr.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/phy.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index a89cb0eef911..77b5e56e2a92 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -158,8 +158,8 @@ struct mii_bus {
 	const char *name;
 	char id[MII_BUS_ID_SIZE];
 	void *priv;
-	int (*read)(struct mii_bus *bus, int phy_id, int regnum);
-	int (*write)(struct mii_bus *bus, int phy_id, int regnum, u16 val);
+	int (*read)(struct mii_bus *bus, int addr, int regnum);
+	int (*write)(struct mii_bus *bus, int addr, int regnum, u16 val);
 	int (*reset)(struct mii_bus *bus);
 
 	/*
-- 
2.6.4
