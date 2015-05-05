From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 06/10] net: dsa: mv88e6131: Add support for mv88e6185
Date: Wed,  6 May 2015 01:09:52 +0200
Message-ID: <1430867396-2268-7-git-send-email-andrew@lunn.ch>
References: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44547 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753877AbbEEXQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 19:16:00 -0400
In-Reply-To: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6185 is part of the family that the mv88e6131 driver
supports. Add it to the probe function, and set the number of ports.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6131.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 765de63f59bd..32f4a08e9bc9 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -37,6 +37,8 @@ static char *mv88e6131_probe(struct device *host_dev, int sw_addr)
 			return "Marvell 88E6131 (B2)";
 		if (ret_masked == PORT_SWITCH_ID_6131)
 			return "Marvell 88E6131";
+		if (ret_masked == PORT_SWITCH_ID_6185)
+			return "Marvell 88E6185";
 	}
 
 	return NULL;
@@ -110,6 +112,7 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 
 	switch (ps->id) {
 	case PORT_SWITCH_ID_6085:
+	case PORT_SWITCH_ID_6185:
 		ps->num_ports = 10;
 		break;
 	case PORT_SWITCH_ID_6095:
-- 
2.1.4
