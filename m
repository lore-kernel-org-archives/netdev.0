From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 3/3] dsa: mv88e6xxx: Set DSA mode based on chip abilities
Date: Mon, 17 Aug 2015 23:52:52 +0200
Message-ID: <1439848372-4055-4-git-send-email-andrew@lunn.ch>
References: <1439848372-4055-1-git-send-email-andrew@lunn.ch>
Cc: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60902 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751387AbbHQWAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 18:00:45 -0400
In-Reply-To: <1439848372-4055-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Older devices only support a single DSA frame format, where as newer
devices have two. Take this into account when configuring a DSA port.
The port needs to be in plain old DSA mode, since this is a DSA link,
where as the newer format can be used for the CPU port.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 486e9792fc05..2ab3f9810593 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1987,12 +1987,15 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 				reg |= PORT_CONTROL_EGRESS_ADD_TAG;
 		}
 	}
-	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
-	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
-	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6065_family(ds) ||
-	    mv88e6xxx_6320_family(ds)) {
-		if (dsa_is_dsa_port(ds, port))
+	if (dsa_is_dsa_port(ds, port)) {
+		if (mv88e6xxx_6095_family(ds) || mv88e6xxx_6185_family(ds))
+			reg |= PORT_CONTROL_DSA_TAG;
+		if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
+		    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
+		    mv88e6xxx_6320_family(ds)) {
 			reg |= PORT_CONTROL_FRAME_MODE_DSA;
+		}
+
 		if (port == dsa_upstream_port(ds))
 			reg |= PORT_CONTROL_FORWARD_UNKNOWN |
 				PORT_CONTROL_FORWARD_UNKNOWN_MC;
-- 
2.5.0
