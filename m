From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH] net: dsa: mv88e6xxx: Respect SPEED_UNFORCED, don't set force bit
Date: Wed, 16 Nov 2016 04:26:48 +0100
Message-ID: <1479266808-10957-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41350 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752020AbcKPD1H (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 22:27:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SPEED_UNFORCED indicates the MAC & PHY should perform
auto-negotiation to determine a speed which works. If this is called
for, don't set the force bit. If it is set, the MAC actually does
10Gbps, why the internal PHYs don't support.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/port.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index e4978f6367aa..af4772d86086 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -213,7 +213,7 @@ static int mv88e6xxx_port_set_speed(struct mv88e6xxx_chip *chip, int port,
 		reg &= ~PORT_PCS_CTRL_ALTSPEED;
 	if (force_bit) {
 		reg &= ~PORT_PCS_CTRL_FORCE_SPEED;
-		if (speed)
+		if (speed != SPEED_UNFORCED)
 			ctrl |= PORT_PCS_CTRL_FORCE_SPEED;
 	}
 	reg |= ctrl;
-- 
2.10.2
